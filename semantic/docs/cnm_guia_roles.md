# Guía de roles semánticos de CNM

Esta guía documenta la **capa de roles** de la semántica de CNM: **qué es un rol**, **cómo se decide su tipo y sus relaciones**, y el **estado actual del catálogo**. Es el análogo a la guía de conceptos, pero con una diferencia importante: **los conceptos son un catálogo cerrado (71) sobre lo que se *mide*; los roles NO están cerrados** —describen el negocio del cliente y se **consensúan e iteran**—. Por eso este documento sirve para (a) recopilar el modelo y lo ya construido, (b) **consensuar con el cliente lo que falta**, y (c) apoyar el Excel maestro que hay que terminar de cerrar.

> Nota metodológica: se distingue **información** (dato verificado en el maestro/CNM) de **inferencia** (síntesis de diseño, sujeta a validación). La taxonomía de tipos y las reglas son inferencia razonada; los recuentos son información extraída de `cnm_roles_maestro.xlsx`.

Relación con el resto de la documentación: el **modelo semántico completo y el pipeline** están en `cnm_guia_proyecto.md`; el **binding métrica→rol** en `cnm_provision_job_diseno.md`; las **incidencias de dato** en `cnm_incidencias_calidad_dato.md`.

---

## Parte 1 — Criterios generales para definir roles

### 1. Qué es un rol y qué lo distingue del concepto

Un **rol** es una pieza con **significado de negocio o de servicio** a la que se atan métricas. La frontera con el concepto es nítida:

> El **concepto** dice **QUÉ se mide** (uso de CPU, latencia, estado de un job). El **rol** dice **A QUÉ pertenece eso y qué importancia/impacto tiene** (la CPU *del servidor de SAP FICO*, que sostiene *el proceso de facturación*).

Corolario (el mismo que en conceptos, visto del otro lado): el significado concreto —"las facturas de España del proceso de facturación"— **no vive en el concepto**, vive en el **rol** y en la **metadata del binding**. Un concepto genérico (`biz.item.throughput_count`) atado a un rol (`proc.order_to_pay`) con metadata (documento=factura, país=ES) produce el KPI de negocio.

### 2. Los cinco `role_type` (una pila por capas)

- **Capa de negocio** (unida por **composición**): `business_process` (cadena de valor de punta a punta, p. ej. *Order to Pay*) → `business_subprocess` (un paso con identidad propia, p. ej. *Invoice payment*).
- **Capa de entrega** (unida por **dependencia**): `application` (software con semántica de negocio: SAP, ICG), `technical_service` (utilidad horizontal que otros consumen: WAN, AD, VTOM, backup, BD), `site` (lugar físico / frontera de fallo por co-ubicación: un CPD, una tienda).

Reglas de clasificación:
- **`application` vs `technical_service`**: ¿da una **capacidad de negocio** que alguien usa como fin (aplicación) o es **fontanería** que otras cosas consumen para funcionar (servicio técnico)? Prueba: si preguntas "¿qué capacidad de negocio da esto?" y la respuesta honesta es "ninguna, es infraestructura", es `technical_service`. Ejemplo clave: **VTOM es `technical_service`** (planificador de jobs, sin semántica de negocio propia); un **job concreto de VTOM no es un rol**, es una instancia/SLI que se ata a un subproceso.
- **`site`**: existe porque el **fallo correlacionado por ubicación** (cae el CPD → caen todas sus apps; cae la red de una tienda → cae ese local) necesita **un nodo** que lo explique, en vez de N alarmas sueltas.

Procedencia (transparencia): estos cinco tipos son una **síntesis** informada por marcos del sector (ITIL 4/CMDB, Google SRE para SLI/SLO/SLA, Backstage `Domain/System/Component` con `partOf`/`dependsOn`/`ownedBy`, CSDM de ServiceNow), **no** copia literal de ninguno. `site` como tipo de primer nivel es una decisión propia para el caso CNM. La taxonomía es deliberadamente **parca**: un tipo nuevo solo se añade si cambia la **propagación**, el **punto de enganche de SLA** o el **enrutado de responsabilidad**.

### 3. Las tres jerarquías (ejes independientes)

| Jerarquía | Campo | Semántica | Cardinalidad |
|---|---|---|---|
| **Composición** | `parent_role_id` | "es parte de" | árbol de **padre único** |
| **Dependencia** | `sem_role_dependency` | "depende de" | **grafo** (múltiples aristas, solapamiento) |
| **Organización** | `owner` → `sem_org_unit` | "responde de / afecta a" | quién posee/se escala |

