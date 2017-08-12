<?
	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panThreatTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A threat/URL event trap."
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panTimeGenerated</strong><br>"Time the log was generated on the data plane"
<br>TimeTicks
   <br>v6: <strong>panSource</strong><br>"Original session source IP address."
<br>IpAddress
   <br>v7: <strong>panDestination</strong><br>"Original session destination IP address."
<br>IpAddress
   <br>v8: <strong>panNatSource</strong><br>"If Source NAT performed, the post-NAT Source IP address."
<br>IpAddress
   <br>v9: <strong>panNatDestination</strong><br>"If Destination NAT performed, the post-NAT Destination IP address."
<br>IpAddress
   <br>v10: <strong>panRule</strong><br>"Name of the rule that the session matched."
<br>OCTET STRING (1..32) 
   <br>v11: <strong>panSrcUser</strong><br>"User name of the user that initiated the session."
<br>OCTET STRING (1..32) 
   <br>v12: <strong>panDstUser</strong><br>"User name of the user to which the session was destined."
<br>OCTET STRING (1..32) 
   <br>v13: <strong>panApplication</strong><br>"Application associated with the session."
<br>OCTET STRING (1..32) 
   <br>v14: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v15: <strong>panSourceZone</strong><br>"Zone the session was sourced from."
<br>OCTET STRING (1..16) 
   <br>v16: <strong>panDestinationZone</strong><br>"Zone the session was destined to."
<br>OCTET STRING (1..16) 
   <br>v17: <strong>panIngressInterface</strong><br>"Interface that the session was sourced form."
<br>Counter64
   <br>v18: <strong>panEgressInterface</strong><br>"Interface that the session was destined to."
<br>Counter64
   <br>v19: <strong>panLogForwardingProfile</strong><br>"Log Forwarding Profile that was applied to the session"
<br>OCTET STRING (1..32) 
   <br>v20: <strong>panSessionID</strong><br>"An internal numerical identifier applied to each session."
<br>Counter32
   <br>v21: <strong>panRepeatCount</strong><br>"Number of sessions with same Source IP, Destination IP, Application, and Subtype seen within 5 seconds; Used for ICMP only."
<br>Counter32
   <br>v22: <strong>panSourcePort</strong><br>"Source port utilized by the session."
<br>Counter32
   <br>v23: <strong>panDestinationPort</strong><br>"Destination port utilized by the session."
<br>Counter32
   <br>v24: <strong>panNatSourcePort</strong><br>"Post-NAT source port."
<br>Counter32
   <br>v25: <strong>panNatDestinationPort</strong><br>"Post-NAT destination port."
<br>Counter32
   <br>v26: <strong>panFlags</strong><br>"32 bit field that provides details on session."
<br>Counter32
   <br>v27: <strong>panProtocol</strong><br>"IP protocol associated with the session"
<br>Counter32
   <br>v28: <strong>panAction</strong><br>"Action taken for the session; Values are allow or deny"
<br>Counter32
   <br>v29: <strong>panMiscellaneous</strong><br>"The actual URI when the subtype is URL; File name or file type when the subtype is file; and File name when the subtype is virus."
<br>OCTET STRING (1..1024) 
   <br>v30: <strong>panThreatId</strong><br>"Palo Alto Networks identifier for the threat. It is a numerical identifier followed by a description in parenthesis for some Subtypes."
<br>Counter32
   <br>v31: <strong>panThreatCategory</strong><br>"Provides URL Category for URL Subtype; For other subtypes the value is ‘any’."
<br>OCTET STRING (1..32) 
   <br>v32: <strong>panThreatSeverity</strong><br>"Severity associated with the threat; Values are informational, low, medium, high, critical."
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v33: <strong>panThreatDirection</strong><br>"Indicates the direction of the attack, ‘client-to-server’ or ‘server-to-client’."
<br>Counter32
   <br>v34: <strong>panSeqno</strong><br>"A 64-bit log entry identifier incremented sequentially. Each log type has a unique number space"
<br>Counter64
   <br>v35: <strong>panActionflags</strong><br>"A bit field indicating if the log was forwarded to Panorama."
<br>Counter64
   <br>v36: <strong>panSrcloc</strong><br>"Source country or Internal region for private addresses. Maximum length is 32 bytes."
<br>OCTET STRING (1..32) 
   <br>v37: <strong>panDstloc</strong><br>"Destination country or Internal region for private addresses. Maximum length is 32 bytes."
<br>OCTET STRING (1..32) 
   <br>v38: <strong>panThreatContentType</strong><br>"Content type of the HTTP response data. Maximum length 32 bytes. Applicable only when Subtype is URL."
<br>OCTET STRING (1..32) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panGeneralGeneralTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"General system event"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panGeneralGeneralTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"General system event"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panGeneralSystemShutdownTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"System shutdown"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHWDiskErrorsTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Hard drive physical issues"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAHa1LinkChangeTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA1 peer link change"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAHa2LinkChangeTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA2 peer link change"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHADataplaneDownTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA has detected a dataplane down"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPolicyPushFailTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA policy push to dataplane failed"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAConnectChangeTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer connection change"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPathMonitorDownTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA monitored path down"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHALinkMonitorDownTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA monitored link down"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerSyncFailureTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA cant synch non-configuration controlplane data to peer"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAConfigFailureTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA configuration push to peer has failed"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerErrorTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA error message from peer"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerVersionUnsupportedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer version is not supported with our local version"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerVersionDegradedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer version is degraded in our local version"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerCompatMismatchTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer compatibility mismatch"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerCompatFailTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer compatibility failure"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAPeerShutdownTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA peer change caused a local shutdown"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHANfsPanlogsFailTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"NFS panlogs failure"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAInternalHaErrorTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA is not working properly; please call support"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHAStateChangeTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA device has changed states"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PAN-TRAPS::panHANonFunctionalLoopTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"HA device going suspend due to non-functional-loop"
v1: <strong>panReceiveTime</strong><br>"Time the log was received at the management plane."
<br>TimeTicks
   <br>v2: <strong>panSerial</strong><br>"Serial number of the device that generated the log."
<br>OCTET STRING (1..16) 
   <br>v3: <strong>panEventType</strong><br>"Specifies type of log; Values are traffic, threat, config, system and hip-match."
<br>OCTET STRING (1..16) 
   <br>v4: <strong>panEventSubType</strong><br>"Subtype of traffic log; Values are start, end, drop, and deny."
<br>OCTET STRING (1..16) 
   <br>v5: <strong>panVsys</strong><br>"Virtual System associated with the session."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>panSystemEventId</strong><br>"System log event ID"
<br>Counter32
   <br>v7: <strong>panSystemObject</strong><br>"System log event object"
<br>OCTET STRING (1..32) 
   <br>v8: <strong>panSystemModule</strong><br>"System log event module"
<br>Counter32
   <br>v9: <strong>panSystemSeverity</strong><br>"System log event severity"
<br>INTEGER {unused(1), informational(2), low(3), medium(4), high(5), critical(6)} 
   <br>v10: <strong>panSystemDescription</strong><br>"System log event description"
<br>OCTET STRING (1..512) 
   <br>',
	);

?>
