# cnm-control

Configuración declarativa de CNM: se describe **cómo debe quedar** y la herramienta
calcula la diferencia con la base de datos `onm`, la enseña (`plan`) y la aplica
(`apply`). El diseño, las decisiones y el plan de trabajo están en `cnm-docs`,
`70-Proyectos/cnm-control/PROY-CNM-cnm-control-Diseno`. El estilo del código sigue
`REF-CNM-Estilo-Scripts`: nombres y comentarios en inglés; ayuda y mensajes en
español, sin tildes.

**Estado: esqueleto v0.1.** Clases `view` (solo comprueba que existe),
`device` (alta) y `metric` (solo latencia: provisión, `c_label` y asociación a
vistas estáticas). Sin plan guardado, cola, auditoría ni borrados.

## Estructura

```
/opt/cnm/control/
  bin/cnm-control                   orden de línea de órdenes
  lib/CNMControl/Core.pm            registro de clases, validación, plan y aplicación
  lib/CNMControl/Profile.pm         perfil + inventario  =>  estado deseado
  lib/CNMControl/Kind/*.pm          una clase por tipo de objeto de CNM (View, Device, Metric)
  profiles/                         perfiles del producto (los de la instalación van en
                                    /cfg/cnm-control/profiles; con el mismo nombre, manda ese)
  t/CTL_*.t                         pruebas sin base de datos
```

Cada clase implementa `order`, `validate`, `key`, `read`, `diff` y `apply` (ver la
cabecera de `Core.pm`). Añadir una clase es un módulo y una línea en `%KINDS`.

## Formato

Las claves de los ficheros y los nombres de clase van en inglés, como en
`CNM-METRICS`:

```json
{ "version": 1,
  "resources": [
    { "kind": "view",   "name": "Tiendas" },
    { "kind": "device", "name": "tda-01", "domain": "local", "ip": "10.20.1.10" },
    { "kind": "metric", "device": "tda-01.local", "subtype": "disp_icmp",
      "c_label": "Disponibilidad tda-01", "views": ["Tiendas"] } ] }
```

Un perfil añade `parameters` (`required`, `default`, `descr`) y usa `{param}` en
los recursos; ver `profiles/icmp-basic.json`. `cnm-control list profiles` dice
qué perfiles hay y de dónde sale cada uno.

El inventario es un CSV con `;`. La primera línea tiene los nombres de los
parámetros del perfil, en cualquier orden. Una columna `custom.<campo>` lleva el
valor del campo de usuario `<campo>` (`cnm-control list fields`) para el
dispositivo de esa fila: sin distinguir mayúsculas, en cualquier orden. Una
celda vacía no toca el campo, y el valor del inventario gana al que ponga el
perfil.

Los atributos del dispositivo (`domain`, `type`, `critic`, `status`, `geodata`,
`version`, `community`) pueden ir como columna aunque el perfil no los declare, con
su nombre o como `device.<atributo>`; una celda vacía no los toca. Si el perfil
tiene un parámetro con ese nombre que significa otra cosa, la columna sin prefijo
es el parámetro y `device.<atributo>` es el atributo.

`--set columna=valor` rellena esa columna en las filas que la dejan vacía, esté o no
en el CSV. Manda la celda, luego `--set` y luego el valor por defecto del perfil.

El dominio por defecto del perfil solo se usa al crear: si la IP ya existe con ese
nombre en otro dominio, el equipo conserva el suyo. Un dominio escrito en el CSV o
con `--set` se comprueba entero, como el nombre.

Una columna `c_label.<subtipo>` lleva el título de la métrica `<subtipo>` de esa
fila (`c_label.disp_icmp`, `c_label.mon_icmp`). Una celda vacía deja el título del
perfil. La fila tiene que tener exactamente una métrica de ese subtipo.

```
name;ip;view;custom.Proveedor;c_label.mon_icmp
tda-01;10.20.1.10;Tiendas;ACME;Servicio ICMP enlace 4G
tda-02;10.20.1.11;Tiendas;;
```

## Uso

```
cnm-control list views --search tienda
cnm-control plan  --profile icmp-basic --inventory tiendas.csv
cnm-control plan  --profile icmp-basic --inventory sede.csv --set view="ALCALA" --set critic=75
cnm-control plan  --profile device-update --inventory mant.csv --set status=2
cnm-control apply --profile icmp-basic --inventory tiendas.csv --confirm
cnm-control expand --profile icmp-basic --inventory tiendas.csv > estado.json
cnm-control plan  -f estado.json --json
```

A un dispositivo creado en el `apply` se le calcula el asistente (aplicaciones y
métricas disponibles) en la misma llamada al motor que genera su plantilla y sus
métricas. A uno que ya existía no se le recalcula.

`cnm-control` crea las métricas que pide el estado aunque el equipo no las ofrezca, y
avisa: en el `plan`, si la métrica no está en el asistente de un dispositivo que ya
existe (o no tiene asistente), y al terminar el `apply`, si no ha entrado en el
asistente recién calculado de un dispositivo nuevo (por ejemplo, porque no responde a
ping).

Cada `apply` deja el plan, la salida del motor y el resultado en
`/store/data/support/cnm-control/runs/AAAAMMDD-HHMMSS-apply/`, y el bloqueo en
`/store/data/support/cnm-control/state/`. Al terminar vuelve a calcular el plan: si no
sale vacío, termina con error.

Si el plan tiene errores, la salida empieza por `NO SE PUEDE APLICAR`, enseña las
causas, agrupa los errores que solo repiten otro (`--verbose` los lista) y marca las
acciones como bloqueadas: `apply` no aplica ninguna mientras haya un error.

Código de salida: 0 bien; 1 error en el plan, al aplicar o al comprobar; 2 uso
incorrecto.

## Pruebas

```
cd /opt/cnm/control
perl -c -Ilib -I/opt/crawler/bin bin/cnm-control
for t in t/*.t; do perl $t || echo "ROJO: $t"; done
```

`t/CTL_flow.t` usa una base y un motor simulados: recorre el código, pero **no**
sustituye la prueba en un appliance de ensayo.
