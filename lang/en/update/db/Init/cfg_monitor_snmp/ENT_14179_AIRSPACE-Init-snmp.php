<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_nclients',
		'descr' => 'AP CLIENTS',
		'items' => 'bsnAPIfLoadNumOfClients',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_ap_status',
		'descr' => 'AP STATUS',
		'items' => 'bsnAPOperationStatus|bsnAPAdminStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'airspace_ap_profiles',
		'descr' => 'AP PROFILE STATUS',
		'items' => 'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState',
	);

?>
