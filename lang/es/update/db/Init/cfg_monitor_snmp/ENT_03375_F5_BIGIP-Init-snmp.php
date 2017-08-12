<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_tcp_active',
		'descr' => 'CONEXIONES TCP ACTIVAS',
		'items' => 'sysTcpStatOpen.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_tcp_inactive',
		'descr' => 'CONEXIONES TCP INACTIVAS',
		'items' => 'sysTcpStatCloseWait|sysTcpStatFinWait|sysTcpStatTimeWait',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pools_tot_mem',
		'descr' => 'MIEMBROS TOTALES EN POOLS',
		'items' => 'ltmPoolMemberNumber.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_cpu_temp',
		'descr' => 'CPU - TEMPERATURA',
		'items' => 'sysCpuTemperature',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_cpu_fans',
		'descr' => 'CPU - VELOCIDAD VENTILADORES',
		'items' => 'sysCpuFanSpeed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_fans',
		'descr' => 'CHASIS - VELOCIDAD VENTILADORES',
		'items' => 'sysChassisFanSpeed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_fan_stat',
		'descr' => 'CHASIS - ESTADO DE LOS VENTILADORES',
		'items' => 'sysChassisFanStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_power_stat',
		'descr' => 'CHASIS - ESTADO DE LA FUENTE ALIMENTACION',
		'items' => 'sysChassisPowerSupplyStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_temp',
		'descr' => 'CHASIS - TEMPERATURA DE SENSOR',
		'items' => 'sysChassisTempTemperature',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pool_active',
		'descr' => 'MIEMBROS ACTIVOS EN POOL',
		'items' => 'ltmPoolActiveMemberCnt|ltmPoolMemberCnt',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pool_avail_stat',
		'descr' => 'ESTADO DEL POOL',
		'items' => 'ltmPoolStatusAvailState|ltmPoolStatusEnabledState',
	);

?>
