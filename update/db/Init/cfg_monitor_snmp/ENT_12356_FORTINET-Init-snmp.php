<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_cpu_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE CPU (%)',
            'items' => 'fgSysCpuUsage.0',
            'oid' => '.1.3.6.1.4.1.12356.101.4.1.3.0',
            'get_iid' => '',
            'oidn' => 'FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '%',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_mem_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE MEMORIA (%)',
            'items' => 'fgSysMemUsage.0',
            'oid' => '.1.3.6.1.4.1.12356.101.4.1.4.0',
            'get_iid' => '',
            'oidn' => 'FORTINET-FORTIGATE-MIB::fgSysMemUsage.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '%',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-FORTIGATE-MIB::fgSysMemUsage.0',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_lowmem_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE MEMORIA BAJA (%)',
            'items' => 'fgSysLowMemUsage.0',
            'oid' => '.1.3.6.1.4.1.12356.101.4.1.9.0',
            'get_iid' => '',
            'oidn' => 'FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '%',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_disk_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE DISCO',
            'items' => '::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0|fgSysDiskCapacity.0',
            'oid' => '|.1.3.6.1.4.1.12356.101.4.1.7.0',
            'get_iid' => '',
            'oidn' => '::::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0|FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'MB',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => '::::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_ses_count',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'NUMERO DE SESIONES ACTIVAS',
            'items' => 'fgSysSesCount.0',
            'oid' => '.1.3.6.1.4.1.12356.101.4.1.8.0',
            'get_iid' => '',
            'oidn' => 'FORTINET-FORTIGATE-MIB::fgSysSesCount.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-FORTIGATE-MIB::fgSysSesCount.0',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortigate_pol_traffic',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'TRAFICO EN POLICY',
            'items' => 'fgFwPolPktCount|fgFwPolByteCount',
            'oid' => '.1.3.6.1.4.1.12356.101.5.1.2.1.1.2.IID|.1.3.6.1.4.1.12356.101.5.1.2.1.1.3.IID',
            'get_iid' => 'fgFwPolID',
            'oidn' => 'fgFwPolPktCount.IID|fgFwPolByteCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-FORTIGATE-MIB::fgFwPolStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_cpu_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE CPU',
            'items' => 'fnHaStatsCpuUsage',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.3.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsCpuUsage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_memory_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'USO DE MEMORIA',
            'items' => 'fnHaStatsMemUsage',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.4.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsMemUsage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_net_usage',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'TRAFICO DE RED',
            'items' => 'fnHaStatsNetUsage',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.5.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsNetUsage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_active_sessions',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'SESIONES ACTIVAS',
            'items' => 'fnHaStatsSesCount',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.6.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsSesCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_packets',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'PAQUETES PROCESADOS',
            'items' => 'fnHaStatsPktCount',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.7.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsPktCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_bytes',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'BYTES PROCESADOS',
            'items' => 'fnHaStatsByteCount',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.8.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsByteCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_attacks',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'ATAQUES EN 20 HORAS',
            'items' => 'fnHaStatsIdsCount',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.9.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsIdsCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'fortinet_virus',
            'class' => 'FORTINET',
            'lapse' => '300',
            'descr' => 'VIRUS EN 20 HORAS',
            'items' => 'fnHaStatsAvCount',
            'oid' => '.1.3.6.1.4.1.12356.1.100.6.1.10.IID',
            'get_iid' => 'fnHaStatsSerial',
            'oidn' => 'fnHaStatsAvCount.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'FORTINET-MIB-280::fnHaStatsTable',
            'enterprise' => '12356',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.FORTINET',
      );


?>
