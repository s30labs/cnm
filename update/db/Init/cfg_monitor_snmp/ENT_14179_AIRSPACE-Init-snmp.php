<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'airspace_nclients',
            'class' => 'CISCO-AIRONET',
            'lapse' => '300',
            'descr' => 'NUMERO DE CLIENTES EN AP',
            'items' => 'bsnAPIfLoadNumOfClients',
            'oid' => '.1.3.6.1.4.1.14179.2.2.13.1.4.IID',
            'get_iid' => 'bsnAPDot3MacAddress',
            'oidn' => 'bsnAPIfLoadNumOfClients.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable',
            'enterprise' => '14179',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.CISCO-WIRELESS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'airspace_ap_status',
            'class' => 'CISCO-AIRONET',
            'lapse' => '300',
            'descr' => 'ESTADO DEL AP',
            'items' => 'bsnAPOperationStatus|bsnAPAdminStatus',
            'oid' => '.1.3.6.1.4.1.14179.2.2.1.1.6.IID|.1.3.6.1.4.1.14179.2.2.1.1.37.IID',
            'get_iid' => 'bsnApIpAddress',
            'oidn' => 'bsnAPOperationStatus.IID|bsnAPAdminStatus.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPTable',
            'enterprise' => '14179',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.CISCO-WIRELESS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'airspace_ap_profiles',
            'class' => 'CISCO-AIRONET',
            'lapse' => '300',
            'descr' => 'ESTADO DE PERFILES DEL AP',
            'items' => 'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState',
            'oid' => '.1.3.6.1.4.1.14179.2.2.16.1.1.IID|.1.3.6.1.4.1.14179.2.2.16.1.2.IID|.1.3.6.1.4.1.14179.2.2.16.1.3.IID|.1.3.6.1.4.1.14179.2.2.16.1.24.IID',
            'get_iid' => 'bsnAPDot3MacAddress',
            'oidn' => 'bsnAPIfLoadProfileState.IID|bsnAPIfInterferenceProfileState.IID|bsnAPIfNoiseProfileState.IID|bsnAPIfCoverageProfileState.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable',
            'enterprise' => '14179',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.CISCO-WIRELESS',
      );


?>
