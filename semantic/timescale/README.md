# semantic/timescale · SQL de la base analítica `obs`

Esquema y código de la capa analítica en el servidor de TimescaleDB (base
`obs`, PostgreSQL 17 con TimescaleDB y su Toolkit): la hipertabla `series` y
sus agregados, la réplica de alertas y de la capa semántica, las vistas, las
funciones de salud y del informe de capacidad, y la API pública (`api_*`).

**Es la referencia de lo desplegado.** Hasta el 8-nov-2026 estos ficheros no
estaban versionados. Se incorporaron partiendo de los `.sql` originales y se
corrigieron hasta reproducir lo que había en producción, medido con
`prueba/comparar.py` contra un volcado de ese día.

## Orden de instalación

El de [`ORDEN`](ORDEN). Cada fichero es idempotente y se aplica como `postgres`:

```bash
for f in $(grep -v '^#' ORDEN); do
  runuser -u postgres -- psql -X -d obs -v ON_ERROR_STOP=1 -f "$f" || { echo "ROJO en $f"; break; }
done
```

Requisitos previos: las extensiones `timescaledb` y `timescaledb_toolkit`
disponibles, y los roles `cnm_loader` (el que usan el loader y las
sincronizaciones) y, si se quiere, `grafana_ro`. `cnm_api` lo crea
`cnm_api_publica.sql`; su contraseña se pone a mano y no está aquí.

## Lo que no está, a propósito

| Qué | Por qué |
|---|---|
| Contenido de `sem_state_dict` | es dato: se genera de la configuración de monitores de cada instalación ([`../README.md`](../README.md), «Separación producto / cliente»). `sem_state_dict.sql` crea solo la tabla; el volcado con los datos se llama `cnm_state_dict.sql` y `../.gitignore` lo excluye |
| Vistas `v_microcortes_*` | seguimiento temporal de una corrección del motor de alertas; se retiran cuando esté validada. Listadas en [`prueba/fuera.txt`](prueba/fuera.txt) |
| Scripts de un solo uso y versiones anteriores | el histórico lo guarda git |

## Permisos

`ts_schema.sql` fija **permisos por defecto**: todo lo que cree `postgres` en
`public` da `ALL` a `cnm_loader` y `SELECT` a `grafana_ro`. Es lo desplegado,
pero da más de lo necesario; está anotado como pendiente de seguridad en la
documentación de CNM. Los `GRANT` explícitos de cada fichero quedan cubiertos
por esos permisos por defecto.

## La prueba: `prueba/comparar.py`

Compara estos ficheros con lo desplegado, objeto a objeto (tablas, columnas,
vistas, funciones, índices, comentarios y permisos):

```bash
# 1. En el servidor de Timescale, como root (solo lee):
bash prueba/extraer-esquema-timescale.sh          # deja /root/esquema-timescale-*.tgz
# 2. En cualquier equipo con los binarios de PostgreSQL 16 o 17, como root:
python3 prueba/comparar.py <esquema.sql del paquete> --salida /tmp/informe
echo $?
```

- **Verde**: salida 0, `VERDE` y ninguna diferencia.
- **Rojo**: salida 1; el detalle está en `informe.txt`.
- **Salida 2**: la prueba no pudo ejecutarse. No es un verde.

`comparar.py` crea un PostgreSQL desechable en `/var/tmp`, no toca ninguna base
existente y no necesita TimescaleDB: lo que solo existe con TimescaleDB se quita
por igual en las dos bases. Por eso **las políticas de Timescale** (compresión,
retención, refresco de los agregados) **no las compara**: se cotejan a mano con
`ts-trabajos.csv` y `ts-agregados.csv` del mismo paquete.

**Estado a 8-nov-2026: rojo por dos comentarios.** `sem_role_lookup.sql` tiene
`COMMENT ON COLUMN` para `ds_valor` y `ds_total` que no están en producción (las
columnas se añadieron allí sin comentario). Se ponen en verde aplicando esos dos
`COMMENT` en producción, o quitándolos de aquí.
