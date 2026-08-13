# Guía de conceptos semánticos de CNM

Esta guía documenta la capa semántica de CNM: **qué es un concepto canónico**, **cómo se decide**, y el **catálogo de los 71 conceptos** consolidado mapeando ~2.730 subtypes del repositorio. Está pensada como referencia tanto para personas (onboarding de nuevas métricas) como para alimentar el contexto de un modelo de IA que tenga que interpretar la monitorización.

La capa semántica **no modifica** el motor de captura, ni los RRD, ni MySQL. Es una capa de lectura (tablas `sem_*`) que traduce el identificador interno de CNM (`subtype` / `idmetric`) a un vocabulario estable y a un significado de negocio.

---

## Parte 1 — Criterios generales para definir conceptos

### 1. Qué nombra un concepto: la *naturaleza* de la medida

Un `canonical_id` nombra **el tipo de cosa que se mide**, no de dónde sale el dato ni en qué aparato corre. La prueba decisiva es la **prueba de colapso**:

> Si dos métricas miden lo mismo, deben colapsar al mismo concepto, por distintas que sean su origen, su tecnología o el dispositivo.

Ejemplos:

- El uso de CPU de un servidor Linux (vía `hrProcessorLoad`), el de un router Cisco (`cisco_cpu`) y el de un switch H3C (`h3c_cpu_usage_slot`) son **el mismo concepto**: `device.cpu.pct`. Que uno sea servidor y otro router es **clase de dispositivo**, no concepto.
- Un recuento de facturas obtenido por una *query* SQL y el mismo recuento leído de un fichero son el mismo concepto de negocio. Que la fuente sea SAP, una base de datos o un fichero **es irrelevante** para el concepto.

Corolario: el concepto se mantiene **genérico**, pero **no más genérico de lo necesario** (ver criterio 5). El significado concreto ("facturas de España del proceso de facturación") **no vive en el concepto**, vive en el **rol** y en la **metadata** del binding.

### 2. La gramática del `canonical_id`

Formato `dominio.subdominio.nombre`, en minúsculas y separado por puntos. Los dominios están ordenados por **capa**:

| Capa | Dominios | Qué agrupa |
|------|----------|-----------|
| Infraestructura | `device`, `net`, `hw` | Recursos del sistema, red/conectividad y sensores de hardware |
| Servicios | `svc` | Demonios y *endpoints* persistentes (HTTP, DB, auth, colas…) |
| Automatización | `flow` | Trabajos/lotes/transferencias discretos (tienen inicio y fin) |
| Negocio | `biz` | Contenido y resultado de negocio (importes, items) |
| Transversales | `sec`, `cert` | Seguridad y certificados |

`device` se llamó así (y no `host`) porque es neutro para servidores, routers y switches. El antiguo dominio `env` (temperatura, ventiladores, voltaje) se eliminó: son lecturas de **sensores de un componente hardware**, no de ambiente, así que viven en `hw`. El antiguo `ups` también es `hw` (la clase "SAI" va a metadata).

### 3. Qué *no* va en el concepto (va a metadata o a rol)

Cuatro cosas que **nunca** deben aparecer como segmento del `canonical_id`:

1. **Identidad de la instancia** (qué dispositivo, qué interfaz, qué fichero, qué país). Va al binding (`iid`, `iddev`) o a la metadata del rol.
2. **Clase de dispositivo** (router vs servidor vs SAI). Va a metadata.
3. **Protocolo** cuando la medida es la misma con independencia de él. Ejemplo: descartes de paquetes a nivel de interfaz o de dispositivo son `net.packets.dropped`; el ámbito (interfaz vs dispositivo) es *scope* del binding, no concepto distinto.
4. **Proceso de negocio o tipo de documento** (facturas vs albaranes vs pedidos). Va a rol + metadata. Contar "facturas" no crea un concepto `biz.invoice.*`; el sustantivo es metadata (ver criterio 9).

### 4. La unidad va en el nombre cuando la misma medida existe en varias unidades

Regla: si una misma magnitud se mide en unidades distintas y no son convertibles con un escalar fijo, **la unidad se fija en el nombre**.

