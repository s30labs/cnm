<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_cpu_util',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'USO DE CPU EN VM',
            'items' => 'vmwCpuUtil',
            'oid' => '.IID',
            'get_iid' => 'vmwCpuVMID',
            'oidn' => 'vmwCpuUtil.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-OBSOLETE-MIB::vmwCpuTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );


		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_mem_util',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'USO DE MEMORIA EN VM',
            'items' => 'vmwMemUtil|vmwMemConfigured',
            'oid' => '.IID|.IID',
            'get_iid' => 'vmwMemVMID',
            'oidn' => 'vmwMemUtil.IID|vmwMemConfigured.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-OBSOLETE-MIB::vmwMemTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );


		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_disk_util_kb',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'USO DE DISCO EN VM',
            'items' => 'vmwKbRead|vmwKbWritten',
            'oid' => '.IID|.IID',
            'get_iid' => 'vmwHbaName',
            'oidn' => 'vmwKbRead.IID|vmwKbWritten.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-OBSOLETE-MIB::vmwHBATable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );


		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_net_util_kb',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'USO DE RED EN VM',
            'items' => 'vmwNetKbTx|vmwNetKbRx',
            'oid' => '.IID|.IID',
            'get_iid' => 'vmwNetName',
            'oidn' => 'vmwNetKbTx.IID|vmwNetKbRx.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-OBSOLETE-MIB::vmwNetTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );


		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_mem_cfg',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'MEMORIA CONFIGURADA EN VM',
            'items' => 'vmwVmMemSize',
            'oid' => '.IID',
            'get_iid' => 'vmwVmDisplayName',
            'oidn' => 'vmwVmMemSize.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-VMINFO-MIB::vmwVmTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_vm_status',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'ESTADO DE VM',
            'items' => 'running|notRunning',
            'oid' => '.IID',
            'get_iid' => 'vmwVmDisplayName',
            'oidn' => 'vmwVmGuestState.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_SOLID',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-VMINFO-MIB::vmwVmTable',
            'enterprise' => '0',
            'esp' => 'MAPS("running")(1,0)|MAPS("notRunning")(0,1)',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_vm_glob_status',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'ESTADO GLOBAL DE TODAS LAS VM',
            'items' => 'running|notRunning',
            'oid' => '.IID',
            'get_iid' => 'vmwVmDisplayName',
            'oidn' => 'vmwVmGuestState.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-VMINFO-MIB::vmwVmTable',
            'enterprise' => '0',
            'esp' => 'TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'vmware_vm_glob_mem',
            'class' => 'VMWARE',
            'lapse' => '300',
            'descr' => 'MEMORIA GLOBAL DE TODAS LAS VM',
            'items' => 'running|notRunning',
            'oid' => '.IID|.IID',
            'get_iid' => 'vmwVmDisplayName',
            'oidn' => 'vmwVmGuestState.IID|vmwVmMemSize.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'VMWARE-VMINFO-MIB::vmwVmTable',
            'enterprise' => '0',
            'esp' => 'TABLE(SUM)("running")|TABLE(SUM)("notRunning")',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'VIRTUAL.VMWARE',
      );


?>