Corolario que gobierna todo el modelado (validado en el proyecto): **el límite de padre único de la composición solo obliga a elegir cuando dos ejes se CRUZAN.** Si los ejes **anidan** (`país ⊃ segmento ⊃ aeropuerto ⊃ concesión`; `proceso ⊃ subproceso`) pueden ser todos niveles de una **misma cadena** de composición sin conflicto. Si un eje **cruza** la composición (la **marca** Illy atraviesa muchos aeropuertos), **no** puede ser composición: va como **atributo** (si solo hay que filtrar) o como **rol lógico + dependencia** (si hay que colgarle SLA/owner).

### 4. Nodo vs atributo (cuándo materializar un eje como rol)

`GROUP BY` sobre un atributo funciona **tengas o no** una jerarquía; por eso "se puede agrupar" **no** es argumento para/contra crear un rol. La regla real:

- **Materializa un eje como NODO (rol)** cuando vas a **colgar algo** de él (un SLA, una dependencia, un `owner`) o **navegarlo** en un cuadro de mando.
- **Déjalo como ATRIBUTO** (`domain`, `geography`, `brand`) cuando solo vas a **filtrar/agregar**.
- Ambos **conviven**: un segmento puede ser a la vez un nodo padre (para su SLA) y estar reflejado en `domain` (para consultas transversales).

### 5. `signal_class`, SLA y criticidad (la explotación del rol)

- La importancia de una métrica **no vive en el concepto ni en el rol solos**: se deriva de `criticality` del rol × peso del binding × `signal_class`.
- **`signal_class`** (sale del **concepto**, no del rol): `health_sli` (¿hace su trabajo? → IMPACTO), `saturation` (cerca del límite → RIESGO), `diagnostic` (contexto), `informative` (inventario).
- **SLI** = las instancias `health_sli` atadas al rol. **SLO/SLA** = reglas JSON en `sem_business_role.sla`. Evaluación en `sem_sla_evaluation` (modo *shadow* al principio). Estado "ahora" en `sem_service_health`.
- **`criticality`** (1-5) = importancia intrínseca (severidad por defecto). Se **fija a mano solo en los roles de negocio** (pocos) y se **deriva por dependencia** en lo técnico (la WAN es crítica porque la facturación depende de ella, no "porque sí"). Distinta del SLA.
- **`is_primary`/`weight`** se entienden **por canal** (salud vs riesgo): en un servicio/app la primaria de salud es la disponibilidad; en un subproceso, el KPI de resultado.

### 6. Cómo rellenar `geography` (vocabulario cerrado)

`geography` (`VARCHAR(16) NULL`) es un **atributo de agregación de un solo valor**, no una jerarquía. Vocabulario **cerrado**:

| Valor | Cuándo | Ejemplo |
|---|---|---|
| **ISO-2** (`ES`,`FR`,`US`,`DE`,`PT`,`MX`) | el rol sirve a **un solo país** | `app.icg_es` → `ES`; `site.us_mia_illy` → `US` |
| **`WW`** | sirve a **más de un país** (dé igual cuáles) **o** a todo el grupo | `svc.vtom` → `WW`; `proc.sales_integration` → `WW` |

**Nada de regiones (`EU`, `NA`…).** Se evaluaron y se descartan: los ámbitos reales son **conjuntos arbitrarios** (ES+PT, ES+PT+IT, ES+DE) que no se dejan agrupar en regiones sin inventar una por cada combinación. Además, mezclar granularidades rompe el filtrado: un rol etiquetado `EU` **no aparecería** en `WHERE geography='ES'` aunque sirva a España.

**El conjunto real de países va en `metadata`** (que es LONGTEXT con JSON parseado en la aplicación):
```json
{"served_countries": ["ES","PT","IT"]}
```
Ejemplo: ICG como despliegue único para tres países → `geography='WW'` + `metadata.served_countries=["ES","PT","IT"]`. Acepta cualquier combinación arbitraria sin farragosidad: es una lista, no una taxonomía.

> **Al rellenar la hoja**: si un rol es multi-país, pon `WW` y anota los países en `Comentarios` (p. ej. "sirve ES+PT+IT"); se convierte a `metadata.served_countries` de forma mecánica al generar.