- Disco: `device.disk.pct` (porcentaje) y `device.disk.bytes` (bytes) son conceptos distintos, porque sin capacidad no se puede pasar de uno a otro.
- Temperatura: `hw.temperature.celsius` (la unidad se ancla; no se usa un genérico "grados").
- Tiempos: `flow.job.exec_time` se ancla a **minutos**; importes a **euros** (`biz.amount.eur`). No se puede normalizar moneda con un escalar fijo, así que el euro se fija igual que el celsius.

Evitamos el token `min` como abreviatura porque se lee como "mínimo"; usamos la palabra completa (`runtime_minutes`, `last_age_minutes`).

### 5. Atributos del concepto y el principio de unicidad

Cada concepto lleva estos atributos (tabla `sem_canonical_concept`):

- **`category`** ∈ {`availability`, `performance`, `capacity`, `security`, `business_process`} — para agrupar en cuadros de mando.
- **`signal_class`** ∈ {`health_sli`, `saturation`, `diagnostic`} — gobierna la **propagación**: `health_sli` propaga *impacto*, `saturation` propaga *riesgo*, `diagnostic` no propaga por defecto (es contexto para diagnóstico).
- **`direction`** ∈ {`higher_is_worse`, `lower_is_worse`, `out_of_band`} — sentido de la degradación. `out_of_band` para estados y para magnitudes cuyo "bueno/malo" se define respecto a un objetivo (no es monótono).
- **`plausible_min` / `plausible_max`** — rango de sanidad para detectar lecturas absurdas (un porcentaje fuera de 0–100 es un fallo de captura, no una alerta de negocio).
- **`needs_instance_capacity`** — si el valor solo es interpretable conociendo la capacidad de la instancia (p. ej. `bytes` o `bps` necesitan saber el total o el ancho de banda).
- **`is_business`** — marca los conceptos de negocio.

Principio rector: **el `canonical_id` debe determinar unívocamente unit + direction + signal_class**. Si dos métricas con el mismo id necesitaran direcciones distintas, el concepto está mal definido (demasiado genérico). Si dos ids difieren solo en la instancia, sobra granularidad (demasiado específico).

### 6. `value_scale`: conversión a la unidad canónica sin tocar el RRD

Una misma medida puede llegar en escalas distintas (segundos, horas, *timeticks*…). En lugar de crear un concepto por escala, el concepto fija **una unidad canónica** y cada `subtype` lleva un **`value_scale`** (multiplicador del valor crudo/graficado a esa unidad). El RRD y la gráfica **no se tocan**; la capa semántica convierte al leer.

Ejemplos numéricos:

- `flow.job.exec_time`, canónico = **minutos**. Un job que reporta en segundos usa `value_scale = 0.01667` (1/60): 90 s × 0.01667 = **1,5 min**. Uno que reporta en horas usa `value_scale = 60`: 2 h × 60 = **120 min**.
- `device.uptime.days`, canónico = **días**, desde *timeticks* SNMP (1/100 s): `value_scale ≈ 1,1574e-07` (= 1/8.640.000). 8.640.000 ticks × 1,1574e-07 = **1 día**.
- `hw.battery.runtime_minutes`, canónico = **minutos**. Un SAI que reporta en segundos: 600 s × 0,01667 = **10 min**; otro que ya da minutos usa `value_scale = 1`.

### 7. El monitor es la señal clave: una métrica → una medida → un concepto

En CNM, los **monitores** son ~1:1 con las métricas (1.812 de 1.815 tienen exactamente un monitor). Eso significa que **cada métrica mide una sola cosa significativa**, y por tanto le corresponde **un solo concepto**. Cuando una métrica devuelve varios valores (`v1|v2|…`), el monitor revela cuál es la medida y cuáles son **operandos o guardas**:

- Un script que devuelve `DBCount|RC`: si el monitor vigila `RC` (p. ej. `v2 <> 0`), la métrica mide **el éxito de la consulta** → `svc.db.query_status`. Si vigila el valor (`v1`, a menudo con guarda `&& v2 = 0`), la métrica mide el **valor** (un recuento de negocio) y `RC` es solo guarda de "la recogida fue válida".
- El patrón `&& vN = 0` casi siempre es una **guarda de recogida correcta**, no la medida.

Los operandos y guardas **no son conceptos independientes**: no hay que crear un concepto por cada valor de la tupla.

