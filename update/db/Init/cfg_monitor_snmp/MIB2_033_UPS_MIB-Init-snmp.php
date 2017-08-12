<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_battery_status',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'ESTADO DE LA BATERIA',
            'items' => 'Estado (2:Normal)',
            'oid' => '.1.3.6.1.2.1.33.1.2.1.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsBatteryStatus.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'estado',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsBatteryStatus.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '4',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_battery_usage',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'TIEMPO DE USO DE LA BATERIA',
            'items' => 'upsSecondsOnBattery.0',
            'oid' => '.1.3.6.1.2.1.33.1.2.2.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsSecondsOnBattery.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsSecondsOnBattery.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_time_estimate',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'TIEMPO ESTIMADO RESTANTE DE LA BATERIA',
            'items' => 'upsEstimatedMinutesRemaining.0',
            'oid' => '.1.3.6.1.2.1.33.1.2.3.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsEstimatedMinutesRemaining.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsEstimatedMinutesRemaining.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_charge_estimate',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CARGA ESTIMADA RESTANTE DE LA BATERIA',
            'items' => 'upsEstimatedChargeRemaining.0',
            'oid' => '.1.3.6.1.2.1.33.1.2.4.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsEstimatedChargeRemaining.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsEstimatedChargeRemaining.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_voltage',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'VOLTAJE DE LA BATERIA',
            'items' => 'Voltios (0.1 Volt DC)',
            'oid' => '.1.3.6.1.2.1.33.1.2.5.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsBatteryVoltage.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 Volt DC',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsBatteryVoltage.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_current',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CORRIENTE DE LA BATERIA',
            'items' => 'Amperios (0.1 Amp DC)',
            'oid' => '.1.3.6.1.2.1.33.1.2.6.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsBatteryCurrent.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 Amp DC',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsBatteryCurrent.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_temperature',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'TEMPERATURA DE LA BATERIA',
            'items' => 'Grados Centigrados',
            'oid' => '.1.3.6.1.2.1.33.1.2.7.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsBatteryTemperature.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'Grados',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsBatteryTemperature.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_num_lines',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'NUMERO DE LINEAS',
            'items' => 'Lineas de Entrada|Lineas de Salida|Lineas de Bypass',
            'oid' => '.1.3.6.1.2.1.33.1.3.2.0|.1.3.6.1.2.1.33.1.4.3.0|.1.3.6.1.2.1.33.1.5.2.0',
            'get_iid' => '',
            'oidn' => 'UPS-MIB::upsInputNumLines.0|UPS-MIB::upsOutputNumLines.0|UPS-MIB::upsBypassNumLines.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsInputNumLines.0',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_in_freq',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'FRECUENCIA DE ENTRADA EN LINEA',
            'items' => 'Frecuencia (0.1 Hertz)',
            'oid' => '.1.3.6.1.2.1.33.1.3.3.1.2.IID',
            'get_iid' => 'upsInputLineIndex',
            'oidn' => 'upsInputFrequency.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 Hertz',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsInputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_in_voltage',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'VOLTAJE DE ENTRADA EN LINEA',
            'items' => 'Voltaje (RMS Volts)',
            'oid' => '.1.3.6.1.2.1.33.1.3.3.1.3.IID',
            'get_iid' => 'upsInputLineIndex',
            'oidn' => 'upsInputVoltage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'RMS Volts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsInputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_in_current',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CORRIENTE DE ENTRADA EN LINEA',
            'items' => 'Corriente (0.1 RMS Amp)',
            'oid' => '.1.3.6.1.2.1.33.1.3.3.1.4.IID',
            'get_iid' => 'upsInputLineIndex',
            'oidn' => 'upsInputCurrent.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 RMS Amp',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsInputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_in_power',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'POTENCIA DE ENTRADA EN LINEA',
            'items' => 'Potencia (Watts)',
            'oid' => '.1.3.6.1.2.1.33.1.3.3.1.5.IID',
            'get_iid' => 'upsInputLineIndex',
            'oidn' => 'upsInputTruePower.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'Watts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsInputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_out_voltage',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'VOLTAJE DE SALIDA EN LINEA',
            'items' => 'Voltaje (RMS Volts)',
            'oid' => '.1.3.6.1.2.1.33.1.4.4.1.2.IID',
            'get_iid' => 'upsOutputLineIndex',
            'oidn' => 'upsOutputVoltage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'RMS Volts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsOutputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_out_current',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CORRIENTE DE SALIDA EN LINEA',
            'items' => 'Corriente (0.1 RMS Amp)',
            'oid' => '.1.3.6.1.2.1.33.1.4.4.1.3.IID',
            'get_iid' => 'upsOutputLineIndex',
            'oidn' => 'upsOutputCurrent.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 RMS Amp',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsOutputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_out_power',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'POTENCIA DE SALIDA EN LINEA',
            'items' => 'Potencia (Watts)',
            'oid' => '.1.3.6.1.2.1.33.1.4.4.1.4.IID',
            'get_iid' => 'upsOutputLineIndex',
            'oidn' => 'upsOutputPower.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'Watts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsOutputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_out_load_perc',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CARGA DE SALIDA EN LINEA',
            'items' => 'Porcentaje de Carga (%)',
            'oid' => '.1.3.6.1.2.1.33.1.4.4.1.5.IID',
            'get_iid' => 'upsOutputLineIndex',
            'oidn' => 'upsOutputPercentLoad.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '%',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'UPS-MIB::upsOutputTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_byp_voltage',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'VOLTAJE DE BYPASS EN LINEA',
            'items' => 'Voltaje (RMS Volts)',
            'oid' => '.1.3.6.1.2.1.33.1.5.3.1.2.IID',
            'get_iid' => 'upsBypassLineIndex',
            'oidn' => 'upsBypassVoltage.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'RMS Volts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsBypassTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_byp_current',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'CORRIENTE DE BYPASS EN LINEA',
            'items' => 'Corriente (0.1 RMS Amp)',
            'oid' => '.1.3.6.1.2.1.33.1.5.3.1.3.IID',
            'get_iid' => 'upsBypassLineIndex',
            'oidn' => 'upsBypassCurrent.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => '0.1 RMS Amp',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsBypassTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'ups_byp_power',
            'class' => 'UPS-MIB',
            'lapse' => '300',
            'descr' => 'POTENCIA DE BYPASS EN LINEA',
            'items' => 'Potencia (Watts)',
            'oid' => '.1.3.6.1.2.1.33.1.5.3.1.4.IID',
            'get_iid' => 'upsBypassLineIndex',
            'oidn' => 'upsBypassPower.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'Watts',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '0',
            'myrange' => 'UPS-MIB::upsBypassTable',
            'enterprise' => '0',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'NET.UPS-MIB',
      );


?>
