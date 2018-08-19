<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'pan_ses_usage',
            'class' => 'PAN-COMMON-MIB',
            'lapse' => '300',
            'descr' => 'USO DE SESIONES',
            'items' => 'panSessionUtilization.0',
            'oid' => '.1.3.6.1.4.1.25461.2.1.2.3.1.0',
            'get_iid' => '',
            'oidn' => 'PAN-COMMON-MIB::panSessionUtilization.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'PAN-COMMON-MIB::panSessionUtilization.0',
            'enterprise' => '25461',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.PALO_ALTO',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'pan_ses_active',
            'class' => 'PAN-COMMON-MIB',
            'lapse' => '300',
            'descr' => 'SESIONES ACTIVAS',
            'items' => 'panSessionActive.0|panSessionActiveTcp.0|panSessionActiveUdp.0|panSessionActiveICMP.0',
            'oid' => '.1.3.6.1.4.1.25461.2.1.2.3.3.0|.1.3.6.1.4.1.25461.2.1.2.3.4.0|.1.3.6.1.4.1.25461.2.1.2.3.5.0|.1.3.6.1.4.1.25461.2.1.2.3.6.0',
            'get_iid' => '',
            'oidn' => 'PAN-COMMON-MIB::panSessionActive.0|PAN-COMMON-MIB::panSessionActiveTcp.0|PAN-COMMON-MIB::panSessionActiveUdp.0|PAN-COMMON-MIB::panSessionActiveICMP.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'PAN-COMMON-MIB::panSessionActive.0',
            'enterprise' => '25461',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.PALO_ALTO',
      );


?>
