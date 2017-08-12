#---------------------------------------------------------------------------
package MIB2_025_HOST_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_000_BASE::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%MIB2_025_HOST_MIB::TABLE_APPS =(

	'PROCTABLE' => {

      'col_filters' => '#text_filter.#select_filter.#text_filter.#text_filter',
		'col_widths' => '25.15.25.25',
		'col_sorting' => 'str.int.int.int',

      'oid_cols' => 'hrSWRunName_hrSWRunStatus_hrSWRunPerfCPU_hrSWRunPerfMem',
      'oid_last' => 'HOST-RESOURCES-MIB::hrSWRunTable',
      'name' => 'PROCESOS EN CURSO',
      'descr' => 'Muestra la lista de procesos que se estan ejecutando en la maquina, junto con el uso de CPU y memoria',
      'xml_file' => '00000-MIBHOST-CPU.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-HOST',
      'aname'=>'app_mib2_processesrunning',
      'range' => 'HOST-RESOURCES-MIB::hrSWRunTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIBHOST-CPU.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.HOST-MIB',
	},


   'DISKTABLE' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '35.25.15.15',
      'col_sorting' => 'str.int.int.int',

      'oid_cols' => 'hrStorageDescr_hrStorageAllocationUnits_hrStorageSize_hrStorageUsed',

      'oid_last' => 'HOST-RESOURCES-MIB::hrStorageTable',
      'name' => 'USO DE DISCO',
      'descr' => 'Uso del disco y particiones definidas',
      'xml_file' => '00000-MIBHOST-DISK.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-HOST',
      'aname'=>'app_mib2_diskuse',
      'range' => 'HOST-RESOURCES-MIB::hrStorageTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIBHOST-DISK.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.HOST-MIB',
   },


   'SWTABLE' => {

      'col_filters' => '#text_filter,#text_filter',
      'col_widths' => '55.20',
      'col_sorting' => 'str.str',

      'oid_cols' => 'hrSWInstalledName_hrSWInstalledDate',
      'oid_last' => 'HOST-RESOURCES-MIB::hrSWInstalledTable',
      'name' => 'SOFTWARE INSTALADO',
      'descr' => 'Lista de programas instalados',
      'xml_file' => '00000-MIBHOST-SW.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-HOST',
      'aname'=>'app_mib2_softwareinstalled',
      'range' => 'HOST-RESOURCES-MIB::hrSWInstalledTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIBHOST-SW.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.HOST-MIB',

   },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_025_HOST_MIB::METRICS=(

#	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN' },
#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_025_HOST_MIB::METRICS_TAB=(

#	{	'name'=> 'NUMERO DE CLIENTES EN AP',  'oid'=>'bsnAPIfLoadNumOfClients', 'subtype'=>'airspace_nclients', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable', 'get_iid'=>'bsnAPDot3MacAddress' },

#	{	'name'=> 'ESTADO DEL AP',  'oid'=>'bsnAPOperationStatus|bsnAPAdminStatus', 'subtype'=>'airspace_ap_status', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPTable', 'get_iid'=>'bsnApIpAddress' },

#	{	'name'=> 'ESTADO DE PERFILES DEL AP',  'oid'=>'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState', 'subtype'=>'airspace_ap_profiles', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable', 'get_iid'=>'bsnAPDot3MacAddress' },

#	{	'name'=> 'USO DE MEMORIA EN VM',  'oid'=>'memUtil|memConfigured', 'subtype'=>'vmware_mem_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::memTable', 'get_iid'=>'memVMID' },
#	{	'name'=> 'USO DE DISCO EN VM',  'oid'=>'kbRead|kbWritten', 'subtype'=>'vmware_disk_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwHBATable', 'get_iid'=>'hbaName' },
#	{	'name'=> 'USO DE RED EN VM',  'oid'=>'kbTx|kbRx', 'subtype'=>'vmware_net_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwNetTable', 'get_iid'=>'netName' },


);


1;
__END__