**Reglas de aplicación:**
- **Vacío no** — rellena siempre. Un campo vacío es ambiguo (¿global? ¿no aplica? ¿olvido?); `WW` es explícito. Mismo criterio que los centinelas de `col7`.
- **`geography` es del ROL (su ámbito de servicio), no del hierro.** Si el servidor está en el CPD de Esplugues pero la app sirve al grupo → `WW`, **no** `ES`.
- **Sites**: ya viene derivado del `type`; solo revisar las excepciones marcadas (p. ej. `Router-FR` con localización COPENHAGUE).
- **Apps/servicios**: país si el sistema es específico de ese país (`ICG ES`, `Domain Controller FRA`, `RDS MX`); `WW` si sirve a varios.
- **Servidores (fuente `col8`)**: el cliente codifica el **país servido en las 2 primeras letras del nombre** del servidor. Se materializa en el campo de usuario **`col8`** (poblado por `cnm_col8_geografia.pl` con **lista blanca ISO-2** —solo asigna si las 2 letras son un ISO-2 válido, para evitar falsos positivos tipo marca/código de site— y luego se mantiene). `col8` es directamente `geography` (ámbito de servicio, no ubicación física). Uso: fuente fiable para roles de servidor/servicio; para una **aplicación** multi-servidor, el **conjunto de `col8`** de sus servidores alimenta `served_countries` (y su `geography` será `WW` si son varios).

**Limitación conocida (v1):** MariaDB 10.0 carece de funciones JSON, así que no se puede filtrar `served_countries` en SQL (se hace en la aplicación, o con un `LIKE '%"ES"%'` feo y sin índice). **Decisión Debian 13:** si consultar por país incluyendo multi-país se vuelve necesario, se normaliza con una tabla de enlace `sem_role_geography(role_id, country)` — la respuesta de libro a un atributo multivaluado: `WHERE country='ES'` encuentra también los multi-país, exacto e indexable, y `geography` pasa a ser derivado/de visualización. Mismo patrón que `kpi_id`: en v1 no se toca DDL; se promueve cuando el uso lo justifique.

#### Caso ilustrativo: un proceso implementado con apps distintas por geografía

Sales Integration (WW) donde Europa usa ICG y EEUU usa la aplicación XX. **El subproceso se nombra por el PASO de negocio, nunca por la aplicación** (si mañana EEUU cambia XX por YY, un subproceso llamado "XX" queda inservible; el paso no ha cambiado). Dos modelados válidos:

**A — un solo subproceso, dos implementaciones por dependencia** (si el negocio considera que es el mismo paso):
```
proc.sales_integration                      WW
  └─ proc.sales_integration.epos_capture    WW
       ├─dep→ app.icg    (ES / EU…)
       └─dep→ app.xx     (US)
```

**B — subproceso partido por geografía** (nombres `_eu`/`_us`, **no** `_icg`/`_xx`):
```
proc.sales_integration.epos_capture_eu   geography=WW  ─dep→ app.icg
proc.sales_integration.epos_capture_us   geography=US  ─dep→ app.xx
```

**Cuándo B:** solo si vas a **colgar algo** de esos nodos — SLA distinto por región, owner distinto, o navegar "Sales Integration en EEUU" como nodo. Si solo quieres filtrar/agregar → A (más simple). La pregunta que lo zanja con negocio: *"¿EEUU y Europa tienen objetivos/responsables distintos para este paso, o es el mismo paso con distinta herramienta?"*.

### 7. Cómo rellenar `owner` (unidad organizativa, no persona)

`owner` (`VARCHAR(64)`) es, por convenio del esquema, el **`org_id` de `sem_org_unit`**: la **unidad organizativa responsable**. Referencia blanda (sin FK, para no forzar poblar la organización).

**Qué NO es:**
- **No es una persona.** Las personas rotan; los equipos son estables. Vocabulario tipo `role_id`: jerárquico, en inglés/slug (`it`, `it.infra_team`, `finance`, `finance.invoicing_es`).
- **No es el nivel 1 de soporte.** Error frecuente. Hay que separar dos cosas:
  - **Ownership** = *quién responde de que esto funcione* → estable y **distinto por rol**.
  - **Enrutado de alerta** = *quién recibe el aviso primero* → proceso operativo; el N1 recibe **todo**, por política.

  Si pusieras `owner='soporte_n1'` en todos los roles, el campo sería **constante** → no aportaría nada, y perderías lo que `owner` existe para dar: **a quién escalar cuando el N1 no resuelve**.

