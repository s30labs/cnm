<?
	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_cluster_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre el cluster de Call Managers</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmName (GAUGE):</strong><br>"The host name of the CallManager."
<strong>CISCO-CCM-MIB::ccmDescription (GAUGE):</strong><br>"The description for the CallManager."
<strong>CISCO-CCM-MIB::ccmVersion (GAUGE):</strong><br>"The version number of the CallManager software."
<strong>CISCO-CCM-MIB::ccmStatus (GAUGE):</strong><br>"The current status of the CallManager. A CallManager
         is up if the SNMP Agent received a system up event
         from the local CCM 
             unknown:    Current status of the CallManager is
                         Unknown
             up:         CallManager is running & is able to
                         communicate with other CallManagers
             down:       CallManager is down or the Agent is
                         unable to communicate with the local
                         CallManager."
<strong>CISCO-CCM-MIB::ccmInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in ccmInetAddress."
<strong>CISCO-CCM-MIB::ccmInetAddress (GAUGE):</strong><br>"The last known IP address of the CallManager."
<strong>CISCO-CCM-MIB::ccmClusterId (GAUGE):</strong><br>"The unique ID of the Cluster to which this CallManager
         belongs. At any point in time, the Cluster Id helps in
         associating a CallManager to any given Cluster."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_cti_dev_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los dispositivos CTI registrados en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmCTIDeviceTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmCTIDeviceName (GAUGE):</strong><br>"The name of the CTI Device. This name is assigned to the
         CTI Device when it is added to the CallManager."
<strong>CISCO-CCM-MIB::ccmCTIDeviceType (GAUGE):</strong><br>"The type of CTI Device.
             unknown:                  Unknown CTI Device
             other:                    Unidentified CTI Device
             ctiRoutePoint:            A CTI Route Point
             ctiPort:                  A CTI Port."
<strong>CISCO-CCM-MIB::ccmCTIDeviceDescription (GAUGE):</strong><br>"A description of the CTI Device. This description is
         given when the CTI Device is configured in the CCM."
<strong>CISCO-CCM-MIB::ccmCTIDeviceStatus (GAUGE):</strong><br>"The status of the CTI Device. The CTI Device status changes
         from unknown to registered when it registers itself with
         the local CCM."
<strong>CISCO-CCM-MIB::ccmCTIDevicePoolIndex (GAUGE):</strong><br>"A positive value of this index is used to identify the
         Device Pool to which this CTI Device entry belongs. A
         value of 0 indicates that the index to the Device Pool
         table is Unknown."
<strong>CISCO-CCM-MIB::ccmCTIDeviceInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmCTIDeviceInetAddress."
<strong>CISCO-CCM-MIB::ccmCTIDeviceInetAddress (GAUGE):</strong><br>"The IP Address of the host where this CTI Device is
         running. A value of all zeros indicates that the IP
         Address is unknown."
<strong>CISCO-CCM-MIB::ccmCTIDeviceAppInfo (GAUGE):</strong><br>"The appinfo string indicates the application name/
         type that uses this CTI Device."
<strong>CISCO-CCM-MIB::ccmCTIDeviceStatusReason (GAUGE):</strong><br>"The reason code associated with the CTI Device status 
         change."
<strong>CISCO-CCM-MIB::ccmCTIDeviceTimeLastStatusUpdt (GAUGE):</strong><br>"The time the status of the CTI device changed."
<strong>CISCO-CCM-MIB::ccmCTIDeviceTimeLastRegistered (GAUGE):</strong><br>"The time the CTI Device last registered with the call 
         manager."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_gatekeeper_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los Gatekeepers definidos en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmGatekeeperTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmGatekeeperName (GAUGE):</strong><br>"This is the Gatekeeper name assigned to the
         Gatekeeper. This name is assigned when a new device
         of type Gatekeeper is added to the CallManager."
<strong>CISCO-CCM-MIB::ccmGatekeeperType (GAUGE):</strong><br>"The type of Gatekeeper.
             unknown:                  Unknown Gatekeeper
             other:                    Unidentified Gatekeeper
             terminal:                 Terminal
             gateway:                  Gateway."
