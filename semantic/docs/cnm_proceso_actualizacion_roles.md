# CNM · Proceso de actualización de la capa semántica (roles)

Cómo se cambian los datos semánticos sin romper nada, iteración tras iteración.
Este documento es **normativo**: si algo se hace de otra forma, acabaremos con
versiones divergentes y cambios irreproducibles.

---

## 1. El principio que lo gobierna todo

> **El fichero maestro (`cnm_roles_maestro.xlsx`) es la ÚNICA fuente de verdad.**
> La tabla `sem_business_role` de CNM es un **derivado** que se regenera desde él.

Consecuencia práctica, y es la regla que más disciplina exige:

**Nunca se edita `sem_business_role` directamente en la base de datos.** Un cambio
hecho a mano en SQL sobrevive hasta la siguiente carga y entonces **desaparece sin
avisar**, porque el generador reimpone lo que dice el maestro. Si hace falta cambiar
algo, se cambia en el maestro y se recarga.

El mismo principio aplica al resto de la capa: `sem_org_unit` se gobierna desde
`cnm_org_unit_elicitacion.xlsx`, y el anclaje `col7` desde su propia propuesta.

---

## 2. El ciclo de iteración

Cada ronda de cambios sigue **siempre** estos siete pasos. Ninguno es opcional.

```
   [1] EDITAR          maestro.xlsx  (solo columnas de esta iteración)
        │
   [2] EXPORTAR        maestro.xlsx → maestro.csv (latin1)
        │              se valida y se carga el MISMO fichero: sin traducciones
   [3] VALIDAR         perl cnm_validar_maestro.pl --csv maestro.csv
        │              → errores duros, avisos, cobertura
        │              ✗ si hay errores duros: volver a [1]
   [4] DIFF            perl cnm_validar_maestro.pl --csv maestro.csv \
        │                   --diff historico/cnm_roles_maestro_AAAAMMDD.csv
        │              → ¿los cambios son EXACTAMENTE los que esperaba?
   [5] DRY-RUN         perl cnm_generate_roles.pl --csv maestro.csv  (SIN --commit)
        │              → segunda puerta: integridad contra la BD real
   [6] CARGAR          onm_copia --commit → verificar → producción --commit
        │
   [7] ARCHIVAR        cnm_archivar_maestro.sh --nota "..."
```

**Las dos puertas de calidad** son distintas y complementarias: el **validador**
(paso 3) mira el fichero *en sí* —lo que el cliente ha editado— y el **generador**
(paso 5) lo contrasta *contra la BD*. Pasar la primera no garantiza la segunda.

Ambos son **Perl y comparten dependencia** (`Text::CSV`), y ambos leen **el mismo CSV**: se valida exactamente el artefacto que se carga, sin pasos de traducción donde puedan esconderse errores.

### Por qué el paso 4 (diff) no se salta nunca

Es la única defensa contra el error más peligroso de este proceso: **cambios
involuntarios**. Un filtro mal aplicado en Excel, un arrastre de celda, un
copiar-pegar desplazado… y modificas 300 filas sin saberlo. El diff te dice
exactamente qué campos han cambiado y en cuántos roles. Si el número no cuadra con
lo que hiciste, **para y revisa**.

---

## 3. El validador en detalle (primera puerta)

`cnm_validar_maestro.pl` — Perl + `Text::CSV` (la misma dependencia que el generador).

### 3.1 Qué lee exactamente

**Solo el CSV que se le pasa con `--csv`**, que debe ser la exportación de la hoja
`sem_business_role (maestro)`. El resto de hojas del libro (leyenda, pendientes,
criticidad propuesta) son **ayudas de trabajo**: no se exportan, no se validan y no se cargan.

La función `cargar()` hace tres cosas que conviene conocer:

- **Elimina el BOM de la cabecera.** Excel suele anteponer un carácter invisible
  (`\x{feff}`); sin quitarlo, la primera columna se llamaría `\x{feff}role_id` y **todas
  las comprobaciones sobre `role_id` fallarían en cascada**.
- **Indexa por NOMBRE de columna, no por posición.** Cada fila se convierte en un hash
  `{ 'role_id' => ..., 'geography' => ... }`. Consecuencias prácticas: **el orden de las
  columnas es indiferente** (se pueden reordenar en Excel) y **las columnas desconocidas se
  ignoran sin protestar** (`n_dispositivos`, `familia`, `notas_generacion`, `brand`…).
