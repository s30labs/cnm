<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_nclients',
		'descr' => 'NUMERO DE CLIENTES EN AP',
		'items' => 'bsnAPIfLoadNumOfClients',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_ap_status',
		'descr' => 'ESTADO DEL AP',
		'items' => 'bsnAPOperationStatus|bsnAPAdminStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_ap_profiles',
		'descr' => 'ESTADO DE PERFILES DEL AP',
		'items' => 'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState',
	);

?>
