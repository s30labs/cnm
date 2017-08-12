<?php
// Para mapear evento->alerta el evkey->subtype
// Ejemplo
// 'id_remote_alert' => '10',    'type' => 'snmp',    'subtype' => '0.0',
// 'descr' => 'INICIO DE EQUIPO (Cold Start)',
// 'monitor' => '-',    'vdata' => '-',   'severity' => '1',   'action' => 'SET',   'script' => '-',

// Para probar los traps:
// /usr/local/bin/snmptrap  -v 1 -c public ssoro4a  1.3.6.1.4.1.13716.99 10.2.73.203 0 101 10 1.3.6.1.4.1.13716.666.100.1 s "Este trap funciona"

   $CFG_EVENTS_DATA = array(
#Traps basicos mib-ii -----------------------------------------------------------------
      array(
'process' => 'TRAP-SNMP',	'evkey' => '0.0',				'txt_custom' => 'Cold Start',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '1.0',				'txt_custom' => 'Warm Start',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '2.0',				'txt_custom' => 'Link Down',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '3.0',				'txt_custom' => 'Link Up',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '4.0',				'txt_custom' => 'Authentication Failure',
      ),


#Traps Cisco ---------------------------------------------------------------------------
		#CF
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.10.1.3.6.6', 	'txt_custom' => 'Retirada Compact Flash',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.10.1.3.6.5',	'txt_custom' => 'Insertada Compact Flash',
      ),
		#VTP
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.46.2.6.3',	'txt_custom' => 'Deshabilitado VTP Server',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.46.2.6.4',	'txt_custom' => 'VTP MTU Muy grande',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.46.2.6.7',	'txt_custom' => 'Cambio en puerto de tipo trunk',
      ),

      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.46.2.6.10',	'txt_custom' => 'Creada VLAN',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '9.9.46.2.6.11',	'txt_custom' => 'Eliminada VLAN',
      ),

#Traps Ironport ---------------------------------------------------------------------------
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.1',  'txt_custom' => 'Recurso en modo Conservacion (resourceConservationMode)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.2',  'txt_custom' => 'Cambio de estado en fuente de alimentacion (powerSupplyStatusChange)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.3',  'txt_custom' => 'Temperatura elevada (highTemperature)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.4',  'txt_custom' => 'Error de ventilador (fanFailure)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.5',  'txt_custom' => 'Clave caducada (keyExpiration)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.6',  'txt_custom' => 'Error de actualizacion (updateFailure)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '15497.1.1.2.0.7',  'txt_custom' => 'Cambio de estado del RAID (raidStatusChange)',
      ),

# Traps BlueCoat --------------------------------------------------------------------------
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.1',  'txt_custom' => 'Antivirus Actualizado Correctamente (avAntivirusUpdateSuccess)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.2',  'txt_custom' => 'Error al actualizar antivirus (avAntivirusUpdateFailed)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.3',  'txt_custom' => 'Virus detectado (avVirusDetected)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.4',  'txt_custom' => 'Fichero despachado (avFileServed)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.5',  'txt_custom' => 'Fichero Bloqueado (avFileBlocked)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.6',  'txt_custom' => 'Nuevo Firmware disponible (avNewFirmwareAvailable)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.7',  'txt_custom' => 'Firmware actualizado correctamente (avNewFirmwareAvailable)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.8',  'txt_custom' => 'Error en actualizacion de Firmware (avFirmwareUpdateFailed)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.9',  'txt_custom' => 'Revisar Licencia Antivirus (avAntivirusLicenseWarning)',
      ),
      array(
'process' => 'TRAP-SNMP',  'evkey' => '3417.2.10.3.6.10',  'txt_custom' => 'Aviso ICTM (avICTMWarning)',
      ),


#---------------------------------------------------------------------------------------
      array(
'process' => 'TRAP-SNMP',	'evkey' => '2505.1.4.6..101',	'txt_custom' => '{v2}  (Host={v3})',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '2505.1.2.6..3006',	'txt_custom' => '{v2}',
      ),
      array(
'process' => 'TRAP-SNMP',	'evkey' => '2505.1.5.6..201',		'txt_custom' => '{v2}  (Host={v3})',
      ),
   );

?>
