<?php
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
// tip_class=0 => De usuario tip_class=1 => De sistema (no se edita ni se borra)
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
//	Aplicacion
// El id_ref coincide con el aname de la aplicacion
//---------------------------------------------------------------------------------------------------------

      $TIPS[]=array(
         'id_ref' => 'app_mib2_listinterfaces',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene la lista de Interfaces de un dispositivo</strong><br>A partir de las tablas SNMP: RFC1213-MIB::ifTable o IF-MIB::ifXTable'
      );
      $TIPS[]=array(
         'id_ref' => 'app_mibhost_diskp',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene el porcentaje de uso de disco</strong><br>A partir de la tabla HOST-RESOURCES-MIB:hrStorageTable'
      );
      $TIPS[]=array(
         'id_ref' => 'app_cisco_cdptable',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene los vecinos CDP de un equipo</strong><br>A partir de las tablas CISCO-CDP-MIB::cdpCacheTable y RFC1213-MIB::ifTable'
      );
      $TIPS[]=array(
         'id_ref' => 'app_cisco_ccm_dev_pool',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene los device pools definidos en un equipo Cisco</strong><br>A partir de las tablas: CISCO-CCM-MIB::ccmGroupTable, CISCO-CCM-MIB::ccmRegionTable, CISCO-CCM-MIB::ccmTimeZoneTable y CISCO-CCM-MIB::ccmDevicePoolTable'
      );

?>
