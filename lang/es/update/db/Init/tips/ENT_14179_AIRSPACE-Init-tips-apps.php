<?
	$TIPS[]=array(
		'id_ref' => 'app_airspace_apifinfo_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los interfaces de los APs que dependen de este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnAPIfTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPIfSlotId (GAUGE):</strong><br>"The slotId of this interface."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfType (GAUGE):</strong><br>"The type of this interface. dot11b also implies 802.11b/g."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyChannelAssignment (GAUGE):</strong><br>"If this value is true, then bsnAPDot11CurrentChannel  in
          bsnAPIfDot11PhyDSSSTable is assigned by dynamic
          algorithm and is read-only."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyChannelNumber (GAUGE):</strong><br>"Current channel number of the AP Interface.
       Channel numbers will be from 1 to 14 for 802.11b interface type.
       Channel numbers will be from 34 to 169 for 802.11a interface 
       type.  Allowed channel numbers also depends on the current 
       Country Code set in the Switch. This attribute cannot be set 
       unless bsnAPIfPhyChannelAssignment is set to customized else 
       this attribute gets assigned by dynamic algorithm."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyTxPowerControl (GAUGE):</strong><br>"If this value is true, then bsnAPIfPhyTxPowerLevel
          is assigned by dynamic algorithm and is read-only."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyTxPowerLevel (GAUGE):</strong><br>"The TxPowerLevel currently being used to transmit data.
             Some PHYs also use this value to determine the receiver
             sensitivity requirements for CCA. Valid values are between
             1 to 8,depnding on what radio, and this attribute can be 
             set only if bsnAPIfPhyTxPowerControl is set to customized."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyAntennaType (GAUGE):</strong><br>"This attribute specified if the Antenna currently used by AP 
      Radio is internal or external. For 802.11a the antenna is always 
      internal. For 802.11b you can set antenna type to be external or 
      internal."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyAntennaMode (GAUGE):</strong><br>"Antenna Mode of the AP Interface.
      For 802.11a this attribute will always be omni for now.
      This attribute doesnt apply to interface of type 802.11b.
      "
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPhyAntennaDiversity (GAUGE):</strong><br>"Diversity doesnt apply to AP Radio of type 802.11a.
      For 802.11b you can set it to connectorA, connectorB or enabled."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfOperStatus (GAUGE):</strong><br>"Operational status of the interface."
<strong>AIRESPACE-WIRELESS-MIB::bsnApIfNoOfUsers (COUNTER):</strong><br>"No of Users associated with this radio."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfAntennaGain (GAUGE):</strong><br>"Represents antenna gain in multiple of 0.5 dBm. An interger 
      value 4 means 4 x 0.5 = 2 dBm of gain"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfChannelList (GAUGE):</strong><br>"List of comma separated channels supported by this radio."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfAdminStatus (GAUGE):</strong><br>"Admin status of the interface."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_airspace_apinfo_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los APs que dependen de este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnAPTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPName (GAUGE):</strong><br>"Name assigned to this AP. If an AP is not configured its
          factory default name will be ap:<last three byte of 
          MACAddress> eg. ap:af:12:be"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPLocation (GAUGE):</strong><br>"User specified location of this AP.
          While configuring AP, user should specify a location for
          the AP so that its easy to figure out for some one where
          the AP is located."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPOperationStatus (GAUGE):</strong><br>"Operation State of the AP. When AP associates with the 
          Airespace Switch its state will be associated. When Airespace
          AP is disassociated from the Switch, its state will be 
          disassociating. The state is downloading when the AP is 
          downloading its firmware."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPSoftwareVersion (GAUGE):</strong><br>"Major Minor Software Version of AP"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPModel (GAUGE):</strong><br>"AP Model"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPSerialNumber (GAUGE):</strong><br>"AP Serial Number."
<strong>AIRESPACE-WIRELESS-MIB::bsnApIpAddress (GAUGE):</strong><br>"IP address of the AP. This will not be available when 
               the switch is operating in the Layer2 mode. In this case,
               the attribute will return 0 as value."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPType (GAUGE):</strong><br>"This is the model of the AP in enumeration."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPStaticIPAddress (GAUGE):</strong><br>"The Static IP-Address configuration for the AP.
          This can only be changed when the LWAPP mode is in Layer-3."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPGroupVlanName (GAUGE):</strong><br>"The AP Group to which this AP has been associated with. 
         If it is empty, then no AP Group overriding has been set."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIOSVersion (GAUGE):</strong><br>"IOS Version of IOS Cisco AP. Zero length string will be 
          returned for other APs"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPEthernetMacAddress (GAUGE):</strong><br>"The Ethernet MAC address of the AP."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPAdminStatus (GAUGE):</strong><br>"Admin State of the AP"
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_airspace_apload_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre la carga que tienen los APs que dependen de este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPName (GAUGE):</strong><br>"Name assigned to this AP. If an AP is not configured its
          factory default name will be ap:<last three byte of 
          MACAddress> eg. ap:af:12:be"
<strong>AIRESPACE-WIRELESS-MIB::bsnApIpAddress (GAUGE):</strong><br>"IP address of the AP. This will not be available when 
               the switch is operating in the Layer2 mode. In this case,
               the attribute will return 0 as value."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPDot3MacAddress (GAUGE):</strong><br>"The MAC address of an AP."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfSlotId (GAUGE):</strong><br>"The slotId of this interface."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadRxUtilization (GAUGE):</strong><br>"This is the percentage of time the Airespace AP 
               receiver is busy operating on packets. It is a number 
               from 0-100 representing a load from 0 to 1."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadTxUtilization (GAUGE):</strong><br>"This is the percentage of time the Airespace AP 
                  transmitter is busy operating on packets. It is a 
                  number from 0-100 representing a load from 0 to 1."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadChannelUtilization (GAUGE):</strong><br>"Channel Utilization"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadNumOfClients (GAUGE):</strong><br>"This is the number of clients attached to this Airespace 
               AP at the last measurement interval(This comes from 
               APF)"
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfPoorSNRClients (GAUGE):</strong><br>"This is the number of clients with poor SNR attached to 
               this Airespace AP at the last measurement interval 
               ( This comes from APF )."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_airspace_approfiles_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los perfiles de carga, interferencia, cobertura y ruido de los APs que dependen de este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadProfileState (GAUGE):</strong><br>"This field represents the current state of the LOAD
                monitor. This is a total measurement of the business of
                this Airespace AP. PASS indicates that this Airespace 
                AP is performing adequately compared to the Airespace 
                AP profile. FAIL indicates the Airespace AP is not
                performing adequately against the LOAD profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfInterferenceProfileState (GAUGE):</strong><br>"This field represents the current state of Interference
               monitor. This is a total measurement of the interference
               present at this Airespace AP. PASS indicates that this 
               Airespace AP is performing adequately compared to the 
               Interference profile.  FAIL indicates the Airespace AP 
               is not performing adequately against the Interference 
               profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfNoiseProfileState (GAUGE):</strong><br>"This field represents the current state of Noise
              monitor. This is a total measurement of the noise
              present at this Airespace AP. PASS indicates that this 
              Airespace AP is performing adequately compared to the 
              noise profile.
              FAIL indicates the Airespace AP is not performing 
              adequately against the noise profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfCoverageProfileState (GAUGE):</strong><br>"This field represents the current state of coverage
                 monitor. This is a total measurement of the client 
                 coverage at this Airespace AP. PASS indicates that 
                 this  Airespace AP is performing adequately compared 
                 to the  coverage profile. FAIL indicates the Airespace
                 AP is not performing adequately against the coverage 
                 profile."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_airspace_mobinfo_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante las estaciones moviles cnectadas a este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnMobileStationTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationMacAddress (GAUGE):</strong><br>"802.11 MAC Address of the Mobile Station."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationIpAddress (GAUGE):</strong><br>"IP Address of the Mobile Station"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationUserName (GAUGE):</strong><br>"User Name,if any, of the Mobile Station. This would   
                  be non empty in case of Web Authentication and IPSec."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationAPMacAddr (GAUGE):</strong><br>"802.11 Mac Address of the AP to which the
                  Mobile Station is associated."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationAPIfSlotId (GAUGE):</strong><br>"Slot ID of AP Interface to which the mobile station
                  is associated. The value 15 is used to indicate that 
                  the slot Id is invalid."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationEssIndex (GAUGE):</strong><br>"Ess Index of the Wlan(SSID) that is being used by Mobile 
          Station to connect to AP"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationSsid (GAUGE):</strong><br>" The SSID Advertised by Mobile Station"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationAID (GAUGE):</strong><br>"AID for the mobile station"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationStatus (GAUGE):</strong><br>"Status of the mobile station"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationReasonCode (GAUGE):</strong><br>" Reason Code as defined by 802.11 standards"
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationMobilityStatus (GAUGE):</strong><br>"Mobility Role of the Mobile Station."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationVlanId (GAUGE):</strong><br>"Vlan ID of the Interface to which the client is 
                  associated."
<strong>AIRESPACE-WIRELESS-MIB::bsnMobileStationPolicyType (GAUGE):</strong><br>"Mode of the AP to which the Mobile Station is associated."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_airspace_rogueinfo_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los Rogue APs que dependen de este equipo</strong><br>Utiliza la tabla SNMP AIRESPACE-WIRELESS-MIB::bsnRogueAPTable (Enterprise=14179)<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPDot11MacAddress (GAUGE):</strong><br>"MAC Address of Rogue Station."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPTotalDetectingAPs (GAUGE):</strong><br>"Total number of Airespace APs that detected this rogue."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPFirstReported (GAUGE):</strong><br>"Time Stamp when this Rogue was First Detected."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPLastReported (GAUGE):</strong><br>"Time Stamp when this Rogue was Last Detected."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPContainmentLevel (GAUGE):</strong><br>"If the state of the rogue is contained, this specifies
                the level of containment. Higher the level, more the 
                number of detecting APs that are used to contain it.
                The value must be between 1 to 4 for contained state."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPType (GAUGE):</strong><br>"This attribute specifies if the Rogue is of ad-hoc type
                 or is an AP."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPOnNetwork (GAUGE):</strong><br>"This attribute specifies if the Rogue is on Wired 
                  Network or not."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPTotalClients (GAUGE):</strong><br>" Total number of Clients detected on this rogue."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPRowStatus (GAUGE):</strong><br>"Row Status"
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPMaxDetectedRSSI (GAUGE):</strong><br>"This is the max RSSI value of all the detctecting APs,
                  which have detected this rogue. "
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPSSID (GAUGE):</strong><br>"This is the SSID of the rogue detected by Access 
                  Point, which has max RSSI value of all the 
                  detectecting APs of this rogue."
<strong>AIRESPACE-WIRELESS-MIB::bsnRogueAPState (GAUGE):</strong><br>"This attribute is use to specify the state in which 
                  the Rogue AP is user can set the Rogue AP in alert, 
                  known or acknowledge state.
                  Alert state means Rogue AP can be a potential threat.
                  Trap will be sent out to trap recipients. 
                  Known state means its just internal AP which is not 
                  on the same Switch.  
                  Acknowledge state means an external AP whose
                  existence is acceptable and not a threat (probably 
                  some other companys AP).
                  Contained means containement is initiated and ongoing.
                  Threat is usually the state when the rogue is found 
                  on wired network.
                  known(4), knownContained(9) and trustedMissing(10) 
                  will appear in known rogue list.
                  known rogues can be pre provisioned and known rogues 
                  state can be changed to alert(2)"
',
	);

?>
