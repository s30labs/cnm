<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'mib2_ent_phy_parts',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'COMPONENTES FISICOS',
            'items' => 'chassis-bplane|powerSup|unk-other|fan|cpu|sensor|module|port|container|stack|all',
            'oid' => '.1.3.6.1.2.1.47.1.1.1.1.5.IID',
            'get_iid' => 'entPhysicalName',
            'oidn' => 'entPhysicalClass.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'ENTITY-MIB::entPhysicalTable',
            'enterprise' => '0',
            'esp' => 'TABLE(MATCH)([3;4])|TABLE(MATCH)(6)|TABLE(MATCH)([1;2])|TABLE(MATCH)(7)|TABLE(MATCH)(12)|TABLE(MATCH)(8)|TABLE(MATCH)(9)|TABLE(MATCH)(10)|TABLE(MATCH)(5)|TABLE(MATCH)(11)|TABLE(MATCH)([1;2;3;4;5;6;7;8;9;10;11;12])',
            'params' => '',
            'itil_type' => '2',
            'apptype' => 'NET.MIB2',
      );


?>
