<?
	$TIPS[]=array(
		'id_ref' => 'app_mib2_diskuse',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Uso del disco y particiones definidas</strong><br>Utiliza la tabla SNMP HOST-RESOURCES-MIB::hrStorageTable (Enterprise=00000)<br><br><strong>HOST-RESOURCES-MIB::hrStorageDescr (GAUGE):</strong><br>"A description of the type and instance of the storage
         described by this entry."
<strong>HOST-RESOURCES-MIB::hrStorageAllocationUnits (GAUGE):</strong><br>"The size, in bytes, of the data objects allocated
         from this pool.  If this entry is monitoring sectors,
         blocks, buffers, or packets, for example, this number
         will commonly be greater than one.  Otherwise this
         number will typically be one."
<strong>HOST-RESOURCES-MIB::hrStorageSize (GAUGE):</strong><br>"The size of the storage represented by this entry, in
         units of hrStorageAllocationUnits. This object is
         writable to allow remote configuration of the size of
         the storage area in those cases where such an
         operation makes sense and is possible on the
         underlying system. For example, the amount of main
         memory allocated to a buffer pool might be modified or
         the amount of disk space allocated to virtual memory
         might be modified."
<strong>HOST-RESOURCES-MIB::hrStorageUsed (GAUGE):</strong><br>"The amount of the storage represented by this entry
         that is allocated, in units of
         hrStorageAllocationUnits."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_processesrunning',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la lista de procesos que se estan ejecutando en la maquina, junto con el uso de CPU y memoria</strong><br>Utiliza la tabla SNMP HOST-RESOURCES-MIB::hrSWRunTable (Enterprise=00000)<br><br><strong>HOST-RESOURCES-MIB::hrSWRunName (GAUGE):</strong><br>"A textual description of this running piece of
         software, including the manufacturer, revision,  and
         the name by which it is commonly known.  If this
         software was installed locally, this should be the
         same string as used in the corresponding
         hrSWInstalledName."
<strong>HOST-RESOURCES-MIB::hrSWRunStatus (GAUGE):</strong><br>"The status of this running piece of software.
         Setting this value to invalid(4) shall cause this
         software to stop running and to be unloaded. Sets to
         other values are not valid."
<strong>HOST-RESOURCES-MIB::hrSWRunPerfCPU (GAUGE):</strong><br>"The number of centi-seconds of the total systems CPU
         resources consumed by this process.  Note that on a
         multi-processor system, this value may increment by
         more than one centi-second in one centi-second of real
         (wall clock) time."
<strong>HOST-RESOURCES-MIB::hrSWRunPerfMem (GAUGE):</strong><br>"The total amount of real system memory allocated to
         this process."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_softwareinstalled',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Lista de programas instalados</strong><br>Utiliza la tabla SNMP HOST-RESOURCES-MIB::hrSWInstalledTable (Enterprise=00000)<br><br><strong>HOST-RESOURCES-MIB::hrSWInstalledName (GAUGE):</strong><br>"A textual description of this installed piece of
         software, including the manufacturer, revision, the
         name by which it is commonly known, and optionally,
         its serial number."
<strong>HOST-RESOURCES-MIB::hrSWInstalledDate (GAUGE):</strong><br>"The last-modification date of this application as it
         would appear in a directory listing.
 
         If this information is not known, then this variable
         shall have the value corresponding to January 1, year
         0000, 00:00:00.0, which is encoded as
         (hex)00 00 01 01 00 00 00 00."
',
	);

?>
