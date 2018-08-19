<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'dial_peer_ctime',
            'class' => 'DIAL-CONTROL',
            'lapse' => '300',
            'descr' => 'TIEMPO DE CONEXION EN PEER',
            'items' => 'dialCtlPeerStatsConnectTime',
            'oid' => '.1.3.6.1.2.1.10.21.1.2.2.1.1.IID',
            'get_iid' => 'dialCtlPeerCfgEntry',
            'oidn' => 'dialCtlPeerStatsConnectTime.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'DIAL-CONTROL-MIB::dialCtlPeerStatsTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TRANS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'dial_peer_calls',
            'class' => 'DIAL-CONTROL',
            'lapse' => '300',
            'descr' => 'LLAMADAS EN PEER',
            'items' => 'dialCtlPeerStatsSuccessCalls|dialCtlPeerStatsFailCalls|dialCtlPeerStatsAcceptCalls|dialCtlPeerStatsRefuseCalls',
            'oid' => '.1.3.6.1.2.1.10.21.1.2.2.1.3.IID|.1.3.6.1.2.1.10.21.1.2.2.1.4.IID|.1.3.6.1.2.1.10.21.1.2.2.1.5.IID|.1.3.6.1.2.1.10.21.1.2.2.1.6.IID',
            'get_iid' => 'dialCtlPeerCfgEntry',
            'oidn' => 'dialCtlPeerStatsSuccessCalls.IID|dialCtlPeerStatsFailCalls.IID|dialCtlPeerStatsAcceptCalls.IID|dialCtlPeerStatsRefuseCalls.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'DIAL-CONTROL-MIB::dialCtlPeerStatsTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.TRANS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'mib2_glob_duplex',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'RESUMEN DEL MODO DUPLEX DE LOS INTERFACES',
            'items' => 'fullDuplex|unknown|halfDuplex',
            'oid' => '.1.3.6.1.2.1.10.7.2.1.19.IID',
            'get_iid' => 'dot3StatsIndex',
            'oidn' => 'dot3StatsDuplexStatus.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'EtherLike-MIB::dot3StatsTable',
            'enterprise' => '0',
            'esp' => 'TABLE(MATCH)(fullDuplex)|TABLE(MATCH)(unknown)|TABLE(MATCH)(halfDuplex)',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.MIB2',
      );


?>