<strong>CISCO-CCM-MIB::ccmGatekeeperDescription (GAUGE):</strong><br>"A description of the Gatekeeper. This description
         is given when the Gatekeeper is configured in the CCM."
<strong>CISCO-CCM-MIB::ccmGatekeeperStatus (GAUGE):</strong><br>"The local call manager registration status with the Gatekeeper.
         The status changes from unknown to registered when the local 
         call manager successfully registers itself with the gatekeeper.
             unknown:        The registration status of the call manager 
                             with the gatekeeper is unknown
             registered:     The local call manager has registered with
                             the gatekeeper successfully
             unregistered:   The local call manager is no longer
                             registered with the gatekeeper
             rejected:       Registration request from the local call 
                             manager was rejected by the gatekeeper."
<strong>CISCO-CCM-MIB::ccmGatekeeperDevicePoolIndex (GAUGE):</strong><br>"A positive value of this index is used to identify the
         Device Pool to which this Gatekeeper entry belongs. A
         value of 0 indicates that the index to the Device Pool
         table is Unknown."
<strong>CISCO-CCM-MIB::ccmGatekeeperInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmGatekeeperInetAddress."
<strong>CISCO-CCM-MIB::ccmGatekeeperInetAddress (GAUGE):</strong><br>"The last known IP Address of the gatekeeper. A value of
          all zeros indicates that the IP Address is not available."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_gateway_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los gateways definidos en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmGatewayTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmGatewayName (GAUGE):</strong><br>"This is the Gateway name assigned to the Gateway in
         the CallManager. This name is assigned when a new
         device of type Gateway is added to the CallManager."
<strong>CISCO-CCM-MIB::ccmGatewayType (GAUGE):</strong><br>"The type of the gateway device.
         unknown(1):                             Unknown Gateway type
         other(2):                               Unidentified Gateway 
                                                 type
         ciscoAnalogAccess(3):                   Analog Access
         ciscoDigitalAccessPRI(4):               Digital Access PRI
         ciscoDigitalAccessT1(5):                Digital Access T1
         ciscoDigitalAccessPRIPlus(6):           Digital Access 
                                                 PRI Plus
         ciscoDigitalAccessWSX6608E1(7):         Cat 6000 Digital 
                                                 Access E1
         ciscoDigitalAccessWSX6608T1(8):         Cat 6000 Digital 
                                                 Access T1
         ciscoAnalogAccessWSX6624(9):            Cat 6000 Analog 
                                                 Access FXS
         ciscoMGCPStation(10):                   MGCP Gateway
         ciscoDigitalAccessE1Plus(11):           Digital Access 
                                                 E1 Plus
         ciscoDigitalAccessT1Plus(12):           Digital Access 
                                                 T1 Plus
         ciscoDigitalAccessWSX6608PRI(13):       Cat 6000 Digital 
                                                 Access PRI
         ciscoAnalogAccessWSX6612(14):           Cat 6000 Analog 
                                                 Access FXO
         ciscoMGCPTrunk(15):                     MGCP Trunk
         ciscoVG200(16):                         VG200
         cisco26XX(17):                          26XX
         cisco362X(18):                          362X
         cisco364X(19):                          364X
         cisco366X(20):                          366X
         ciscoCat4224VoiceGatewaySwitch(21):     Cisco Catalyst 4224 
                                                 Voice Gateway Switch
         ciscoCat4000AccessGatewayModule(22):    Cisco Catalyst 4000 
                                                 Access Gateway Module
         ciscoIAD2400(23):                       Cisco IAD2400
         ciscoVGCEndPoint(24):                   Cisco VGC Phone
         ciscoVG224VG248Gateway(25):             Cisco VGC Gateway
         ciscoVGCBox(26):                        Cisco VGC Box
         ciscoATA186(27):                        Cisco ATA 186
         ciscoICS77XXMRP2XX(28):                 Cisco ICS77XX-MRP2XX
         ciscoICS77XXASI81(29):                  Cisco ICS77XX-ASI81
         ciscoICS77XXASI160(30):                 Cisco ICS77XX-ASI160
         ciscoSlotVGCPort(31):                   Cisco VGC Port
         ciscoCat6000AVVIDServModule(32)         Cisco Catalyst 6000
                                                 AVVID Services Module
         ciscoWSX6600                            WS-X6600."
