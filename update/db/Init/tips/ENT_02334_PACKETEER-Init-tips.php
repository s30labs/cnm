<?php
      $TIPS[]=array(
         'id_ref' => 'pkteer_link_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkByteCount</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkByteCount (COUNTER):</strong> "The byte count in the link"
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_pkts',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkPkts|linkDataPkts</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkPkts (COUNTER):</strong> "The packet count in the link"
<strong>PACKETEER-MIB::linkDataPkts (COUNTER):</strong> "The TCP data packet count in the link"
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_ret_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkReTxByteCount</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkReTxByteCount (COUNTER):</strong> "The count of retransmitted bytes on the link.  This is the
           low-order 32 bits."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_ret_pkts',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkReTxs|linkReTxTosses</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkReTxs (COUNTER):</strong> "The TCP retransmit packet count in the link"
<strong>PACKETEER-MIB::linkReTxTosses (COUNTER):</strong> "The TCP tossed retransmit packet count in the link"
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_tcp_peak',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkPeakTcpConns</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkPeakTcpConns (GAUGE):</strong> "The peak number of active TCP flows in the link."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_tcp',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkTcpConnInits|linkTcpConnRefuses|linkTcpConnIgnores|linkTcpConnAborts</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkTcpConnInits (COUNTER):</strong> "The count of TCP flows started in the link"
<strong>PACKETEER-MIB::linkTcpConnRefuses (COUNTER):</strong> "The count of TCP flows exited by TCP refuse in the link"
<strong>PACKETEER-MIB::linkTcpConnIgnores (COUNTER):</strong> "The count of TCP flows exited by being ignored in the link."
<strong>PACKETEER-MIB::linkTcpConnAborts (COUNTER):</strong> "The count of TCP flows aborted in the link."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_pkts_tot',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkTotalRxPkts|linkTotalTxPkts</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkTotalRxPkts (COUNTER):</strong> "The total packets received on the link."
<strong>PACKETEER-MIB::linkTotalTxPkts (COUNTER):</strong> "The total packets transmitted on the link."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_pkts_drop',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkRxPktDrops|linkTxPktDrops</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkRxPktDrops (COUNTER):</strong> "The count of packets dropped due to no buffers, no connection blocks or random dropping."
<strong>PACKETEER-MIB::linkTxPktDrops (COUNTER):</strong> "The count of transmitted packets that were dropped due to no route available, an i/o error or no buffers."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_link_pkts_err',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>linkRxErrors|linkTxErrors</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::linkRxErrors (COUNTER):</strong> "The count of received packets that were dropped due to hardware errors."
<strong>PACKETEER-MIB::linkTxErrors (COUNTER):</strong> "The count of transmitted packets that were dropped due to hardware errors."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classByteCount</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classByteCount (COUNTER):</strong> "The byte count in the class."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_pkts',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classPkts|classDataPkts</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classPkts (COUNTER):</strong> "The packet count in the class."
<strong>PACKETEER-MIB::classDataPkts (COUNTER):</strong> "The TCP data packet count in the class."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_ret_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classReTxByteCount</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classReTxByteCount (COUNTER):</strong> "The count of retransmitted bytes on the class.  This is the low-order
           32 bits."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_ret_pkts',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classReTxs|classReTxTosses</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classReTxs (COUNTER):</strong> "The TCP retransmit packet count in the class."
<strong>PACKETEER-MIB::classReTxTosses (COUNTER):</strong> "The TCP tossed retransmit packet count in the class."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_tcp',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classTcpConnInits|classTcpConnRefuses|classTcpConnIgnores|classTcpConnAborts</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classTcpConnInits (COUNTER):</strong> "The count of TCP flows started in the class."
<strong>PACKETEER-MIB::classTcpConnRefuses (COUNTER):</strong> "The count of TCP flows exited by TCP refuse in the class."
<strong>PACKETEER-MIB::classTcpConnIgnores (COUNTER):</strong> "The count of TCP flows exited by being ignored in the class."
<strong>PACKETEER-MIB::classTcpConnAborts (COUNTER):</strong> "The count of TCP flows aborted in the class."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_rate',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classCurrentRate</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classCurrentRate (GAUGE):</strong> "The current rate in bits per second."
',
      );


      $TIPS[]=array(
         'id_ref' => 'pkteer_class_exchtime',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>classPktExchangeTime</strong> a partir de los siguientes atributos de la mib PACKETEER-MIB:<br><br><strong>PACKETEER-MIB::classPktExchangeTime (COUNTER):</strong> "(PacketShaper only).  The packet exchange time for TCP
           data packets, between PacketShaper and the server side.
           This is the low-order 32 bits."
',
      );


?>
