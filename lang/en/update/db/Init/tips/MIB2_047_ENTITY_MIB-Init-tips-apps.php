<?
	$TIPS[]=array(
		'id_ref' => 'app_ent_phys_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra los componentes fisicos del equipo</strong><br>Utiliza la tabla SNMP ENTITY-MIB::entPhysicalTable (Enterprise=00000)<br><br><strong>ENTITY-MIB::entPhysicalContainedIn (GAUGE):</strong><br>"The value of entPhysicalIndex for the physical entity which
             contains this physical entity.  A value of zero indicates
             this physical entity is not contained in any other physical
             entity.  Note that the set of containment relationships
             define a strict hierarchy; that is, recursion is not
             allowed.
 
             In the event that a physical entity is contained by more
             than one physical entity (e.g., double-wide modules), this
             object should identify the containing entity with the lowest
             value of entPhysicalIndex."
<strong>ENTITY-MIB::entPhysicalDescr (GAUGE):</strong><br>"A textual description of physical entity.  This object
             should contain a string that identifies the manufacturers
             name for the physical entity, and should be set to a
             distinct value for each version or model of the physical
             entity."
<strong>ENTITY-MIB::entPhysicalClass (GAUGE):</strong><br>"An indication of the general hardware type of the physical
             entity.
 
             An agent should set this object to the standard enumeration
             value that most accurately indicates the general class of
             the physical entity, or the primary class if there is more
             than one entity.
 
             If no appropriate standard registration identifier exists
             for this physical entity, then the value other(1) is
             returned.  If the value is unknown by this agent, then the
             value unknown(2) is returned."
<strong>ENTITY-MIB::entPhysicalSerialNum (GAUGE):</strong><br>"The vendor-specific serial number string for the physical
             entity.  The preferred value is the serial number string
             actually printed on the component itself (if present).
 
             On the first instantiation of an physical entity, the value
             of entPhysicalSerialNum associated with that entity is set
             to the correct vendor-assigned serial number, if this
             information is available to the agent.  If a serial number
             is unknown or non-existent, the entPhysicalSerialNum will be
             set to a zero-length string instead.
 
             Note that implementations that can correctly identify the
             serial numbers of all installed physical entities do not
             need to provide write access to the entPhysicalSerialNum
             object.  Agents which cannot provide non-volatile storage
             for the entPhysicalSerialNum strings are not required to
             implement write access for this object.
 
             Not every physical component will have a serial number, or
             even need one.  Physical entities for which the associated
             value of the entPhysicalIsFRU object is equal to false(2)
             (e.g., the repeater ports within a repeater module), do not
             need their own unique serial number.  An agent does not have
             to provide write access for such entities, and may return a
             zero-length string.
 
             If write access is implemented for an instance of
             entPhysicalSerialNum, and a value is written into the
             instance, the agent must retain the supplied value in the
             entPhysicalSerialNum instance (associated with the same
             physical entity) for as long as that entity remains
             instantiated.  This includes instantiations across all
             re-initializations/reboots of the network management system,
             including those resulting in a change of the physical
 
 
             entitys entPhysicalIndex value."
<strong>ENTITY-MIB::entPhysicalSoftwareRev (GAUGE):</strong><br>"The vendor-specific software revision string for the
             physical entity.
 
             Note that if revision information is stored internally in a
 
 
             non-printable (e.g., binary) format, then the agent must
             convert such information to a printable format, in an
             implementation-specific manner.
 
             If no specific software programs are associated with the
             physical component, or if this information is unknown to the
             agent, then this object will contain a zero-length string."
<strong>ENTITY-MIB::entPhysicalFirmwareRev (GAUGE):</strong><br>"The vendor-specific firmware revision string for the
             physical entity.
 
             Note that if revision information is stored internally in a
             non-printable (e.g., binary) format, then the agent must
             convert such information to a printable format, in an
             implementation-specific manner.
 
             If no specific firmware programs are associated with the
             physical component, or if this information is unknown to the
             agent, then this object will contain a zero-length string."
<strong>ENTITY-MIB::entPhysicalModelName (GAUGE):</strong><br>"The vendor-specific model name identifier string associated
             with this physical component.  The preferred value is the
             customer-visible part number, which may be printed on the
             component itself.
 
             If the model name string associated with the physical
             component is unknown to the agent, then this object will
             contain a zero-length string."
<strong>ENTITY-MIB::entPhysicalVendorType (GAUGE):</strong><br>"An indication of the vendor-specific hardware type of the
             physical entity.  Note that this is different from the
             definition of MIB-IIs sysObjectID.
 
             An agent should set this object to an enterprise-specific
             registration identifier value indicating the specific
             equipment type in detail.  The associated instance of
             entPhysicalClass is used to indicate the general type of
             hardware device.
 
             If no vendor-specific registration identifier exists for
             this physical entity, or the value is unknown by this agent,
             then the value { 0 0 } is returned."
<strong>ENTITY-MIB::entPhysicalIsFRU (GAUGE):</strong><br>"This object indicates whether or not this physical entity
             is considered a field replaceable unit by the vendor.  If
             this object contains the value true(1) then this
             entPhysicalEntry identifies a field replaceable unit.  For
             all entPhysicalEntries that represent components
             permanently contained within a field replaceable unit, the
             value false(2) should be returned for this object."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_ent_logic_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra los componentes logicos del equipo</strong><br>Utiliza la tabla SNMP ENTITY-MIB::entLogicalTable (Enterprise=00000)<br><br><strong>ENTITY-MIB::entLogicalDescr (GAUGE):</strong><br>"A textual description of the logical entity.  This object
             should contain a string that identifies the manufacturers
             name for the logical entity, and should be set to a distinct
             value for each version of the logical entity."
<strong>ENTITY-MIB::entLogicalType (GAUGE):</strong><br>"An indication of the type of logical entity.  This will
             typically be the OBJECT IDENTIFIER name of the node in the
             SMIs naming hierarchy which represents the major MIB
             module, or the majority of the MIB modules, supported by the
             logical entity.  For example:
                a logical entity of a regular host/router -> mib-2
                a logical entity of a 802.1d bridge -> dot1dBridge
                a logical entity of a 802.3 repeater -> snmpDot3RptrMgmt
             If an appropriate node in the SMIs naming hierarchy cannot
             be identified, the value mib-2 should be used."
<strong>ENTITY-MIB::entLogicalCommunity (GAUGE):</strong><br>"An SNMPv1 or SNMPv2C community-string, which can be used to
             access detailed management information for this logical
             entity.  The agent should allow read access with this
             community string (to an appropriate subset of all managed
             objects) and may also return a community string based on the
             privileges of the request used to read this object.  Note
             that an agent may return a community string with read-only
             privileges, even if this object is accessed with a
             read-write community string.  However, the agent must take
 
 
             care not to return a community string that allows more
             privileges than the community string used to access this
             object.
 
             A compliant SNMP agent may wish to conserve naming scopes by
             representing multiple logical entities in a single default
             naming scope.  This is possible when the logical entities,
             represented by the same value of entLogicalCommunity, have
             no object instances in common.  For example, bridge1 and
             repeater1 may be part of the main naming scope, but at
             least one additional community string is needed to represent
             bridge2 and repeater2.
 
             Logical entities bridge1 and repeater1 would be
             represented by sysOREntries associated with the default
             naming scope.
 
             For agents not accessible via SNMPv1 or SNMPv2C, the value
             of this object is the empty string.  This object may also
             contain an empty string if a community string has not yet
             been assigned by the agent, or if no community string with
             suitable access rights can be returned for a particular SNMP
             request.
 
             Note that this object is deprecated.  Agents which implement
             SNMPv3 access should use the entLogicalContextEngineID and
             entLogicalContextName objects to identify the context
             associated with each logical entity.  SNMPv3 agents may
             return a zero-length string for this object, or may continue
             to return a community string (e.g., tri-lingual agent
             support)."
<strong>ENTITY-MIB::entLogicalContextName (GAUGE):</strong><br>"The contextName that can be used to send an SNMP message
             concerning information held by this logical entity, to the
             address specified by the associated
             entLogicalTAddress/entLogicalTDomain pair.
 
             This object, together with the associated
             entLogicalContextEngineID object, defines the context
             associated with a particular logical entity, and allows
 
 
             access to SNMP engines identified by a contextEngineId and
             contextName pair.
 
             If no value has been configured by the agent, a zero-length
             string is returned, or the agent may choose not to
             instantiate this object at all."
',
	);

?>
