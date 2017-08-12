<?php
      $TIPS[]=array(
         'id_ref' => 'app_cisco_chasisinfo',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el chasis del dispositivo</strong><br>Utiliza la tabla SNMP OLD-CISCO-CHASSIS-MIB::cardTable (Enterprise=00009)<br><br><strong>OLD-CISCO-CHASSIS-MIB::cardIndex (GAUGE):</strong><br>"Index into cardTable (not physical chassis
                            slot number)."
<strong>OLD-CISCO-CHASSIS-MIB::cardType (GAUGE):</strong><br>"Functional type of this card."
<strong>OLD-CISCO-CHASSIS-MIB::cardDescr (GAUGE):</strong><br>"Text description of this card."
<strong>OLD-CISCO-CHASSIS-MIB::cardSerial (GAUGE):</strong><br>"The serial number of this card, or zero if
                            unavailable."
<strong>OLD-CISCO-CHASSIS-MIB::cardHwVersion (GAUGE):</strong><br>"Hardware revision level of this card, or an
                            empty string if unavailable."
<strong>OLD-CISCO-CHASSIS-MIB::cardSwVersion (GAUGE):</strong><br>"Version of the firmware or microcode
                            installed on this card, or an empty string if
                            unavailable."
<strong>OLD-CISCO-CHASSIS-MIB::cardSlotNumber (GAUGE):</strong><br>"Slot number relative to the containing card or 
                            chassis, or -1 if neither applicable nor 
                            determinable."
<strong>OLD-CISCO-CHASSIS-MIB::cardContainedByIndex (GAUGE):</strong><br>"cardIndex of the parent card which
                            directly contains this card, or 0 if
                            contained by the chassis, or -1 if not
                            applicable nor determinable."
<strong>OLD-CISCO-CHASSIS-MIB::cardOperStatus (GAUGE):</strong><br>"The operational status of the card.
                            cardOperStatus is up when a card is
                            recognized by the device and is enabled for
                            operation. cardOperStatus is down if the
                            card is not recognized by the device, or if
                            it is not enabled for operation.
                            cardOperStatus is standby if the card is
                            enabled and acting as a standby slave"
<strong>OLD-CISCO-CHASSIS-MIB::cardSlots (GAUGE):</strong><br>"Number of slots on this card, or 0 if no
                            slots or not applicable, or -1 if not 
 			   determinable."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_cpuuse',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion en detalle sobre el uso de CPU del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-PROCESS-MIB::cpmCPUTotalTable (Enterprise=00009)<br><br><strong>CISCO-PROCESS-MIB::cpmCPUTotalPhysicalIndex (GAUGE):</strong><br>"The entPhysicalIndex of the physical entity for which
 		 the CPU statistics in this entry are maintained.
 		 The physical entity can be a CPU chip, a group of CPUs,
 		 a CPU card etc. The exact type of this entity is described by
 		 its entPhysicalVendorType value. If the CPU statistics
 		 in this entry correspond to more than one physical entity
 		 (or to no physical entity), or if the entPhysicalTable is
 		 not supported on the SNMP agent, the value of this object
 		 must be zero."
<strong>CISCO-PROCESS-MIB::cpmCPUTotal5sec (GAUGE):</strong><br>"The overall CPU busy percentage in the last 5 second 
 		period. This object obsoletes the busyPer object from 
 		the OLD-CISCO-SYSTEM-MIB. This object is deprecated
 		by cpmCPUTotal5secRev which has the changed range of
 		value (0..100)."
<strong>CISCO-PROCESS-MIB::cpmCPUTotal1min (GAUGE):</strong><br>"The overall CPU busy percentage in the last 1 minute
 		period. This object obsoletes the avgBusy1 object from 
 		the OLD-CISCO-SYSTEM-MIB. This object is deprecated
 		by cpmCPUTotal1minRev which has the changed range
 		of value (0..100)."
