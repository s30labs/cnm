<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_log_file',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'OCUPACION DEL LOG',
            'items' => 'logFullPercent.0',
            'oid' => '.1.3.6.1.4.1.12532.1.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::logFullPercent.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '%',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::logFullPercent.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_sign_webu',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USUARIOS DE WEB FIRMADOS',
            'items' => 'signedInWebUsers.0',
            'oid' => '.1.3.6.1.4.1.12532.2.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::signedInWebUsers.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'usuarios',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::signedInWebUsers.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_sign_mailu',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USUARIOS DE CORREO FIRMADOS',
            'items' => 'signedInMailUsers.0',
            'oid' => '.1.3.6.1.4.1.12532.3.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::signedInMailUsers.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'usuarios',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::signedInMailUsers.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_cpu_usage',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USO DE CPU',
            'items' => 'iveCpuUtil.0',
            'oid' => '.1.3.6.1.4.1.12532.10.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::iveCpuUtil.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::iveCpuUtil.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_mem_usage',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USO DE MEMORIA',
            'items' => 'iveMemoryUtil.0',
            'oid' => '.1.3.6.1.4.1.12532.11.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::iveMemoryUtil.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::iveMemoryUtil.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_users',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USUARIOS CONCURRENTES',
            'items' => 'iveConcurrentUsers.0',
            'oid' => '.1.3.6.1.4.1.12532.12.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::iveConcurrentUsers.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::iveConcurrentUsers.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_cluster_users',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USUARIOS CONCURRENTES DEL CLUSTER',
            'items' => 'clusterConcurrentUsers.0',
            'oid' => '.1.3.6.1.4.1.12532.13.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::clusterConcurrentUsers.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::clusterConcurrentUsers.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_swap_usage',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USO DE SWAP',
            'items' => 'iveSwapUtil.0',
            'oid' => '.1.3.6.1.4.1.12532.24.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::iveSwapUtil.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::iveSwapUtil.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'juniper_disk_usage',
            'class' => 'JUNIPER',
            'lapse' => '300',
            'descr' => 'USO DE DISCO',
            'items' => 'diskFullPercent.0',
            'oid' => '.1.3.6.1.4.1.12532.25.0',
            'get_iid' => '',
            'oidn' => 'JUNIPER-IVE-MIB::diskFullPercent.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'JUNIPER-IVE-MIB::diskFullPercent.0',
            'enterprise' => '12532',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.JUNIPER',
      );


?>
