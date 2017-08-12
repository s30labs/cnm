<?php
      $TIPS[]=array(
         'id_ref' => 'app_vmware_vminfo_table',  'tip_type' => 'app', 'url' => '',
         'date' => 1430853107,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra las maquinas virtuales configuradas en el sistema</strong><br>Utiliza la tabla SNMP VMWARE-VMINFO-MIB::vmTable (Enterprise=06876)<br><br><strong>VMWARE-VMINFO-MIB::vmDisplayName (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmConfigFile (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmGuestOS (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmMemSize (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmState (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmVMID (GAUGE):</strong><br><strong>VMWARE-VMINFO-MIB::vmGuestState (GAUGE):</strong><br>',
      );


      $TIPS[]=array(
         'id_ref' => 'app_vmware_get_info',  'tip_type' => 'app', 'url' => '',
         'date' => 1430853107,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra informacion basica sobre el equipo</strong><br>Utiliza atributos de la mib VMWARE-SYSTEM-MIB:<br><br><strong>VMWARE-SYSTEM-MIB::vmwProdName (GAUGE):</strong>&nbsp;"This products name.
          VIM Property: AboutInfo.name
          https://esx.example.com/mob/?moid=ServiceInstance&doPath=content%2eabout"
<br><strong>VMWARE-SYSTEM-MIB::vmwProdVersion (GAUGE):</strong>&nbsp;"The products version release identifier. Format is Major.Minor.Update
          VIM Property: AboutInfo.version
          https://esx.example.com/mob/?moid=ServiceInstance&doPath=content%2eabout"
<br><strong>VMWARE-SYSTEM-MIB::vmwProdOID (GAUGE):</strong>&nbsp;<br><strong>VMWARE-SYSTEM-MIB::vmwProdBuild (GAUGE):</strong>&nbsp;"This identifier represents the most specific identifier.
          VIM Property: AboutInfo.build
          https://esx.example.com/mob/?moid=ServiceInstance&doPath=content%2eabout"
<br>',
      );


?>
