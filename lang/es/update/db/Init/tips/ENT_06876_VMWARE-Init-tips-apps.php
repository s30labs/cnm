<?
	$TIPS[]=array(
		'id_ref' => 'app_vmware_vminfo_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra las maquinas virtuales configuradas en el sistema</strong><br>Utiliza la tabla SNMP VMWARE-VMINFO-MIB::vmTable (Enterprise=06876)<br><br><strong>VMWARE-VMINFO-MIB::vmDisplayName (GAUGE):</strong><br>"Name by which this vm is displayed."
<strong>VMWARE-VMINFO-MIB::vmConfigFile (GAUGE):</strong><br>"Path to the configuration file for this vm."
<strong>VMWARE-VMINFO-MIB::vmGuestOS (GAUGE):</strong><br>"Operating system running on this vm."
<strong>VMWARE-VMINFO-MIB::vmMemSize (GAUGE):</strong><br>"Memory configured for this vm. (MB) "
<strong>VMWARE-VMINFO-MIB::vmState (GAUGE):</strong><br>"Virtual machine ON or OFF."
<strong>VMWARE-VMINFO-MIB::vmVMID (GAUGE):</strong><br>"If a VM is active, an ID is assigned to it (like a pid). Some VMs may 
       have been configured but not running. Information about these VMs without
       VM IDs is also displayed, so we cant use VM ID as the tables index."
<strong>VMWARE-VMINFO-MIB::vmGuestState (GAUGE):</strong><br>"Guest operating system ON or OFF."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_vmware_get_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion basica sobre el equipo</strong><br>Utiliza atributos de la mib VMWARE-SYSTEM-MIB:<br><br><strong>VMWARE-SYSTEM-MIB::vmwProdName (GAUGE):</strong>&nbsp;"The product name."
<br><strong>VMWARE-SYSTEM-MIB::vmwProdVersion (GAUGE):</strong>&nbsp;"Product version."
<br><strong>VMWARE-SYSTEM-MIB::vmwProdOID (GAUGE):</strong>&nbsp;"Version-specific unique OID for product in the VMware MIB."
<br><strong>VMWARE-SYSTEM-MIB::vmwProdBuild (GAUGE):</strong>&nbsp;"Build number of the product."
<br>',
	);

?>