<strong>CISCO-PROCESS-MIB::cpmCPUTotal5min (GAUGE):</strong><br>"The overall CPU busy percentage in the last 5 minute
 		period. This object deprecates the avgBusy5 object from 
 		the OLD-CISCO-SYSTEM-MIB. This object is deprecated
 		by cpmCPUTotal5minRev which has the changed range 
 		of value (0..100)."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_cryptotunnels',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre los tuneles IPSEC configurados en el dispositivo</strong><br>Utiliza la tabla SNMP CISCO-IPSEC-MIB::cipsStaticCryptomapTable (Enterprise=00009)<br><br><strong>CISCO-IPSEC-MIB::cipsStaticCryptomapType (GAUGE):</strong><br>"The type of the cryptomap entry. This can be an ISAKMP
       cryptomap, CET or manual. Dynamic cryptomaps are not
       counted in this table."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapDescr (GAUGE):</strong><br>"The description string entered by the operatoir
       while creating this cryptomap. The string generally
       identifies a description and the purpose of this
       policy."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapPeer (GAUGE):</strong><br>"The IP address of the current peer associated with 
       this IPSec policy item. Traffic that is protected by
       this cryptomap is protected by a tunnel that terminates
       at the device whose IP address is specified by this
       object."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapPeer (GAUGE):</strong><br>"The IP address of the current peer associated with 
       this IPSec policy item. Traffic that is protected by
       this cryptomap is protected by a tunnel that terminates
       at the device whose IP address is specified by this
       object."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapNumPeers (GAUGE):</strong><br>"The number of peers associated with this cryptomap 
        entry. The peers other than the one identified by 
       cipsStaticCryptomapPeer are backup peers. 
       
       Manual cryptomaps may have only one peer."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapPfs (GAUGE):</strong><br>"This object identifies if the tunnels instantiated
       due to this policy item should use Perfect Forward Secrecy 
       (PFS) and if so, what group of Oakley they should use."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapLifetime (GAUGE):</strong><br>"This object identifies the lifetime of the IPSec
       Security Associations (SA) created using this IPSec policy
       entry. If this value is zero, the lifetime assumes the 
       value specified by the global lifetime parameter."
<strong>CISCO-IPSEC-MIB::cipsStaticCryptomapLevelHost (GAUGE):</strong><br>"This object identifies the granularity of the
       IPSec SAs created using this IPSec policy entry. 
       If this value is TRUE, distinct SA bundles are created
       for distinct hosts at the end of the application traffic."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_fan',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el estado de los ventiladores del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable (Enterprise=00009)<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonFanStatusDescr (GAUGE):</strong><br>"Textual description of the fan being instrumented.
                 This description is a short textual label, suitable as a
                 human-sensible identification for the rest of the
                 information in the entry."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonFanState (GAUGE):</strong><br>"The current state of the fan being instrumented."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_fw_con_status',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra informacion sobre los valores de estado de las conexiones del firewall interno</strong><br>Utiliza la tabla SNMP CISCO-FIREWALL-MIB::cfwConnectionStatTable (Enterprise=00009)<br><br><strong>CISCO-FIREWALL-MIB::cfwConnectionStatService (GAUGE):</strong><br>"The identification of the type of connection providing
             statistics."
<strong>CISCO-FIREWALL-MIB::cfwConnectionStatType (GAUGE):</strong><br>"The state of the connections that this row contains
             statistics for."
<strong>CISCO-FIREWALL-MIB::cfwConnectionStatDescription (GAUGE):</strong><br>"A detailed textual description of this statistic."
<strong>CISCO-FIREWALL-MIB::cfwConnectionStatCount (COUNTER):</strong><br>"This is an integer that contains the value of the
             resource statistic. If a type of gauge is more
             appropriate this object will be omitted resulting 
             in a sparse table."
<strong>CISCO-FIREWALL-MIB::cfwConnectionStatValue (GAUGE):</strong><br>"This is an integer that contains the value of the
             resource statistic. If a type of counter is more
             appropriate this object will be omitted resulting 
             in a sparse table."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_fw_hw_status',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra informacion sobre los valores de estado del firewall interno</strong><br>Utiliza la tabla SNMP CISCO-FIREWALL-MIB::cfwHardwareStatusTable (Enterprise=00009)<br><br><strong>CISCO-FIREWALL-MIB::cfwHardwareType (GAUGE):</strong><br>"The hardware type for which this row provides 
             status information."
<strong>CISCO-FIREWALL-MIB::cfwHardwareInformation (GAUGE):</strong><br>"A detailed textual description of the resource
             identified by cfwHardwareType."
<strong>CISCO-FIREWALL-MIB::cfwHardwareStatusValue (GAUGE):</strong><br>"This object contains the current status of the resource."
<strong>CISCO-FIREWALL-MIB::cfwHardwareStatusDetail (GAUGE):</strong><br>"A detailed textual description of the current status of
             the resource which may provide a more specific description 
             than cfwHardwareStatusValue."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_flashuse',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el uso de la memoria Flash del dispositivo</strong><br>Utiliza la tabla SNMP OLD-CISCO-FLASH-MIB::lflashFileDirTable (Enterprise=00009)<br><br><strong>OLD-CISCO-FLASH-MIB::flashDirName (GAUGE):</strong><br>"Name associated with the flash entry"