Un apunte importante: el concepto es **intrínseco a lo que se mide**, independiente de que la métrica tenga monitor activo o no. "Sin monitor" significa "ahora mismo no se alerta sobre esto" (una decisión del usuario), y se captura en un eje aparte (`currently_alerted`), **no degrada el concepto**.

### 8. Las capas y la frontera `flow` vs `biz`

`flow` mide **el ejecutor** (¿corrió el job?, ¿cuánto tardó?, ¿falló?, ¿cuántos ficheros movió?). `biz` mide **el contenido o resultado de negocio** (facturas, euros, pedidos). La distinción es real: **un job puede terminar con éxito y aun así producir un resultado de negocio malo** (corrió, pero generó 0 facturas cuando debía generar 5.000). Por eso `flow.job.status = OK` y `biz.item.throughput_count = 0` pueden coexistir, y ambas señales son útiles.

Análogamente, `svc.service.status` (estado de un servicio **persistente**) ≠ `flow.job.status` (estado de un **run discreto**).

### 9. Taxonomía de funciones de conteo (la "cosa" es metadata)

Contar entidades (TPVs, facturas, registros, pedidos, albaranes, errores, líneas…) **no** crea un concepto por sustantivo. La entidad va a metadata/rol; el concepto se diferencia por **la función**, que es la que fija la dirección:

| Función | Significado | Dirección típica |
|---------|-------------|------------------|
| `throughput` | volumen procesado en un periodo | `out_of_band` (objetivo por rol) |
| `pending` | acumulado en espera (*backlog*) | `higher_is_worse` |
| `error` | recuento de fallos | `higher_is_worse` |
| `level` | nivel actual frente a un límite | `saturation` |

Estas cuatro funciones son ortogonales a la capa (existen en `device`, `net`, `svc`, `biz`). No se prefabrica la matriz 4×4 completa (YAGNI); se instancian bajo demanda. Por eso en negocio están en uso `biz.item.throughput_count` y `biz.item.pending_count`, pero todavía no `biz.item.error_count` ni `biz.item.level_count`: se añadirán cuando aparezca una métrica que los necesite.

### 10. El significado de negocio vive en el rol, no en el concepto

El mismo concepto tiene **importancia distinta** según el dispositivo o servicio donde se observe; por eso la importancia **no es** un atributo del concepto. Se deriva del **rol** (`sem_business_role.criticality`) × el peso del binding × el `signal_class`. La dirección de los importes y *throughput* de negocio es `out_of_band` precisamente porque el "bueno/malo" lo fija el objetivo del rol (vender de más no es malo; vender por debajo del objetivo sí), no el concepto.

### 11. Cómo añadir un concepto nuevo (lista de comprobación)

1. ¿Existe ya un concepto que mida **lo mismo**? (prueba de colapso). Si sí, reusar y mandar lo distintivo a metadata/rol.
2. ¿La diferencia que veo es de **instancia, clase de dispositivo, protocolo o documento**? Entonces **no** es concepto nuevo.
3. ¿La unidad obliga a separar (no convertible con escalar)? Entonces va en el nombre.
4. ¿`unit`, `direction` y `signal_class` se siguen unívocamente del id? Si no, el id está mal calibrado.
5. ¿La escala del dato se resuelve con `value_scale`? Entonces no crear variantes por escala.
6. Mapear con `confidence = ai_suggested` si lo propone la IA; **solo** un humano lo pasa a `human_confirmed` antes de producción.

---

## Parte 2 — Catálogo de los 71 conceptos

Notación de las tablas: **cat** = category, **sig** = signal_class, **dir** = direction, **rango** = plausible_min..plausible_max. Los ejemplos son `subtype` reales del repositorio. Distribución por dominio: `svc` 17, `device` 15, `net` 14, `hw` 11, `flow` 6, `biz` 5, `sec` 2, `cert` 1.