<strong>CISCO-CCM-MIB::ccmGatewayDescription (GAUGE):</strong><br>"The description attached to the gateway device."
<strong>CISCO-CCM-MIB::ccmGatewayStatus (GAUGE):</strong><br>"The status of the gateway. The Gateway status changes from
         Unknown to Registered when the Gateway registers itself with
         the local CCM."
<strong>CISCO-CCM-MIB::ccmGatewayDevicePoolIndex (GAUGE):</strong><br>"A positive value of this index is used to identify
         the Device Pool to which this Gateway entry belongs.
         A value of 0 indicates that the index to the Device
         Pool table is Unknown."
<strong>CISCO-CCM-MIB::ccmGatewayInetAddress (GAUGE):</strong><br>"The last known IP Address of the gateway. A value of
          all zeros indicates that the IP Address is not available."
<strong>CISCO-CCM-MIB::ccmGatewayProductId (GAUGE):</strong><br>"The product identifier of the gateway device."
<strong>CISCO-CCM-MIB::ccmGatewayStatusReason (GAUGE):</strong><br>"The reason code associated with the gateway status change."
<strong>CISCO-CCM-MIB::ccmGatewayTimeLastStatusUpdt (GAUGE):</strong><br>"The time the status of the gateway changed."
<strong>CISCO-CCM-MIB::ccmGatewayTimeLastRegistered (GAUGE):</strong><br>"The time the gateway last registered with the call manager."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_h323_dev_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los dispositivos H323 registraods en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmH323DeviceTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmH323DevName (GAUGE):</strong><br>"The device name assigned to the H323 Device. 
          This name is assigned when a new H323 device is added to
          the CallManager."
<strong>CISCO-CCM-MIB::ccmH323DevProductId (GAUGE):</strong><br>"The product identifier of the H323 device."
<strong>CISCO-CCM-MIB::ccmH323DevDescription (GAUGE):</strong><br>"A description of the H323 device. This description
         is given when the H323 device is configured in the CCM."
<strong>CISCO-CCM-MIB::ccmH323DevInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmH323DeviceInetAddress."
<strong>CISCO-CCM-MIB::ccmH323DevInetAddress (GAUGE):</strong><br>"The last known IP Address of the H323 device. A value of
          all zeros indicates that the IP Address is not available."
<strong>CISCO-CCM-MIB::ccmH323DevCnfgGKInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmH323DevCnfgGKInetAddress."
<strong>CISCO-CCM-MIB::ccmH323DevCnfgGKInetAddress (GAUGE):</strong><br>"The configured gatekeeper DNS name or ip address for this
         H323 device. This is applicable only for H323 devices with 
         gatekeepers configured. When there is no gatekeeper 
         configured, this will be NULL."
<strong>CISCO-CCM-MIB::ccmH323DevStatus (GAUGE):</strong><br>"The H323 device registration status with the gatekeeper.
         The status changes from unknown to registered when the H323
         device successfully registers itself with the gatekeeper.
             notApplicable:  The registration status is not applicable
                             for this H323 device 
             unknown:        The registration status of the H323 device 
                             with the gatekeeper is unknown
             registered:     The H323 device has registered with the 
                             gatekeeper successfully
             unregistered:   The H323 device is no longer registered
                             with the gatekeeper
             rejected:       Registration request from the H323 device
                             was rejected by the gatekeeper."
<strong>CISCO-CCM-MIB::ccmH323DevStatusReason (GAUGE):</strong><br>"The reason code associated with ccmH233DevStatus change.
         This is applicable only for H323 devices with gatekeepers 
         configured."
<strong>CISCO-CCM-MIB::ccmH323DevTimeLastStatusUpdt (GAUGE):</strong><br>"The time the registration status with the gatekeeper changed.
         This is applicable only for H323 devices with gatekeepers 
         configured."
