<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'mib2_stp_top_change',
            'class' => 'BRIDGE-MIB',
            'lapse' => '300',
            'descr' => 'CAMBIOS DE TOPOLOGIA SPANNING TREE',
            'items' => 'dot1dStpTopChanges.0',
            'oid' => '.1.3.6.1.2.1.17.2.4.0',
            'get_iid' => '',
            'oidn' => 'BRIDGE-MIB::dot1dStpTopChanges.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'BRIDGE-MIB::dot1dStpTopChanges.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.BRIDGE-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'entity_sensor_stat',
            'class' => 'ENTITY-SENSOR-MIB',
            'lapse' => '300',
            'descr' => 'ESTADO DE SENSOR',
            'items' => 'ok(1)|unavailable(2)|nonoperational(3)   forwarding(5)|disabled(1)|blocking(2)|broken(6)|listening(3)|learning(4)',
            'oid' => '.1.3.6.1.2.1.99.1.1.1.5.IID',
            'get_iid' => '',
            'oidn' => 'entPhySensorOperStatus.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_SOLID',
            'vlabel' => 'estado',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'ENTITY-SENSOR-MIB::entPhySensorTable',
            'enterprise' => '0',
            'esp' => 'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)',
            'params' => '',
            'itil_type' => '4',
            'apptype' => 'NET.ENT_SENSOR-MIB',
      );


?>
