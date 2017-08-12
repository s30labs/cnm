<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::subHostDown',
		'hiid' => 'b639a187f3',
		'descr' => 'CAIDA DE SUBHOST',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailProtectionGroupError',
		'hiid' => '90ac57f4f0',
		'descr' => 'ERROR EN GRUPO DE PROTECCION',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailConfigMissing',
		'hiid' => 'b639a187f3',
		'descr' => 'EQUIPO SIN CONFIGURACION',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailConfigError',
		'hiid' => 'b639a187f3',
		'descr' => 'ERROR DE CONFIGURACION',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailHwDeviceDown',
		'hiid' => 'b639a187f3',
		'descr' => 'DISPOSITVO HARDWARE CAIDO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailHwSensorCritical',
		'hiid' => 'b639a187f3',
		'descr' => 'SENSOR HARDWARE EN ESTADO CRITICO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailSwComponentDown',
		'hiid' => 'dba32c578c',
		'descr' => 'PROCESO SOFTWARE CAIDO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailSystemStatusCritical',
		'hiid' => 'b639a187f3',
		'descr' => 'SISTEMA EN ESTADO CRITICO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailSystemStatusDegraded',
		'hiid' => 'b639a187f3',
		'descr' => 'SISTEMA DEGRADADO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailFilesystemCritical',
		'hiid' => 'b639a187f3',
		'descr' => 'SISTEMA DE FICHEROS LLENO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailGRETunnelFailure',
		'hiid' => 'b639a187f3',
		'descr' => 'ERROR EN TUNEL GRE',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailNextHopUnreachable',
		'hiid' => 'b639a187f3',
		'descr' => 'NO SE ALCANZA NEXT HOP',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailPerformance',
		'hiid' => '1a8f9efa98',
		'descr' => 'SISTEMA DEGRADADO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailSystemStatusError',
		'hiid' => 'b639a187f3',
		'descr' => 'ERROR DE ESTADO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailCloudSignalTimeout',
		'hiid' => 'b639a187f3',
		'descr' => 'TIMEOUT EN ACCESO A SERVICIOS EN LA NUBE',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailCloudSignalThreshold',
		'hiid' => 'b639a187f3',
		'descr' => 'ERRROR EN ACCESO A SERVICIOS EN LA NUBE',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailTrapTraffic',
		'hiid' => 'd193e9716c',
		'descr' => 'EXCESO DE TRAFICO EN GRUPO DE PROTECCION',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailTrapBotnetAttack',
		'hiid' => 'd193e9716c',
		'descr' => 'ATAQUE DE BOTNET',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailTrapLicenseLimit',
		'hiid' => 'b639a187f3',
		'descr' => 'EXCEDIDO EL LIMITE DE LICENCIAS',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'PRAVAIL-MIB::pravailTrapBlockedTraffic',
		'hiid' => 'd193e9716c',
		'descr' => 'EL TRAFICO BLOQUEADO SUPERA EL UMBRAL DEL GRUPO DE PROTECCION',
	);

?>
