<?
	$TIPS[]=array(
		'id_ref' => 'app_jun_chassis_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion sobre los elementos que componen el chasis del equipo</strong><br>Utiliza la tabla SNMP JUNIPER-MIB::jnxContainersTable (Enterprise=02636)<br><br><strong>JUNIPER-MIB::jnxContainersView (GAUGE):</strong><br>"The view(s) from which the specific container
 		appears.
 
 		This variable indicates that the specific container
 		is embedded and accessible from the corresponding
 		view(s).
 
 		The value is a bit map represented as a sum.
 		If multiple bits are set, the specified
 		container(s) are located and accessible from 
 		that set of views.
 
 		The various values representing the bit positions
 		and its corresponding views are:
 		    1   front
 		    2   rear
 		    4   top
 		    8   bottom
 		   16   leftHandSide
 		   32   rightHandSide
 
 		Note 1: 
 		LefHandSide and rightHandSide are referred
 		to based on the view from the front.
 
 		Note 2: 
 		If the specified containers are scattered 
 		around various views, the numbering is according
 		to the following sequence:
 		    front -> rear -> top -> bottom
 			  -> leftHandSide -> rightHandSide
 		For each view plane, the numbering sequence is
 		first from left to right, and then from up to down.
 
 		Note 3: 
 		Even though the value in chassis hardware (e.g. 
 		slot number) may be labelled from 0, 1, 2, and up,
 		all the indices in MIB start with 1 (not 0) 
 		according to network management convention."
<strong>JUNIPER-MIB::jnxContainersLevel (GAUGE):</strong><br>"The abstraction level of the box or chassis.
 		It is enumerated from the outside to the inside, 
 		from the outer layer to the inner layer.
 		For example, top level (i.e. level 0) refers to 
 		chassis frame, level 1 FPC slot within chassis 
 		frame, level 2 PIC space within FPC slot."
<strong>JUNIPER-MIB::jnxContainersWithin (GAUGE):</strong><br>"The index of its next higher level container 
 		housing	this entry.  The associated 
 		jnxContainersIndex in the jnxContainersTable 
 		represents its next higher level container."
<strong>JUNIPER-MIB::jnxContainersType (GAUGE):</strong><br>"The type of this container."
<strong>JUNIPER-MIB::jnxContainersDescr (GAUGE):</strong><br>"The name or detailed description of this
 		subject."
<strong>JUNIPER-MIB::jnxContainersCount (GAUGE):</strong><br>"The maximum number of containers of this level
 		per container of the next higher level.  
 		e.g. if there are six level 2 containers in 
 		level 1 container, then jnxContainersCount for
 		level 2 is six."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_jun_vlan_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion sobre las VLANs definidas en el equipo</strong><br>Utiliza la tabla SNMP JUNIPER-VLAN-MIB::jnxExVlanTable (Enterprise=02636)<br><br><strong>JUNIPER-VLAN-MIB::jnxExVlanID (GAUGE):</strong><br>"This is the locally significant ID that is used internally by this
         device to reference this VLAN."
<strong>JUNIPER-VLAN-MIB::jnxExVlanName (GAUGE):</strong><br>"Vlan name is the textual name."
<strong>JUNIPER-VLAN-MIB::jnxExVlanType (GAUGE):</strong><br>"The vlan type can be
         static (1)
         Dynamic(2)"
   DEFVAL	{ 1 }
<strong>JUNIPER-VLAN-MIB::jnxExVlanPortGroupInstance (GAUGE):</strong><br>"jnxExVlanPortGroupInstance is the index that identifies that the sub
         tree in the jnxVlanPortGroupTable helps to retrieve the group of
         ports in this VLAN."
<strong>JUNIPER-VLAN-MIB::jnxExVlanTag (GAUGE):</strong><br>"jnxExVlanTag gives the Vlan Tag details for each Vlan."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_juniper_get_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion basica sobre el equipo</strong><br>Utiliza atributos de la mib JUNIPER-MIB:<br><br><strong>JUNIPER-MIB::jnxBoxClass (GAUGE):</strong>&nbsp;"The class of the box, indicating which product line
 		the box is about, for example, Internet Router."
<br><strong>JUNIPER-MIB::jnxBoxDescr (GAUGE):</strong>&nbsp;"The name, model, or detailed description of the box,
 		indicating which product the box is about, for example
 		M40."
<br><strong>JUNIPER-MIB::jnxBoxSerialNo (GAUGE):</strong>&nbsp;"The serial number of this subject, blank if unknown 
 		or unavailable."
<br>',
	);

?>
