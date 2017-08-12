<?
	$TIPS[]=array(
		'id_ref' => 'vmware_cpu_util',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>cpuUtil</strong> a partir de los siguientes atributos de la mib VMWARE-RESOURCES-MIB:<br><br><strong>VMWARE-RESOURCES-MIB::cpuUtil (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_mem_util',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memUtil|memConfigured</strong> a partir de los siguientes atributos de la mib VMWARE-RESOURCES-MIB:<br><br><strong>VMWARE-RESOURCES-MIB::memUtil (GAUGE):</strong> <strong>VMWARE-RESOURCES-MIB::memConfigured (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_disk_util_kb',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>kbRead|kbWritten</strong> a partir de los siguientes atributos de la mib VMWARE-RESOURCES-MIB:<br><br><strong>VMWARE-RESOURCES-MIB::kbRead (GAUGE):</strong> <strong>VMWARE-RESOURCES-MIB::kbWritten (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_net_util_kb',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>kbTx|kbRx</strong> a partir de los siguientes atributos de la mib VMWARE-RESOURCES-MIB:<br><br><strong>VMWARE-RESOURCES-MIB::kbTx (GAUGE):</strong> <strong>VMWARE-RESOURCES-MIB::kbRx (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_mem_cfg',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>vmMemSize</strong> a partir de los siguientes atributos de la mib VMWARE-VMINFO-MIB:<br><br><strong>VMWARE-VMINFO-MIB::vmMemSize (GAUGE):</strong> "Memory configured for this vm. (MB) "
',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_vm_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>running|notRunning</strong> a partir de los siguientes atributos de la mib VMWARE-VMINFO-MIB:<br><br><strong>VMWARE-VMINFO-MIB::vmGuestState (GAUGE):</strong> "Guest operating system ON or OFF."
',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_vm_glob_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>running|notRunning</strong> a partir de los siguientes atributos de la mib VMWARE-VMINFO-MIB:<br><br><strong>VMWARE-VMINFO-MIB::vmGuestState (GAUGE):</strong> "Guest operating system ON or OFF."
',
	);

	$TIPS[]=array(
		'id_ref' => 'vmware_vm_glob_mem',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>running|notRunning</strong> a partir de los siguientes atributos de la mib VMWARE-VMINFO-MIB:<br><br><strong>VMWARE-VMINFO-MIB::vmGuestState (GAUGE):</strong> "Guest operating system ON or OFF."
<strong>VMWARE-VMINFO-MIB::vmMemSize (GAUGE):</strong> "Memory configured for this vm. (MB) "
',
	);

?>
