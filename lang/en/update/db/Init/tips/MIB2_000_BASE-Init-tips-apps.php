<?
	$TIPS[]=array(
		'id_ref' => 'app_mib2_arptable',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la tabla de ARP del dispositivo (IP/direccion MAC)</strong><br>Utiliza la tabla SNMP IP-MIB::ipNetToMediaTable (Enterprise=00000)<br><br><strong>IP-MIB::ipNetToMediaPhysAddress (GAUGE):</strong><br>"The media-dependent `physical address."
<strong>IP-MIB::ipNetToMediaNetAddress (GAUGE):</strong><br>"The IpAddress corresponding to the media-
             dependent `physical address."
<strong>IP-MIB::ipNetToMediaType (GAUGE):</strong><br>"The type of mapping.
 
             Setting this object to the value invalid(2) has
             the effect of invalidating the corresponding entry
             in the ipNetToMediaTable.  That is, it effectively
             dissasociates the interface identified with said
             entry from the mapping identified with said entry.
             It is an implementation-specific matter as to
             whether the agent removes an invalidated entry
             from the table.  Accordingly, management stations
             must be prepared to receive tabular information
             from agents that corresponds to entries not
             currently in use.  Proper interpretation of such
             entries requires examination of the relevant
             ipNetToMediaType object."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_routetable',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la tabla derutas del dispositivo. Conviene tener precaucion con aquellos dispositivos con gran numero de rutas porque puede aumentar la carga del equipo</strong><br>Utiliza la tabla SNMP RFC1213-MIB::ipRouteTable (Enterprise=00000)<br><br><strong>RFC1213-MIB::ipRouteMetric1 (GAUGE):</strong><br>"The primary routing metric for this route.  The
             semantics of this metric are determined by the
             routing-protocol specified in the routes
             ipRouteProto value.  If this metric is not used,
             its value should be set to -1."
<strong>RFC1213-MIB::ipRouteNextHop (GAUGE):</strong><br>"The IP address of the next hop of this route.
             (In the case of a route bound to an interface
             which is realized via a broadcast media, the value
             of this field is the agents IP address on that
             interface.)"
<strong>RFC1213-MIB::ipRouteType (GAUGE):</strong><br>"The type of route.  Note that the values
             direct(3) and indirect(4) refer to the notion of
             direct and indirect routing in the IP
             architecture.
 
             Setting this object to the value invalid(2) has
             the effect of invalidating the corresponding entry
             in the ipRouteTable object.  That is, it
             effectively dissasociates the destination
             identified with said entry from the route
             identified with said entry.  It is an
             implementation-specific matter as to whether the
             agent removes an invalidated entry from the table.
             Accordingly, management stations must be prepared
             to receive tabular information from agents that
             corresponds to entries not currently in use.
             Proper interpretation of such entries requires
             examination of the relevant ipRouteType object."
<strong>RFC1213-MIB::ipRouteProto (GAUGE):</strong><br>"The routing mechanism via which this route was
             learned.  Inclusion of values for gateway routing
             protocols is not intended to imply that hosts
             should support those protocols."
<strong>RFC1213-MIB::ipRouteMask (GAUGE):</strong><br>"Indicate the mask to be logical-ANDed with the
             destination address before being compared to the
             value in the ipRouteDest field.  For those systems
             that do not support arbitrary subnet masks, an
             agent constructs the value of the ipRouteMask by
             determining whether the value of the correspondent
             ipRouteDest field belong to a class-A, B, or C
             network, and then using one of:
 
                  mask           network
                  255.0.0.0      class-A
                  255.255.0.0    class-B
                  255.255.255.0  class-C
 
             If the value of the ipRouteDest is 0.0.0.0 (a
             default route), then the mask value is also
             0.0.0.0.  It should be noted that all IP routing
             subsystems implicitly use this mechanism."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_tcpsessions',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra las sesiones TCP del dispositivo</strong><br>Utiliza la tabla SNMP TCP-MIB::tcpConnTable (Enterprise=00000)<br><br><strong>TCP-MIB::tcpConnState (GAUGE):</strong><br>"The state of this TCP connection.
 
             The only value which may be set by a management
             station is deleteTCB(12).  Accordingly, it is
             appropriate for an agent to return a `badValue
             response if a management station attempts to set
             this object to any other value.
 
             If a management station sets this object to the
             value deleteTCB(12), then this has the effect of
             deleting the TCB (as defined in RFC 793) of the
             corresponding connection on the managed node,
             resulting in immediate termination of the
             connection.
 
             As an implementation-specific option, a RST
 
             segment may be sent from the managed node to the
             other TCP endpoint (note however that RST segments
             are not sent reliably)."
<strong>TCP-MIB::tcpConnLocalAddress (GAUGE):</strong><br>"The local IP address for this TCP connection.  In
             the case of a connection in the listen state which
             is willing to accept connections for any IP
             interface associated with the node, the value
             0.0.0.0 is used."
<strong>TCP-MIB::tcpConnLocalPort (GAUGE):</strong><br>"The local port number for this TCP connection."
<strong>TCP-MIB::tcpConnRemAddress (GAUGE):</strong><br>"The remote IP address for this TCP connection."
<strong>TCP-MIB::tcpConnRemPort (GAUGE):</strong><br>"The remote port number for this TCP connection."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_udpports',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra los puertos UDP utilizados por el dispositivo</strong><br>Utiliza la tabla SNMP UDP-MIB::udpTable (Enterprise=00000)<br><br><strong>UDP-MIB::udpLocalAddress (GAUGE):</strong><br>"The local IP address for this UDP listener.  In
 
             the case of a UDP listener which is willing to
             accept datagrams for any IP interface associated
             with the node, the value 0.0.0.0 is used."
<strong>UDP-MIB::udpLocalPort (GAUGE):</strong><br>"The local port number for this UDP listener."
',
	);

?>
