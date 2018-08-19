<?php
      $TIPS[]=array(
         'id_ref' => 'app_mib2_bgppeers',  'tip_type' => 'app', 'url' => '',
         'date' => 1430855177,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra la tabla de peers BGP.</strong><br>Utiliza la tabla SNMP BGP4-MIB::bgpPeerTable (Enterprise=00000)<br><br><strong>BGP4-MIB::bgpPeerIdentifier (GAUGE):</strong><br>"The BGP Identifier of this entrys BGP
                             peer."
<strong>BGP4-MIB::bgpPeerState (GAUGE):</strong><br>"The BGP peer connection state."
<strong>BGP4-MIB::bgpPeerAdminStatus (GAUGE):</strong><br>"The desired state of the BGP connection.
                             A transition from stop to start will
                             cause the BGP Start Event to be generated.
                             A transition from start to stop will
                             cause the BGP Stop Event to be generated.
                             This parameter can be used to restart BGP
                             peer connections.  Care should be used in
                             providing write access to this object
                             without adequate authentication."
<strong>BGP4-MIB::bgpPeerNegotiatedVersion (GAUGE):</strong><br>"The negotiated version of BGP running
                             between the two peers."
<strong>BGP4-MIB::bgpPeerLocalAddr (GAUGE):</strong><br>"The local IP address of this entrys BGP
                             connection."
<strong>BGP4-MIB::bgpPeerLocalPort (GAUGE):</strong><br>"The local port for the TCP connection
                             between the BGP peers."
<strong>BGP4-MIB::bgpPeerRemoteAddr (GAUGE):</strong><br>"The remote IP address of this entrys BGP
                             peer."
<strong>BGP4-MIB::bgpPeerRemotePort (GAUGE):</strong><br>"The remote port for the TCP connection
                             between the BGP peers.  Note that the
                             objects bgpPeerLocalAddr,
                             bgpPeerLocalPort, bgpPeerRemoteAddr and
                             bgpPeerRemotePort provide the appropriate
                             reference to the standard MIB TCP
                             connection table."
<strong>BGP4-MIB::bgpPeerRemoteAs (GAUGE):</strong><br>"The remote autonomous system number."
<strong>BGP4-MIB::bgpPeerInUpdates (COUNTER):</strong><br>"The number of BGP UPDATE messages
                             received on this connection.  This object
                             should be initialized to zero (0) when the
                             connection is established."
<strong>BGP4-MIB::bgpPeerOutUpdates (COUNTER):</strong><br>"The number of BGP UPDATE messages
                             transmitted on this connection.  This
                             object should be initialized to zero (0)
                             when the connection is established."
<strong>BGP4-MIB::bgpPeerInTotalMessages (COUNTER):</strong><br>"The total number of messages received
                             from the remote peer on this connection.
                             This object should be initialized to zero
                             when the connection is established."
<strong>BGP4-MIB::bgpPeerOutTotalMessages (COUNTER):</strong><br>"The total number of messages transmitted to
                             the remote peer on this connection.  This
                             object should be initialized to zero when
                             the connection is established."
<strong>BGP4-MIB::bgpPeerLastError (GAUGE):</strong><br>"The last error code and subcode seen by this
                             peer on this connection.  If no error has
                             occurred, this field is zero.  Otherwise, the
                             first byte of this two byte OCTET STRING
                             contains the error code, and the second byte
                             contains the subcode."
<strong>BGP4-MIB::bgpPeerFsmEstablishedTransitions (COUNTER):</strong><br>"The total number of times the BGP FSM
                             transitioned into the established state."
<strong>BGP4-MIB::bgpPeerFsmEstablishedTime (GAUGE):</strong><br>"This timer indicates how long (in
                             seconds) this peer has been in the
                             Established state or how long
                             since this peer was last in the
                             Established state.  It is set to zero when
                             a new peer is configured or the router is
                             booted."
<strong>BGP4-MIB::bgpPeerConnectRetryInterval (GAUGE):</strong><br>"Time interval in seconds for the
                             ConnectRetry timer.  The suggested value
                             for this timer is 120 seconds."
<strong>BGP4-MIB::bgpPeerHoldTime (GAUGE):</strong><br>"Time interval in seconds for the Hold
                             Timer established with the peer.  The
                             value of this object is calculated by this
                             BGP speaker by using the smaller of the
                             value in bgpPeerHoldTimeConfigured and the
                             Hold Time received in the OPEN message.
                             This value must be at lease three seconds
                             if it is not zero (0) in which case the
                             Hold Timer has not been established with
                             the peer, or, the value of
                             bgpPeerHoldTimeConfigured is zero (0)."
<strong>BGP4-MIB::bgpPeerKeepAlive (GAUGE):</strong><br>"Time interval in seconds for the KeepAlive
                             timer established with the peer.  The value
                             of this object is calculated by this BGP
                             speaker such that, when compared with
                             bgpPeerHoldTime, it has the same
                             proportion as what
                             bgpPeerKeepAliveConfigured has when
                             compared with bgpPeerHoldTimeConfigured.
                             If the value of this object is zero (0),
                             it indicates that the KeepAlive timer has
                             not been established with the peer, or,
                             the value of bgpPeerKeepAliveConfigured is
                             zero (0)."
<strong>BGP4-MIB::bgpPeerHoldTimeConfigured (GAUGE):</strong><br>"Time interval in seconds for the Hold Time
                             configured for this BGP speaker with this
                             peer.  This value is placed in an OPEN
                             message sent to this peer by this BGP
                             speaker, and is compared with the Hold
                             Time field in an OPEN message received
                             from the peer when determining the Hold
                             Time (bgpPeerHoldTime) with the peer.
                             This value must not be less than three
                             seconds if it is not zero (0) in which
                             case the Hold Time is NOT to be
                             established with the peer.  The suggested
                             value for this timer is 90 seconds."
<strong>BGP4-MIB::bgpPeerKeepAliveConfigured (GAUGE):</strong><br>"Time interval in seconds for the
                             KeepAlive timer configured for this BGP
                             speaker with this peer.  The value of this
                             object will only determine the
                             KEEPALIVE messages frequency relative to
                             the value specified in
                             bgpPeerHoldTimeConfigured; the actual
                             time interval for the KEEPALIVE messages
                             is indicated by bgpPeerKeepAlive.  A
                             reasonable maximum value for this timer
                             would be configured to be one
                             third of that of
                             bgpPeerHoldTimeConfigured.
                             If the value of this object is zero (0),
                             no periodical KEEPALIVE messages are sent
                             to the peer after the BGP connection has
                             been established.  The suggested value for
                             this timer is 30 seconds."
<strong>BGP4-MIB::bgpPeerMinASOriginationInterval (GAUGE):</strong><br>"Time interval in seconds for the
                             MinASOriginationInterval timer.
                             The suggested value for this timer is 15
                             seconds."
<strong>BGP4-MIB::bgpPeerMinRouteAdvertisementInterval (GAUGE):</strong><br>"Time interval in seconds for the
                             MinRouteAdvertisementInterval timer.
                             The suggested value for this timer is 30
                             seconds."
<strong>BGP4-MIB::bgpPeerInUpdateElapsedTime (GAUGE):</strong><br>"Elapsed time in seconds since the last BGP
                             UPDATE message was received from the peer.
                             Each time bgpPeerInUpdates is incremented,
                             the value of this object is set to zero
                             (0)."
',
      );


?>