### Dominio `device — recursos del sistema` (15 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `device.component.count` | capacity | informative | count | out_of_band | 0..∞ | `mib2_ent_phy_parts`, `socups_num_lines`, `ups_num_lines` |
| `device.cpu.activity` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `xagt_004502`, `xagt_004503`, `xagt_004504` |
| `device.cpu.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `cisco_cpu`, `cpq_cpu_usage`, `custom_2326795c` |
| `device.disk.activity` | performance | diagnostic | iops | higher_is_worse | 0..∞ | `custom_22112831`, `custom_88e6f67f`, `custom_ef98372c` |
| `device.disk.bytes` | capacity | saturation | bytes | higher_is_worse | 0..∞ | `xagt_ac18b2` · needs_capacity |
| `device.disk.latency` | performance | diagnostic | ms | higher_is_worse | 0..∞ | `xagt_004532`, `xagt_004533`, `custom_32767743` |
| `device.disk.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `cpq_disk_usage`, `disk_mibhost`, `disk_mibhostp` |
| `device.load` | performance | saturation | load | higher_is_worse | 0..∞ | `cpq_cpu_interrupts`, `cpq_os_context`, `cpq_os_cpu_queue` |
| `device.memory.activity` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `novell_nw_fs_cache`, `ucd_swap`, `winnt_memory_faults` |
| `device.memory.bytes` | capacity | saturation | bytes | higher_is_worse | 0..∞ | `cisco_memory`, `ucd_mem_buffer`, `ucd_mem_linux` · needs_capacity |
| `device.memory.error_count` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `cisco_buffer_errors` |
| `device.memory.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `cisco_buffer_usage`, `fortigate_lowmem_usage`, `fortigate_mem_usage` |
| `device.process.count` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `cpq_os_processes`, `cpq_os_threads`, `custom_2f2ef5d2` |
| `device.swap.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `juniper_swap_usage` |
| `device.uptime.days` | availability | diagnostic | days | lower_is_worse | 0..∞ | `mib2_uptime`, `xagt_004401` |

Notas de distinción: `device.cpu.pct`/`device.memory.pct`/`device.disk.pct`/`device.swap.pct` son porcentaje de ocupación; `device.disk.bytes` y `device.memory.bytes` son el mismo recurso en **bytes** (necesitan capacidad, `needs_instance_capacity=1`), por eso son conceptos aparte. `device.cpu.activity`, `device.disk.activity`/`device.disk.latency` y `device.memory.activity` son señales de **actividad/rendimiento** (IOPS, ms, faltas de página), distintas del %; sustituyen al antiguo `device.disk.io`, ahora desdoblado en actividad y latencia. `device.memory.error_count` cuenta errores de buffer/memoria. `device.component.count` es inventario (nº de componentes/líneas, `informative`). `device.load` es la cola/carga media, no un %. `device.process.count` cuenta procesos/hilos del SO (no el up/down de un servicio: eso es `svc.service.status`). `device.uptime.days` baja al reiniciar (de ahí `lower_is_worse`).

### Dominio `net — red y conectividad` (14 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `net.bytes.count` | performance | diagnostic | bytes | higher_is_worse | 0..∞ | `pkteer_class_bytes`, `pkteer_class_ret_bytes`, `pkteer_link_bytes` |
| `net.icmp.availability` | availability | health_sli | state | out_of_band | — | `mon_icmp`, `xagt_004020`, `disp_icmp` |
| `net.icmp.latency` | performance | health_sli | ms | higher_is_worse | 0..∞ | `xagt_004021`, `mon_ip_icmp2`, `mon_ip_icmp3` |
| `net.iface.error_count` | availability | diagnostic | count | higher_is_worse | 0..∞ | `errors_mibii_if`, `pkteer_link_pkts_err`, `xagt_004537` |
| `net.iface.status` | availability | health_sli | state | out_of_band | — | `airspace_ap_profiles`, `mib2_glob_duplex`, `mib2_glob_ifstat` |
| `net.iface.traffic_bps` | performance | saturation | bps | higher_is_worse | 0..∞ | `brocade_frames_port`, `fortigate_pol_traffic`, `custom_e0efa9d5` · needs_capacity |
| `net.packets.count` | performance | diagnostic | count | higher_is_worse | 0..∞ | `fortinet_packets`, `netscaler_vsvr_pkts`, `pkteer_class_pkts` |
| `net.packets.dropped` | availability | diagnostic | count | higher_is_worse | 0..∞ | `ip_pkts_discard`, `mib2_ipInAddrErrors`, `mib2_ipOutNoRoutes` |
| `net.radio.signal` | performance | diagnostic | dbm | out_of_band | — | `oneaccess_radio_params` |
| `net.requests.count` | performance | diagnostic | count | higher_is_worse | 0..∞ | `finjan_det_log`, `finjan_ftp_thro`, `finjan_http_thro` |
| `net.routing.events` | performance | diagnostic | count | higher_is_worse | 0..∞ | `enterasys_flow2`, `enterasys_flow3`, `esp_arp_mibii_cnt` |
| `net.routing.status` | availability | health_sli | state | out_of_band | — | `ospf_NbrState`, `stp_port_status` |
| `net.sessions.count` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `airspace_nclients`, `checkpoint_numconex`, `checkpoint_peakconex` |
| `net.sessions.rejected_count` | availability | diagnostic | count | higher_is_worse | 0..∞ | `cisco_ds0_errors`, `cisco_modem_errors` |

