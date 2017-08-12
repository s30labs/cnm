<?php
      $TIPS[]=array(
         'id_ref' => 'cisco_fan_state',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)</strong> a partir de los siguientes atributos de la mib CISCO-ENVMON-MIB:<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonFanState (GAUGE):</strong> "The current state of the fan being instrumented."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cisco_powersup_state',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)</strong> a partir de los siguientes atributos de la mib CISCO-ENVMON-MIB:<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonSupplyState (GAUGE):</strong> "The current state of the power supply being instrumented."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cisco_temperature_state',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)</strong> a partir de los siguientes atributos de la mib CISCO-ENVMON-MIB:<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonTemperatureState (GAUGE):</strong> "The current state of the testpoint being instrumented."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cisco_voltage_state',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)</strong> a partir de los siguientes atributos de la mib CISCO-ENVMON-MIB:<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageState (GAUGE):</strong> "The current state of the testpoint being instrumented."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cisco_vlan_sum',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>operational(1)|suspended(2)|mtuTooBigForDevice(3)|mtuTooBigForTrunk(4)</strong> a partir de los siguientes atributos de la mib CISCO-VTP-MIB:<br><br><strong>CISCO-VTP-MIB::vtpVlanState (GAUGE):</strong> "The state of this VLAN.
 
             The state mtuTooBigForDevice indicates that this device
             cannot participate in this VLAN because the VLANs MTU is
             larger than the device can support.
 
             The state mtuTooBigForTrunk indicates that while this
             VLANs MTU is supported by this device, it is too large for
             one or more of the devices trunk ports."
',
      );


?>