<strong>OLD-CISCO-FLASH-MIB::flashDirSize (GAUGE):</strong><br>"Size in Octets of a flash entry"
<strong>OLD-CISCO-FLASH-MIB::flashDirStatus (GAUGE):</strong><br>"Indicates the status of the entry"
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_ipsectunnels',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre los tuneles IPSEC establecidos del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunnelTable (Enterprise=00009)<br><br><strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunLocalType (GAUGE):</strong><br>"The type of local peer identity.  The local 
          peer may be identified by:
           1. an IP address, or
           2. a host name."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunLocalValue (GAUGE):</strong><br>"The value of the local peer identity.
 
           If the local peer type is an IP Address, then this
           is the IP Address used to identify the local peer.
 
           If the local peer type is a host name, then this is
           the host name used to identify the local peer."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunLocalAddr (GAUGE):</strong><br>"The IP address of the local endpoint for the IPsec
           Phase-1 IKE Tunnel."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunLocalName (GAUGE):</strong><br>"The DNS name of the local IP address for 
          the IPsec Phase-1 IKE Tunnel. If the DNS 
          name associated with the local tunnel endpoint 
          is not known, then the value of this
           object will be a NULL string."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunRemoteType (GAUGE):</strong><br>"The type of remote peer identity.  
          The remote peer may be identified by:
           1. an IP address, or
           2. a host name."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunRemoteValue (GAUGE):</strong><br>"The value of the remote peer identity.
 
           If the remote peer type is an IP Address, then this
           is the IP Address used to identify the remote peer.
 
           If the remote peer type is a host name, then 
           this is the host name used to identify the 
           remote peer."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunRemoteAddr (GAUGE):</strong><br>"The IP address of the remote endpoint for the IPsec
           Phase-1 IKE Tunnel."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunRemoteName (GAUGE):</strong><br>"The DNS name of the remote IP address of IPsec Phase-1
           IKE Tunnel. If the DNS name associated with the remote
           tunnel endpoint is not known, then the value of this
           object will be a NULL string."
<strong>CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunNegoMode (GAUGE):</strong><br>"The negotiation mode of the IPsec Phase-1 IKE Tunnel."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_memoryused',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion en detalle sobre el uso de memoria del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolTable (Enterprise=00009)<br><br><strong>CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolName (GAUGE):</strong><br>"A textual name assigned to the memory pool.  This
         object is suitable for output to a human operator,
         and may also be used to distinguish among the various
         pool types, especially among dynamic pools."
<strong>CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolUsed (GAUGE):</strong><br>"Indicates the number of bytes from the memory pool
         that are currently in use by applications on the
         managed device."
<strong>CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolFree (GAUGE):</strong><br>"Indicates the number of bytes from the memory pool
         that are currently unused on the managed device.
 
         Note that the sum of ciscoMemoryPoolUsed and
         ciscoMemoryPoolFree is the total amount of memory
         in the pool"
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_nat_ext_status',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra informacion sobre las estadisticas de NAT del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-NAT-EXT-MIB::cneAddrTranslationStatsTable (Enterprise=00009)<br><br><strong>CISCO-NAT-EXT-MIB::cneAddrTranslationNumActive (GAUGE):</strong><br>"The total number of address translation entries that
                  are currently available in the NAT device. This indicates
                  the aggregate of the translation entries created from 
                  both the static and dynamic address translation 
                  mechanisms.
                 "
<strong>CISCO-NAT-EXT-MIB::cneAddrTranslationNumPeak (GAUGE):</strong><br>"The maximum number of address translation entries
                  that are active at any one time since the system
                  startup. This indicates the high watermark of
                  address translation entries that are active at any
                  one time since the system startup.
                  
                  This object includes the translation entries created
                  from both the static and dynamic address translation
                  mechanisms.
                 "
<strong>CISCO-NAT-EXT-MIB::cneAddrTranslation1min (GAUGE):</strong><br>"The averaged number of address translation entries 
                  which the NAT device establishing per second, averaged
                  over the last 1 minute.
                  
                  This object includes the translation entries created
          from both the static and dynamic address translation
                  mechanisms.
                 "
