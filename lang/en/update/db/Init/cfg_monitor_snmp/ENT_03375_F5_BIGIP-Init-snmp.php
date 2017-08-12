<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_tcp_active',
		'descr' => 'TCP OPEN CONNECTIONS',
		'items' => 'sysTcpStatOpen.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_tcp_inactive',
		'descr' => 'TCP INACTIVE CONNECTIONS',
		'items' => 'sysTcpStatCloseWait|sysTcpStatFinWait|sysTcpStatTimeWait',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pools_tot_mem',
		'descr' => 'POOL MEMBER NUMBER',
		'items' => 'ltmPoolMemberNumber.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_cpu_temp',
		'descr' => 'CPU - TEMPERATURE',
		'items' => 'sysCpuTemperature',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_cpu_fans',
		'descr' => 'CPU - FAN SPEED',
		'items' => 'sysCpuFanSpeed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_fans',
		'descr' => 'CHASSIS - FAN SPEED',
		'items' => 'sysChassisFanSpeed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_fan_stat',
		'descr' => 'CHASSIS - FAN STATUS',
		'items' => 'sysChassisFanStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_power_stat',
		'descr' => 'CHASSIS - POWER SUPPLY STATUS',
		'items' => 'sysChassisPowerSupplyStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_chas_temp',
		'descr' => 'CHASSIS - TEMPERATURE',
		'items' => 'sysChassisTempTemperature',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pool_active',
		'descr' => 'ACTIVE POOL MEMBER',
		'items' => 'ltmPoolActiveMemberCnt|ltmPoolMemberCnt',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'f5big_pool_avail_stat',
		'descr' => 'POOL STATUS',
		'items' => 'ltmPoolStatusAvailState|ltmPoolStatusEnabledState',
	);

?>
