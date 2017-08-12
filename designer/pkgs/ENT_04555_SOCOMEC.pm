#---------------------------------------------------------------------------
package ENT_04555_SOCOMEC;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
$ENT_04555_SOCOMEC::ENTERPRISE_PREFIX='04555';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

%TABLE_APPS =(
	'TABLA DE DATOS DE ENTRADA' => {

      'col_filters' => '#numeric_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20',
      'col_sorting' => 'int.str.str.str.str',

		'oid_cols' => 'socoupsInputLineIndex_socoupsInputCurrent_socoupsInputVoltage_socoupsInputVoltageMax_socoupsInputVoltageMin',
		'oid_last' => 'SOCOMECUPS-MIB::upsInputTable',
		'name' => 'TABLA DE V/I EN ENTRADA',
		'descr' => 'Muestra la tabla de Voltaje y corriente de entrada',
		'xml_file' => '04555-SOCOMECUPS_INPUT_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'SOCOMECUPS-MIB',
		'aname'=>'app_socups_input_table',
		'range' => 'SOCOMECUPS-MIB::upsInputTable',
		'enterprise' => '04555',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 04555-SOCOMECUPS_INPUT_TABLE.xml -w xml ',
		'itil_type' => 1, 	'apptype'=>'HW.SOCOMEC',
	},

   'TABLA DE DATOS DE SALIDA' => {

      'col_filters' => '#numeric_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20',
      'col_sorting' => 'int.str.str.str',

      'oid_cols' => 'socoupsOutputLineIndex_socoupsOutputVoltage_socoupsOutputCurrent_socoupsOutputPercentLoad',
      'oid_last' => 'SOCOMECUPS-MIB::upsOutputTable',
      'name' => 'TABLA DE V/I/CARGA EN SALIDA',
      'descr' => 'Muestra la tabla de Voltaje, corriente y carga en salida',
      'xml_file' => '04555-SOCOMECUPS_OUTPUT_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'SOCOMECUPS-MIB',
      'aname'=>'app_socups_output_table',
      'range' => 'SOCOMECUPS-MIB::upsOutputTable',
      'enterprise' => '04555',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 04555-SOCOMECUPS-OUTPUT_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'HW.SOCOMEC',
   },


#upsAlarmsTable MIRAR !!!

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@METRICS=(

	{  'name'=> 'ESTADO DE LA BATERIA',   'oid'=>'SOCOMECUPS-MIB::socoupsBatteryStatus.0', 'subtype'=>'socups_battery_status', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'estado', 'include'=>1, 'items'=>'Estado (2:Normal)', 'itil_type' => 4, 'apptype'=>'HW.SOCOMEC' },
	{  'name'=> 'TIEMPO DE USO DE LA BATERIA',   'oid'=>'SOCOMECUPS-MIB::socoupsSecondsOnBattery.0', 'subtype'=>'socups_battery_usage', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{  'name'=> 'TIEMPO ESTIMADO RESTANTE DE LA BATERIA',   'oid'=>'SOCOMECUPS-MIB::socoupsEstimatedMinutesRemaining.0', 'subtype'=>'socups_time_remaining', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 4, 'apptype'=>'HW.SOCOMEC' },
	{  'name'=> 'CARGA ESTIMADA RESTANTE DE LA BATERIA',   'oid'=>'SOCOMECUPS-MIB::socupsEstimatedChargeRemaining.0', 'subtype'=>'socups_charge_remaining', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 4, 'apptype'=>'HW.SOCOMEC' },
	{  'name'=> 'VOLTAJE DE LA BATERIA',     'oid'=>'SOCOMECUPS-MIB::socoupsBatteryVoltage.0', 'subtype'=>'socups_voltage', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'0.1 Volt DC', 'include'=>1, 'items'=>'Voltaje (0.1 Volt DC)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{  'name'=> 'NUMERO DE LINEAS',     'oid'=>'SOCOMECUPS-MIB::socoupsInputNumLines.0|SOCOMECUPS-MIB::socoupsOutputNumLines.0|SOCOMECUPS-MIB::socoupsBypassNumLines.0', 'subtype'=>'socups_num_lines', 'class'=>'SOCOMECUPS-MIB', 'vlabel'=>'num', 'include'=>0, 'items'=>'Lineas de Entrada|Lineas de Salida|Lineas de Bypass', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@METRICS_TAB=(

	{	'name'=> 'VOLTAJE DE ENTRADA EN LINEA',      'oid'=>'socoupsInputVoltage|socoupsInputVoltageMax|socoupsInputVoltageMin', 'subtype'=>'socups_in_voltage', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsInputTable', 'get_iid'=>'socoupsInputLineIndex', 'vlabel'=>'0.1 Volts', 'include'=>1, 'items'=>'Voltaje (0.1 Volts)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{	'name'=> 'CORRIENTE DE ENTRADA EN LINEA',      'oid'=>'socoupsInputCurrent', 'subtype'=>'socups_in_current', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsInputTable', 'get_iid'=>'socoupsInputLineIndex', 'vlabel'=>'0.1 Amp', 'include'=>0, 'items'=>'Corriente (0.1 Amp)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },


	{	'name'=> 'VOLTAJE DE SALIDA EN LINEA',      'oid'=>'socoupsOutputVoltage', 'subtype'=>'socups_out_voltage', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsOutputTable', 'get_iid'=>'socoupsOutputLineIndex', 'vlabel'=>'0.1 Volts', 'include'=>1, 'items'=>'Voltaje (0.1 Volts)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{	'name'=> 'CORRIENTE DE SALIDA EN LINEA',      'oid'=>'socoupsOutputCurrent', 'subtype'=>'socups_out_current', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsOutputTable', 'get_iid'=>'socoupsOutputLineIndex', 'vlabel'=>'0.1 Amp', 'include'=>1, 'items'=>'Corriente (0.1 Amp)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{	'name'=> 'CARGA DE SALIDA EN LINEA',      'oid'=>'socoupsOutputPercentLoad', 'subtype'=>'socups_out_load_perc', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsOutputTable', 'get_iid'=>'socoupsOutputLineIndex', 'vlabel'=>'%', 'include'=>1, 'items'=>'Porcentaje de carga (%)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },


	{	'name'=> 'VOLTAJE DE BYPASS EN LINEA',      'oid'=>'socoupsBypassVoltage', 'subtype'=>'socups_byp_voltage', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsBypassTable', 'get_iid'=>'socoupsBypassLineIndex', 'vlabel'=>'0.1 Volts', 'include'=>0, 'items'=>'Voltaje (0.1 Volts)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },
	{	'name'=> 'CORRIENTE DE BYPASS EN LINEA',      'oid'=>'socoupsBypassCurrent', 'subtype'=>'socups_byp_current', 'class'=>'SOCOMECUPS-MIB', 'range'=>'SOCOMECUPS-MIB::socoupsBypassTable', 'get_iid'=>'socoupsBypassLineIndex', 'vlabel'=>'0.1 Amp', 'include'=>0, 'items'=>'Corriente (0.1 Amp)', 'itil_type' => 1, 'apptype'=>'HW.SOCOMEC' },

);


1;
__END__
