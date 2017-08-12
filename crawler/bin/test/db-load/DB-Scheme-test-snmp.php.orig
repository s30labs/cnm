<?php

/*
	INSTRUCCIONES PARA INCLUIR EN CNM METRICAS SNMP DE CLASE 1
	a)	Definir los datos necesarios de la metrica para incluirla en el sistema.
	Son los siguientes:

	subtype: 	Se debe poner un nombre que no exista ya en BD asignado a otra metrica. 
					Si existe no se puede insertar en BD.
	class:		Es la clase de la metrica. Para las de enterprises se debe poner el nombre 
					fabricante. Si cuelgan de la parte de MIB-II extendida poner el nombre de la MIB.
	descr:		La descripcion de la metrica
	items:		Los elementos a medir. Si son varios, separar por |.
	oid:			Los oids a medir. Si son varios, separar por |.
	oidn:			El nombre (segun la MIB) de los oids a medir.
	oid_info: 	La informacion de los diferentes oids son 4 campos separados por |. Para los diferentes
					oids se separa por <br>. El detalle de los campos es:
					1. Nombre de la MIB
					2. El valor de oidn
					3. El tipo de datos (se saca de la MIB)
					4. La descripcion (se saca de la MIB)

   lapse:      Por ahora siempre es 300
   get_iid:    En las de clase1 hay que poner ''.


	b) Ejecutar: php /opt/crawler/bin/test/db-load/db-load-snmp.php


*/

	$CFG_MONITOR_SNMP=array(

//      array(
//            'subtype' => 'enterasys_cpu_usage',
//            'class' => 'ENTERASYS',
//            'descr' => 'USO DE CPU',
//            'items' => 'Uso de CPU',
//            'oid' => '.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1',
//            'oidn' => 'capCPUCurrentUtilization.1',
//            'oid_info' => 'CTRON-SSR-CAPACITY-MIB|capCPUCurrentUtilization.1|INTEGER (0..100)|The CPU utilization expressed as an integer percentage. This is calculated over the last 5 seconds at a 0.1 second interval as a simple average.',
//
//            'lapse' => '300',
//            'get_iid' => '',
//			     'label' => 'Uso de CPU',
//			     'module' => 'mod_snmp_get',
//			     'mtype' => 'STD_BASE',
//			     'vlabel' => '%',
//			     'mode' => 'GAUGE',
//			     'top_value' => '',
//
//      ),




	);

?>


