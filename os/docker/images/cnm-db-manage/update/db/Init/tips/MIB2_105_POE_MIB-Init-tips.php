<?php
      $TIPS[]=array(
         'id_ref' => 'poe_pse_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>on(1)|off(2)|faulty(3)|unk</strong> a partir de los siguientes atributos de la mib POWER-ETHERNET-MIB:<br><br><strong>POWER-ETHERNET-MIB::pethMainPseOperStatus (GAUGE):</strong> "The operational status of the main PSE."
',
      );


      $TIPS[]=array(
         'id_ref' => 'poe_pse_usage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>pethMainPseConsumptionPower|pethMainPsePower</strong> a partir de los siguientes atributos de la mib POWER-ETHERNET-MIB:<br><br><strong>POWER-ETHERNET-MIB::pethMainPseConsumptionPower (GAUGE):</strong> "Measured usage power expressed in Watts."
<strong>POWER-ETHERNET-MIB::pethMainPsePower (GAUGE):</strong> "The nominal power of the PSE expressed in Watts."
',
      );


      $TIPS[]=array(
         'id_ref' => 'poe_pse_usagep',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>pethMainPsePower|pethMainPseConsumptionPower</strong> a partir de los siguientes atributos de la mib POWER-ETHERNET-MIB:<br><br><strong>POWER-ETHERNET-MIB::pethMainPsePower (GAUGE):</strong> "The nominal power of the PSE expressed in Watts."
<strong>POWER-ETHERNET-MIB::pethMainPseConsumptionPower (GAUGE):</strong> "Measured usage power expressed in Watts."
',
      );


      $TIPS[]=array(
         'id_ref' => 'poe_class_types',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>class0(1)|class1(2)|class2(3)|class3(4)|class4(5)</strong> a partir de los siguientes atributos de la mib POWER-ETHERNET-MIB:<br><br><strong>POWER-ETHERNET-MIB::pethPsePortPowerClassifications (GAUGE):</strong> "Classification is a way to tag different terminals on the
         Power over LAN network according to their power consumption.
         Devices such as IP telephones, WLAN access points and others,
         will be classified according to their power requirements.
 
         The meaning of the classification labels is defined in the
         IEEE specification.
 
        This variable is valid only while a PD is being powered,
         that is, while the attribute pethPsePortDetectionStatus
         is reporting the enumeration deliveringPower."
',
      );


?>
