<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'tip_pkts_block',
            'class' => 'TIPPING-POINT',
            'lapse' => '300',
            'descr' => 'PAQUETES ELIMINADOS',
            'items' => 'policyPacketsDropped.0|policyPacketsBlocked.0',
            'oid' => '.1.3.6.1.4.1.10734.3.3.2.1.1.0|.1.3.6.1.4.1.10734.3.3.2.1.2.0',
            'get_iid' => '',
            'oidn' => 'TPT-POLICY::policyPacketsDropped.0|TPT-POLICY::policyPacketsBlocked.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'TPT-POLICY::policyPacketsDropped.0',
            'enterprise' => '10734',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TIPPINGPOINT',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'tip_pkts_flow',
            'class' => 'TIPPING-POINT',
            'lapse' => '300',
            'descr' => 'PAQUETES CURSADOS',
            'items' => 'policyPacketsIncoming.0|policyPacketsOutgoing.0',
            'oid' => '.1.3.6.1.4.1.10734.3.3.2.1.3.0|.1.3.6.1.4.1.10734.3.3.2.1.4.0',
            'get_iid' => '',
            'oidn' => 'TPT-POLICY::policyPacketsIncoming.0|TPT-POLICY::policyPacketsOutgoing.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'TPT-POLICY::policyPacketsIncoming.0',
            'enterprise' => '10734',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TIPPINGPOINT',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'tip_pkts_perm',
            'class' => 'TIPPING-POINT',
            'lapse' => '300',
            'descr' => 'PAQUETES PERMITIDOS',
            'items' => 'policyPacketsPermitted.0',
            'oid' => '.1.3.6.1.4.1.10734.3.3.2.1.7.0',
            'get_iid' => '',
            'oidn' => 'TPT-POLICY::policyPacketsPermitted.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'TPT-POLICY::policyPacketsPermitted.0',
            'enterprise' => '10734',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TIPPINGPOINT',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'tip_pkts_inval',
            'class' => 'TIPPING-POINT',
            'lapse' => '300',
            'descr' => 'PAQUETES INVALIDOS',
            'items' => 'policyPacketsInvalid.0',
            'oid' => '.1.3.6.1.4.1.10734.3.3.2.1.6.0',
            'get_iid' => '',
            'oidn' => 'TPT-POLICY::policyPacketsInvalid.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'TPT-POLICY::policyPacketsInvalid.0',
            'enterprise' => '10734',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TIPPINGPOINT',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'tip_alerts_proto',
            'class' => 'TIPPING-POINT',
            'lapse' => '300',
            'descr' => 'ALERTAS POR PROTOCOLO',
            'items' => 'protocolAlertCount',
            'oid' => '.1.3.6.1.4.1.10734.3.3.2.1.13.1.2.IID',
            'get_iid' => 'alertProtocol',
            'oidn' => 'protocolAlertCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'TPT-POLICY::alertsByProtocolTable',
            'enterprise' => '10734',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TIPPINGPOINT',
      );


?>
