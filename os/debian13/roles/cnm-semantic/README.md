# Rol `cnm-semantic`

Instala **lo que la capa semántica necesita fuera de `/opt/cnm`**. La capa
semántica es parte de la instalación de CNM, no un añadido del cliente, pero
sus datos sí son del cliente y no están en ningún repositorio.

## La frontera

| Qué | Quién lo pone |
|---|---|
| El código: `/opt/cnm/semantic/bin`, `/opt/cnm/crawler/bin` | **git** |
| El esquema: 12 tablas `sem_*` y 11 vistas | **el plugin** `/opt/cnm/update/cnm-semantic/install` — paso 8 del corte, `RUNBOOK-MIGRACION-CNMPRD02` §4.1 |
| `/opt/data/semantic`, los dos ficheros de configuración, la cuenta de lectura, la rotación del log | **este rol** |
| Los datos del cliente: maestro de roles, crosswalk, sitemap, `concept_rules.conf`, `historico/` | **un paquete aparte**, después del corte |
| `/opt/cnm-local` (planificación del cliente) | **otro rol** |

## Las seis tareas

1. `/opt/data/semantic` con `log/`, `backup/` e `historico/` · root:root 0755
2. `semantic.conf` desde plantilla · **0640**
3. `semantic.credentials` desde plantilla · **0600 root**. Tres valores de
   `ansible-vault` (`ro_pass`, `pg_user`, `pg_pass`) y **la contraseña de root
   de MySQL tomada del rol `mysql`** (`db_root_password`), no duplicada aquí
4. `/etc/logrotate.d/cnm-semantic`
5. La cuenta MySQL `cnm_ts_ro@localhost` con sus **14 `GRANT SELECT`**
6. Comprobación de que están los datos del cliente que la cadena necesita

## ⚠️ Lo que NO está probado de este rol

Dicho aquí para que no se confunda con lo que sí: **este rol no se ha ejecutado
nunca**, ni en modo `--check`. Lo escrito es código revisado, no código
validado, y la regla del proyecto es que `rc=0` no es prueba.

Lo que falta por probar, en orden:

```bash
# 1 · sintaxis y plantillas, sin tocar nada
ansible-playbook --connection=local cnm.yml --tags cnm-semantic --check --diff

# 2 · la via 2 de la contrasena, que es la que se usa el dia del corte:
#     SIN pasar --extra-vars, para que tenga que ir a /root/.my.cnf
ansible-playbook --connection=local cnm.yml --tags cnm-semantic --check --diff

# 3 · y que el fichero sale igual que el de produccion, sin mirar los valores
sha256sum /opt/data/semantic/semantic.credentials   # antes y despues
```

**El punto de más riesgo es la extracción de `password=` de `/root/.my.cnf`**:
usa `regex_findall` sobre el fichero y aquí no hay Ansible para ejecutarlo. La
parte de expresión regular sí se ha comprobado aparte contra una contraseña con
coma, `#` y espacios, que son los tres caracteres que rompen este tipo de
*parsing*; lo que no se ha ejecutado es la cadena de filtros de Jinja.

Si falla, el síntoma será el `assert` quejándose de que no hay contraseña —no un
fichero de credenciales a medias—, y eso es deliberado.

## Lo que el rol no escribe, y por qué

`stable_key_rules.conf`, `cnm_code_role_map.csv` y `concept_rules.conf` son
**datos del cliente**: `cnm_derive_code_map.pl` regenera el mapa y alguien lo
edita a mano. Un rol que los sobrescribiera borraría el trabajo del cliente en
la siguiente ejecución. Así que el rol **comprueba que están** y, si faltan,
falla diciendo de dónde salen.

La tarea 6 sólo exige los dos sin los que la cadena diaria **no arranca**:

| Fichero | Quién lo lee | Cuándo |
|---|---|---|
| `stable_key_rules.conf` | `cnm_mirror.pl` | paso 1, a diario |
| `cnm_code_role_map.csv` | `cnm_binding.pl` | paso 4, a diario |

`concept_rules.conf` lo usa `cnm_load_concepts.pl` bajo demanda, así que no
bloquea: no entra en la comprobación.

## Orden en el día del corte

```
paso 4 de §4.1   DROP DATABASE onm + restaurar
   -> ESTE ROL                 (la cuenta necesita que existan las tablas)
paso 8 de §4.1   /opt/cnm/update/cnm-semantic/install
   -> comprobar geography_field_id (ver abajo)
paso 5.4 de DOC-CNM-01   descomentar la planificación
```

El plazo real no es la ventana: es **`cnm-hourly`, que corre a la hora
siguiente**, y la cadena diaria a las **05:25** del día después.

## Dos comprobaciones que no hace el rol y hay que hacer

**1 · `geography_field_id` después de restaurar.** El valor es `8` y el propio
`semantic.conf` advierte de que *«depende del orden en que se crearon los
campos en el GUI»* y que en la instalación de referencia *«resultó ser 8, pero
es casual»*. Como el corte restaura el volcado del origen, `devices_custom_types`
llega con los mismos ids y 8 sigue valiendo — pero conviene verlo, porque si
alguna vez se instala de cero, esto envenena los datos en silencio:

