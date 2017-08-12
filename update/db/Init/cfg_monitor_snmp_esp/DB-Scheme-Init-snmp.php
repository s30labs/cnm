<?php

	$CFG_MONITOR_SNMP_ESP=array(
	
//---------------------------------------------------------------------------------------------------------
// iparams ==> Parametros internos (predefinidos en cada metrica. No por el usuario).
// Permiten entre otras cosas de futuro manejar eficientemente la cache en las metricas especiales.
// txt >> Es la posicion del pattern (valor configurado por el usuario)
// v1 >> Es la posicion de primera variable a considerar en la funcion fx dada.
// Las posiciones dependen de la definicion del campo oid oid1_oid2_...oidN
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
// fx=match
//---------------------------------------------------------------------------------------------------------
		array(
         'name' => 'esp_proc_mibhost',
         'class' => 'MIB-HOST',
			'lapse' => 300,
         'description' => 'MONITORIZAR UN PROCESO CONCRETO',
         'items' => 'Num. Procesos',
         'oid' => 'hrSWRunName_hrSWRunPerfCPU_hrSWRunPerfMem',
         'get_iid' => '1',
#oidn
         'info' => 'Cuenta el número de ocurrencias del proceso especificado en la tabla de procesos HOST-RESOURCES-MIB::hrSWRunTable.',
         'module' => 'mod_snmp_walk',
         'mtype' => 'STD_BASEIP1',
   'fx' => 'match',
         'vlabel' => 'num',
         'mode' => 'GAUGE',
   'label' => 'Proceso',
   		'iparams' => 'txt=1;v1=2',
# realmente myrange usa dos tablas hrSWRunTable y hrSWRunPerfTable
			'myrange' => 'HOST-RESOURCES-MIB::hrSWRunPerfTable',
         'enterprise' => '0',
			'include'=> 1,
#top_value
			'itil_type'=>4,   'apptype'=>'os.generic',
		),



//---------------------------------------------------------------------------------------------------------
// fx=sum
//---------------------------------------------------------------------------------------------------------
      array(
         'name' => 'esp_cpu_mibhost',
         'class' => 'MIB-HOST',
			'lapse' => 300,
         'description' => 'CPU CONSUMIDA POR UN PROCESO CONCRETO',
         'items' => 'Num. Ciclos',
         'oid' => 'hrSWRunName_hrSWRunPerfCPU_hrSWRunPerfMem',
         'get_iid' => '1',
#oidn
         'info' => 'Obtiene la cantidad total de CPU utilizada por el proceso especificado, a partir del atributo HOST-RESOURCES-MIB::hrSWRunPerfCPU. Considera todas las instancias de dicho proceso en la tabla HOST-RESOURCES-MIB::hrSWRunTable.
HOST-RESOURCES-MIB::hrSWRunPerfCPU (Integer32) The number of centi-seconds of the total systems CPU resources consumed by this process.  Note that on a multi-processor system, this value may increment by more than one centi-second in one centi-second of real (wall clock) time.',
         'module' => 'mod_snmp_walk',
         'mtype' => 'STD_BASEIP1',
   'fx' => 'sum',
         'vlabel' => 'ciclos',
         'mode' => 'GAUGE',
   'label' => 'CPU Proceso',
   		'iparams' => 'txt=1;v1=2',
# realmente myrange usa dos tablas hrSWRunTable y hrSWRunPerfTable
			'myrange' => 'HOST-RESOURCES-MIB::hrSWRunPerfTable',
         'enterprise' => '0',
			'include'=> 1,
#top_value
			'itil_type'=>4,   'apptype'=>'os.generic',
      ),


      array(
         'name' => 'esp_mem_mibhost',
         'class' => 'MIB-HOST',
			'lapse' => 300,
         'description' => 'MEMORIA CONSUMIDA POR UN PROCESO CONCRETO',
         'items' => 'KBytes',
         'oid' => 'hrSWRunName_hrSWRunPerfCPU_hrSWRunPerfMem',
         'get_iid' => '1',
#oidn
         'info' => 'Obtiene la cantidad total de memoria utilizada por el proceso especificado, a partir del atributo HOST-RESOURCES-MIB::hrSWRunPerfMem. Considera todas las instancias de dicho proceso en la tabla HOST-RESOURCES-MIB::hrSWRunTable.
HOST-RESOURCES-MIB::hrSWRunPerfMem (Integer32) The total amount of real system memory allocated to this process.',

         'module' => 'mod_snmp_walk',
         'mtype' => 'STD_BASEIP1',
   'fx' => 'sum',
         'vlabel' => 'kbytes',
         'mode' => 'GAUGE',
   'label' => 'MEMORIA Proceso',
   		'iparams' => 'txt=1;v1=3',
# realmente myrange usa dos tablas hrSWRunTable y hrSWRunPerfTable
			'myrange' => 'HOST-RESOURCES-MIB::hrSWRunPerfTable',
         'enterprise' => '0',
			'include'=> 1,
#top_value
			'itil_type'=>4,   'apptype'=>'os.generic',
      ),


//---------------------------------------------------------------------------------------------------------
// fx=subkey
//---------------------------------------------------------------------------------------------------------
      array(
         'name' => 'esp_vmware_vm_mem',
         'class' => 'VMWARE-VMINFO-MIB',
			'lapse' => 300,
         'description' => 'VMWARE: MEMORIA EN MAQUINA VIRTUAL',
			'items' => 'cpuUtil',
			'oid' => 'vmIdx_vmVMID_vmDisplayName&cpuUtil',
         'get_iid' => '1',
#oidn
         'info' => 'VMWARE-VMINFO-MIB|vmIdx_vmVMID_vmDisplayName|OCTET STRING (0..64)|A textual description of this running piece of software, including the manufacturer, revision,  and the name by which it is commonly known. If this software was installed locally, this should be the same string as used in the corresponding hrSWInstalledName. Mide el numero de ocurrencias del proceso especificado en la tabla descrita.',
         'name' => 'esp_vmware_vm_cpu',
         'description' => 'VMWARE: USO DE CPU EN MAQUINA VIRTUAL',
         'info' => 'VMWARE-VMINFO-MIB|cpuUtil|INTEGER|Time the virtual machine has been running on the CPU (seconds).',
         'module' => 'mod_snmp_walk',
         'mtype' => 'STD_BASEIP1',
	'fx' => 'subkey',
   		'vlabel' => 'Porc',
         'mode' => 'COUNTER',
         'mtype' => 'STD_BASEIP1',
   		'iparams' => 'txt=0',
			'myrange' => 'VMWARE-VMINFO-MIB::vmTable',
         'enterprise' => '6876',
			'include'=> 1,
			'itil_type'=>4,   'apptype'=>'os.vmware',
      ),
      array(
         'name' => 'esp_vmware_vm_mem',
         'description' => 'VMWARE: USO DE MEMORIA EN MAQUINA VIRTUAL',
         'info' => 'VMWARE-VMINFO-MIB|memConfigured|INTEGER|Amount of memory the vm was configured with. (KB)<br>VMWARE-VMINFO-MIB|memUtil|INTEGER|Amount of memory utilized by the vm. (KB; instantaneous)',
         'oid' => 'vmIdx_vmVMID_vmDisplayName&memConfigured_memUtil',
         'class' => 'VMWARE-VMINFO-MIB',
			'lapse' => 300,
         'module' => 'mod_snmp_walk',
         'fx' => 'subkey',
         'get_iid' => '1',
         'items' => 'memConfigured|memUtil',
         'vlabel' => 'KB',
         'label' => 'Uso de Memoria',
         'mode' => 'GAUGE',
   'label' => 'Uso de CPU',
   		'iparams' => 'txt=0',
			'myrange' => 'VMWARE-VMINFO-MIB::memTable',
         'enterprise' => '6876',
			'include'=> 1,
#top_value
			'itil_type'=>4,   'apptype'=>'os.vmware',
      ),

	);
?>
