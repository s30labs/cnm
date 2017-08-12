<?
	$TIPS[]=array(
		'id_ref' => 'disk_mibhost',
		'tip_type' => 'cfg' ,	'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Disco Usado|Disco Total</strong> a partir de los siguientes atributos de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB::hrStorageAllocationUnits (Integer32):</strong> The size, in bytes, of the data objects allocated from this pool.  If this entry is monitoring sectors, blocks, buffers, or packets, for example, this number will commonly be greater than one.  Otherwise this number will typically be one.<br><strong>HOST-RESOURCES-MIB::hrStorageSize (Integer32):</strong> The size of the storage represented by this entry, in units of hrStorageAllocationUnits. This object is writable to allow remote configuration of the size of the storage area in those cases where such an operation makes sense and is possible on the underlying system. For example, the amount of main memory allocated to a buffer pool might be modified or the amount of disk space allocated to virtual memory might be modified.<br><strong>HOST-RESOURCES-MIB::hrStorageUsed (Integer32):</strong> The amount of the storage represented by this entry that is allocated, in units of hrStorageAllocationUnits.',
	);

	$TIPS[]=array(
		'id_ref' => 'disk_mibhostp',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>El porcentaje de Disco Usado</strong> a partir de los siguientes atributos de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB::hrStorageSize (Integer32):</strong> The size of the storage represented by this entry, in units of hrStorageAllocationUnits. This object is writable to allow remote configuration of the size of the storage area in those cases where such an operation makes sense and is possible on the underlying system. For example, the amount of main memory allocated to a buffer pool might be modified or the amount of disk space allocated to virtual memory might be modified.<br><strong>HOST-RESOURCES-MIB::hrStorageUsed (Integer32):</strong> The amount of the storage represented by this entry that is allocated, in units of hrStorageAllocationUnits.',
	);

	$TIPS[]=array(
		'id_ref' => 'proc_cnt_mibhost',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Número de procesos en el sistema</strong> a partir del siguiente atributo de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB::hrSystemProcesses (Gauge32):</strong> The number of process contexts currently loaded or running on this system.',
	);

	$TIPS[]=array(
		'id_ref' => 'users_cnt_mibhost',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Numero de sesiones de usuario activas</strong> a partir del siguiente atributos de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB:hrSystemNumUsers.0 (Gauge32):</strong> The number of user sessions for which this host is storing state information. A session is a collection of processes requiring a single act of user authentication and possibly subject to collective job control.',
	);

	$TIPS[]=array(
		'id_ref' => 'esp_cpu_mibhost',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>Uso de CPU</strong> a partir del s siguientes atributos de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB::hrProcessorLoad.x (Integer32):</strong> The average, over the last minute, of the percentage of time that this processor was not idle. Implementations may approximate this one minute smoothing period if necessary.',
	);

	$TIPS[]=array(
		'id_ref' => 'esp_cpu_avg_mibhost',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Uso promediado de CPU</strong> a partir de los siguientes atributos de la MIB HOST:<br><br><strong>HOST-RESOURCES-MIB::hrProcessorLoad (Integer32):</strong> The average, over the last minute, of the percentage of time that this processor was not idle. Implementations may approximate this one minute smoothing period if necessary.',
	);

	$TIPS[]=array(
		'id_ref' => 'traffic_mibii_if',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Bits Transmitidos|Bits Recibidos por cada interfaz</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ifInOctets (Counter32):</strong> The total number of octets received on the interface, including framing characters.<br><strong>RFC1213-MIB::ifOutOctets (Counter32):</strong> The total number of octets transmitted out of the interface, including framing characters.',
	);

	$TIPS[]=array(
		'id_ref' => 'traffic_mibii_if_hc',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Bits Transmitidos|Bits Recibidos por cada interfaz con los contadores de 64 bits. (No todos los equipos responden a éstos contadores)</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ifHCInOctets (Counter32):</strong> The total number of octets received on the interface, including framing characters.<br><strong>RFC1213-MIB::ifHCOutOctets (Counter32):</strong> The total number of octets transmitted out of the interface, including framing characters.',
	);

	$TIPS[]=array(
		'id_ref' => 'pkts_type_mibii_if',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>tipo de tráfico que circula por cada interfaz y lo divide en Unicast y No unicast</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ifInUcastPkts (Counter32):</strong> The number of subnetwork-unicast packets delivered to a higher-layer protocol.<br><strong>RFC1213-MIB::ifInNUcastPkts (Counter32):</strong>The number of non-unicast (i.e., subnetwork-broadcast or subnetwork-multicast) packets delivered to a higher-layer protocol.<br><strong>RFC1213-MIB::ifOutUcastPkts (Counter32):</strong> The total number of packets that higher-level protocols requested be transmitted to a subnetwork-unicast address, including those that were discarded or not sent.<br><strong>RFC1213-MIB::ifOutNUcastPkts (Counter32):</strong> The total number of packets that higher-level protocols requested be transmitted to a non-unicast (i.e., a subnetwork-broadcast or subnetwork-multicast) address, including those that were discarded or not sent.',
	);

	$TIPS[]=array(
		'id_ref' => 'pkts_type_mibii_if_ext',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>tipo de tráfico que circula por cada interfaz y lo divide en unicast, multicast y broadcast</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong> RFC1213-MIB::ifInUcastPkts (Counter32):</strong> The number of subnetwork-unicast packets delivered to a higher-layer protocol.<br><strong>RFC1213-MIB::ifInMulticastPkts (Counter32):</strong> The number of packets, delivered by this sub-layer to a higher (sub-)layer, which were addressed to a multicast address at this sub-layer. For a MAC layer protocol, this includes both Group and Functional addresses. Discontinuities in the value of this counter can occur at re-initialization of the management system, and at other times as indicated by the value of ifCounterDiscontinuityTime.<br><strong>RFC1213-MIB::ifInBroadcastPkts (Counter32):</strong> The number of packets, delivered by this sub-layer to a higher (sub-)layer, which were addressed to a broadcast address at this sub-layer. Discontinuities in the value of this counter can occur at re-initialization of the management system, and at other times as indicated by the value of ifCounterDiscontinuityTime.<br><strong>RFC1213-MIB::ifOutUcastPkts (Counter32):</strong> The total number of packets that higher-level protocols requested be transmitted to a subnetwork-unicast address, including those that were discarded or not sent.<br><strong>RFC1213-MIB::ifOutMulticastPkts (Counter32):</strong> The total number of packets that higher-level protocols requested be transmitted, and which were addressed to a multicast address at this sub-layer, including those that were discarded or not sent. For a MAC layer protocol, this includes both Group and Functional addresses. Discontinuities in the value of this counter can occur at re-initialization of the management system, and at other times as indicated by the value of ifCounterDiscontinuityTime.<br><strong>RFC1213-MIB::ifOutBroadcastPkts (Counter32):</strong> The total number of packets that higher-level protocols requested be transmitted, and which were addressed to a broadcast address at this sub-layer, including those that were discarded or not sent. Discontinuities in the value of this counter can occur at re-initialization of the management system, and at other times as indicated by the value of ifCounterDiscontinuityTime.',
	);

	$TIPS[]=array(
		'id_ref' => 'pkts_type_mibrmon',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>tipo de tráfico que circula por cada interfaz y lo divide en tráfico total, multicast y broadcast</strong> a partir de los siguientes atributos de la MIB RMON:<br><br><strong>RMON-MIB::etherStatsPkts (Counter32):</strong> The total number of packets (including bad packets, broadcast packets, and multicast packets) received.<br><strong>RMON-MIB::etherStatsBroadcastPkts (Counter32):</strong> The total number of good packets received that were directed to the broadcast address.  Note that this does not include multicast packets.<br><strong>RMON-MIB::etherStatsMulticastPkts (Counter32): The total number of good packets received that were directed to a multicast address.  Note that this number does not include packets directed to the broadcast address.',
	);

	$TIPS[]=array(
		'id_ref' => 'ip_pkts_discard',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>número de paquetes IP descartados en entrada y salida</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ipInDiscards.0 (Counter32):</strong> The number of input IP datagrams for which no problems were encountered to prevent their continued processing, but which were discarded (e.g., for lack of buffer space). Note that this counter does not include any datagrams discarded while awaiting re-assembly.<br><strong>RFC1213-MIB::ipInDiscards.0 (Counter32):</strong> The number of output IP datagrams for which no problem was encountered to prevent their transmission to their destination, but which were discarded (e.g., for lack of buffer space).  Note that this counter would include datagrams counted in ipForwDatagrams if any such packets met this (discretionary) discard criterion.',
	);

	$TIPS[]=array(
		'id_ref' => 'tcp_estab',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>número de sesiones TCP establecidas</strong> a partir del siguiente atributos de la MIB II:<br><br><strong>RFC1213-MIB::tcpCurrEstab.0 (Gauge32):</strong> The number of TCP connections for which the current state is either ESTABLISHED or CLOSE-WAIT.',
	);

	$TIPS[]=array(
		'id_ref' => 'tcp_ap',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>número de sesiones TCP abiertas entre activas y pasivas</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::tcpActiveOpens.0 (Counter32):</strong> The number of times TCP connections have made a direct transition to the SYN-SENT state from the CLOSED state.<br><strong>RFC1213-MIB::tcpPassiveOpens.0 (Counter32):<strong> The number of times TCP connections have made a direct transition to the SYN-RCVD state from the LISTEN state.',
	);

	$TIPS[]=array(
		'id_ref' => 'udp_pkts',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>número de paquetes UDP de entrada/salida</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::udpInDatagrams.0 (Counter32):</strong> The total number of UDP datagrams delivered to UDP users.<br><strong>RFC1213-MIB::udpOutDatagrams.0 (Counter32):</strong> The total number of UDP datagrams sent from this entity.',
	);

	$TIPS[]=array(
		'id_ref' => 'esp_arp_mibii_cnt',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>n&uacute;mero de entradas de la tabla de ARP del dispositivo</strong> a partir de los siguientes atributos de la MIB-II:<br><br><strong>RFC1213-MIB::ipNetToMediaNetAddress (Counter32):</strong>The IpAddress corresponding to the media-dependent physical address.<br><strong>RFC1213-MIB::ipNetToMediaPhysAddress (Counter32):</strong>The media-dependent physical address.</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'pkts_discard_mibii_if',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>n&uacute;mero de paquetes descartados en un interfaz</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ifInDiscards (Counter32):</strong>The number of inbound packets which were chosen to be discarded even though no errors had been detected to prevent their being deliverable to a higher-layer protocol.  One possible reason for discarding such a packet could be to free up buffer space.<br><strong>RFC1213-MIB::ifOutDiscards (Counter32):</strong>The number of outbound packets which were chosen to be discarded even though no errors had been detected to prevent their being transmitted.  One possible reason for discarding such a packet could be to free up buffer space.',
	);

	$TIPS[]=array(
		'id_ref' => 'errors_mibii_if',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>n&uacute;mero de errores producidos en un interfaz</strong> a partir de los siguientes atributos de la MIB II:<br><br><strong>RFC1213-MIB::ifInErrors (Counter32)</strong>The number of inbound packets that contained errors preventing them from being deliverable to a higher-layer protocol.<br><strong>RFC1213-MIB::ifOutErrors (Counter32)</strong>The number of outbound packets that could not be transmitted because of errors.',
	);

	$TIPS[]=array(
		'id_ref' => 'status_mibii_if',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>estado de un Interfaz</strong> a partir de los siguientes atributos de la MIB :<br><br><strong>RFC1213-MIB::ifAdminStatus (Counter32)</strong>The desired state of the interface.  The testing(3) state indicates that no operational packets can be passed.<br><strong>RFC1213-MIB::ifOperStatus (Counter32)</strong>The current operational state of the interface. The testing(3) state indicates that no operational packets can be passed.<br>Sobre los datos obtenidos aplica la siguiente lógica:<br>
ADMIN DOWN (azul) : Si ifAdminStatus = down (2)<br>
UP (verde)  : Si ifOperStatus = up (1) y ifAdminStatus = up (1)<br>
DOWN (rojo) : Si ifOperStatus = down (2) y ifAdminStatus = up (1)<br>
UNK (naranja) : Resto',
	);

	$TIPS[]=array(
		'id_ref' => 'nortel_memory',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide la: <strong>memoria</strong> de un router de Nortel a partir de los siguientes atributos de la MIB :<br><br><strong>Wellfleet-Series7-MIB::wfGameGroup.7.1.6.1</strong><br><strong>Wellfleet-Series7-MIB::wfGameGroup.7.1.7.1</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'nortel_cpu',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide la: <strong>cpu</strong> de un router de Nortel a partir de los siguientes atributos de la MIB :<br><br><strong>Wellfleet-Series7-MIB::wfGameGroup.7.1.2.1</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_memory',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>uso de memoria de un equipo Cisco IOS</strong> a partir de los siguientes atributos de la MIB CISCO-MEMORY-POOL-MIB:<br><br><strong>CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolUsed</strong>Indicates the number of bytes from the memory pool that are currently in use by applications on the managed device.<br><strong>CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolFree</strong>Indicates the number of bytes from the memory pool that are currently unused on the managed device. Note that the sum of ciscoMemoryPoolUsed and  ciscoMemoryPoolFree is the total amount of memory in the pool',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_cpu',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>uso de CPU del equipo</strong> a partir de los siguientes atributos de la MIB OLD-CISCO-SYS-MIB:<br><br><strong>OLD-CISCO-SYS-MIB::avgBusy5.0 (Integer)</strong>5 minute exponentially-decayed moving average of the CPU busy percentage.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_buffer_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>uso de los buffers de memoria</strong> a partir de los siguientes atributos de la MIB OLD-CISCO-MEMORY-MIB:<br><br><strong>OLD-CISCO-MEMORY-MIB::bufferSmTotal.0 (Integer)</strong> Contains the total number of small buffers.<br><strong>OLD-CISCO-MEMORY-MIB::bufferMdTotal.0 (Integer)</strong> Contains the total number of medium buffers.<br><strong>OLD-CISCO-MEMORY-MIB::bufferBgTotal.0 (Integer)</strong> Contains the total number of big buffers.<br><strong>OLD-CISCO-MEMORY-MIB::bufferLgTotal.0 (Integer)</strong> Contains the total number of large buffers.<br><strong>OLD-CISCO-MEMORY-MIB::bufferHgTotal.0 (Integer)</strong> Contains the total number of huge buffers.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_buffer_errors',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong>n&uacute;mero de errores en el manejo de los buffers de memoria</strong> a partir de los siguientes atributos de la MIB OLD-CISCO-SYS-MIB:<br><br><strong>OLD-CISCO-SYS-MIB::bufferFail.0 (Integer)</strong> Count of the number of buffer allocation failures.<br><strong>OLD-CISCO-SYS-MIB::bufferNoMem.0 (Integer)</strong> Count of the number of buffer create failures due to no free memory.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_ds0_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide la: <strong> ocupaci&oacute; de b&aacute;sicos RDSI</strong> a partir de los siguientes atributos de la MIB CISCO-POP-MGMT-MIB:<br><br><strong>CISCO-POP-MGMT-MIB::cpmActiveDS0s.0 (Gauge32)</strong>The number of DS0s that are currently in use.<br><strong>CISCO-POP-MGMT-MIB:: cpmActiveDS0sHighWaterMark.0 (Gauge32)</strong>The high water mark for number of DS0s that are active simultaneously',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_ds0_errors',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los: <strong>errores en circuitos b&aacute;sicos RDSI</strong> a partir de los siguientes atributos de la MIB CISCO-POP-MGMT-MIB:<br><br><strong>CISCO-POP-MGMT-MIB::cpmISDNCallsRejected.0 (Gounter32)</strong>The number of rejected ISDN calls in this managed device.<br><strong>CISCO-POP-MGMT-MIB::cpmISDNNoResource.0 (Gounter32)</strong>The number of ISDN calls that have been rejected because there is no B-Channel available to handle the call.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_modem_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide la: <strong>ocupaci&oacute;n de modems anal&oacute;gicos</strong> a partir de los siguientes atributos de la MIB CISCO-POP-MGMT-MIB:<br><br><strong>CISCO-POP-MGMT-MIB::cpmISDNCfgBChanInUseForAnalog.0 (Gauge32)</strong>The number of configured ISDN B-Channels that are currently occupied by analog calls.<br><strong>CISCO-POP-MGMT-MIB::cmSystemModemsAvailable.0 (Gauge32)</strong>The number of modems in the system that are onHook. That is, they are ready to accept a call.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_modem_errors',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los <strong>errores en modems anal&oacute;gicos</strong> a partir de los siguientes atributos de la MIB CISCO-POP-MGMT-MIB:<br><br><strong>CISCO-POP-MGMT-MIB::cpmModemCallsRejected.0(Gounter32)</strong> The number of rejected modem calls in this managed device.<br><strong>CISCO-POP-MGMT-MIB::cpmModemNoResource.0</strong> The number of modem calls that have been rejected because there is no modem available to handle the call.',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_wap_users',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los <strong>usuarios activos en un Punto de Acceso wireless</strong> a partir de los siguientes atributos de la MIB CISCO-DOT11-ASSOCIATION-MIB:<br><br><strong>CISCO-DOT11-ASSOCIATION-MIB::cDot11ActiveWirelessClients.1 (Gauge32)</strong> This is the number of wireless clients currently associating with this device on this  interface.',
	);

	$TIPS[]=array(
		'id_ref' => 'enterasys_cpu_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de CPU</strong> a partir del siguiente atributo de la MIB CTRON-SSR-CAPACITY-MIB:<br><br><strong>CTRON-SSR-CAPACITY-MIB::capCPUCurrentUtilization.1 (Integer)</strong>The CPU utilization expressed as an integer percentage. This is calculated over the last 5 seconds at a 0.1 second interval as a simple average.',
	);

	$TIPS[]=array(
		'id_ref' => 'enterasys_flow3',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los <strong>flujos de nivel 3</strong> a partir de los siguientes atributos de la MIB CTRON-SSR-CAPACITY-MIB:<br><br><strong>CTRON-SSR-CAPACITY-MIB::capCPUL3Learned.1 (Counter32)</strong>The total number of new layer 3 flows the CPU has processed and programmed into the Layer 3 hardware flow tables. Layer 3 flows are packets for IP or IPX protocols that will be routed from one subnet to another. Bridged flows or IP and IPX flows that originate and terminate in the same subnet are accounted for by capCPUL2Learned object.<br><strong>CTRON-SSR-CAPACITY-MIB::capCPUL3Aged.1 (Counter32)</strong>The total number of Layer 3flows that have been removed from the layer 3 hardware flow tables across all modules by the Layer 3 aging task. This number may increase quickly if routing protocols are not stable. Removal or insertion of routes into the forwarding table will cause premature aging of flows. Flows are normally aged/removed from the hardware when there are no more packets being sent for a defined time period.',
	);

	$TIPS[]=array(
		'id_ref' => 'enterasys_flow2',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los <strong>flujos de nivel 2</strong> a partir de los siguientes atributos de la MIB CTRON-SSR-CAPACITY-MIB:<br><br><strong>CTRON-SSR-CAPACITY-MIB::capCPUL2Learned.1 (Counter32)</strong>The number of L2 flows or addresses learned. The intended result here is to see how many stations attempt to establish switched communication through the SSR.<br><strong>CTRON-SSR-CAPACITY-MIB::capCPUL2Aged.1 (Counter32)</strong>The total number of L2 addresses or flows aged out.  Hosts that end switched communication through the SSR are aged out every 15 seconds.',
	);

	$TIPS[]=array(
		'id_ref' => 'brocade_frames_port',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>tr&aacute;fico por puerto Fiber Channel</strong> a partir de los siguientes atributos de la MIB SW-MIB:<br><br><strong>SW-MIB::swFCPortTxFrames (Counter32)</strong>This object counts the number of (Fibre Channel)frames that the port has transmitted.<br><strong>SW-MIB::swFCPortRxFrames (Counter32)</strong>This object counts the number of (Fibre Channel) frames that the port has received.',
	);

	$TIPS[]=array(
		'id_ref' => 'brocade_status_port',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => '',
	);

	$TIPS[]=array(
		'id_ref' => 'novell_nw_fs_read_write',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide la <strong>actividad de un sistema de ficheros Netware</strong> a partir de los siguientes atributos de la MIB NetWare-Server-MIB:<br><br><strong>NetWare-Server-MIB::nwFSWrites (Counter32)</strong>The total number of file reads the file system has made since this server was started. This value provides a relative measure of server activity.<br><strong>NetWare-Server-MIB::nwFSReads (Counter32)</strong>The total number of file writes the file system has made since this server was started. This value provides a relative measure of server activity.',
	);

	$TIPS[]=array(
		'id_ref' => 'novell_nw_fs_cache',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de la cache en un sistema de ficheros Netware</strong> a partir de los siguientes atributos de la MIB NetWare-Server-MIB:<br><br><strong>NetWare-Server-MIB::nwFSCacheChecks (Counter32)</strong>The total number of checks that have been made against the file cache.<br><strong>NetWare-Server-MIB::nwFSCacheHits (Counter32)</strong>The total number of times a file cache check has resulted in a hit.',
	);

	$TIPS[]=array(
		'id_ref' => 'novell_nw_open_files',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de ficheros abiertos en un servidor Netware</strong> a partir de los siguientes atributos de la MIB NetWare-Server-MIB:<br>
<br><strong>NetWare-Server-MIB::nwFSOpenFiles (Integer)</strong>The number of open files in the file system.
',
	);

	$TIPS[]=array(
		'id_ref' => 'novell_nw_disk_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de disco en un servidor Netware</strong> a partir de los siguientes atributos de la MIB NetWare-Server-MIB:<br><br><strong>NetWare-Server-MIB::nwVolSize (Integer32)</strong>The size of the volume in KBytes.<br><strong>NetWare-Server-MIB::nwVolFree (Integer32)</strong>The free space on the volume in KBytes. As this number approaches zero, the volume is running out of space for new or expanding files.
<br><strong>NetWare-Server-MIB::nwVolFreeable (Integer32)</strong>The amount of freeable space (in KBytes) being used by previously deleted files on this volume. The freeable space can be reclaimed as free space by purging deleted files.',
	);

	$TIPS[]=array(
		'id_ref' => 'novell_nw_disk_dir',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de directorios en un servidor Netware</strong> a partir de los siguientes atributos de la MIB NetWare-Server-MIB:<br><br><strong>NetWare-Server-MIB::nwVolTotalDirEntries (Integer)</strong> The total number of directory table entries available on this volume.<br><strong>NetWare-Server-MIB::nwVolUsedDirEntries (Integer)</strong> The number of directory table entries that are currently being used on this volume.',
	);

	$TIPS[]=array(
		'id_ref' => 'checkpoint_numconex',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de conexiones en un Firewall de Checkpoint</strong> a partir de los siguientes atributos de la MIB CHECKPOINT-MIB:<br><br><strong>CHECKPOINT-MIB::fwNumConn (Integer)</strong> Number of connections.',
	);

	$TIPS[]=array(
		'id_ref' => 'checkpoint_peakconex',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero m&aacute;ximo de conexiones en un Firewall de Checkpoint</strong> a partir de los siguientes atributos de la MIB CHECKPOINT-MIB:<br><br><strong>CHECKPOINT-MIB::fwPeakNumConn (Integer)</strong> Peak number of connections.',
	);

	$TIPS[]=array(
		'id_ref' => 'ucdavis_interrupts',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de interrupciones y cambios de contexto</strong> a partir de los siguientes atributos de la MIB UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssRawInterrupts (Counter32)</strong> Number of interrupts processed.<br><strong>UCD-SNMP-MIB::ssRawContexts (Counter32)</strong> Number of context switches.',
	);

	$TIPS[]=array(
		'id_ref' => 'ucdavis_cpu',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de CPU</strong> a partir de los siguientes atributos de la MIB UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawUser (Counter32)</strong> user CPU time.<br><strong>UCD-SNMP-MIB::ssCpuRawSystem (Counter32)</strong> system CPU time.<br><strong>UCD-SNMP-MIB::ssCpuRawIdle (Counter32)</strong> idle CPU time.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_files_sent',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de ficheros enviados por un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::totalFilesSent (Counter)</strong> This is the total number of files sent by this Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_current_users',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de usuarios actuales de un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::currentAnonymousUsers (Counter)</strong> This is the number of anonymous users currently connected to the Http Server.<br><strong>HttpServer-MIB::currentNonAnonymousUsers (Counter)</strong> This is the number of nonanonymous users currently connected to the Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_total_users',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de usuarios total de un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::totalAnonymousUsers (Counter)</strong> This is the total number of anonymous users that have ever connected to the Http Server.<br><strong>HttpServer-MIB::totalNonAnonymousUsers (Counter)</strong> This is the total number of nonanonymous users that have ever connected to the Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_max_users',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero m&aacute;ximo de usuarios conectados a un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::maxAnonymousUsers (Counter)</strong> This is the maximum number of anonymous users simultaneously connected to the Http Server.<br><strong>>HttpServer-MIB::maxNonAnonymousUsers (Counter)</strong> This is the maximum number of nonanonymous users simultaneously connected to the Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_current_connections',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero actual de conexiones de un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::currentConnections (Gauge)</strong> This is the current number of connections to the Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_connections',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide los <strong>intentos de conexi&oacute;n a un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::connectionAttempts (Counter)</strong> This is the number of connection attempts that have been made to the Http Server<br><strong>HttpServer-MIB::logonAttempts (Counter)</strong> This is the number of logon attempts that have been made to this Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_request_type1',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de peticiones de tipo GET, POST, HEAD u otras a un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::totalGets (Counter)</strong> This is the number of requests using the GET method that have been made to this Http Server.<br><strong>HttpServer-MIB::totalPosts (Counter)</strong> This is the number of requests using the POST method that have been made to this Http Server.<br><strong>HttpServer-MIB::totalHeads (Counter)</strong> This is the number of requests using the HEAD method that have been made to this Http Server.<br><strong>HttpServer-MIB::totalOthers (Counter)</strong> This is the number of requests not using the GET, POST or HEAD method that have been made to this Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_request_type2',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de peticiones de tipo CGI o BGI a un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::totalCGIRequests (Counter)</strong> This is the number of Common Gateway Interface (CGI) requests that have been made to this Http Server.<br><strong>HttpServer-MIB::totalBGIRequests (Counter)</strong> This is the number of Binary Gateway Interface (BGI) requests that have been made to this Http Server.',
	);

	$TIPS[]=array(
		'id_ref' => 'httpserver_error_notfound',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de peticiones no satisfechas por error 404 de un servidor WEB IIS</strong> a partir de los siguientes atributos de la MIB HttpServer-MIB:<br><br><strong>HttpServer-MIB::totalNotFoundErrors (Counter)</strong> This is the number of requests the Http server could not satisfy because the requested resource could not be found.',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_cpu_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de CPU en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsCpuUsage (Gauge32)</strong> CPU Usage of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_memory_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de memoria en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsMemUsage (Gauge32)</strong> Memory Usage of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_net_usage',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>tr&aacute:fico de red en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsNetUsage (Gauge32)</strong> Network Usage of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_active_sessions',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de sesiones activas en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsSesCount (Gauge32)</strong> Sessions Counter of HA Clusters unit.',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_packets',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de paquetes procesados por un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsPktCount (Counter32)</strong> Packets Counter of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_bytes',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de bytes procesados por un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsByteCount (Counter32)</strong> Bytes Counter of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_attacks',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de ataques detectados por el IDS en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsIdsCount (Counter32)</strong> IDS Counter of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_virus',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>n&uacute;mero de virus detectadis por el AV en un Firewall Fortinet</strong> a partir de los siguientes atributos de la MIB FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsAvCount (Counter32)</strong> AV Counter of HA Clusters unit',
	);

	$TIPS[]=array(
		'id_ref' => 'squid_cache_memory',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el <strong>uso de memoria por la cache de un proxy SQUID</strong> a partir de los siguientes atributos de la MIB SQUID-MIB:<br><br><strong>SQUID-MIB::cacheMemUsage (Integer32)</strong> Amount of system memory allocated by the cache.',
	);

	$TIPS[]=array(
		'id_ref' => '',   'tip_type' =>'cfg' , 'url' => '',
		'tip_type' => 'cfg' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Mide el: <strong></strong> a partir de los siguientes atributos de la MIB :<br>
<br><strong></strong>
<br><strong></strong>
<br><strong></strong>
<br><strong></strong>
',
	);

?>