- **Salta filas totalmente vacías** y hace `trim` de todos los valores, de modo que un
  espacio accidental al final de una celda no genera falsos positivos.

### 3.2 Bloque 1 — Errores duros (impiden cargar)

Son los que harían abortar al generador. Por fila:

| Comprobación | Por qué es error duro |
|---|---|
| `role_id` vacío o **duplicado** | Es la clave; sin ella no hay upsert posible |
| `role_type` fuera de los 5 válidos | El ENUM de la tabla lo rechazaría |
| `status` fuera de `draft/active/deprecated/archived` | Ídem |
| `criticality` fuera de 1-5 | Ídem |
| Campos obligatorios vacíos (`@CLAVE`) | `role_id`, `role_type`, `display_name`, `domain`, `environment`, `status` |

Y dos comprobaciones que necesitan el fichero **entero**, no fila a fila:

- **`parent_role_id` inexistente**: se construye el conjunto de todos los `role_id` y se
  verifica que cada padre referenciado existe. Es lo que caza la errata al escribir un padre.
- **Auto-referencia y ciclos**: un rol que es su propio padre, o cadenas circulares (A→B→A).
  La detección recorre hacia arriba la cadena de padres desde cada rol marcando lo visitado;
  si repite nodo, hay ciclo (con tope de 100 saltos como red de seguridad). **Un ciclo
  colgaría cualquier recorrido del árbol** en la interfaz o en el job de binding.

### 3.3 Bloque 2 — Avisos (cargaría, pero el dato sería malo)

Aquí está el valor añadido respecto a la puerta del generador: son cosas
**sintácticamente válidas pero semánticamente inútiles**.

- **Roles sin `geography`** — regla del proyecto: nunca vacío (ISO-2 o `WW`).
- **`geography` fuera del vocabulario cerrado** — si alguien escribe `SP` en vez de `ES`, o
  `EU` (descartado), la BD lo aceptaría tal cual y **rompería el filtrado sin avisar**.
- **`criticality` constante** — si todas las filas tienen el mismo valor, el campo no
  discrimina y **anula la ponderación de severidad** de las señales (§6.6 de la arquitectura).
- **Filas `__dup`** — crítico: el generador **las excluye en silencio**; sin este aviso, un
  rol desaparecería del resultado sin ningún mensaje.
- **`owner` vacío en todas** — recordatorio de la dependencia con `sem_org_unit`.
- **Sites sin `parent`** — quedan fuera de la jerarquía de composición.
- **Roles en `draft`** — recordatorio de la decisión pendiente sobre qué consume v1.

### 3.4 Bloque 3 — Cobertura y reparto (seguimiento entre iteraciones)

No juzga, **mide**: por cada columna, cuántas filas la tienen rellena, con una barra.
Permite ver el avance entre iteraciones de un vistazo (`geography 470/556 84%`). El reparto
de valores de `role_type`, `status`, `geography` y `criticality` detecta anomalías de golpe.

### 3.5 El diff (`--diff`) — la protección más importante

Carga el CSV de la iteración anterior y compara **por `role_id`**:

- **Roles nuevos** y **roles quitados**. En los quitados avisa expresamente de que
  **quitar la fila NO borra el rol en BD** (el error conceptual más peligroso del proceso).
- **Roles modificados**, con el **desglose por columna**: cuántas filas cambiaron en cada
  campo y un ejemplo concreto (`app.agora: '5' -> '3'`).

Ese desglose es el corazón de la protección: si editaste 20 geografías y el diff dice
*"geography: 340 cambios"*, **algo ha ido mal** —un filtro mal aplicado, un arrastre de
celda— y paras **antes** de tocar la BD.

### 3.6 Código de salida

`0` si no hay errores duros, `1` si los hay. Pensado para encadenar:

```bash
perl cnm_validar_maestro.pl --csv maestro.csv && \
perl cnm_generate_roles.pl  --csv maestro.csv --db onm_copia --user U --pass P
```
Así el generador **ni se lanza** si el fichero está mal.

### 3.7 Lo que NO hace (sus límites)

- **No toca la base de datos.** No sabe qué hay cargado ni qué cambiaría: eso es el dry-run
  del generador. **Pasar el validador no garantiza que la carga vaya bien.**
- **No valida `owner`** contra `sem_org_unit` (no existe el catálogo aún). Cuando exista, es
  una comprobación fácil de añadir y conviene hacerlo.