<strong>CISCO-CCM-MIB::ccmH323DevTimeLastRegistered (GAUGE):</strong><br>"The time when the H323 device last registered with the
         gatekeeper. This is applicable only for H323 devices with 
         gatekeepers configured."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_media_dev_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los media devices definidos en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmMediaDeviceTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmMediaDeviceName (GAUGE):</strong><br>"This is the device name assigned to the Media Device.
         This name is assigned when a new device of this type
         is added to the CallManager."
<strong>CISCO-CCM-MIB::ccmMediaDeviceType (GAUGE):</strong><br>"The type of Media Device.
         unknown(1):                         Unknown Media Device
         ciscoMediaTerminPointWSX6608(2):    Hardware based 
                                             Media Termination Point
         ciscoConfBridgeWSX6608(3):          Hardware based 
                                             Conference Bridge
         ciscoSwMediaTerminationPoint(4):    Sofware based 
                                             Media Termination Point
         ciscoSwConfBridge(5):               Software based 
                                             Conference Bridge
         ciscoMusicOnHold(6):                Music on Hold Server."
<strong>CISCO-CCM-MIB::ccmMediaDeviceDescription (GAUGE):</strong><br>"A description of the Media Device. This description
         is given when the device is configured in the CCM."
<strong>CISCO-CCM-MIB::ccmMediaDeviceStatus (GAUGE):</strong><br>"The status of the Media Device. The status changes
         from unknown to registered when it registers itself with
         the local CCM."
<strong>CISCO-CCM-MIB::ccmMediaDeviceDevicePoolIndex (GAUGE):</strong><br>"A positive value of this index is used to identify the
         Device Pool to which this MediaDevice entry belongs. A
         value of 0 indicates that the index to the Device Pool
         table is Unknown."
<strong>CISCO-CCM-MIB::ccmMediaDeviceInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmMediaDeviceInetAddress."
<strong>CISCO-CCM-MIB::ccmMediaDeviceInetAddress (GAUGE):</strong><br>"The last known IP Address of the Media Device.
         A value of all zeros indicates that the IP Address is not
         available."
<strong>CISCO-CCM-MIB::ccmMediaDeviceStatusReason (GAUGE):</strong><br>"The reason code associated with the media device status 
         change."
<strong>CISCO-CCM-MIB::ccmMediaDeviceTimeLastStatusUpdt (GAUGE):</strong><br>"The time the status of the media device changed."
<strong>CISCO-CCM-MIB::ccmMediaDeviceTimeLastRegistered (GAUGE):</strong><br>"The time the media device last registered with the 
         call manager."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_phone_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los telefonos definidos en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmPhoneTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmPhonePhysicalAddress (GAUGE):</strong><br>"The physical address(MAC address) of the IP phone."
<strong>CISCO-CCM-MIB::ccmPhoneType (GAUGE):</strong><br>"The type of the phone device.
             unknown:                  Unknown phone type
             other:                    Unidentified phone type
             cisco30SPplus:            IP Phone 30 SP+
             cisco12SPplus:            IP Phone 12 SP+
             cisco12SP:                IP Phone 12 SP
             cisco12S:                 IP Phone 12 S
             cisco30VIP:               IP Phone 30 VIP
             ciscoTeleCasterBid:       IP Phone Telecaster 7910
             ciscoTeleCasterMgr:       IP Phone Telecaster 7960
             ciscoTeleCasterBusiness:  IP Phone Telecaster 7940
             ciscoSoftPhone:           Softphone
             ciscoConferencePhone:     IP Conference Station 7935."
<strong>CISCO-CCM-MIB::ccmPhoneDescription (GAUGE):</strong><br>"The description about the phone itself."
<strong>CISCO-CCM-MIB::ccmPhoneUserName (GAUGE):</strong><br>"The name of the user of the phone. When the phone
         is not in use, the name would refer to the last known
         user of the phone."
<strong>CISCO-CCM-MIB::ccmPhoneIpAddress (GAUGE):</strong><br>"The last known IP address of the phone."
<strong>CISCO-CCM-MIB::ccmPhoneStatus (GAUGE):</strong><br>"The status of the phone. The status of the Phone changes
         from Unknown to registered when it registers itself with
         the local CCM."
<strong>CISCO-CCM-MIB::ccmPhoneTimeLastRegistered (GAUGE):</strong><br>"The time when the phone last registered with the
         CallManager."
