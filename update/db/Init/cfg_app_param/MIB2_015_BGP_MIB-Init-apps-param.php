<?php

   $CFG_APP_PARAM[]=array(
      'aname' => 'app_mib2_bgppeers', 'hparam' => '20000008', 'type' => 'snmp', 'enable' => '1', 'value' => '00000-MIB2-BGP4-PEER_TABLE.xml',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_mib2_bgppeers', 'hparam' => '20000009', 'type' => 'snmp', 'enable' => '1', 'value' => 'json',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_mib2_bgppeers', 'hparam' => '2000000a', 'type' => 'snmp', 'enable' => '1', 'value' => '',
      'script' => 'snmptable',
   );


?>
