#---------------------------------------------------------------------------
package ENT_00311_WINDOWS_NT_PERFORMANCE;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00311_WINDOWS_NT_PERFORMANCE::ENTERPRISE_PREFIX='00311';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

%ENT_00311_WINDOWS_NT_PERFORMANCE::TABLE_APPS =(
	'TABLA DE USO DE CPU' => {

      'col_filters' => '#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.20.20.20.20.20.20.20.20',
      'col_sorting' => 'int.int.int.int.int.int.int.int.int.int.int.',

		'oid_cols' => 'cpuprocessorIndex_cpuPercentProcessorTime_cpuPercentUserTime_cpuPercentPrivilegedTime_cpuInterruptsPerSec_cpuPercentDPCTime_cpuPercentInterruptTime_cpuDPCsQueuedPerSec_cpuDPCRate_cpuDPCBypassesPerSec_cpuAPCBypassesPerSec',
		'oid_last' => 'WINDOWS-NT-PERFORMANCE::cpuprocessorTable',
		'name' => 'TABLA DE USO DE CPU',
		'descr' => 'Muestra la tabla de uso de CPU de un Windows NT 4.0',
		'xml_file' => '00311-MICROSOFT-WINDOWS-NT-CPU_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'WINDOWS-NT',
		'aname'=>'app_winnt_cpu_usage',
		'range' => 'WINDOWS-NT-PERFORMANCE::cpuprocessorTable',
		'enterprise' => '00311',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00311-MICROSOFT-WINDOWS-NT-CPU_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'SO.WINDOWS',
	},

);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00311_WINDOWS_NT_PERFORMANCE::METRICS=(

	{  'name'=> 'MEMORIA DISPONIBLE',      'oid'=>'WINDOWS-NT-PERFORMANCE::memoryAvailableBytes.0', 'subtype'=>'winnt_memory_avail_bytes', 'class'=>'WINDOWS-NT', 'itil_type' => 1, 'apptype'=>'SO.WINDOWS' },
	{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT', 'itil_type' => 1, 'apptype'=>'SO.WINDOWS' },
   {	'name'=> 'MEMORIA - ERRORES',      'oid'=>'WINDOWS-NT-PERFORMANCE::memoryPageFaultsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryTransitionFaultsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryDemandZeroFaultsPerSec.0', 'subtype'=>'winnt_memory_faults', 'class'=>'WINDOWS-NT', 'itil_type' => 1, 'apptype'=>'SO.WINDOWS' },
   {  'name'=> 'MEMORIA - PAGINACION',      'oid'=>'WINDOWS-NT-PERFORMANCE::memoryPageReadsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryPageWritesPerSec.0', 'subtype'=>'winnt_memory_page_rw', 'class'=>'WINDOWS-NT', 'itil_type' => 1, 'apptype'=>'SO.WINDOWS' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00311_WINDOWS_NT_PERFORMANCE::METRICS_TAB=(

	{	'name'=> 'DISCO LIBRE (%)',      'oid'=>'WINDOWS-NT-PERFORMANCE::ldiskPercentFreeSpace', 'subtype'=>'winnt_ldisk_free_perc', 'class'=>'WINDOWS-NT', 'range'=>'WINDOWS-NT-PERFORMANCE::ldisklogicalDiskTable', 'get_iid'=>'ldisklogicalDiskInstance', 'itil_type' => 1, 'apptype'=>'SO.WINDOWS' },


);


1;
__END__