<strong>CISCO-CCM-MIB::ccmPhoneE911Location (GAUGE):</strong><br>"The E911 location of the phone."
<strong>CISCO-CCM-MIB::ccmPhoneLoadID (GAUGE):</strong><br>"The load ID string of the phone."
<strong>CISCO-CCM-MIB::ccmPhoneLastError (GAUGE):</strong><br>"A positive value or 0 indicates the last error
         reported by the phone. A value of -1 indicates
         that the last error reported is Unknown."
<strong>CISCO-CCM-MIB::ccmPhoneTimeLastError (GAUGE):</strong><br>"The amount of time elapsed since the last phone error
         occured. The reference point for this time is the time
         the last error occured, as reported by the local CCM."
<strong>CISCO-CCM-MIB::ccmPhoneDevicePoolIndex (GAUGE):</strong><br>"A positive value of this index is used to identify the
         Device Pool to which this Phone entry belongs. A value
         of 0 indicates that the index to the Device Pool table
         is Unknown."
<strong>CISCO-CCM-MIB::ccmPhoneInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in 
         ccmPhoneInetAddress."
<strong>CISCO-CCM-MIB::ccmPhoneInetAddress (GAUGE):</strong><br>"The last known IP address of the phone."
<strong>CISCO-CCM-MIB::ccmPhoneStatusReason (GAUGE):</strong><br>"The reason code associated with the phone status change."
<strong>CISCO-CCM-MIB::ccmPhoneTimeLastStatusUpdt (GAUGE):</strong><br>"The time the status of the phone changed."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_timezone_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre las zonas horarias definidas en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmTimeZoneTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmTimeZoneName (GAUGE):</strong><br>"The name of the time zone group."
<strong>CISCO-CCM-MIB::ccmTimeZoneOffsetHours (GAUGE):</strong><br>"The offset hours of the time zone groups time zone 
         from GMT."
<strong>CISCO-CCM-MIB::ccmTimeZoneOffsetMinutes (GAUGE):</strong><br>"The offset minutes of the time zone groups time zone 
         from GMT."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_cisco_ccm_vmail_dev_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion relevante sobre los dispositivos de buzon de voz registraods en el Call Manager</strong><br>Utiliza la tabla SNMP CISCO-CCM-MIB::ccmVoiceMailDeviceTable (Enterprise=00009)<br><br><strong>CISCO-CCM-MIB::ccmVMailDevName (GAUGE):</strong><br>"The name of the Voice Mail Device. This name is assigned 
         to the Voice Mail Device when it is added to the 
         CallManager."
<strong>CISCO-CCM-MIB::ccmVMailDevProductId (GAUGE):</strong><br>"The product identifier of the Voice Mail device."
<strong>CISCO-CCM-MIB::ccmVMailDevDescription (GAUGE):</strong><br>"A description of the Voice Mail Device. This description is
         given when the Voice Mail Device is configured in the CCM."
<strong>CISCO-CCM-MIB::ccmVMailDevStatus (GAUGE):</strong><br>"The status of the Voice Mail Device. The Voice Mail Device 
         status changes from unknown to registered when it registers 
         itself with the local CCM."
<strong>CISCO-CCM-MIB::ccmVMailDevInetAddressType (GAUGE):</strong><br>"Represents the type of address stored in
         ccmVoiceMailDevInetAddress."
<strong>CISCO-CCM-MIB::ccmVMailDevInetAddress (GAUGE):</strong><br>"The IP Address of the Voice Mail Device. A value of all
         zeros indicates that the IP Address is unknown."
<strong>CISCO-CCM-MIB::ccmVMailDevStatusReason (GAUGE):</strong><br>"The reason code associated with the Voice Mail Device 
         status change."
<strong>CISCO-CCM-MIB::ccmVMailDevTimeLastStatusUpdt (GAUGE):</strong><br>"The time the status of the voice mail device changed."
<strong>CISCO-CCM-MIB::ccmVMailDevTimeLastRegistered (GAUGE):</strong><br>"The time the Voice Mail Device has last registered 
         with the call manager."
',
	);

?>
