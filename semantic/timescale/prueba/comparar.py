#!/usr/bin/env python3
"""comparar.py · ¿Reproducen los .sql de semantic/timescale lo desplegado en obs?

Carga en un PostgreSQL local y desechable dos bases: una con el volcado de
produccion (lo que deja prueba/extraer-esquema-timescale.sh) y otra con los
.sql de este directorio en el orden de ORDEN. Vuelca las dos con pg_dump y las
compara objeto a objeto: tablas, vistas, funciones, indices, comentarios y
permisos.

No necesita TimescaleDB. Lo que solo existe con TimescaleDB (hipertabla,
agregados continuos, politicas) se quita en las DOS bases por igual y se
sustituye por equivalentes minimos (time_bucket, approx_percentile, rollup,
last y dos tablas series_1h y series_1d). Por eso las politicas de Timescale
NO se comparan aqui: se cotejan con ts-trabajos.csv del mismo volcado.

    sudo python3 comparar.py <esquema.sql del volcado> [--salida DIR]

Necesita: root (usa runuser para el usuario postgres) y los binarios de un
PostgreSQL (initdb, pg_ctl, psql, pg_dump); toma el de version mas alta de
/usr/lib/postgresql/*/bin, o el de la variable PG_BIN. No toca ninguna base
existente: crea su propio cluster en un directorio temporal y lo borra.

Salida 0 (VERDE): ninguna diferencia fuera de prueba/fuera.txt.
Salida 1 (ROJO):  alguna diferencia; el detalle queda en DIR/informe.txt.
Salida 2:         la prueba no ha podido ejecutarse (no es un verde).
"""
import argparse
import collections
import difflib
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
SQL = os.path.dirname(AQUI)

PRELUDIO = r"""
DO $$ BEGIN CREATE ROLE cnm_api;    EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE cnm_loader; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE grafana_ro; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
-- Equivalentes minimos de TimescaleDB y su Toolkit: solo para que las vistas
-- compilen. Iguales en las dos bases; no se comparan.
CREATE FUNCTION public.time_bucket(interval, timestamptz) RETURNS timestamptz LANGUAGE sql IMMUTABLE AS 'select $2';
CREATE FUNCTION public.time_bucket(interval, timestamptz, text) RETURNS timestamptz LANGUAGE sql IMMUTABLE AS 'select $2';
CREATE FUNCTION public.approx_percentile(double precision, text) RETURNS double precision LANGUAGE sql IMMUTABLE AS 'select $1';
CREATE FUNCTION public.zz_rollup_sf(text, text) RETURNS text LANGUAGE sql IMMUTABLE AS 'select $2';
CREATE AGGREGATE public.rollup(text) (sfunc = public.zz_rollup_sf, stype = text);
CREATE FUNCTION public.zz_last_sf(anyelement, anyelement, anyelement) RETURNS anyelement LANGUAGE sql IMMUTABLE AS 'select $2';
CREATE AGGREGATE public.last(anyelement, anyelement) (sfunc = public.zz_last_sf, stype = anyelement);
CREATE TABLE public.series_1h (bucket timestamptz, id_metric integer, ds smallint, n bigint,
  avg_value double precision, min_value double precision, max_value double precision,
  last_value double precision, pct_sketch text);
CREATE TABLE public.series_1d (dia timestamptz, id_metric integer, ds smallint, n numeric,
  suma_ponderada double precision, min_value double precision, max_value double precision,
  last_value double precision, pct_sketch text);
"""
# series_time_idx lo crea create_hypertable por su cuenta; en la base sin
# TimescaleDB no existe.
EQUIVALENTES = ('time_bucket', 'approx_percentile', 'rollup', 'last', 'zz_', 'series_1h', 'series_1d',
                'series_time_idx')


def quitar_ts(sql):
    """Fuera lo que solo existe con TimescaleDB. Se aplica igual a las dos fuentes."""
    sql = re.sub(r'(?is)CREATE EXTENSION[^;]*;', '', sql)
    sql = re.sub(r'(?is)COMMENT ON EXTENSION[^;]*;', '', sql)
    sql = re.sub(r'(?is)SELECT\s+(create_hypertable|add_\w+_policy|set_chunk_time_interval)\s*\(.*?\)\s*;', '', sql)
    sql = re.sub(r'(?is)ALTER\s+(TABLE|MATERIALIZED VIEW)\s+\w+\s+SET\s*\(\s*timescaledb[^;]*;', '', sql)
    sql = re.sub(r'(?is)CREATE MATERIALIZED VIEW\s+(IF NOT EXISTS\s+)?(series_1[dh])\b.*?WITH NO DATA\s*;', '', sql)
    sql = re.sub(r'(?is)CALL\s+refresh_continuous_aggregate[^;]*;', '', sql)
    return sql


