<?
	$TIPS[]=array(
		'id_ref' => 'dial_peer_ctime',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>dialCtlPeerStatsConnectTime</strong> a partir de los siguientes atributos de la mib DIAL-CONTROL-MIB:<br><br><strong>DIAL-CONTROL-MIB::dialCtlPeerStatsConnectTime (GAUGE):</strong> "Accumulated connect time to the peer since system startup.
              This is the total connect time, i.e. the connect time
              for outgoing calls plus the time for incoming calls."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dial_peer_calls',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>dialCtlPeerStatsSuccessCalls|dialCtlPeerStatsFailCalls|dialCtlPeerStatsAcceptCalls|dialCtlPeerStatsRefuseCalls</strong> a partir de los siguientes atributos de la mib DIAL-CONTROL-MIB:<br><br><strong>DIAL-CONTROL-MIB::dialCtlPeerStatsSuccessCalls (GAUGE):</strong> "Number of completed calls to this peer."
<strong>DIAL-CONTROL-MIB::dialCtlPeerStatsFailCalls (GAUGE):</strong> "Number of failed call attempts to this peer since system
              startup."
<strong>DIAL-CONTROL-MIB::dialCtlPeerStatsAcceptCalls (GAUGE):</strong> "Number of calls from this peer accepted since system
              startup."
<strong>DIAL-CONTROL-MIB::dialCtlPeerStatsRefuseCalls (GAUGE):</strong> "Number of calls from this peer refused since system
              startup."
',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_glob_duplex',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fullDuplex|unknown|halfDuplex</strong> a partir de los siguientes atributos de la mib EtherLike-MIB:<br><br><strong>EtherLike-MIB::dot3StatsDuplexStatus (GAUGE):</strong> "The current mode of operation of the MAC
                     entity.  unknown indicates that the current
                     duplex mode could not be determined.
 
                     Management control of the duplex mode is
                     accomplished through the MAU MIB.  When
                     an interface does not support autonegotiation,
                     or when autonegotiation is not enabled, the
                     duplex mode is controlled using
                     ifMauDefaultType.  When autonegotiation is
                     supported and enabled, duplex mode is controlled
                     using ifMauAutoNegAdvertisedBits.  In either
                     case, the currently operating duplex mode is
                     reflected both in this object and in ifMauType.
 
                     Note that this object provides redundant
                     information with ifMauType.  Normally, redundant
                     objects are discouraged.  However, in this
                     instance, it allows a management application to
                     determine the duplex status of an interface
                     without having to know every possible value of
                     ifMauType.  This was felt to be sufficiently
                     valuable to justify the redundancy."
',
	);

?>
