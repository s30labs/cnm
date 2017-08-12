<?
	$TIPS[]=array(
		'id_ref' => 'BRIDGE-MIB::newRoot',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The newRoot trap indicates that the sending agent
                       has become the new root of the Spanning Tree; the
                       trap is sent by a bridge soon after its election
                       as the new root, e.g., upon expiration of the
                       Topology Change Timer immediately subsequent to
                       its election.  Implementation of this trap is
                       optional."
',
	);

	$TIPS[]=array(
		'id_ref' => 'BRIDGE-MIB::topologyChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A topologyChange trap is sent by a bridge when
                       any of its configured ports transitions from the
                       Learning state to the Forwarding state, or from
                       the Forwarding state to the Blocking state.  The
                       trap is not sent if a newRoot trap is sent for the
                       same transition.  Implementation of this trap is
                       optional."
',
	);

?>