- **No detecta errores de criterio.** Un rol bien formado pero **mal clasificado** (una
  aplicación marcada como `technical_service`, una geografía `ES` que debería ser `WW`) pasa
  sin más: es sintácticamente perfecto. Eso solo lo caza la revisión humana — para eso existe
  la columna `Validación`.
- **No comprueba la codificación.** Si se exporta en UTF-8 en vez de latin1, lo leerá
  (Text::CSV en modo binario) pero los acentos pueden acabar mal en la BD. Ese control es del
  operador al exportar.

> **Separador: autodetectado.** Excel en configuración regional española exporta con **`;`**
> y en inglesa con `,`. Tanto el validador como el generador **detectan el separador de la
> cabecera**, así que da igual con cuál se exporte. (Antes no era así: un CSV con `;` se leía
> como *una sola columna* y producía un aluvión de errores falsos — lo detectó el validador
> en la primera iteración real, antes de tocar la BD.)

> Detalle menor: un rol que es su propio padre genera **dos** errores (auto-referencia y
> ciclo). Es redundante pero inofensivo: mejor que sobre información a que falte.

---

## 4. Garantías que ya da el generador (segunda puerta)

Lo que **sí** está protegido:

- **Upsert idempotente por `role_id`**: cargar dos veces el mismo fichero no duplica
  ni cambia nada la segunda vez.
- **No pisa con blancos**: una celda vacía **no borra** el valor que ya está en BD.
  Protege el trabajo previo (especialmente los campos de enriquecimiento).
- **Puerta de integridad antes de tocar la BD**: aborta si hay errores duros, sin
  dejar cambios a medias.
- **Dos pasadas** para resolver `parent_role_id` (auto-referencia).
- **Transaccional + `change_log` + `sem_load_audit`**: todo cambio queda registrado y
  es reversible.
- **Excluye filas `__dup`** automáticamente.

Lo que **no** hace, y hay que tener presente:

- **No valida `owner`** (no hay FK a `sem_org_unit`): un owner mal escrito entra tal cual.
- **No borra roles**: quitar una fila del maestro **no** elimina el rol en BD (ver §5.3).
- **No avisa de las `__dup`**: las excluye en silencio, así que el rol desaparece del
  resultado sin mensaje. El validador sí las señala.
- **No detecta cambios de significado**: si reutilizas un `role_id` para otra cosa,
  el generador lo trata como una simple actualización.

---

## 5. Cómo se hace cada tipo de cambio

### 5.1 Añadir un rol nuevo
Añadir la fila al maestro con `role_id` único y los campos obligatorios
(`role_type`, `display_name`, `domain`, `environment`, `status`, `geography`).
Si cuelga de otro, `parent_role_id` debe existir ya en el fichero.

### 5.2 Modificar un rol
Editar la celda. El upsert lo actualiza. **Excepción: `role_id` no se edita nunca**
(ver 5.4).

### 5.3 Retirar un rol
**No borrar la fila.** Poner `status = deprecated`. Motivos: se conserva el
histórico y la trazabilidad, los bindings antiguos siguen resolviendo, y borrar la
fila **no elimina nada en BD** (el rol seguiría ahí, huérfano y sin mantenimiento).

> Si de verdad hay que eliminarlo de la BD, es una operación **manual y deliberada**,
> con backup previo, y se documenta en el histórico de la iteración.

### 5.4 Renombrar un `role_id`
`role_id` es la **clave de identidad**: no se renombra ni se reutiliza. Si cambia el
identificador, para el sistema es **otro rol**. Procedimiento: crear el rol nuevo y
marcar el viejo como `deprecated`. Renombrar en el maestro sin más crearía un rol
duplicado y dejaría el antiguo vivo y sin dueño.

Para cambiar solo la etiqueta visible, se edita `display_name` (eso sí es libre).

### 5.5 Cambiar la jerarquía
Editar `parent_role_id`. El validador comprueba que el padre existe y que no se crean
**ciclos**. Un rol sin padre es una raíz legítima.

### 5.6 Rellenar campos por lotes (el caso habitual)
Al rellenar `geography` u `owner` en masa: usar la hoja de pendientes correspondiente
para trabajar cómodo, volcar al maestro, y **confirmar con el diff** (paso 4) que solo
ha cambiado esa columna y en el número de filas esperado.

---

## 6. Versionado, layout de directorios y archivado

### 6.1 Layout: código y datos separados

La capa semántica **depende de cada cliente**, así que hay tres capas distintas y
confundirlas es el error a evitar:

| Capa | Qué es | Dónde vive | ¿Al repo? |
|---|---|---|---|
| **Producto** | Validador, generador, esquema, plantillas, docs | `/opt/cnm/semantic` | **Sí** |
| **Configuración** | Países, filtro de servidores, BD (`semantic.conf`) | `/opt/data/semantic` | Solo el `.example` |
| **Datos** | Maestro, histórico, backups, logs | `/opt/data/semantic` | **Nunca** |

> **Regla para decidir:** *si es el resultado de mirar la instalación del cliente, es
> dato; si es lo que sabe mirarla, es producto.* El script que extrae el diccionario de
> estados es producto; el volcado con los 626 subtypes de este cliente, no.

```
/opt/cnm/semantic/            CODIGO (repo; se actualiza con el producto)
├── bin/                        CNMSemanticConf.pm, validador, generador,
│                               archivador, col8
├── schema/                     cnm_semantic_schema_v3.sql
├── templates/                  cnm_roles_maestro_PLANTILLA.xlsx (vacia)
├── docs/                       guias y este runbook
└── semantic.conf.example

/opt/data/semantic/           DATOS DEL CLIENTE (nunca en el repo publico)
├── semantic.conf               config de esta instalacion
├── cnm_roles_maestro.xlsx      fichero VIVO (el que se edita)
├── cnm_roles_maestro.csv       export actual (lo que se valida y se carga)
├── historico/                  versiones cargadas + ultima_cargada.csv + registro_cargas.txt
├── backup/                     dumps puntuales de sem_business_role
└── log/                        salida del validador y del generador por carga
```

Sigue la convención que ya usa CNM (código en `/opt/cnm`, datos en `/opt/data`, como el
crawler y sus RRD) y tiene una ventaja concreta: **actualizar el producto no puede tocar
el trabajo semántico del cliente**, y reinstalar el código no destruye el maestro.

- **Un solo fichero vivo**: `cnm_roles_maestro.xlsx`. Nada de `maestro_final_v3_bueno.xlsx`.
- Rutas **sin acentos ni espacios** (el host de CNM es Debian 8, charset latin1).

### 6.1.1 Lo específico del cliente va en `semantic.conf`, no en el código

El vocabulario geográfico, el filtro que identifica un servidor o el nombre de la BD son
**distintos en cada instalación**. Si van incrustados en el código, el tooling deja de ser
producto. Se declaran en `semantic.conf` y los scripts lo localizan solo
(`/opt/data/semantic/semantic.conf`, `--conf <ruta>` o `$CNM_SEMANTIC_CONF`):

```
geography_vocab  = WW,ES,FR,US,DE,PT,MX     # solo paises a los que se da servicio
server_type_like = %erver%                  # que 'type' es un servidor (col8)
db_name          = onm
data_dir         = /opt/data/semantic
```

En cambio `role_type` y `status` **no** son configurables: salen del ENUM del esquema y
son iguales para todos los clientes. La frontera es nítida — *lo que viene del DDL es
producto; lo que viene de la realidad del cliente es configuración*.

### 6.2 Cuándo se archiva

**Justo después de un `--commit` con éxito, nunca antes.** `historico/` no es un "por si
acaso": es el **registro de lo que está realmente en la base de datos** y la referencia
contra la que se hará el `--diff` de la próxima iteración. Archivar antes de cargar haría
que el histórico mintiera si la carga fallara.

### 6.3 Cómo se archiva

```bash
cd /opt/data/semantic
bash /opt/cnm/semantic/bin/cnm_archivar_maestro.sh --nota "carga inicial roles v1"
```

El script copia el CSV y el xlsx a `historico/` con marca de tiempo, actualiza el symlink
y añade una línea al registro. Tres decisiones detrás:

- **Marca de tiempo con hora** (`AAAAMMDD_HHMM`), no solo fecha: con muchas iteraciones,
  dos cargas el mismo día son normales y la segunda pisaría a la primera.
- **Se archiva el CSV exacto que se cargó**, no uno re-exportado después: un re-export
  puede diferir en detalles (orden, comillas, formato) y produciría **cambios fantasma**
  en el diff siguiente.
- **Se archivan los dos ficheros**: el CSV porque es lo que se cargó y lo que compara el
  diff; el xlsx porque es lo que se edita (si hay que retroceder, se quiere el libro con
  sus hojas y formato, no solo los datos planos).

### 6.4 El symlink `ultima_cargada.csv`

Hace que el diff se invoque **siempre igual**, sin recordar el nombre de la última versión:

