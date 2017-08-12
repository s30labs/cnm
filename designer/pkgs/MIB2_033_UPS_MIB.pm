#---------------------------------------------------------------------------
package MIB2_033_UPS_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_033_UPS_MIB::ENTERPRISE_PREFIX='00000';


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

%MIB2_033_UPS_MIB::TABLE_APPS =(
	'TABLA DE DATOS DE ENTRADA' => {

      'col_filters' => '#numeric_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20',
      'col_sorting' => 'int.str.str.str',

		'oid_cols' => 'upsInputLineIndex_upsInputFrequency_upsInputVoltage_upsInputTruePower',
		'oid_last' => 'UPS-MIB::upsInputTable',
		'name' => 'TABLA DE FREC/V/I EN ENTRADA',
		'descr' => 'Muestra la tabla de frecuencia, Voltaje y potencia de entrada',
		'xml_file' => '00000-33-UPS_INPUT_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'UPS-MIB',
		'aname'=>'app_ups_input_table',
		'range' => 'UPS-MIB::upsInputTable',
		'enterprise' => '00000',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-33-UPS-INPUT_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.UPS-MIB',
	},

   'TABLA DE DATOS DE SALIDA' => {

      'col_filters' => '#numeric_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20',
      'col_sorting' => 'int.str.str.str.str',

      'oid_cols' => 'upsOutputLineIndex_upsOutputVoltage_upsOutputCurrent_upsOutputPower_upsOutputPercentLoad',
      'oid_last' => 'UPS-MIB::upsOutputTable',
      'name' => 'TABLA DE V/I/POT/CARGA EN SALIDA',
      'descr' => 'Muestra la tabla de Voltaje, corriente, potencia y carga en salida',
      'xml_file' => '00000-33-UPS_OUTPUT_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'UPS-MIB',
      'aname'=>'app_ups_output_table',
      'range' => 'UPS-MIB::upsOutputTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-33-UPS-OUTPUT_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.UPS-MIB',
   },


#upsAlarmsTable MIRAR !!!

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_033_UPS_MIB::METRICS=(

#upsInputLineBads  Wrong Type (should be Counter32): NULL
#upsOutputFrequency  ??
#upsBypassFrequency  ??
#upsAlarmsPresent Wrong Type (should be Gauge32 or Unsigned32): Counter32: 0

	{  'name'=> 'ESTADO DE LA BATERIA',   'oid'=>'UPS-MIB::upsBatteryStatus.0', 'subtype'=>'ups_battery_status', 'class'=>'UPS-MIB', 'vlabel'=>'estado', 'include'=>1, 'items'=>'Estado (2:Normal)', 'itil_type' => 4, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'TIEMPO DE USO DE LA BATERIA',   'oid'=>'UPS-MIB::upsSecondsOnBattery.0', 'subtype'=>'ups_battery_usage', 'class'=>'UPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'TIEMPO ESTIMADO RESTANTE DE LA BATERIA',   'oid'=>'UPS-MIB::upsEstimatedMinutesRemaining.0', 'subtype'=>'ups_time_estimate', 'class'=>'UPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'CARGA ESTIMADA RESTANTE DE LA BATERIA',   'oid'=>'UPS-MIB::upsEstimatedChargeRemaining.0', 'subtype'=>'ups_charge_estimate', 'class'=>'UPS-MIB', 'vlabel'=>'num', 'include'=>1, 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'VOLTAJE DE LA BATERIA',     'oid'=>'UPS-MIB::upsBatteryVoltage.0', 'subtype'=>'ups_voltage', 'class'=>'UPS-MIB', 'vlabel'=>'0.1 Volt DC', 'include'=>1, 'items'=>'Voltios (0.1 Volt DC)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'CORRIENTE DE LA BATERIA',     'oid'=>'UPS-MIB::upsBatteryCurrent.0', 'subtype'=>'ups_current', 'class'=>'UPS-MIB', 'vlabel'=>'0.1 Amp DC', 'include'=>0, 'items'=>'Amperios (0.1 Amp DC)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'TEMPERATURA DE LA BATERIA',     'oid'=>'UPS-MIB::upsBatteryTemperature.0', 'subtype'=>'ups_temperature', 'class'=>'UPS-MIB', 'vlabel'=>'Grados', 'include'=>1 , 'items'=>'Grados Centigrados', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{  'name'=> 'NUMERO DE LINEAS',     'oid'=>'UPS-MIB::upsInputNumLines.0|UPS-MIB::upsOutputNumLines.0|UPS-MIB::upsBypassNumLines.0', 'subtype'=>'ups_num_lines', 'class'=>'UPS-MIB', 'vlabel'=>'num', 'include'=>0, 'items'=>'Lineas de Entrada|Lineas de Salida|Lineas de Bypass', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_033_UPS_MIB::METRICS_TAB=(

	{	'name'=> 'FRECUENCIA DE ENTRADA EN LINEA',      'oid'=>'upsInputFrequency', 'subtype'=>'ups_in_freq', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsInputTable', 'get_iid'=>'upsInputLineIndex', 'vlabel'=>'0.1 Hertz', 'include'=>0, 'items'=>'Frecuencia (0.1 Hertz)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'VOLTAJE DE ENTRADA EN LINEA',      'oid'=>'upsInputVoltage', 'subtype'=>'ups_in_voltage', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsInputTable', 'get_iid'=>'upsInputLineIndex', 'vlabel'=>'RMS Volts', 'include'=>1, 'items'=>'Voltaje (RMS Volts)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'CORRIENTE DE ENTRADA EN LINEA',      'oid'=>'upsInputCurrent', 'subtype'=>'ups_in_current', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsInputTable', 'get_iid'=>'upsInputLineIndex', 'vlabel'=>'0.1 RMS Amp', 'include'=>0, 'items'=>'Corriente (0.1 RMS Amp)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'POTENCIA DE ENTRADA EN LINEA',      'oid'=>'upsInputTruePower', 'subtype'=>'ups_in_power', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsInputTable', 'get_iid'=>'upsInputLineIndex', 'vlabel'=>'Watts', 'include'=>0,  'items'=>'Potencia (Watts)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB'},


	{	'name'=> 'VOLTAJE DE SALIDA EN LINEA',      'oid'=>'upsOutputVoltage', 'subtype'=>'ups_out_voltage', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsOutputTable', 'get_iid'=>'upsOutputLineIndex', 'vlabel'=>'RMS Volts', 'include'=>1, 'items'=>'Voltaje (RMS Volts)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'CORRIENTE DE SALIDA EN LINEA',      'oid'=>'upsOutputCurrent', 'subtype'=>'ups_out_current', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsOutputTable', 'get_iid'=>'upsOutputLineIndex', 'vlabel'=>'0.1 RMS Amp', 'include'=>0, 'items'=>'Corriente (0.1 RMS Amp)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'POTENCIA DE SALIDA EN LINEA',      'oid'=>'upsOutputPower', 'subtype'=>'ups_out_power', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsOutputTable', 'get_iid'=>'upsOutputLineIndex', 'vlabel'=>'Watts', 'include'=>1, 'items'=>'Potencia (Watts)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'CARGA DE SALIDA EN LINEA',  'oid'=>'upsOutputPercentLoad', 'subtype'=>'ups_out_load_perc', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsOutputTable', 'get_iid'=>'upsOutputLineIndex', 'vlabel'=>'%', 'include'=>1, 'items'=>'Porcentaje de Carga (%)', 'apptype'=>'NET.UPS-MIB' },


	{	'name'=> 'VOLTAJE DE BYPASS EN LINEA',      'oid'=>'upsBypassVoltage', 'subtype'=>'ups_byp_voltage', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsBypassTable', 'get_iid'=>'upsBypassLineIndex', 'vlabel'=>'RMS Volts', 'include'=>0, 'items'=>'Voltaje (RMS Volts)',  'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'CORRIENTE DE BYPASS EN LINEA',      'oid'=>'upsBypassCurrent', 'subtype'=>'ups_byp_current', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsBypassTable', 'get_iid'=>'upsBypassLineIndex', 'vlabel'=>'0.1 RMS Amp', 'include'=>0, 'items'=>'Corriente (0.1 RMS Amp)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
	{	'name'=> 'POTENCIA DE BYPASS EN LINEA',      'oid'=>'upsBypassPower', 'subtype'=>'ups_byp_power', 'class'=>'UPS-MIB', 'range'=>'UPS-MIB::upsBypassTable', 'get_iid'=>'upsBypassLineIndex', 'vlabel'=>'Watts', 'include'=>0, 'items'=>'Potencia (Watts)', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },

);


1;
__END__