**Y no hace falta forzar dos owners en un campo: las capas ya lo resuelven.** Ejemplo:
```
app.icg                        owner = apps.icg_team      ← dueño de la aplicación
   ├─dep→ svc.oracle_db        owner = it.dba_team        ← BD compartida (varias apps)
   ├─dep→ svc.vmware_cluster   owner = it.infra_team      ← plataforma compartida
   └─dep→ site.cpd_esplugues   owner = it.infra_team      ← emplazamiento

   (el servidor de ICG NO es un rol: col7 = app.icg; su ICMP/CPU/disco
    son señales health_sli / saturation de app.icg — ver aviso abajo)
```
Cada rol tiene **su** owner y ambos aparecen solos: los servicios compartidos de los que ICG depende son de infraestructura; la aplicación es del equipo de ICG. El **N1** recibe la alerta por política de alertado, no por ownership.

Prueba mental: *"si esto se rompe y el N1 no sabe arreglarlo, ¿a quién llamo?"*. La respuesta es distinta para la BD (DBA), la plataforma (infra) y la aplicación (equipo de ICG); ninguna es "N1".

> **Aviso — un servidor dedicado NO es un rol.** Regla: **un rol por cada dominio de fallo distinguible**. Si el elemento es **dedicado** a un solo consumidor (el servidor que solo ejecuta ICG), no falla independientemente de él → **no es rol**: su ancla es `col7 = app.icg` y sus métricas son señales de la app (vía 3). Si es **compartido** por varios consumidores (NAS, switch de core, BD de varias apps, VTOM, el CPD) → **sí es rol** (`technical_service`/`site`), porque su fallo tiene radio de impacto propio y hay que poder apuntarle dependencias desde varios sitios. Crear un rol por servidor multiplicaría el catálogo (~400 roles) sin aportar ninguna distinción.
>
> Consecuencia asumida: "el servidor de ICG no responde" es una alerta **sobre `app.icg`** (owner: equipo de ICG) aunque lo arregle infraestructura. Correcto: el ownership no es el enrutado; quién la recibe y quién repara el SO es política de alertado/escalado (`metadata.escalation`, N1).
>
> Excepción: un **clúster** de N servidores tras balanceador para una sola app (un nodo caído ≠ app caída) sí tiene dominios de fallo distinguibles; por defecto modelarlos como **instancias con `is_primary`/`weight`**, y como roles solo si hace falta SLA u ownership **por nodo**.

**Excepción legítima:** roles que el N1 posee de punta a punta (la propia consola de monitorización, o un site cuya única acción posible es "reiniciar el router", que hace el N1). Es la excepción, no la regla.

**Reglas de aplicación:**
- **Granularidad**: el **equipo** que responde (`it.infra_team`), no la persona ni la división entera (`it`).
- **No hace falta en los 717 roles**: ponlo donde la responsabilidad es clara (negocio, apps, servicios); los sites hoja pueden heredar del segmento.
- **Contacto y escalado no van en `owner`**: el contacto vive en `sem_org_unit.contact`; la cadena de escalado (operador/responsable/director) en `metadata.escalation`, como indica el propio esquema. `owner` solo dice **quién**.

> **Dependencia de orden:** `sem_org_unit` **aún no está poblada** (por eso `owner` está a 0 en el maestro). Primero se define el catálogo de unidades (10-20 entradas: divisiones/equipos, jerarquía, contacto) y luego se referencia desde los roles. Rellenar owners a mano sin catálogo produce texto libre incoherente (`"IT"`, `"it"`, `"Equipo IT"`, `"Juan"`) — el mismo problema que sufrimos con `col1`.
>
> **Aviso:** el generador **no valida** `owner` (no hay FK ni comprobación en la puerta de integridad). La disciplina la pone quien rellena; se puede añadir la comprobación cuando `sem_org_unit` esté poblada.

### 8. El binding métrica→rol y el ancla `col7`

Una métrica se ata a un rol por tres vías (detalle en `cnm_provision_job_diseno.md`): código `P##-SP##-KPI##` en `c_label`, o en `label`, o —si no hay código— por herencia del **rol del dispositivo** vía el campo de usuario **`col7` (RoleID)**. Valores reservados de `col7`: `multiple_roles` (excepción legítima: VTOM/NAS/backup/BD, se resuelven por KPI) y `unassigned` (pendiente de clasificar). Un rol jamás se crea desde el binding: el job **resuelve contra** el catálogo.

