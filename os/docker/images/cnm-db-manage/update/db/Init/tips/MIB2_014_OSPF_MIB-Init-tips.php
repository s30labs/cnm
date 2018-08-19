<?php
      $TIPS[]=array(
         'id_ref' => 'mib2_ospfExternLsaCksumSum',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ospfExternLsaCksumSum.0</strong> a partir de los siguientes atributos de la mib OSPF-MIB:<br><br><strong>OSPF-MIB::ospfExternLsaCksumSum.0 (GAUGE):</strong> "The 32-bit unsigned sum of the LS checksums of
            the  external  link-state  advertisements  con-
            tained in the link-state  database.   This  sum
            can  be  used  to determine if there has been a
            change in a routers link state  database,  and
            to  compare  the  link-state  database  of  two
            routers."
',
      );


      $TIPS[]=array(
         'id_ref' => 'ospf_SpfRuns',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ospfSpfRuns</strong> a partir de los siguientes atributos de la mib OSPF-MIB:<br><br><strong>OSPF-MIB::ospfSpfRuns (COUNTER):</strong> "The number of times that the intra-area  route
            table  has  been  calculated  using this areas
            link-state database.  This  is  typically  done
            using Dijkstras algorithm."
',
      );


      $TIPS[]=array(
         'id_ref' => 'ospf_AreaLsaCksumSum',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ospfAreaLsaCksumSum</strong> a partir de los siguientes atributos de la mib OSPF-MIB:<br><br><strong>OSPF-MIB::ospfAreaLsaCksumSum (GAUGE):</strong> "The 32-bit unsigned sum of the link-state  ad-
            vertisements  LS  checksums  contained in this
            areas link-state database.  This sum  excludes
            external (LS type 5) link-state advertisements.
            The sum can be used to determine if  there  has
            been  a  change  in a routers link state data-
            base, and to compare the link-state database of
 
            two routers."
   DEFVAL	{ 0 }
',
      );


      $TIPS[]=array(
         'id_ref' => 'ospf_NbrEvents',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ospfNbrEvents</strong> a partir de los siguientes atributos de la mib OSPF-MIB:<br><br><strong>OSPF-MIB::ospfNbrEvents (COUNTER):</strong> "The number of times this neighbor relationship
            has changed state, or an error has occurred."
',
      );


      $TIPS[]=array(
         'id_ref' => 'ospf_NbrState',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)</strong> a partir de los siguientes atributos de la mib OSPF-MIB:<br><br><strong>OSPF-MIB::ospfNbrState (GAUGE):</strong> "The State of the relationship with this Neigh-
            bor."
   DEFVAL	{ down }
',
      );


?>
