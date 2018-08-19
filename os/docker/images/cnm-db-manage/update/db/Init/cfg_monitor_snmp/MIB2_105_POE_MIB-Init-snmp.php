<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'poe_pse_status',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'ESTADO DE LA FUENTE',
            'items' => 'on(1)|off(2)|faulty(3)|unk',
            'oid' => '.1.3.6.1.2.1.105.1.3.1.1.3.IID',
            'get_iid' => 'pethMainPseGroupIndex',
            'oidn' => 'pethMainPseOperStatus.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_SOLID',
            'vlabel' => 'estado',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'POWER-ETHERNET-MIB::pethMainPseTable',
            'enterprise' => '0',
            'esp' => 'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.MIB2',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'poe_pse_usage',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'CONSUMO DE LA FUENTE',
            'items' => 'pethMainPseConsumptionPower|pethMainPsePower',
            'oid' => '.1.3.6.1.2.1.105.1.3.1.1.4.IID|.1.3.6.1.2.1.105.1.3.1.1.2.IID',
            'get_iid' => 'pethMainPseGroupIndex',
            'oidn' => 'pethMainPseConsumptionPower.IID|pethMainPsePower.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_SOLID',
            'vlabel' => 'Watt',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'POWER-ETHERNET-MIB::pethMainPseTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.MIB2',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'poe_pse_usagep',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'CONSUMO DE LA FUENTE (%)',
            'items' => 'pethMainPsePower|pethMainPseConsumptionPower',
            'oid' => '.1.3.6.1.2.1.105.1.3.1.1.2.IID|.1.3.6.1.2.1.105.1.3.1.1.4.IID',
            'get_iid' => 'pethMainPseGroupIndex',
            'oidn' => 'pethMainPsePower.IID|pethMainPseConsumptionPower.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_SOLID',
            'vlabel' => 'Watt',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'POWER-ETHERNET-MIB::pethMainPseTable',
            'enterprise' => '0',
            'esp' => '100*o2/o1',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.MIB2',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'poe_class_types',
            'class' => 'MIB2',
            'lapse' => '300',
            'descr' => 'CLASES DE POTENCIA CONECTADAS',
            'items' => 'class0(1)|class1(2)|class2(3)|class3(4)|class4(5)',
            'oid' => '.1.3.6.1.2.1.105.1.1.1.10.IID',
            'get_iid' => 'pethPsePortIndex',
            'oidn' => 'pethPsePortPowerClassifications.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'POWER-ETHERNET-MIB::pethPsePortTable',
            'enterprise' => '0',
            'esp' => 'TABLE(MATCH)(1)|TABLE(MATCH)(2)|TABLE(MATCH)(3)|TABLE(MATCH)(4)|TABLE(MATCH)(5)',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.MIB2',
      );


?>