### 9. Convenciones de nombrado

- **`role_id`**: estable, legible, en inglés/slug, **nunca basado en IP** (un readdressing no debe cambiar la identidad). Prefijos por tipo: `proc.`, `proc.<proceso>.<subproceso>`, `app.`, `svc.`, `site.`. Sites finos: `site.<geo>_<slug(nombre)>` (p. ej. `site.us_mia_illy`). Segmentos: `site.segment_<segmento>_<geo>` (p. ej. `site.segment_airport_es`).
- **`display_name`**: legible para humanos (puede ir en castellano: "Aeropuertos ES", "MIA Illy").
- **`domain`**: en **inglés** (faceta de agregación; ver Parte 2).
- Los duplicados detectados se marcan con sufijo `__dup` y `Validación` para colapsar (no se cargan como roles espurios).

### 10. Ciclo de vida del rol (`status`)

El esquema define `status ENUM('draft','active','deprecated','archived')`.

#### 10.1 Los dos ejes (la distinción que evita el bloqueo)

Sobre un rol hay **dos preguntas distintas**, y confundirlas paraliza el proyecto:

| Eje | Campo | Pregunta |
|---|---|---|
| **Ciclo de vida** | `status` | ¿este rol **existe y se usa**? |
| **Revisión** | `Validación` | ¿he **revisado sus atributos** (geografía, criticidad, dominio, owner)? |

Son **ortogonales**. Un site puede estar `active` (existe, sale del inventario, se le atan métricas) y a la vez tener `Validación = PENDIENTE` (su criticidad sigue por confirmar). Si se exige que `status` espere a que *todos* los atributos sean perfectos, **todo se queda en `draft` para siempre** y la capa semántica nunca arranca.

`valid_from`/`valid_to` son un **tercer** eje distinto: vigencia de **calendario** (el propio esquema lo anota: *"status (a state, not dates)"*). Un rol puede estar `active` con `valid_from` futura.

#### 10.2 Qué significa cada estado

- **`draft`** — existencia **especulativa**: propuesto por heurística y sin confirmar (p. ej. roles que salgan del crosswalk de `col1`). Se puede atar métricas de forma provisional, pero **no se publica**.
- **`active`** — existencia **cierta**: el rol es real y está en uso. Es el estado normal de trabajo. *No significa "perfecto", significa "real"*.
- **`deprecated`** — retirado: ya no aplica, pero **se conserva**. Clave: borrarlo dejaría huérfanos los bindings históricos y el dato pasado sin atribuir. Permite decir "esto ya no se usa" **sin romper el histórico**.
- **`archived`** — **reservado, no usar en v1**. No tiene un consumidor que se comporte distinto que con `deprecated`; se mantiene en el ENUM (cambiarlo exigiría DDL) por si el catálogo crece a miles de roles y hace falta un estado "oculto de todo listado".

> Criterio para justificar un estado: **¿algún consumidor se comporta distinto?** Si dos estados producen el mismo comportamiento en todas partes, uno sobra. Por eso en la práctica se usan **tres**.

#### 10.3 Contrato de consumo (qué hace cada consumidor con cada estado)

| `status` | Binding (atar métricas) | `sem_service_health` | Dashboards / IA | Resolver histórico |
|---|---|---|---|---|
| `draft` | **sí**, marcado provisional | no | no | — |
| `active` | sí | sí | **sí** | sí |
| `deprecated` | no (no nuevos) | no | no | **sí** |
| `archived` | *(no usar en v1)* | — | — | sí |

La clave está en la primera fila: **atar métricas a los `draft` sí, publicarlos no**. Así la maquinaria técnica funciona de punta a punta desde el primer día (se puede probar el binding) mientras la puerta de *publicación* hacia negocio sigue siendo `active`. Si no se ataran los `draft`, nada funcionaría hasta terminar toda la validación.

#### 10.4 Estado aplicado en el maestro

Los 556 roles proceden del **inventario real** (sites) o del **catálogo de códigos KPI del propio cliente** (procesos, subprocesos, apps, servicios): su existencia es cierta, así que están en **`active`**. Quedan fuera: `site.autopistas.es` (`deprecated`, sin datos) y `svc.sftp__dup_w16` (`draft`, pendiente de decidir si se colapsa). La revisión de atributos se sigue por la columna `Validación`.