Notas de distinción: `net.iface.traffic_bps` mide **bits/s** (saturación, necesita capacidad); `net.bytes.count` cuenta **bytes** acumulados; `net.packets.count` paquetes; `net.packets.dropped` descartes; `net.iface.error_count` errores de trama. `net.sessions.count` cuenta conexiones/sesiones/registros (usuarios logados, teléfonos registrados: gente *como conexión*); `net.sessions.rejected_count` son sesiones/registros **rechazados**. `net.radio.signal` es nivel de señal radio/enlace. `net.icmp.availability` (estado alcanzable/no) y `net.icmp.latency` (ms) son conceptos distintos: la latencia que devuelve `U`/NaN al no responder es señal de "no dato", no una segunda disponibilidad — la alerta de "caído" la posee la disponibilidad, para no duplicar avisos.

### Dominio `svc — servicios y aplicaciones` (17 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `svc.auth.latency` | performance | health_sli | ms | higher_is_worse | 0..∞ | `mon_ldap`, `custom_89a9066c` |
| `svc.cache.hit_pct` | performance | diagnostic | pct | lower_is_worse | 0..100 | `xagt_004101` |
| `svc.db.query_status` | availability | health_sli | code | out_of_band | — | `custom_013d9369`, `custom_04b990d1`, `custom_08241655` |
| `svc.http.availability` | availability | health_sli | state | out_of_band | — | `custom_5477ccef`, `custom_625c29b3`, `custom_6d59c37a` |
| `svc.http.error_count` | availability | diagnostic | count | higher_is_worse | 0..∞ | `httpserver_error_notfound` |
| `svc.http.html_diff_count` | performance | diagnostic | count | higher_is_worse | 0..∞ | `mon_httppage` |
| `svc.http.latency` | performance | health_sli | ms | higher_is_worse | 0..∞ | `mon_http`, `mon_tcp`, `xagt_004010` |
| `svc.http.link_count` | performance | diagnostic | count | out_of_band | 0..∞ | `mon_httplinks` |
| `svc.http.requests` | performance | diagnostic | count | higher_is_worse | 0..∞ | `httpserver_connections`, `httpserver_files_sent`, `httpserver_request_type1` |
| `svc.http.response_code` | availability | health_sli | code | out_of_band | 100..599 | `custom_0760a97c`, `custom_0c448a38`, `custom_1236690d` |
| `svc.license.count` | capacity | saturation | count | higher_is_worse | 0..∞ | `xagt_00451A`, `xagt_00451B` |
| `svc.queue.depth_count` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `xagt_003000` |
| `svc.queue.oldest_age_minutes` | capacity | diagnostic | minutes | higher_is_worse | 0..∞ | `ironport_oldest_message` |
| `svc.resource.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `xagt_004100`, `xagt_004102` |
| `svc.service.status` | availability | health_sli | state | out_of_band | — | `apc_comm_status`, `brocade_status_port`, `cisco_vlan_sum` |
| `svc.tcpip.latency` | performance | health_sli | ms | higher_is_worse | 0..∞ | `dial_peer_ctime`, `custom_9a90db14`, `custom_c90ef07a` |
| `svc.update.count` | performance | informative | count | out_of_band | 0..∞ | `ironport_update_rate` |

Notas de distinción: `svc.service.status` es el up/down de un servicio/función persistente; todo corre sobre un dispositivo, pero la función de servicio es `svc`, no `device`. `svc.http.response_code` es el **código** (200/302…); `svc.http.availability` un estado **cocinado** arriba/abajo; `svc.http.latency` el tiempo; `svc.http.requests` (throughput neutro) ≠ `svc.http.error_count` (malo); `svc.http.link_count`/`svc.http.html_diff_count` vigilan cambios/roturas de contenido web. `svc.db.query_status` mide el **éxito** de una consulta (RC), no el valor. `svc.cache.hit_pct` (acierto de caché) y `svc.resource.pct` (uso genérico de recurso de servicio) son porcentajes; `svc.license.count`/`svc.update.count` cuentan licencias/actualizaciones pendientes. `svc.queue.depth_count` (profundidad de cola) y `svc.queue.oldest_age_minutes` (antigüedad del más viejo, frescura de *backlog*) son distintos. `svc.tcpip.latency`/`svc.auth.latency` son latencias de protocolo/autenticación.

### Dominio `flow — automatización, lotes y transferencias` (6 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `flow.file.count` | capacity | diagnostic | count | higher_is_worse | 0..∞ | `custom_0214adb0`, `custom_0302c327`, `custom_0342e42d` |
| `flow.file.last_age_minutes` | capacity | diagnostic | minutes | higher_is_worse | 0..∞ | `custom_2382d87f`, `custom_2b888789`, `custom_35fffd68` |
| `flow.job.error_count` | availability | diagnostic | count | higher_is_worse | 0..∞ | `custom_011ea9ef`, `custom_043611d1`, `custom_044180b2` |
| `flow.job.exec_time` | performance | diagnostic | minutes | higher_is_worse | 0..∞ | `custom_00ee5b34`, `custom_046c3f89`, `custom_06b4eb95` |
| `flow.job.last_state_age_minutes` | availability | diagnostic | minutes | higher_is_worse | 0..∞ | `Time since job last known state (minutes)` |
| `flow.job.status` | availability | health_sli | state | out_of_band | — | `custom_000fbd47`, `custom_00186987`, `custom_00277416` |

Notas: `flow.job.status` es el resultado de ejecución de un *run* discreto (el más poblado). `flow.job.exec_time` es **un único concepto** con unidad canónica minutos y `value_scale` por subtype. `flow.job.last_state_age_minutes` es la **frescura del último estado** de un job (cuánto hace que se sabe algo de él). `flow.file.count`/`flow.file.last_age_minutes` cuentan/fechan transferencias de fichero. Frontera del criterio 8: `flow.job.error_count` es error **de ejecución**; si contara registros de negocio rechazados sería `biz.item.error_count`.

### Dominio `hw — sensores de hardware` (11 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `hw.battery.charge_pct` | capacity | saturation | pct | lower_is_worse | 0..100 | `socups_charge_remaining`, `ups_charge_estimate` |
| `hw.battery.runtime_minutes` | capacity | diagnostic | minutes | lower_is_worse | 0..∞ | `apc_bat_time`, `socups_battery_usage`, `socups_time_remaining` |
| `hw.component.status` | availability | health_sli | state | out_of_band | — | `airspace_ap_status`, `apc_bat_status`, `cisco_fan_state` |
| `hw.current.amps` | capacity | diagnostic | amps | higher_is_worse | 0..∞ | `socups_byp_current`, `socups_in_current`, `socups_out_current` |
| `hw.fan.rpm` | capacity | diagnostic | rpm | lower_is_worse | 0..∞ | `f5big_chas_fans`, `f5big_cpu_fans`, `ironport_fanrpms1` |
| `hw.frequency.hz` | capacity | diagnostic | hz | out_of_band | — | `ups_in_freq` |
| `hw.load.pct` | capacity | saturation | pct | higher_is_worse | 0..100 | `apc_load`, `cpq_powersup_capacity`, `socups_out_load_perc` |
| `hw.poe.class` | capacity | informative | class | out_of_band | — | `poe_class_types` |
| `hw.power.watts` | capacity | diagnostic | watts | higher_is_worse | 0..∞ | `poe_pse_usage`, `poe_pse_usagep`, `ups_byp_power` |
| `hw.temperature.celsius` | capacity | saturation | celsius | higher_is_worse | -20..120 | `apc_temperature`, `f5big_chas_temp`, `f5big_cpu_temp` |
| `hw.voltage.volts` | capacity | diagnostic | volts | out_of_band | — | `apc_voltage`, `cisco_voltage_state`, `socups_byp_voltage` |

Notas de distinción: ojo a **valor** vs **estado**: `hw.temperature.celsius` son grados, pero muchas métricas con "TEMP"/"VOLT" devuelven un **estado** (Ok/Warn/Fail) y entonces son `hw.component.status`. `hw.voltage.volts`/`hw.current.amps`/`hw.power.watts`/`hw.frequency.hz` son magnitudes eléctricas; `hw.load.pct` es carga de una unidad hardware; `hw.poe.class` la clase PoE del puerto. `hw.fan.rpm` es `lower_is_worse` (ventilador parado = fallo) pero `diagnostic`, así que la dirección es orientativa. `hw.battery.charge_pct` (carga %) y `hw.battery.runtime_minutes` (autonomía) son distintos, ambos `lower_is_worse`.

### Dominio `biz — negocio` (5 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `biz.amount.eur` | business_process | diagnostic | eur | out_of_band | — | `custom_022f06d0`, `custom_08eeb076`, `custom_09ed36fe` · is_business |
| `biz.item.error_count` | business_process | diagnostic | count | higher_is_worse | 0..∞ | `custom_3f0c5fe9`, `custom_46777236`, `custom_810e0bcc` · is_business |
| `biz.item.level_count` | business_process | diagnostic | count | out_of_band | 0..∞ | `custom_04c39f4a`, `custom_09f785fc`, `custom_0e8d5291` · is_business |
| `biz.item.pending_count` | business_process | diagnostic | count | higher_is_worse | 0..∞ | `custom_948506fa`, `custom_9e526705`, `custom_a6a332ec` · is_business |
| `biz.item.throughput_count` | business_process | diagnostic | count | out_of_band | 0..∞ | `custom_00947acf`, `custom_016728d6`, `custom_224f144b` · is_business |

Notas: todos los importes monetarios son **un solo concepto** `biz.amount.eur`; el rol (venta/compra) y la dirección respecto al objetivo van en rol+metadata. `biz.item.*` generaliza cualquier entidad contable (el sustantivo —factura, TPV, pedido— es metadata; la **función** fija la dirección): `throughput_count` (flujo, `out_of_band`), `pending_count` (backlog, `higher_is_worse`), `level_count` (nivel/stock, `out_of_band`), `error_count` (rechazos de negocio, `higher_is_worse`). Todos `is_business=1`.

### Dominio `sec — seguridad` (2 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `sec.requests.blocked` | security | diagnostic | count | higher_is_worse | 0..∞ | `finjan_det_block`, `finjan_ftp_block`, `finjan_ftp_block_det` |
| `sec.threat.count` | security | diagnostic | count | higher_is_worse | 0..∞ | `fortinet_attacks`, `fortinet_virus`, `tip_alerts_proto` |

Notas de distinción: en un dispositivo de seguridad, el total de peticiones procesadas es `net.requests.count`; las **bloqueadas/denegadas** son `sec.requests.blocked`; amenazas/virus/ataques detectados son `sec.threat.count`. Lo que decide cuál aplica es qué umbral vigila el monitor.

### Dominio `cert — certificados` (1 conceptos)

| canonical_id | cat | sig | unit | dir | rango | ejemplos |
|---|---|---|---|---|---|---|
| `cert.expiry.days` | security | health_sli | days | lower_is_worse | 0..∞ | `custom_1ece67dc`, `custom_2bd06f24`, `custom_4273a9a0` |

Notas: `cert.expiry.days` es `lower_is_worse` (cuantos menos días quedan, peor): es la señal de salud que dispara la renovación.

---

## Resumen

71 conceptos cubren el repositorio de métricas (~2.730 mapeos subtype→concepto). La carga es muy desigual: en la revisión, un puñado de conceptos —`flow.job.status`, `svc.service.status`, `flow.job.error_count`, `flow.file.count`— concentraban la mayor parte de las métricas, lo que confirma que el volumen es una guía de *esfuerzo de revisión*, no de importancia: conceptos con una sola métrica (`net.icmp.latency`, `svc.queue.oldest_age_minutes`) pueden ser críticos para un servicio concreto. La importancia real se deriva del rol al que se ata cada métrica, no del concepto ni de su volumen.