<strong>CISCO-NAT-EXT-MIB::cneAddrTranslation5min (GAUGE):</strong><br>"The averaged number of address translation entries which
          the NAT device establishing per second, averaged over
                  the last 5 minutes.
                  
          This object includes the translation entries created
          from both the static and dynamic address translation
                  mechanisms.
                 "
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_powersupply',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el estado de las fuentes de alimentacion del dispositivo</strong><br>Utiliza la tabla SNMP CISCO (Enterprise=00009)<br><br><strong>::::ciscoEnvMonSupplyStatusDescr (GAUGE):</strong><br><strong>::::ciscoEnvMonSupplyState (GAUGE):</strong><br><strong>::::ciscoEnvMonSupplySource (GAUGE):</strong><br>',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_processestable',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion en detalle sobre los procesos en curso del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-PROCESS-MIB::cpmProcessTable (Enterprise=00009)<br><br><strong>CISCO-PROCESS-MIB::cpmProcessPID (GAUGE):</strong><br>"This object contains the process ID. cpmTimeCreated
 		should be checked against the last time it was polled,
 		and if it has changed the PID has been reused and the
 		 entire entry should be polled again."
<strong>CISCO-PROCESS-MIB::cpmProcessName (GAUGE):</strong><br>"The name associated with this process. If the name is
 		longer than 32 characters, it will be truncated to the first
 		31 characters, and a `* will be appended as the last
 		character to imply this is a truncated process name."
<strong>CISCO-PROCESS-MIB::cpmProcessuSecs (GAUGE):</strong><br>"Average elapsed CPU time in microseconds when the 
                 process was active. This object is deprecated
 		by cpmProcessAverageUSecs."
<strong>CISCO-PROCESS-MIB::cpmProcessTimeCreated (GAUGE):</strong><br>"The time when the process was created. The process ID 
 		and the time when the process was created, uniquely 
 		identifies a process."
<strong>CISCO-PROCESS-MIB::cpmProcessAverageUSecs (GAUGE):</strong><br>"Average elapsed CPU time in microseconds when the 
 		process was active. This object deprecates the
 		object cpmProcessuSecs."
<strong>CISCO-PROCESS-MIB::cpmProcExtMemAllocated (GAUGE):</strong><br>"The sum of all the dynamically allocated memory that
 		this process has received from the system. This includes
 		memory that may have been returned. The sum of freed
 		memory is provided by cpmProcExtMemFreed. This object
 		is deprecated by cpmProcExtMemAllocatedRev."
<strong>CISCO-PROCESS-MIB::cpmProcExtMemFreed (GAUGE):</strong><br>"The sum of all memory that this process has returned 
 		to the system. This object is deprecated by 
 		cpmProcExtMemFreedRev."
<strong>CISCO-PROCESS-MIB::cpmProcExtInvoked (COUNTER):</strong><br>"The number of times since cpmTimeCreated that 
 		the process has been invoked. This object is
 		deprecated by cpmProcExtInvokedRev."
<strong>CISCO-PROCESS-MIB::cpmProcExtRuntime (GAUGE):</strong><br>"The amount of CPU time the process has used, in 
 		microseconds. This object is deprecated by
 		cpmProcExtRuntimeRev."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil5Sec (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 5 
 		second period. It is determined as a weighted 
 		decaying average of the current idle time over 
 		the longest idle time. Note that this information 
 		should be used as an estimate only. This object is 
 		deprecated by cpmProcExtUtil5SecRev which has the 
 		changed range of value (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil1Min (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 1 
 		minute period. It is determined as a weighted 
 		decaying average of the current idle time over the 
 		longest idle time. Note that this information 
 		should be used as an estimate only. This object is 
 		deprecated by cpmProcExtUtil1MinRev which has
 		the changed range of value (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil5Min (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 5 
 		minute period. It is determined as a weighted 
 		decaying average of the current idle time over 
 		the longest idle time. Note that this information 
 		should be used as an estimate only. This object
 		is deprecated by cpmProcExtUtil5MinRev which
 		has the changed range of value (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtPriority (GAUGE):</strong><br>"The priority level at which the process is 
 		running. This object is deprecated by
 		cpmProcExtPriorityRev."
<strong>CISCO-PROCESS-MIB::cpmProcExtMemAllocatedRev (GAUGE):</strong><br>"The sum of all the dynamically allocated memory that
 		this process has received from the system. This includes
 		memory that may have been returned. The sum of freed
 		memory is provided by cpmProcExtMemFreedRev. This object
 		deprecates cpmProcExtMemAllocated."
<strong>CISCO-PROCESS-MIB::cpmProcExtMemFreedRev (GAUGE):</strong><br>"The sum of all memory that this process has returned 
 		to the system. This object  deprecates 
 		cpmProcExtMemFreed."
<strong>CISCO-PROCESS-MIB::cpmProcExtInvokedRev (COUNTER):</strong><br>"The number of times since cpmTimeCreated that 
 		the process has been invoked. This object 
 		deprecates cpmProcExtInvoked."
<strong>CISCO-PROCESS-MIB::cpmProcExtRuntimeRev (GAUGE):</strong><br>"The amount of CPU time the process has used, in 
 		microseconds. This object deprecates
 		cpmProcExtRuntime."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil5SecRev (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 5 
 		second period. It is determined as a weighted 
 		decaying average of the current idle time over 
 		the longest idle time. Note that this information 
 		should be used as an estimate only. This object
 		deprecates cpmProcExtUtil5Sec and increases the 
 		value range to (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil1MinRev (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 1 
 		minute period. It is determined as a weighted 
 		decaying average of the current idle time over the 
 		longest idle time. Note that this information 
 		should be used as an estimate only. This object 
 		deprecates cpmProcExtUtil1Min and increases the value
 		range to (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtUtil5MinRev (GAUGE):</strong><br>"This object provides a general idea of how busy 
 		a process caused the processor to be over a 5 
 		minute period. It is determined as a weighted 
 		decaying average of the current idle time over 
 		the longest idle time. Note that this information 
 		should be used as an estimate only. This object
 		deprecates cpmProcExtUtil5Min and increases the
 		value range to (0..100)."
<strong>CISCO-PROCESS-MIB::cpmProcExtPriorityRev (GAUGE):</strong><br>"The priority level at which the process is 
 		running. This object deprecates 
 		cpmProcExtPriority."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_temperature',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el estado de las temperaturas del dispositivo</strong><br>Utiliza la tabla SNMP CISCO (Enterprise=00009)<br><br><strong>::::ciscoEnvMonTemperatureStatusDescr (GAUGE):</strong><br><strong>::::ciscoEnvMonTemperatureStatusValue (GAUGE):</strong><br><strong>::::ciscoEnvMonTemperatureThreshold (GAUGE):</strong><br><strong>::::ciscoEnvMonTemperatureLastShutdown (GAUGE):</strong><br><strong>::::ciscoEnvMonTemperatureState (GAUGE):</strong><br>',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_vlans',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre las VLANs definidas en el equipo</strong><br>Utiliza la tabla SNMP CISCO-VTP-MIB::vtpVlanTable (Enterprise=00009)<br><br><strong>CISCO-VTP-MIB::vtpVlanName (GAUGE):</strong><br>"The name of this VLAN.  This name is used as the ELAN-name
             for an ATM LAN-Emulation segment of this VLAN."
<strong>CISCO-VTP-MIB::vtpVlanType (GAUGE):</strong><br>"The type of this VLAN."
<strong>CISCO-VTP-MIB::vtpVlanState (GAUGE):</strong><br>"The state of this VLAN.
 
             The state mtuTooBigForDevice indicates that this device
             cannot participate in this VLAN because the VLANs MTU is
             larger than the device can support.
 
             The state mtuTooBigForTrunk indicates that while this
             VLANs MTU is supported by this device, it is too large for
             one or more of the devices trunk ports."
<strong>CISCO-VTP-MIB::vtpVlanMtu (GAUGE):</strong><br>"The MTU size on this VLAN, defined as the size of largest
             MAC-layer (information field portion of the) data frame
             which can be transmitted on the VLAN."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_cisco_voltage',  'tip_type' => 'app', 'url' => '',
         'date' => 1430850790,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra Informacion sobre el estado de los voltajes del dispositivo</strong><br>Utiliza la tabla SNMP CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusTable (Enterprise=00009)<br><br><strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusDescr (GAUGE):</strong><br>"Textual description of the testpoint being instrumented.
                 This description is a short textual label, suitable as a
                 human-sensible identification for the rest of the
                 information in the entry."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusValue (GAUGE):</strong><br>"The current measurement of the testpoint being instrumented."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageThresholdLow (GAUGE):</strong><br>"The lowest value that the associated instance of the object
                 ciscoEnvMonVoltageStatusValue may obtain before an emergency
                 shutdown of the managed device is initiated."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageThresholdHigh (GAUGE):</strong><br>"The highest value that the associated instance of the object
                 ciscoEnvMonVoltageStatusValue may obtain before an emergency
                 shutdown of the managed device is initiated."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageLastShutdown (GAUGE):</strong><br>"The value of the associated instance of the object
                 ciscoEnvMonVoltageStatusValue at the time an emergency
                 shutdown of the managed device was last initiated.  This
                 value is stored in non-volatile RAM and hence is able to
                 survive the shutdown."
<strong>CISCO-ENVMON-MIB::ciscoEnvMonVoltageState (GAUGE):</strong><br>"The current state of the testpoint being instrumented."
',
      );


?>