def del_volcado(sql):
    sql = quitar_ts(sql)
    # Los agregados continuos salen en el volcado como vistas sobre
    # _timescaledb_internal; su sustituto esta en el preludio.
    for v in ('series_1h', 'series_1d'):
        sql = re.sub(r'(?s)CREATE VIEW public\.%s AS.*?;\n' % v, '', sql)
    # Parametro de PostgreSQL 17 que un 16 no conoce: no es esquema.
    sql = re.sub(r'(?m)^SET transaction_timeout = .*$', '', sql)
    return sql


class Cluster:
    def __init__(self, binarios):
        self.bin = binarios
        self.dir = tempfile.mkdtemp(prefix='comparar-obs-', dir='/var/tmp')
        os.chmod(self.dir, 0o755)
        shutil.chown(self.dir, 'postgres')
        self.env = dict(os.environ, PGHOST=self.dir, PGOPTIONS='-c check_function_bodies=off')

    def pg(self, *a, **k):
        return subprocess.run(['runuser', '-u', 'postgres', '--', *a], env=self.env, **k)

    def arrancar(self):
        self.pg(f'{self.bin}/initdb', '-D', f'{self.dir}/data', '-A', 'peer',
                stdout=subprocess.DEVNULL, check=True)
        self.pg(f'{self.bin}/pg_ctl', '-D', f'{self.dir}/data', '-w', '-o',
                f"-k {self.dir} -c listen_addresses=''", '-l', f'{self.dir}/log', 'start',
                stdout=subprocess.DEVNULL, check=True)

    def parar(self):
        self.pg(f'{self.bin}/pg_ctl', '-D', f'{self.dir}/data', 'stop', '-m', 'fast',
                stdout=subprocess.DEVNULL)
        shutil.rmtree(self.dir, ignore_errors=True)

    def cargar(self, db, piezas, registro):
        """piezas: [(nombre, sql)]. Devuelve el numero de errores de carga."""
        self.pg(f'{self.bin}/createdb', db, check=True)
        self.pg(f'{self.bin}/psql', '-X', '-q', '-d', db, '-v', 'ON_ERROR_STOP=1', '-c', PRELUDIO,
                check=True, stdout=subprocess.DEVNULL)
        errores = 0
        for nombre, sql in piezas:
            tmp = os.path.join(self.dir, f'{db}-{os.path.basename(nombre)}')
            with open(tmp, 'w', encoding='utf-8') as f:
                f.write(sql)
            shutil.chown(tmp, 'postgres')
            r = self.pg(f'{self.bin}/psql', '-X', '-q', '-d', db, '-v', 'app_user=cnm_loader',
                        '-f', tmp, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            malos = [l for l in r.stdout.splitlines() if 'ERROR' in l]
            errores += len(malos) + (r.returncode != 0)
            registro.write(f'== {nombre}: rc={r.returncode}, {len(malos)} errores\n')
            registro.writelines(l + '\n' for l in r.stdout.splitlines() if 'ERROR' in l or 'LINE' in l)
        return errores

    def objetos(self, db, salida):
        r = self.pg(f'{self.bin}/pg_dump', '-d', db, '--schema-only', '--no-owner',
                    stdout=subprocess.PIPE, text=True, check=True)
        with open(os.path.join(salida, f'{db}.sql'), 'w', encoding='utf-8') as f:
            f.write(r.stdout)
        partes = re.split(r'(?m)^--\n-- (Name: .*?)(?:; Schema: [^;]*)?; Owner: .*\n--\n', r.stdout)
        d = collections.OrderedDict()
        for i in range(1, len(partes), 2):
            k, v = partes[i], partes[i + 1]
            # \restrict y \unrestrict llevan una clave aleatoria por volcado.
            v = re.sub(r'(?m)^(SELECT pg_catalog\.set_config|SET default_t|\\(un)?restrict ).*$', '', v).strip()
            if 'Type: TABLE' in k and v.startswith('CREATE TABLE'):
                # El orden de columnas cambia si una se anadio con ALTER: no cuenta.
                cab, cuerpo = v.split('(\n', 1)
                cols, fin = cuerpo.rsplit('\n)', 1)
                v = cab + '(\n' + ',\n'.join(sorted(c.strip().rstrip(',') for c in cols.split('\n'))) + '\n)' + fin
            # PostgreSQL 17 escribe el alias implicito de una conversion ('x'::text AS text).
            v = re.sub(r'::(\w+) AS "?\1"?(?=[,\s)])', r'::\1', v)
            d[k] = (d.get(k, '') + '\n' + v).strip()
        return d


def binarios():
    b = os.environ.get('PG_BIN')
    if b:
        return b
    cands = sorted(glob.glob('/usr/lib/postgresql/*/bin'), key=lambda p: int(p.split('/')[-2]))
    if not cands:
        sys.exit('ERROR: no encuentro PostgreSQL (/usr/lib/postgresql/*/bin); indica PG_BIN')
    return cands[-1]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('volcado')
    ap.add_argument('--salida', default=None)
    a = ap.parse_args()
    if os.geteuid() != 0:
        print('ERROR: hace falta root (runuser -u postgres)'); return 2
    salida = a.salida or tempfile.mkdtemp(prefix='comparar-informe-')
    os.makedirs(salida, exist_ok=True)

    with open(os.path.join(SQL, 'ORDEN'), encoding='utf-8') as f:
        orden = [l.strip() for l in f if l.strip() and not l.startswith('#')]
    with open(os.path.join(AQUI, 'fuera.txt'), encoding='utf-8') as f:
        fuera = [l.strip() for l in f if l.strip() and not l.startswith('#')]
    with open(a.volcado, encoding='utf-8') as f:
        volcado = f.read()

    c = Cluster(binarios())
    try:
        c.arrancar()
        with open(os.path.join(salida, 'carga.log'), 'w', encoding='utf-8') as reg:
            e_vol = c.cargar('desplegado', [('volcado', del_volcado(volcado))], reg)
            piezas = []
            for n in orden:
                with open(os.path.join(SQL, n), encoding='utf-8') as f:
                    piezas.append((n, quitar_ts(f.read())))
            e_rep = c.cargar('repositorio', piezas, reg)
        A = c.objetos('desplegado', salida)
        R = c.objetos('repositorio', salida)
    except (subprocess.CalledProcessError, OSError) as ex:
        print(f'ERROR: la prueba no ha podido ejecutarse: {ex}'); return 2
    finally:
        c.parar()

    def cuenta(k):
        nombre = k.split(';')[0]
        return not any(s in nombre for s in EQUIVALENTES) and not any(
            re.search(r'\b%s\b' % re.escape(x), nombre) for x in fuera)

    solo_a = [k for k in A if k not in R and cuenta(k)]
    solo_r = [k for k in R if k not in A and cuenta(k)]
    distintos = [k for k in A if k in R and A[k] != R[k] and cuenta(k)]
    iguales = sum(1 for k in A if k in R and A[k] == R[k] and cuenta(k))
    with open(os.path.join(salida, 'informe.txt'), 'w', encoding='utf-8') as o:
        o.write(f'errores de carga: volcado={e_vol} repositorio={e_rep} (detalle en carga.log)\n')
        o.write(f'objetos iguales={iguales} solo_desplegado={len(solo_a)} '
                f'solo_repositorio={len(solo_r)} distintos={len(distintos)}\n')
        o.write(f'\n## Solo en lo desplegado ({len(solo_a)})\n' + ''.join(f'  {k}\n' for k in solo_a))
        o.write(f'\n## Solo en el repositorio ({len(solo_r)})\n' + ''.join(f'  {k}\n' for k in solo_r))
        o.write(f'\n## Distintos ({len(distintos)})\n')
        for k in distintos:
            o.write(f'\n### {k}\n' + ''.join(difflib.unified_diff(
                R[k].splitlines(True), A[k].splitlines(True), 'repositorio', 'desplegado', n=1)))
    with open(os.path.join(salida, 'informe.txt'), encoding='utf-8') as f:
        print(f.read())
    rojo = e_vol or e_rep or solo_a or solo_r or distintos
    print(('ROJO' if rojo else 'VERDE') + f' · informe en {salida}/informe.txt')
    return 1 if rojo else 0


if __name__ == '__main__':
    sys.exit(main())
