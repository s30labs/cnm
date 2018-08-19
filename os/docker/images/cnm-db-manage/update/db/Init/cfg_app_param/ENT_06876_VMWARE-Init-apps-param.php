<?php

   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_vminfo_table', 'hparam' => '20000008', 'type' => 'snmp', 'enable' => '1', 'value' => '06876-VMWARE-VMINFO-MIB.xml',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_vminfo_table', 'hparam' => '20000009', 'type' => 'snmp', 'enable' => '1', 'value' => 'json',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_vminfo_table', 'hparam' => '2000000a', 'type' => 'snmp', 'enable' => '1', 'value' => '',
      'script' => 'snmptable',
   );



   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_get_info', 'hparam' => '20000008', 'type' => 'snmp', 'enable' => '1', 'value' => '06876-VMWARE-get-info.xml',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_get_info', 'hparam' => '20000009', 'type' => 'snmp', 'enable' => '1', 'value' => 'json',
      'script' => 'snmptable',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_vmware_get_info', 'hparam' => '2000000a', 'type' => 'snmp', 'enable' => '1', 'value' => '',
      'script' => 'snmptable',
   );


?>