> **Cómo se ejecutan los cambios:** el maestro `cnm_roles_maestro.xlsx` es la **fuente única de verdad**; `sem_business_role` es un derivado que se regenera desde él (nunca editar la BD a mano). El ciclo de iteración obligatorio —validar → diff → dry-run → copia → producción → archivar— está en **`cnm_proceso_actualizacion_roles.md`**, con las reglas para añadir/modificar/retirar roles y la vuelta atrás.

### 11. Cómo añadir/validar un rol (lista de comprobación)

1. ¿Es una pieza con **significado propio** que se **observa y falla por separado**? Si no, no es un rol (puede ser una métrica/atributo).
2. ¿Qué **`role_type`**? ¿capacidad de negocio → `application`; utilidad horizontal → `technical_service`; lugar físico → `site`; paso de una cadena de negocio → `business_subprocess`; la cadena entera → `business_process`?
3. ¿Tiene **padre de composición**? Solo si **anida** en el único eje de contención (negocio o geográfico). Si el eje **cruza**, va por dependencia/atributo.
4. ¿De qué **depende**? → aristas en `sem_role_dependency` (se consensúa con negocio/IT).
5. ¿Quién lo **posee**? → `owner` = `org_id` del **equipo** responsable (§7). No una persona; no el N1.
6. ¿Qué lo **mide**? → bindings (marca la primaria de salud; el resto por su `signal_class`).
7. Rellena **`domain`** y **`geography`** (§6: ISO-2 si es de un país, `WW` si multi-país/global; nunca vacío; los países concretos a `Comentarios`/`metadata.served_countries`) y deja **`criticality`** para fijarla en negocio / derivarla en técnico.

---

## Parte 2 — Catálogo y estado actual (fuente: `cnm_roles_maestro.xlsx`, 717 roles)

### Reparto por `role_type`

| role_type | nº | qué es | jerarquía típica | ejemplos del maestro |
|---|---|---|---|---|
| `business_process` | 3 | cadena de valor de negocio | raíz de composición | `proc.order_to_pay`, `proc.sales_integration`, `proc.master_data_accuracy` |
| `business_subprocess` | 25 | paso dentro de un proceso | hijo del proceso | `proc.order_to_pay.invoice_payment`, `proc.sales_integration.epos_information` |
| `application` | 79 | software con semántica de negocio | dependencia | SAP (FICO/S4/BW…), ICG, Thetys, Diapason, Meta4… |
| `technical_service` | 42 | utilidad horizontal | dependencia | WAN, Active Directory, VTOM, sFTP, backup, BD… |
| `site` | 568 | lugar físico / frontera de fallo | composición geográfica | `site.us_mia_illy`, `site.segment_airport_es`, `site.cpd_esplugues` |

### Reparto por `domain` (atributo de agregación, en inglés)

Negocio/app/servicio: `procure_to_pay` 9, `master_data` 13, `sales` 16, `erp_sap` 19, `bi` 23, `scheduling` 10, `treasury` 6, `e_invoicing` 4, `hr` 3, `network` 1, `infrastructure` 10, `it_ops` 2, `other` 33.
Sites por segmento: `airport_sites` 411, `motorway_sites` 48, `railway_sites` 26, `resort_sites` 8, `datacenter_sites` 8, `other_sites` 67.

### Reparto por `geography` y `status`

Geografía: FR 257, US 167, ES 146, WW 51, PT 4, DE 3, MX 3, sin geografía 86 (procesos/apps/servicios sin país). Es **atributo derivado del `type`**, no jerarquía.
Estado: `draft` 710 (candidatos a validar), `active` 6 (los segmentos revividos), `deprecated` 1.

### La capa de negocio (composición)

Los 3 procesos y sus 25 subprocesos son el **esqueleto aprovechable** (P05/P06 antiguos se retiraron por no vigentes). Es donde la composición proceso→subproceso tiene sentido real; el resto del catálogo se relaciona por **dependencia**.

### La capa de sites (la más grande: 568)

