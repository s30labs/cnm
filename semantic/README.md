# CNM · Capa semántica

Maquinaria para definir **qué significan** las métricas de CNM: conceptos
(qué se mide), roles de negocio (a qué sirve) y el anclaje entre ambos.

---

## Separación producto / cliente

La capa semántica **depende de cada cliente**: sus procesos, sus países, sus
emplazamientos. Por eso hay tres capas bien distintas, y confundirlas es el
error que hay que evitar:

| Capa | Qué es | Dónde vive | ¿Va al repo? |
|---|---|---|---|
| **Producto** | Validador, generador, esquema, plantillas, documentación | `/opt/cnm/semantic` | **Sí** |
| **Configuración** | Países, filtro de servidores, nombre de BD | `semantic.conf` | Solo el `.example` |
| **Datos** | Maestro con los roles, histórico, backups, logs | `/opt/data/semantic` | **Nunca** |

**Regla para decidir en caso de duda:** *si es el resultado de mirar la instalación
del cliente, es dato; si es lo que sabe mirarla, es producto.* Ejemplo: el script
que extrae el diccionario de estados de `cfg_monitor` es producto; el volcado con
los 626 subtypes de un cliente concreto, no.

Los datos de cliente no son solo "datos": los `role_id` revelan emplazamientos,
marcas, procesos y arquitectura interna. No pueden acabar en un repo de producto.

---

## Layout

```
/opt/cnm/semantic/             CÓDIGO — checkout del repo, se actualiza con el producto
├── bin/
│   ├── CNMSemanticConf.pm       cargador de configuración (común)
│   ├── cnm_validar_maestro.pl   validación pre-vuelo del maestro (1ª puerta)
│   ├── cnm_generate_roles.pl    carga CSV -> sem_business_role (2ª puerta)
│   ├── cnm_archivar_maestro.sh  archiva la versión cargada
│   └── cnm_col8_geografia.pl    puebla col8 (geografía desde el nombre del servidor)
├── schema/
│   └── cnm_semantic_schema_v3.sql
├── templates/
│   └── cnm_roles_maestro_PLANTILLA.xlsx   maestro vacío (estructura, sin datos)
├── docs/
│   ├── cnm_guia_conceptos.md
│   ├── cnm_guia_roles.md
│   └── cnm_proceso_actualizacion_roles.md
├── semantic.conf.example
└── .gitignore

/opt/data/semantic/            DATOS DEL CLIENTE — nunca en el repo público
├── semantic.conf                configuración de esta instalación
├── cnm_roles_maestro.xlsx       fichero vivo (el que se edita)
├── cnm_roles_maestro.csv        export actual (lo que se valida y se carga)
├── historico/                   versiones cargadas + ultima_cargada.csv + registro
├── backup/                      dumps puntuales de sem_business_role
└── log/                         salidas de validación y carga
```

Esta separación sigue la convención que ya usa CNM (código en `/opt/cnm`, datos en
`/opt/data`, como el crawler y sus RRD) y tiene una ventaja concreta: **actualizar el
producto no puede tocar el trabajo semántico del cliente**, y reinstalar el código no
destruye el maestro.

---

## Instalación en un cliente nuevo

```bash
# 1. codigo
git clone <repo> /opt/cnm/semantic

# 2. datos y configuracion
mkdir -p /opt/data/semantic/{historico,backup,log}
cp /opt/cnm/semantic/semantic.conf.example /opt/data/semantic/semantic.conf
chmod 0640 /opt/data/semantic/semantic.conf
$EDITOR /opt/data/semantic/semantic.conf     # paises, filtro de servidores, BD

# 3. esquema en la BD de CNM
mysql onm < /opt/cnm/semantic/schema/cnm_semantic_schema_v3.sql

# 4. punto de partida del maestro
cp /opt/cnm/semantic/templates/cnm_roles_maestro_PLANTILLA.xlsx \
   /opt/data/semantic/cnm_roles_maestro.xlsx
```

Dependencias Perl: `Text::CSV`, `DBI`, `DBD::mysql`
(`apt install libtext-csv-perl libdbi-perl libdbd-mysql-perl`).

---

## Uso diario

El ciclo completo (editar → exportar → validar → diff → dry-run → cargar → archivar)
está en **`docs/cnm_proceso_actualizacion_roles.md`**, que es normativo. Resumen:

```bash
cd /opt/data/semantic
BIN=/opt/cnm/semantic/bin

perl $BIN/cnm_validar_maestro.pl --csv cnm_roles_maestro.csv
perl $BIN/cnm_validar_maestro.pl --csv cnm_roles_maestro.csv --diff historico/ultima_cargada.csv
perl $BIN/cnm_generate_roles.pl  --db-name onm --db-user U --db-pass P --file cnm_roles_maestro.csv
perl $BIN/cnm_generate_roles.pl  --db-name onm --db-user U --db-pass P --file cnm_roles_maestro.csv --commit
bash $BIN/cnm_archivar_maestro.sh --nota "descripción del cambio"
```

Los scripts localizan `semantic.conf` automáticamente
(`/opt/data/semantic/semantic.conf`, o `--conf <ruta>`, o `$CNM_SEMANTIC_CONF`).

---

## Versionado de los datos del cliente (opcional)

Como el maestro se guarda también en **CSV** (texto plano), un **repo git privado y
separado** para `/opt/data/semantic/` daría versionado y diff con mejor grano que el
`historico/` por fechas. No es necesario —el mecanismo actual cubre la necesidad—,
pero es la evolución natural si el número de iteraciones crece. Sería un repo
**privado**, nunca el del producto.
