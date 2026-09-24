# `cnm-semantic` — capa semántica de CNM

Instala el esquema de la capa semántica (`sem_*`) y sus vistas **usando el
mecanismo de plugins de `db-manage.php`**, pero no es un plugin de cliente: vive
en `/opt/cnm/update/cnm-semantic`, dentro del núcleo del producto, no en
`/opt/cnm-sp`.

Que se instale «como plugin» es solo la vía técnica: `db-manage.php -p <dir>` es
hoy la única forma de declarar tablas propias y que converjan con los mismos
criterios que el esquema estándar.

## Qué instala

| | Objetos |
|---|---|
| **12 tablas** `sem_*` | `sem_canonical_concept`, `sem_metric_concept`, `sem_instance`, `sem_metric_binding`, `sem_business_role`, `sem_org_unit`, `sem_binding_role`, `sem_role_dependency`, `sem_service_health`, `sem_sla_evaluation`, `sem_load_audit`, `sem_role_change_log` |
| **11 claves ajenas** | las de producción, `ON DELETE CASCADE` incluido |
| **11 vistas** | `v_alerta_contexto`, `v_alerta_panel`, `v_alerta_semantica`, `v_binding_health`, `v_diag_*` (4), `v_valida_vista_rol`, `v_validacion_vistas`, `valert_map` |

**La fuente del esquema es `cnmprd02`**, no el fichero
`semantic/schema/cnm_semantic_schema_v3.sql` del repositorio, que está obsoleto
(le faltan siete columnas y un índice). El esquema que genera este directorio se
ha comparado columna a columna con el de producción: **121 columnas y todos los
índices idénticos**.

No instala las dos tablas `sem_business_role_bak_*` de `cnmprd02`: son copias de
seguridad puntuales, no parte del modelo. Tampoco instala los datos de ejemplo
que el fichero del repositorio traía al final (ver «Qué se ha dejado fuera»).

## Cómo se instala

```bash
/opt/cnm/update/cnm-semantic/install
```

Que hace, exactamente:

```bash
/update/db/db-manage.php -p /opt/cnm/update/cnm-semantic   # tablas y claves ajenas
/opt/cnm/update/cnm-semantic/post-install                  # vistas
```

**Debe ejecutarse DESPUÉS del `db-manage.php` estándar**, porque varias vistas se
apoyan en tablas del producto (`alerts`, `metrics`, `devices`,
`devices_custom_data`). El `install` propaga el código de salida de las dos
llamadas (`REV-CNM-02` §16).

## Estructura

```
/opt/cnm/update/cnm-semantic/
├── install                              # propaga el código de salida
├── post-install                         # aplica las vistas
├── README.md
├── sql/views/*.sql                      # 11 vistas, CREATE OR REPLACE
└── update/db/
    ├── DB-Scheme-Create.php             # $DBScheme con las 12 tablas
    └── Init/                            # vacío: no se cargan datos
```

## Decisiones de diseño

1. **Charset explícito en cada columna de texto.** `db-manage` no declara charset
   de tabla: la tabla hereda el de la base (`latin1`) y, además,
   `table_charset_latin1()` fuerza `charset=latin1` en cada ejecución. Sin
   `character set utf8 collate utf8_spanish_ci` explícito las columnas saldrían
   `latin1` y no coincidirían con producción.

2. **Nulabilidad explícita en cada `TIMESTAMP`.** `explicit_defaults_for_timestamp`
   no vale lo mismo en MySQL 5.5 que en MariaDB. `TIMESTAMP DEFAULT
   CURRENT_TIMESTAMP` produce `NOT NULL` en uno y `NULL` en el otro; declarándolo
   el esquema converge en los dos.

3. **Orden del array = orden de creación.** `db-manage` crea las tablas en el
   orden del array y no desactiva la comprobación de claves ajenas, así que cada
   tabla va después de aquella a la que apunta.

4. **Las vistas van en `post-install`.** `db-manage` gestiona tablas, datos y
   procedimientos; no tiene ninguna función para vistas. El `post-install`
   localiza la BBDD de cliente con el mismo mecanismo que `db-manage`
   (`get_db_credentials()` + `_cnms()`), de modo que aquí no hay credenciales
   escritas, y las aplica en varias pasadas porque unas dependen de otras
   (`v_alerta_semantica` → `v_alerta_contexto` → `v_alerta_panel`).

5. **Las vistas llevan `SQL SECURITY INVOKER`.** En `cnmprd02` están con
   `DEFINER=root@localhost` y `SQL SECURITY DEFINER`, lo que ata la vista a un
   usuario del equipo antiguo y falla al restaurar en otro.

## Qué se ha dejado fuera, y por qué

`semantic/schema/cnm_semantic_schema_v3.sql` termina con un bloque rotulado
`ILLUSTRATIVE EXAMPLE` (líneas 356-409) que inserta **datos de demostración**:
el rol `infra.identity.ad`, el rol `sales.invoicing.es`, las unidades `it` y
`finance`, instancias con `instance_id` 900001-900010 sobre el dispositivo 501 y
sus bindings. No son datos del cliente: son un ejemplo didáctico. Este directorio
no los instala.

## Requisito previo: los conceptos canónicos

El directorio instala el **esquema**, no el **contenido**. `sem_canonical_concept`
y `sem_metric_concept` se pueblan con `semantic/bin/cnm_load_concepts.pl`, y hay
que hacerlo **antes** de cargar instancias o bindings: `sem_metric_concept` tiene
una clave ajena contra `sem_canonical_concept`.

## Convergencia

Comprobado en laboratorio (MariaDB 10.11):

- instalación desde cero → 12 tablas, 11 claves ajenas, 11 vistas, RC=0;
- ejecuciones sucesivas → `ESQUEMA: 0 ALTER`, `errores: 0`;
- si se borra una clave ajena a mano, la siguiente ejecución **la vuelve a crear**
  (`_addColumn()` trata la línea `CONSTRAINT … FOREIGN KEY …` como un índice más).
  Eso sí, no aparece en el recuento de `ESQUEMA:`, que solo cuenta `ALTER` de
  columna.

Requiere `db-manage.php` con la corrección **A22** (`REV-CNM-02` §19). Sin ella
estas 12 tablas provocan 8 `ALTER` inútiles en cada ejecución, para siempre.