```bash
perl $BIN/cnm_validar_maestro.pl --csv cnm_roles_maestro.csv \
     --diff historico/ultima_cargada.csv
```

### 6.5 El xlsx vive en dos sitios (fricción a resolver)

El **xlsx se edita en Excel** (PC del cliente o propio) pero el **CSV se carga desde el host
de CNM**. Eso crea el riesgo de dos copias divergentes del fichero vivo, justo lo que el
principio de fuente única quiere evitar. Dos formas de resolverlo:

- **El directorio es la referencia** (recomendado si hay muchas iteraciones): se edita el
  xlsx **desde** `/opt/cnm/semantic/` por samba/sshfs/recurso compartido. Solo hay un
  fichero vivo, físicamente.
- **Ida y vuelta disciplinada**: se edita en el PC y al terminar se suben **ambos** ficheros
  antes de validar. Funciona, pero si solo se sube el CSV, el xlsx del host queda desfasado
  y el histórico guardará un libro que no corresponde al CSV cargado. *(El script avisa si
  no encuentra el xlsx.)*

### 6.6 Cuánto se guarda

**Todo.** Cada versión son unos cientos de KB: el coste es irrelevante frente a poder
reconstruir qué se cargó y cuándo. El `log/` con la salida del validador y del generador
complementa al `change_log` de la BD como evidencia de cada carga.

### 6.7 Seguimiento de la revisión

- **La columna `Validación`** lleva el avance:
  `PENDIENTE` (sin revisar) · `OK` (revisado y correcto) · `REVISAR` (hay algo que discutir,
  explicado en `Comentarios`).
- **`notas_generacion`** contiene las pistas automáticas de nuestro tooling. Es
  informativa, no se carga, y no debe usarse para el seguimiento (para eso está `Validación`).

---

## 7. Deriva entre el maestro y la BD

Si alguien hubiera tocado la BD a mano (no debería), el maestro y `sem_business_role`
**divergen en silencio**. Cómo detectarlo y resolverlo:

1. **Detección**: el dry-run del generador muestra cambios que nadie ha hecho en el
   maestro. Esa es la señal.
2. **Investigación**: `change_log` / `sem_load_audit` dicen qué cambió y cuándo.
3. **Resolución**: decidir cuál es la verdad. Por norma, **gana el maestro**; si el
   cambio hecho en BD era correcto, se **incorpora al maestro** y se recarga (así el
   maestro vuelve a ser la fuente única).

---

## 8. Vuelta atrás

- **Antes de un `--commit` en producción**: backup de la tabla
  (`CREATE TABLE sem_business_role_bak_AAAAMMDD AS SELECT * FROM sem_business_role;`).
- **Si la carga falla a medias**: no hace falta hacer nada, la transacción hace rollback.
- **Si la carga fue bien pero el resultado no es el esperado**: recuperar el maestro
  archivado de la iteración anterior y recargarlo (el upsert deja la tabla como estaba),
  o restaurar del backup.
- **`change_log`** permite reconstruir qué cambió en cada carga.

---

## 9. Errores que hay que evitar

| Error | Por qué duele |
|---|---|
| Editar `sem_business_role` en SQL | Se pierde en la siguiente carga, sin aviso |
| Borrar filas del maestro para "quitar" roles | No borra nada en BD; deja roles huérfanos |
| Reutilizar o renombrar un `role_id` | Rompe la identidad: bindings e histórico apuntan a otra cosa |
| Cargar sin mirar el diff | Cambios masivos involuntarios (arrastres de Excel) |
| Cargar directo a producción | Sin ensayo en `onm_copia` no hay red de seguridad |
| Trabajar sobre una copia del maestro | Dos fuentes de verdad = divergencia garantizada |
| Rellenar `owner` sin catálogo | Texto libre incoherente (el problema de `col1` otra vez) |

---

## 10. Variante: carga directa a producción (con red de seguridad)

El ciclo estándar ensaya en `onm_copia` antes de tocar `onm`. Existe una variante
**aceptable en casos concretos**: cargar directamente en `onm` de producción,
saltándose la copia intermedia. Es más operativo, pero solo es defendible bajo
condiciones estrictas.

### 10.1 Cuándo es aceptable