```sql
SELECT id, descr FROM devices_custom_types ORDER BY id;
```

**2 · La prueba funcional de la capa.** No hay que construir nada:

```bash
cnm-semantic-daily.sh --ensayo --sin-capacidad
```

`--ensayo` **no escribe en ninguna parte** (las piezas son ensayo por defecto y
no escriben sin `--commit`) y `--sin-capacidad` se salta el sondeo SNMP, que
tarda ~20 min contra ~2.500 instancias.

> ⚠️ **`--sin-capacidad` a secas NO es seguro antes del corte.** Se salta el
> SNMP pero **sigue ejecutando el paso 5**, que replica a Timescale con
> reemplazo completo. Dos appliances haciendo eso se pisan. Antes del corte,
> `--ensayo` siempre.

Y los tres recuentos de `REF-SEM-05` §4, contra Timescale:

```sql
SELECT DISTINCT ultimo_dato_plataforma, ultima_lectura_alertas FROM api_salud_roles;
SELECT count(*) FROM sem_role_lookup;                            -- ~8.259 (sep-2026)
SELECT count(*) FROM sem_metric_map WHERE metric_name IS NULL;   -- 0
```

## De dónde sale cada credencial

Son **cuatro valores y dos dueños**. Importa porque una contraseña con dos
fuentes es una contraseña que algún día estará desincronizada.

| Valor de `semantic.credentials` | Quién lo define |
|---|---|
| `my_user` / `my_pass` | **la instalación de CNM**, por una de dos vías (abajo). Este rol lo **consume**; no lo declara |
| `ro_user` | `defaults/main.yml` de este rol: `cnm_ts_ro` |
| `ro_pass` | el vault de este rol — y **la cuenta la crea este rol** |
| `pg_user` / `pg_pass` | el vault de este rol. La cuenta vive en **otro servidor** (PostgreSQL) y el rol no la crea |

### Las dos vías de la contraseña de root, y por qué hacen falta las dos

| | De dónde | Cuándo sirve |
|---|---|---|
| **1** | `db_root_password`, que la instalación pasa por **`--extra-vars`** (`ansible-playbook --connection=local cnm.yml --extra-vars="db_root_password=xxx"`, documentado en `group_vars/all:5`) | **solo durante esa ejecución.** No es una variable guardada en ningún sitio |
| **2** | **`/root/.my.cnf`**, donde el rol `mysql` la deja escrita (`roles/mysql/templates/my.cnf.root.j2`) | **siempre.** Es la única fuente persistente en el appliance |

El rol prefiere la 1 cuando está —es la intención explícita de quien instala— y
**cae a la 2 cuando no**. Sin la vía 2 este rol no se podría ejecutar solo, y
ejecutarlo solo es exactamente lo que pasa el día del corte: el paso **C7** va
después de restaurar la base, no dentro de la instalación.

> La v1.0 declaraba `sem_vault_my_pass` en su propio vault: una **segunda
> fuente** de una contraseña que el rol `mysql` ya posee. Corregido. Si el
> `assert` se queja, la solución es pasar `db_root_password` o comprobar que
> existe `/root/.my.cnf` — **nunca** copiar la contraseña al vault de este rol.

## Dos cosas que este rol deja a la vista

- **`my_user` es `root` de MySQL.** Una cadena que escribe en 12 tablas no
  necesita root, y mientras siga así `semantic.credentials` contiene la
  contraseña de root. Es deuda, no de la migración: punto **4.24** de
  `claude/DOC-CNM-01`.
- **La contraseña de `cnm_ts_ro` quedó expuesta el 17-sep-2026**
  (`DOC-SEM-01` F15, `DOC-CNM-01` punto 1.9). El rol la crea con la contraseña
  del vault: **ponerle una nueva**. El corte es el momento barato, porque hay
  que editar igualmente `semantic.credentials` y `/opt/cnm-local/cnm-hourly`.

## Las 14 tablas que lee la capa semántica

Es su superficie de lectura completa sobre CNM, tomada del `SHOW GRANTS` de
`cnmprd02` el 7-oct-2026.

| Núcleo de CNM (8) | Capa semántica (6) |
|---|---|
| `devices`, `devices_custom_data`, `devices_custom_types`, `metrics`, `alerts`, `alerts_store`, `alert_type`, `cfg_monitor_snmp` | `sem_instance`, `sem_binding_role`, `sem_business_role`, `sem_metric_binding`, `sem_metric_concept`, `sem_canonical_concept` |

**No** están concedidas `sem_role_dependency`, `sem_load_audit`,
`sem_role_change_log` ni `sem_sla_evaluation`. Si algún día la propagación
jerárquica (`DOC-SEM-01` E5) lee `sem_role_dependency`, habrá que añadir el
`GRANT` — y el síntoma será un error de permisos, no un cero.
