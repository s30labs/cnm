<?php
      $TIPS[]=array(
         'id_ref' => 'mib2_stp_top_change',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>dot1dStpTopChanges.0</strong> a partir de los siguientes atributos de la mib BRIDGE-MIB:<br><br><strong>BRIDGE-MIB::dot1dStpTopChanges.0 (COUNTER):</strong> "The total number of topology changes detected by
                       this bridge since the management entity was last
                       reset or initialized."
',
      );


      $TIPS[]=array(
         'id_ref' => 'stp_port_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>forwarding(5)|disabled(1)|blocking(2)|broken(6)|listening(3)|learning(4)</strong> a partir de los siguientes atributos de la mib BRIDGE-MIB:<br><br><strong>BRIDGE-MIB::dot1dStpPortState (GAUGE):</strong> "The ports current state as defined by
                       application of the Spanning Tree Protocol.  This
                       state controls what action a port takes on
                       reception of a frame.  If the bridge has detected
                       a port that is malfunctioning it will place that
                       port into the broken(6) state.  For ports which
                       are disabled (see dot1dStpPortEnable), this object
                       will have a value of disabled(1)."
',
      );


?>