Estructura de composición **por segmento y país**: `segmento → aeropuerto/localización → concesión`, con profundidad donde el dato la sostiene (US: concesión→aeropuerto; TPV AENA: local→AENA; Resorts) y a un solo nivel donde `col4` ya estaba a nivel sitio (routers ES/FR). Los **6 segmentos-parent** (`active`): Aeropuertos ES/US/FR, Autopistas FR, Ferrocarriles ES, Resorts FR. **Autopistas ES quedó `deprecated`** (no hay sites de autopista en España en el dato; ESSO es FR) — a confirmar con el cliente. El **país es atributo** (`geography`), no nodo. Naming basado en el nombre estable (col4/col1), no en la IP.

### La capa de entrega (aplicaciones 79 + servicios técnicos 42)

Es el *landscape* IT: familia SAP (S4/FICO/BW/CAR/Hybris…), ICG, e-factura (EDICOM/VOXEL), BI/reporting, RRHH, y servicios técnicos transversales (WAN, AD, VTOM, sFTP, SMTP, backup, BD, DC). Se conectan a negocio y entre sí por **dependencia** (aún por poblar).

### Atributos poblados hoy

- **`geography`**: derivado del `type`, con excepciones marcadas (p. ej. un router FR con localización COPENHAGUE).
- **`domain`**: propuesto, en inglés.
- **`brand`**: 200 filas con candidato **poco fiable** (extraído del nombre); para un SLA de marca real hará falta un **diccionario de marcas** o modelar `brand.*` como rol lógico + dependencia. No se carga en `sem_business_role` (no hay columna) en v1.
- **`criticality`**: vacía a propósito (se fija en negocio / se deriva en técnico).
- **`owner`**, **`sla`**, **dependencias**: vacíos — es lo que falta consensuar.

---

## Parte 3 — Pendiente de consensuar con el cliente (para cerrar el modelo)

Esto es lo que **el Excel maestro aún no fija** y que requiere aportación de negocio/IT (ordenado por impacto):

1. **Dependencias** (`sem_role_dependency`): el grafo "quién depende de quién" **no está** en las tripas de CNM; es el mayor valor a aportar. Recomendado empezar por el **piloto Order to Pay** (`cnm_piloto_order_to_pay.xlsx`).
2. **Owners** (`sem_org_unit`): estructura organizativa y responsables por rol.
3. **SLA**: objetivos por proceso/servicio. Hay uno ya identificado por el cliente: **SLA de disponibilidad del canal Autopistas** — buen primer caso para materializar un segmento como nodo con SLA.
4. **`criticality`**: fijar 1-5 en los 3 procesos de negocio; derivar el resto por dependencia.
5. **Crosswalk `col1 → role_id`** (para sembrar `col7` de app/infra): ~314 dispositivos pendientes de que se valide el mapeo (`cnm_col1_crosswalk_propuesta.csv`).
6. **`brand`**: sustituir la extracción por nombre por un **diccionario de marcas** validado; decidir si marca es atributo o rol lógico con SLA.
7. **`other_sites` (67)**: revisar y asignar segmento (o crear `fair_sites`/`street_sites` si negocio lo quiere).
8. **Duplicados `__dup`** (p. ej. `svc.sftp` = W16 + P04-SP0010): colapsar; y revisión más amplia **P04-vs-entradas-propias** (los que no colisionan en `role_id` no los caza el chequeo automático).
9. **Autopistas ES `deprecated`**: confirmar si se retira definitivamente o si hay sites que faltan.
10. **86 roles sin `geography`**: rellenar según §6 (ISO-2 o `WW`; ninguno debe quedar vacío).
11. **Catálogo `sem_org_unit`**: definirlo (10-20 entradas) **antes** de rellenar `owner` (§7).

---

## Resumen

El maestro tiene hoy **717 roles** (3 procesos, 25 subprocesos, 79 aplicaciones, 42 servicios técnicos, 568 sites), casi todos en `draft` a la espera de validación. La **estructura** (tipos, jerarquías, atributos, naming, ciclo de vida) está definida y es estable; lo que falta para "cerrar" no son más filas sino el **conocimiento de negocio** que solo el cliente aporta: **dependencias, owners y SLA**, más la validación de los mapeos automáticos (crosswalk `col1→role_id`) y la limpieza de los puntos abiertos de la Parte 3. A diferencia del catálogo de conceptos (cerrado), la capa de roles es **viva**: crece y cambia con el negocio, y por eso el modelo prioriza que todo cambio de criterio sea **aditivo** (agregar por atributo, encadenar composición) y no una re-división costosa.
