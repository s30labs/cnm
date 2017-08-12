<?
	$TIPS[]=array(
		'id_ref' => 'mib2_ipInAddrErrors',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ipInAddrErrors.0</strong> a partir de los siguientes atributos de la mib RFC1213-MIB:<br><br><strong>RFC1213-MIB::ipInAddrErrors.0 (COUNTER):</strong> "The number of input datagrams discarded because
             the IP address in their IP headers destination
             field was not a valid address to be received at
             this entity.  This count includes invalid
             addresses (e.g., 0.0.0.0) and addresses of
             unsupported Classes (e.g., Class E).  For entities
             which are not IP Gateways and therefore do not
             forward datagrams, this counter includes datagrams
             discarded because the destination address was not
             a local address."
',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_ipRoutingDiscards',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ipRoutingDiscards.0</strong> a partir de los siguientes atributos de la mib RFC1213-MIB:<br><br><strong>RFC1213-MIB::ipRoutingDiscards.0 (COUNTER):</strong> "The number of routing entries which were chosen
             to be discarded even though they are valid.  One
             possible reason for discarding such an entry could
             be to free-up buffer space for other routing
 
             entries."
',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_ipOutNoRoutes',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ipOutNoRoutes.0</strong> a partir de los siguientes atributos de la mib RFC1213-MIB:<br><br><strong>RFC1213-MIB::ipOutNoRoutes.0 (COUNTER):</strong> "The number of IP datagrams discarded because no
             route could be found to transmit them to their
             destination.  Note that this counter includes any
             packets counted in ipForwDatagrams which meet this
             `no-route criterion.  Note that this includes any
             datagarms which a host cannot route because all of
             its default gateways are down."
',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_uptime',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>sysUpTime.0</strong> a partir de los siguientes atributos de la mib SNMPv2-MIB:<br><br><strong>SNMPv2-MIB::sysUpTime.0 (GAUGE):</strong> "The time (in hundredths of a second) since the
             network management portion of the system was last
             re-initialized."
',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_glob_ifstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => '',
	);

?>