Cuando la carga es **aditiva y aislada**: las tablas `sem_*` son nuevas y **ningún
proceso vivo de CNM las consume todavía** (ni el crawler, ni el motor de alertas, ni
la interfaz). El generador solo hace `INSERT/UPDATE` sobre `sem_business_role` y **no
toca ninguna tabla del CNM operativo** (`devices`, `metrics`, RRD, alertas). Si la
carga saliera mal, lo inconsistente es una tabla que aún nadie lee → *blast radius*
prácticamente nulo.

### 10.2 Cuándo NO es aceptable

- Cuando la operación escribe en **tablas vivas** que el CNM operativo usa —el caso
  de aplicar `col7` sobre `devices_custom_data`—. Ahí se ensaya en copia, sin excepción.
- Cuando **algún consumidor ya lee `sem_*`** (interfaz nueva, job de binding, IA). A
  partir de ese momento, cada `--commit` es un cambio en producción **en caliente** y
  visible al instante; la copia intermedia vuelve a ser obligatoria.

### 10.3 Secuencia mínima de seguridad

Saltarse la copia **no** elimina ningún control; los reubica sobre producción:

```bash
# 1. validar (primera puerta)
perl cnm_validar_maestro.pl --csv cnm_roles_maestro.csv

# 2. confirmar que el esquema sem_* existe en produccion
mysql onm -e "SHOW TABLES LIKE 'sem_%'"

# 3. backup PUNTUAL de la tabla (rapido de restaurar; no confiar solo en el dump completo)
mysql onm -e "CREATE TABLE IF NOT EXISTS sem_business_role_bak_$(date +%Y%m%d) \
              AS SELECT * FROM sem_business_role"

# 4. DIFF contra la ultima version cargada (imprescindible: no hay copia donde descubrir sorpresas)
perl cnm_validar_maestro.pl --csv cnm_roles_maestro.csv --diff historico/<anterior>.csv

# 5. DRY-RUN contra produccion (NO escribe: es el sustituto del ensayo en copia)
perl cnm_generate_roles.pl --db-name onm --db-user U --db-pass P \
     --file cnm_roles_maestro.csv --operator tu_nombre --note "carga inicial"

# 6. revisar el resumen (altas/updates/errores/__dup excluido). Si cuadra:
perl cnm_generate_roles.pl --db-name onm --db-user U --db-pass P \
     --file cnm_roles_maestro.csv --operator tu_nombre --note "carga inicial v1" --commit

# 7. verificar y archivar (paso 7 del ciclo)
```

### 10.4 Los dos controles que NO se saltan nunca

- **Dry-run**: su valor no era "no tocar producción", era **ver qué va a pasar antes
  de que pase**. Se conserva ejecutando el generador sin `--commit` contra `onm`.
- **Diff**: al no haber copia intermedia, es la única defensa contra un cambio masivo
  involuntario. Aquí es **más** importante, no menos.

### 10.5 Si algo sale mal

La idempotencia del generador (upsert por `role_id`, no pisa con blancos) permite
**corregir el maestro y recargar** sin duplicar. Si hace falta revertir del todo:
`TRUNCATE sem_business_role; INSERT INTO sem_business_role SELECT * FROM sem_business_role_bak_AAAAMMDD;`
— sin tocar el resto de `onm`.

---

## 11. Resumen operativo

```bash
cd /opt/data/semantic            # DATOS del cliente
BIN=/opt/cnm/semantic/bin        # CODIGO (repo)

# 1-2. editar el xlsx y exportar a CSV latin1
#      (Excel: "CSV (delimitado por comas)", codificación Europa Occidental / ISO-8859-1;
#       el separador ; o , se autodetecta)

# 3. validar el CSV que se va a cargar
perl $BIN/cnm_validar_maestro.pl --csv cnm_roles_maestro.csv

# 4. diff contra la última versión cargada  (PASO OBLIGATORIO)
perl $BIN/cnm_validar_maestro.pl --csv cnm_roles_maestro.csv \
     --diff historico/ultima_cargada.csv

# 5. dry-run (no toca la BD)
perl $BIN/cnm_generate_roles.pl --db-name onm --db-user U --db-pass P \
     --file cnm_roles_maestro.csv --operator tu_nombre --note "descripcion"

# 6. cargar (ver §10 si es directo a produccion)
perl $BIN/cnm_generate_roles.pl --db-name onm --db-user U --db-pass P \
     --file cnm_roles_maestro.csv --operator tu_nombre --note "descripcion" --commit

# 7. archivar la versión cargada (CSV + xlsx + symlink + registro)
bash $BIN/cnm_archivar_maestro.sh --nota "descripcion del cambio"
```
