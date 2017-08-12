<?
	$TIPS[]=array(
		'id_ref' => 'app_mib2_listinterfaces',
		'tip_type' => 'app',
		'name' => 'Description',
		'descr' => '<strong>Obtains the list of interfaces of a device </strong><br>using the SNMP tables: RFC1213-MIB::ifTable or IF-MIB::ifXTable',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mibhost_diskp',
		'tip_type' => 'app',
		'name' => 'Description',
		'descr' => '<strong>Obtains the disk usage of a host</strong><br> using the table HOST-RESOURCES-MIB:hrStorageTable',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_cdptable',
		'tip_type' => 'app',
		'name' => 'Description',
		'descr' => '<strong>Obtains the CDP neighbours of a host </strong><br>using the tables CISCO-CDP-MIB::cdpCacheTable and RFC1213-MIB::ifTable',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_dev_pool',
		'tip_type' => 'app',
		'name' => 'Description',
		'descr' => '<strong>Obtains the device pools defined in a Cisco device </strong><br>using the tables CISCO-CCM-MIB::ccmGroupTable, CISCO-CCM-MIB::ccmRegionTable, CISCO-CCM-MIB::ccmTimeZoneTable and CISCO-CCM-MIB::ccmDevicePoolTable',
	);

?>
