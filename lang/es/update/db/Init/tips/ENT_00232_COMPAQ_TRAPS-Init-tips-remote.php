<?
	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterNodeDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of a node in
              the cluster becomes degraded.
 
              User Action: Make a note of the cluster node name then
              check the node for the cause of the degraded condition."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterNodeName</strong><br>"The name of the node."
<br>OCTET STRING (0..64) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of the cluster
              becomes failed."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterName</strong><br>"The name of the cluster."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of the cluster
              becomes degraded."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterName</strong><br>"The name of the cluster."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterNodeFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of a node in
              the cluster becomes failed.
 
              User Action: Make a note of the cluster node name
              then check the node for the cause of the failure."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterNodeName</strong><br>"The name of the node."
<br>OCTET STRING (0..64) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterResourceDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of a cluster
              resource becomes degraded.
 
              User Action: Make a note of the cluster resource name then
              check the resource for the cause of the degraded condition."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterResourceName</strong><br>"The name of the resource.  It must be unique within the cluster."
<br>OCTET STRING (0..64) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterResourceFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of a cluster
              resource becomes failed.
 
              User Action: Make a note of the cluster resource name
              then check the resource for the cause of the failure."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterResourceName</strong><br>"The name of the resource.  It must be unique within the cluster."
<br>OCTET STRING (0..64) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQCLUSTER-MIB::cpqClusterNetworkDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap will be sent any time the condition of a cluster
              network becomes degraded.
 
              User Action: Make a note of the cluster network name then
              check the network for the cause of the degraded condition."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqClusterNetworkName</strong><br>"The text name of the network."
<br>OCTET STRING (0..64) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalTempFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to failed.
 
              The system will be shutdown due to this thermal condition."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalTempDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to degraded.
 
              The servers temperature is outside of the normal operating
              range.  The server will be shutdown if the
              cpqHeThermalDegradedAction variable is set to shutdown(3)."
v1: <strong>cpqHeThermalDegradedAction</strong><br>"The action to perform when the thermal condition is degraded.
 
             This value will be one of the following:
             other(1)
               This feature is not supported by this system or driver.
 
             continue(2)
               The system should be allowed to continue.
 
             shutdown(3)
               The system should be shutdown."
<br>INTEGER {other(1), continue(2), shutdown(3)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalTempOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to ok.
 
              The servers temperature has returned to the normal operating
              range."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalSystemFanFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to failed.
 
              A required system fan is not operating normally.  The system
              will be shutdown if the cpqHeThermalDegradedAction variable
              is set to shutdown(3)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalSystemFanDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to degraded.
 
              An optional system fan is not operating normally."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalSystemFanOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to ok.
 
              Any previously non-operational system fans have returned to
              normal operation."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalCpuFanFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The CPU fan status has been set to failed.
 
              A processor fan is not operating normally.  The server will be
              shutdown."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeThermalCpuFanOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The CPU fan status has been set to ok.
 
              Any previously non-operational processor fans have returned
              to normal operation."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHePostError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"One or more POST errors occurred.
 
              Power On Self-Test (POST) errors occur during the server
              restart process.  "
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeFltTolPwrSupplyDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply sub-system condition has been
              set to degraded."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalTempFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to failed.
 
              The system will be shutdown due to this thermal condition."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalTempDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to degraded.
 
              The servers temperature is outside of the normal operating
              range.  The server will be shutdown if the
              cpqHeThermalDegradedAction variable is set to shutdown(3)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalTempOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to ok.
 
              The servers temperature has returned to the normal operating
              range."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to failed.
 
              A required system fan is not operating normally.  The system
              will be shutdown if the cpqHeThermalDegradedAction variable
              is set to shutdown(3)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to degraded.
 
              An optional system fan is not operating normally."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The system fan status has been set to ok.
 
              Any previously non-operational system fans have returned to
              normal operation."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalCpuFanFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The CPU fan status has been set to failed.
 
              A processor fan is not operating normally.  The server will be
              shutdown."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3ThermalCpuFanOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The CPU fan status has been set to ok.
 
              Any previously non-operational processor fans have returned
              to normal operation."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3PostError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"One or more POST errors occurred.
 
              Power On Self-Test (POST) errors occur during the server
              restart process. Details of the POST error messages can 
              be found in Integrated Management Log "
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPwrSupplyDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply sub-system condition has been
              set to degraded."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply condition has been set
             to degraded for the specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply condition has been set
             to failed for the specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyLost',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Power Supplies have lost redundancy for
             the specified chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyInserted',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A Fault Tolerant Power Supply has been inserted into the
             specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyRemoved',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A Fault Tolerant Power Supply has been removed from the
             specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Fan condition has been set to degraded
             for the specified chassis and fan."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Fan condition has been set to failed
             for the specified chassis and fan."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyLost',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Fans have lost redundancy for the
             specified chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanInserted',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A Fault Tolerant Fan has been inserted into the specified
             chassis and fan location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanRemoved',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A Fault Tolerant Fan has been removed from the specified
             chassis and fan location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3TemperatureFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to failed in the
             specified chassis and location.
 
             The system will be shutdown due to this condition."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3TemperatureDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to degraded in the
             specified chassis and location.
 
             The servers temperature is outside of the normal operating
             range.  The server will be shutdown if the
             cpqHeThermalDegradedAction variable is set to shutdown(3)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3TemperatureOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The temperature status has been set to ok in the
             specified chassis and location.
 
             The servers temperature has returned to the normal operating
             range."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3PowerConverterDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The DC-DC Power Converter condition has been set to degraded
             for the specified chassis, slot and socket."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3PowerConverterFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The DC-DC Power Converter condition has been set to failed
             for the specified chassis, slot and socket."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3PowerConverterRedundancyLost',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The DC-DC Power Converters have lost redundancy for the
             specified chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3CacheAccelParityError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A cache accelerator parity error indicates a cache module
              needs to be replaced.
 
              The error information is reported in the variable
              cpqHeEventLogErrorDesc."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResilientMemOnlineSpareEngaged',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Advanced Memory Protection Online Spare Engaged.
 
            The Advanced Memory Protection subsystem has detected a memory
            fault. The Online Spare Memory has been activated.
 
            User Action: Schedule server down-time to replace the faulty
            memory."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyOk',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply condition has been set back
             to the OK state for the specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply condition has been set
             to degraded for the specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The fault tolerant power supply condition has been set
             to failed for the specified chassis and bay location."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResilientMemMirroredMemoryEngaged',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Advanced Memory Protection Mirrored Memory Engaged.
 
            The Advanced Memory Protection subsystem has detected a memory
            fault. Mirrored Memory has been activated.
 
            User Action: Replace the faulty memory."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResilientAdvancedECCMemoryEngaged',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Advanced Memory Protection Advanced ECC Memory Engaged.
 
            The Advanced Memory Protection subsystem has detected a memory
            fault. Advanced ECC has been activated.
 
            User Action: Replace the faulty memory."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResilientMemXorMemoryEngaged',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Advanced Memory Protection XOR Engine Memory Engaged.
 
            The Advanced Memory Protection subsystem has detected a memory
            fault. The XOR engine has been activated.
 
            User Action: Replace the faulty memory."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyRestored',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Power Supplies have returned to a redundant
             state for the specified chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyRestored',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Fault Tolerant Fans have returned to a redundant state for
             the specified chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHe4CorrMemReplaceMemModule',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Corrected Memory Errors Detected
 
              The errors have been corrected, but the memory module should be
              replaced."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResMemBoardRemoved',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Memory board or cartridge removed.
 
            An Advanced Memory Protection sub-system board or cartridge has
            been removed from the system.
 
            User Action: Insure the board or cartridge has memory correctly
            installed and re-insert the memory board or cartridge back into
            the system."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResMemBoardInserted',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Memory board or cartridge inserted.
 
            An Advanced Memory Protection sub-system board or cartridge has
            been inserted into the system.
 
            User Action: None."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQHLTH-MIB::cpqHeResMemBoardBusError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Memory board or cartridge bus error detected.
 
            An Advanced Memory Protection sub-system board or cartridge
            bus error has been detected.
 
            User Action: Replace the indicated board or cartridge."
',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaLogDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Logical Drive Status Change.
 
             This trap signifies that the agent has detected a change in the
             status of a drive array logical drive.  The variable
             cpqDaLogDrvStatus indicates the current logical drive status."
v1: <strong>cpqDaLogDrvStatus</strong><br>"Logical Drive Status.
 
             The logical drive can be in one of the following states:
 
             Ok (2)
               Indicates that the logical drive is in normal operation mode.
 
             Failed (3)
               Indicates that more physical drives have failed than the
               fault tolerance mode of the logical drive can handle without
               data loss.
 
             Unconfigured (4)
               Indicates that the logical drive is not configured.
 
             Recovering (5)
               Indicates that the logical drive is using Interim Recovery Mode.
               In Interim Recovery Mode, at least one physical drive has
               failed, but the logical drives fault tolerance mode lets the
               drive continue to operate with no data loss.
 
             Ready Rebuild (6)
               Indicates that the logical drive is ready for Automatic Data
               Recovery.  The physical drive that failed has been replaced,
               but the logical drive is still operating in Interim Recovery
               Mode.
 
             Rebuilding (7)
               Indicates that the logical drive is currently doing Automatic
               Data Recovery.  During Automatic Data Recovery, fault tolerance
               algorithms restore data to the replacement drive.
 
             Wrong Drive (8)
               Indicates that the wrong physical drive was replaced after a
               physical drive failure.
 
             Bad Connect (9)
               Indicates that a physical drive is not responding.
 
             Overheating (10)
               Indicates that the drive array enclosure that contains the
               logical drive is overheating.  The drive array is still
               functioning, but should be shutdown.
 
             Shutdown (11)
               Indicates that the drive array enclosure that contains the
               logical drive has overheated.  The logical drive is no longer
               functioning.
 
             Expanding (12)
               Indicates that the logical drive is currently doing Automatic
               Data Expansion.  During Automatic Data Expansion, fault
               tolerance algorithms redistribute logical drive data to the
               newly added physical drive.
 
             Not Available (13)
               Indicates that the logical drive is currently unavailable.
               If a logical drive is expanding and the new configuration
               frees additional disk space, this free space can be
               configured into another logical volume.  If this is done,
               the new volume will be set to not available.
 
             Queued For Expansion (14)
               Indicates that the logical drive is ready for Automatic Data
               Expansion.  The logical drive is in the queue for expansion.
 
             Multi-path Access Degraded (15)
               Indicates that previously all disk drives of this logical
               drive had more than one I/O path to the controller, but now
               one or few of them have only one I/O path.
 
             Erasing (16)
               Indicates that the logical drive is currently being erased."
<br>INTEGER {other(1), ok(2), failed(3), unconfigured(4), recovering(5), readyForRebuild(6), rebuilding(7), wrongDrive(8), badConnect(9), overheating(10), shutdown(11), expanding(12), notAvailable(13), queuedForExpansion(14), multipathAccessDegraded(15), erasing(16)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaSpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.  The
              variable cpqDaSpareBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v2: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaPhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
              The variable cpqDaPhyDrvBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v2: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaPhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects on
              a drive array has been exceeded.  The variable
              cpqDaPhyDrvBusNumber indicates the SCSI bus number associated
              with the drive."
v1: <strong>cpqDaPhyDrvThreshPassed</strong><br>"Physical Drive Factory Threshold Passed (Exceeded).
 
             When the drive is shipped, certain thresholds have been set to
             monitor performance of the drives.  For example, a threshold
             might be set for Spin up Time.  If the time that it takes the
             drive to spin up exceeds the factory threshold, there may be
             a problem with one of the drives.
 
             If you suspect a problem, schedule server down time to run
             diagnostics.
 
             Note:   These thresholds may be under warranty under certain
                     conditions."
<br>INTEGER {false(1), true(2)} 
   <br>v2: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaAccelStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Status Change.
 
              This trap signifies that the agent has detected a change in the
              cpqDaAccelStatus of an array accelerator write cache.  The
              current status is represented by the variable cpqDaAccelStatus."
v1: <strong>cpqDaAccelStatus</strong><br>"Array Accelerator Board Status.
 
             This describes the status of the accelerator write cache.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               status of the Array Accelerator.  You may need to upgrade
               the instrument agent.
 
             Invalid (2)
               Indicates that an Array Accelerator board has not been
               installed in this system or is present but not configured.
 
             Enabled (3)
               Indicates that write cache operations are currently configured
               and enabled for at least one logical drive.
 
             Temporarily Disabled (4)
               Indicates that write cache operations have been temporarily
               disabled. View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been
               temporarily disabled.
 
             Permanently Disabled (5)
               Indicates that write cache operations have been permanently
               disabled.  View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been disabled."
<br>INTEGER {other(1), invalid(2), enabled(3), tmpDisabled(4), permDisabled(5)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaAccelBadDataTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Bad Data.
 
              This trap signifies that the agent has detected an array
              accelerator cache board that has lost battery power.  If data
              was being stored in the accelerator memory when the server lost
              power, that data has been lost."
v1: <strong>cpqDaAccelBadData</strong><br>"Array Accelerator Board Bad Data.
 
             The following values are valid:
 
             None (2)
               Indicates that no data loss occurred.  The battery packs were
               properly charged when the system was initialized.
 
             Possible (3)
               Indicates that at power up, the battery packs were not
               sufficiently charged.  Because the batteries did not retain
               sufficient charge when the system resumed power, the board
               has not retained any data that may have been stored.
               If no data was on the board, no data was lost.  Several things
               may have caused this condition:
 
               * If the system was without power for eight days, and the
                 battery packs were on (battery packs only activate if
                 system looses power unexpectedly), any data that may have
                 been stored in the cache was lost.
 
               * There may be a problem with the battery pack.
                 See the Battery Status for more information.
 
               * This status will also appear if the Array Accelerator
                 board is replaced with a new board that has discharged
                 batteries.  No data has been lost in this case, and posted
                 writes will automatically be enabled when the batteries
                 reach full charge."
<br>INTEGER {other(1), none(2), possible(3)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaAccelBatteryFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Battery Failed.
 
              This trap signifies that the agent has detected a battery
              failure associated with the array accelerator cache board.
              The current battery status is indicated by the
              cpqDaAccelBattery variable."
v1: <strong>cpqDaAccelBattery</strong><br>"Array Accelerator Board Backup Power Status.
 
             This monitors the status of each backup power source on the board.  
             The backup power source can only recharge when the system has 
             power applied. The type of backup power source used is indicated 
             by cpqDaAccelBackupPowerSource.
 
             The following values are valid:
 
             Other (1)
               Indicates that the instrument agent does not recognize
               battery status.  You may need to update your software.
 
             Ok (2)
               Indicates that a particular battery pack is fully charged.
 
             Charging (3)
               The battery power is less than 75%.  The Drive Array
               Controller is attempting to recharge the battery.  A
               battery can take as long as 36 hours to fully recharge.
               After 36 hours, if the battery has not recharged, it is
               considered failed.
 
             Failed (4)
               The battery pack is below the sufficient voltage level and
               has not recharged in 36 hours.  Your Array Accelerator board
               needs to be serviced.
 
             Degraded (5)
               The battery is still operating, however, one of the batteries
               in the pack has failed to recharge properly.  Your Array
               Accelerator board should be serviced as soon as possible.
 
             NotPresent (6)
               There are no batteries associated with this controller.
               
             Capacitor Failed (7)
               The capacitor is below the sufficient voltage level and
               has not recharged in 10 minutes.  Your Array Accelerator board
               needs to be serviced."
<br>INTEGER {other(1), ok(2), recharging(3), failed(4), degraded(5), notPresent(6), capacitorFailed(7)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2LogDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Logical Drive Status Change.
 
             This trap signifies that the agent has detected a change in the
             status of a drive array logical drive.  The variable
             cpqDaLogDrvStatus indicates the current logical drive status."
v1: <strong>cpqDaLogDrvStatus</strong><br>"Logical Drive Status.
 
             The logical drive can be in one of the following states:
 
             Ok (2)
               Indicates that the logical drive is in normal operation mode.
 
             Failed (3)
               Indicates that more physical drives have failed than the
               fault tolerance mode of the logical drive can handle without
               data loss.
 
             Unconfigured (4)
               Indicates that the logical drive is not configured.
 
             Recovering (5)
               Indicates that the logical drive is using Interim Recovery Mode.
               In Interim Recovery Mode, at least one physical drive has
               failed, but the logical drives fault tolerance mode lets the
               drive continue to operate with no data loss.
 
             Ready Rebuild (6)
               Indicates that the logical drive is ready for Automatic Data
               Recovery.  The physical drive that failed has been replaced,
               but the logical drive is still operating in Interim Recovery
               Mode.
 
             Rebuilding (7)
               Indicates that the logical drive is currently doing Automatic
               Data Recovery.  During Automatic Data Recovery, fault tolerance
               algorithms restore data to the replacement drive.
 
             Wrong Drive (8)
               Indicates that the wrong physical drive was replaced after a
               physical drive failure.
 
             Bad Connect (9)
               Indicates that a physical drive is not responding.
 
             Overheating (10)
               Indicates that the drive array enclosure that contains the
               logical drive is overheating.  The drive array is still
               functioning, but should be shutdown.
 
             Shutdown (11)
               Indicates that the drive array enclosure that contains the
               logical drive has overheated.  The logical drive is no longer
               functioning.
 
             Expanding (12)
               Indicates that the logical drive is currently doing Automatic
               Data Expansion.  During Automatic Data Expansion, fault
               tolerance algorithms redistribute logical drive data to the
               newly added physical drive.
 
             Not Available (13)
               Indicates that the logical drive is currently unavailable.
               If a logical drive is expanding and the new configuration
               frees additional disk space, this free space can be
               configured into another logical volume.  If this is done,
               the new volume will be set to not available.
 
             Queued For Expansion (14)
               Indicates that the logical drive is ready for Automatic Data
               Expansion.  The logical drive is in the queue for expansion.
 
             Multi-path Access Degraded (15)
               Indicates that previously all disk drives of this logical
               drive had more than one I/O path to the controller, but now
               one or few of them have only one I/O path.
 
             Erasing (16)
               Indicates that the logical drive is currently being erased."
<br>INTEGER {other(1), ok(2), failed(3), unconfigured(4), recovering(5), readyForRebuild(6), rebuilding(7), wrongDrive(8), badConnect(9), overheating(10), shutdown(11), expanding(12), notAvailable(13), queuedForExpansion(14), multipathAccessDegraded(15), erasing(16)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3SpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.  The
              variable cpqDaSpareBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v4: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2SpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.
              The variable cpqDaSpareBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v2: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
              The variable cpqDaPhyDrvBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v2: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2PhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects on
              a drive array has been exceeded.  The variable
              cpqDaPhyDrvBusNumber indicates the SCSI bus number associated
              with the drive."
v1: <strong>cpqDaPhyDrvThreshPassed</strong><br>"Physical Drive Factory Threshold Passed (Exceeded).
 
             When the drive is shipped, certain thresholds have been set to
             monitor performance of the drives.  For example, a threshold
             might be set for Spin up Time.  If the time that it takes the
             drive to spin up exceeds the factory threshold, there may be
             a problem with one of the drives.
 
             If you suspect a problem, schedule server down time to run
             diagnostics.
 
             Note:   These thresholds may be under warranty under certain
                     conditions."
<br>INTEGER {false(1), true(2)} 
   <br>v2: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2AccelStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Status Change.
 
              This trap signifies that the Insight Agent has detected a
              change in the cpqDaAccelStatus of array accelerator cache.
              The current status is represented by the variable
              cpqDaAccelStatus."
v1: <strong>cpqDaAccelStatus</strong><br>"Array Accelerator Board Status.
 
             This describes the status of the accelerator write cache.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               status of the Array Accelerator.  You may need to upgrade
               the instrument agent.
 
             Invalid (2)
               Indicates that an Array Accelerator board has not been
               installed in this system or is present but not configured.
 
             Enabled (3)
               Indicates that write cache operations are currently configured
               and enabled for at least one logical drive.
 
             Temporarily Disabled (4)
               Indicates that write cache operations have been temporarily
               disabled. View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been
               temporarily disabled.
 
             Permanently Disabled (5)
               Indicates that write cache operations have been permanently
               disabled.  View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been disabled."
<br>INTEGER {other(1), invalid(2), enabled(3), tmpDisabled(4), permDisabled(5)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2AccelBadDataTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Bad Data.
 
              This trap signifies that the agent has detected an array
              accelerator cache board that has lost battery power.  If data
              was being stored in the accelerator memory when the server lost
              power, that data has been lost."
v1: <strong>cpqDaAccelBadData</strong><br>"Array Accelerator Board Bad Data.
 
             The following values are valid:
 
             None (2)
               Indicates that no data loss occurred.  The battery packs were
               properly charged when the system was initialized.
 
             Possible (3)
               Indicates that at power up, the battery packs were not
               sufficiently charged.  Because the batteries did not retain
               sufficient charge when the system resumed power, the board
               has not retained any data that may have been stored.
               If no data was on the board, no data was lost.  Several things
               may have caused this condition:
 
               * If the system was without power for eight days, and the
                 battery packs were on (battery packs only activate if
                 system looses power unexpectedly), any data that may have
                 been stored in the cache was lost.
 
               * There may be a problem with the battery pack.
                 See the Battery Status for more information.
 
               * This status will also appear if the Array Accelerator
                 board is replaced with a new board that has discharged
                 batteries.  No data has been lost in this case, and posted
                 writes will automatically be enabled when the batteries
                 reach full charge."
<br>INTEGER {other(1), none(2), possible(3)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa2AccelBatteryFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Battery Failed.
 
              This trap signifies that the agent has detected a battery
              failure associated with the array accelerator cache board.  The
              current battery status is indicated by the cpqDaAccelBattery
              variable."
v1: <strong>cpqDaAccelBattery</strong><br>"Array Accelerator Board Backup Power Status.
 
             This monitors the status of each backup power source on the board.  
             The backup power source can only recharge when the system has 
             power applied. The type of backup power source used is indicated 
             by cpqDaAccelBackupPowerSource.
 
             The following values are valid:
 
             Other (1)
               Indicates that the instrument agent does not recognize
               battery status.  You may need to update your software.
 
             Ok (2)
               Indicates that a particular battery pack is fully charged.
 
             Charging (3)
               The battery power is less than 75%.  The Drive Array
               Controller is attempting to recharge the battery.  A
               battery can take as long as 36 hours to fully recharge.
               After 36 hours, if the battery has not recharged, it is
               considered failed.
 
             Failed (4)
               The battery pack is below the sufficient voltage level and
               has not recharged in 36 hours.  Your Array Accelerator board
               needs to be serviced.
 
             Degraded (5)
               The battery is still operating, however, one of the batteries
               in the pack has failed to recharge properly.  Your Array
               Accelerator board should be serviced as soon as possible.
 
             NotPresent (6)
               There are no batteries associated with this controller.
               
             Capacitor Failed (7)
               The capacitor is below the sufficient voltage level and
               has not recharged in 10 minutes.  Your Array Accelerator board
               needs to be serviced."
<br>INTEGER {other(1), ok(2), recharging(3), failed(4), degraded(5), notPresent(6), capacitorFailed(7)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3LogDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Logical Drive Status Change.
 
             This trap signifies that the agent has detected a change in the
             status of a drive array logical drive.  The variable
             cpqDaLogDrvStatus indicates the current logical drive status."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaLogDrvStatus</strong><br>"Logical Drive Status.
 
             The logical drive can be in one of the following states:
 
             Ok (2)
               Indicates that the logical drive is in normal operation mode.
 
             Failed (3)
               Indicates that more physical drives have failed than the
               fault tolerance mode of the logical drive can handle without
               data loss.
 
             Unconfigured (4)
               Indicates that the logical drive is not configured.
 
             Recovering (5)
               Indicates that the logical drive is using Interim Recovery Mode.
               In Interim Recovery Mode, at least one physical drive has
               failed, but the logical drives fault tolerance mode lets the
               drive continue to operate with no data loss.
 
             Ready Rebuild (6)
               Indicates that the logical drive is ready for Automatic Data
               Recovery.  The physical drive that failed has been replaced,
               but the logical drive is still operating in Interim Recovery
               Mode.
 
             Rebuilding (7)
               Indicates that the logical drive is currently doing Automatic
               Data Recovery.  During Automatic Data Recovery, fault tolerance
               algorithms restore data to the replacement drive.
 
             Wrong Drive (8)
               Indicates that the wrong physical drive was replaced after a
               physical drive failure.
 
             Bad Connect (9)
               Indicates that a physical drive is not responding.
 
             Overheating (10)
               Indicates that the drive array enclosure that contains the
               logical drive is overheating.  The drive array is still
               functioning, but should be shutdown.
 
             Shutdown (11)
               Indicates that the drive array enclosure that contains the
               logical drive has overheated.  The logical drive is no longer
               functioning.
 
             Expanding (12)
               Indicates that the logical drive is currently doing Automatic
               Data Expansion.  During Automatic Data Expansion, fault
               tolerance algorithms redistribute logical drive data to the
               newly added physical drive.
 
             Not Available (13)
               Indicates that the logical drive is currently unavailable.
               If a logical drive is expanding and the new configuration
               frees additional disk space, this free space can be
               configured into another logical volume.  If this is done,
               the new volume will be set to not available.
 
             Queued For Expansion (14)
               Indicates that the logical drive is ready for Automatic Data
               Expansion.  The logical drive is in the queue for expansion.
 
             Multi-path Access Degraded (15)
               Indicates that previously all disk drives of this logical
               drive had more than one I/O path to the controller, but now
               one or few of them have only one I/O path.
 
             Erasing (16)
               Indicates that the logical drive is currently being erased."
<br>INTEGER {other(1), ok(2), failed(3), unconfigured(4), recovering(5), readyForRebuild(6), rebuilding(7), wrongDrive(8), badConnect(9), overheating(10), shutdown(11), expanding(12), notAvailable(13), queuedForExpansion(14), multipathAccessDegraded(15), erasing(16)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
              The variable cpqDaPhyDrvBusNumber indicates the SCSI bus number
              associated with this drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v4: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3PhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects on
              a drive array has been exceeded.  The variable
              cpqDaPhyDrvBusNumber indicates the SCSI bus number associated
              with the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvThreshPassed</strong><br>"Physical Drive Factory Threshold Passed (Exceeded).
 
             When the drive is shipped, certain thresholds have been set to
             monitor performance of the drives.  For example, a threshold
             might be set for Spin up Time.  If the time that it takes the
             drive to spin up exceeds the factory threshold, there may be
             a problem with one of the drives.
 
             If you suspect a problem, schedule server down time to run
             diagnostics.
 
             Note:   These thresholds may be under warranty under certain
                     conditions."
<br>INTEGER {false(1), true(2)} 
   <br>v4: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3AccelStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Status Change.
 
              This trap signifies that the agent has detected a change in the
              cpqDaAccelStatus of an array accelerator cache board.  The
              current status is represented by the variable cpqDaAccelStatus."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaAccelStatus</strong><br>"Array Accelerator Board Status.
 
             This describes the status of the accelerator write cache.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               status of the Array Accelerator.  You may need to upgrade
               the instrument agent.
 
             Invalid (2)
               Indicates that an Array Accelerator board has not been
               installed in this system or is present but not configured.
 
             Enabled (3)
               Indicates that write cache operations are currently configured
               and enabled for at least one logical drive.
 
             Temporarily Disabled (4)
               Indicates that write cache operations have been temporarily
               disabled. View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been
               temporarily disabled.
 
             Permanently Disabled (5)
               Indicates that write cache operations have been permanently
               disabled.  View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been disabled."
<br>INTEGER {other(1), invalid(2), enabled(3), tmpDisabled(4), permDisabled(5)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3AccelBadDataTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Bad Data.
 
              This trap signifies that the agent has detected an array
              accelerator cache board that has lost battery power.  If data
              was being stored in the accelerator memory when the server lost
              power, that data has been lost."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaAccelBadData</strong><br>"Array Accelerator Board Bad Data.
 
             The following values are valid:
 
             None (2)
               Indicates that no data loss occurred.  The battery packs were
               properly charged when the system was initialized.
 
             Possible (3)
               Indicates that at power up, the battery packs were not
               sufficiently charged.  Because the batteries did not retain
               sufficient charge when the system resumed power, the board
               has not retained any data that may have been stored.
               If no data was on the board, no data was lost.  Several things
               may have caused this condition:
 
               * If the system was without power for eight days, and the
                 battery packs were on (battery packs only activate if
                 system looses power unexpectedly), any data that may have
                 been stored in the cache was lost.
 
               * There may be a problem with the battery pack.
                 See the Battery Status for more information.
 
               * This status will also appear if the Array Accelerator
                 board is replaced with a new board that has discharged
                 batteries.  No data has been lost in this case, and posted
                 writes will automatically be enabled when the batteries
                 reach full charge."
<br>INTEGER {other(1), none(2), possible(3)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa3AccelBatteryFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Battery Failed.
 
              This trap signifies that the agent has detected a battery
              failure associated with the array accelerator cache board.  The
              current battery status is indicated by the cpqDaAccelBattery
              variable."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaAccelBattery</strong><br>"Array Accelerator Board Backup Power Status.
 
             This monitors the status of each backup power source on the board.  
             The backup power source can only recharge when the system has 
             power applied. The type of backup power source used is indicated 
             by cpqDaAccelBackupPowerSource.
 
             The following values are valid:
 
             Other (1)
               Indicates that the instrument agent does not recognize
               battery status.  You may need to update your software.
 
             Ok (2)
               Indicates that a particular battery pack is fully charged.
 
             Charging (3)
               The battery power is less than 75%.  The Drive Array
               Controller is attempting to recharge the battery.  A
               battery can take as long as 36 hours to fully recharge.
               After 36 hours, if the battery has not recharged, it is
               considered failed.
 
             Failed (4)
               The battery pack is below the sufficient voltage level and
               has not recharged in 36 hours.  Your Array Accelerator board
               needs to be serviced.
 
             Degraded (5)
               The battery is still operating, however, one of the batteries
               in the pack has failed to recharge properly.  Your Array
               Accelerator board should be serviced as soon as possible.
 
             NotPresent (6)
               There are no batteries associated with this controller.
               
             Capacitor Failed (7)
               The capacitor is below the sufficient voltage level and
               has not recharged in 10 minutes.  Your Array Accelerator board
               needs to be serviced."
<br>INTEGER {other(1), ok(2), recharging(3), failed(4), degraded(5), notPresent(6), capacitorFailed(7)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaCntlrStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Controller Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array controller.  The variable
              cpqDaCntlrBoardStatus indicates the current controller status.
 
              User Action: If the board status is generalFailure(3), the
              you may need to replace the controller.  If the board status
              is cableProblem(4), check the cable connections between the
              controller and the storage system."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrBoardStatus</strong><br>"Array Controller Board Status.
 
             The following values are valid:
 
             other (1)
               Indicates that the instrument agent does not recognize the
               status of the controller.  You may need to upgrade the instrument
               agent.
 
             ok (2)
               The array controller is operating properly.
 
             generalFailure (3)
               The array controller is failed.
 
             cableProblem (4)
               The array controller has a cable problem.  Please check
               all cable connections to this controller.
 
             poweredOff (5)
               The array controller is powered off.  Please replace the
               controller and restore power to the slot."
<br>INTEGER {other(1), ok(2), generalFailure(3), cableProblem(4), poweredOff(5)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDaCntlrActive',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Controller Active.
 
              This trap signifies that the agent has detected that a backup
              array controller in a duplexed pair has switched over to the
              active role.  The variable cpqDaCntlrSlot indicates the
              active controller slot and cpqDaCntlrPartnerSlot indicates the
              backup.
 
              User Action: Check the partner controller for problems.
              If this was the result of a user initiated switch over,
              no action is required."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrPartnerSlot</strong><br>"Array Controller Partner Slot.
 
             For duplexed array controllers, this is the slot number of the
             partner controller.  For non-duplexed controllers and partner 
             controllers that reside in a separate host system, the value should
             be -1."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa4SpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.
 
              User Action: If the spare drive status is failed, replace
              the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v4: <strong>cpqDaSpareCntlrIndex</strong><br>"Drive Array Spare Controller Index.
 
             This index maps the spare drive back to the controller to which
             it is attached.  The value of this index is the same as the one
             used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>v6: <strong>cpqDaSpareBay</strong><br>"Spare Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive."
<br>INTEGER (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa4PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
 
              User Action: If the physical drive failed or predicting
              failure, replace the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v4: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v6: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa4PhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects on
              a drive array has been exceeded.
 
              User Action: If the physical drive is predicting failure,
              replace the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v4: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5AccelStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Status Change.
 
              This trap signifies that the agent has detected a change in
              the status of an array accelerator cache board.  The current
              status is represented by the variable cpqDaAccelStatus.
 
              User Action: If the accelerator board status is permDisabled(5),
              you may need to replace the accelerator board."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>v7: <strong>cpqDaAccelStatus</strong><br>"Array Accelerator Board Status.
 
             This describes the status of the accelerator write cache.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               status of the Array Accelerator.  You may need to upgrade
               the instrument agent.
 
             Invalid (2)
               Indicates that an Array Accelerator board has not been
               installed in this system or is present but not configured.
 
             Enabled (3)
               Indicates that write cache operations are currently configured
               and enabled for at least one logical drive.
 
             Temporarily Disabled (4)
               Indicates that write cache operations have been temporarily
               disabled. View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been
               temporarily disabled.
 
             Permanently Disabled (5)
               Indicates that write cache operations have been permanently
               disabled.  View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been disabled."
<br>INTEGER {other(1), invalid(2), enabled(3), tmpDisabled(4), permDisabled(5)} 
   <br>v8: <strong>cpqDaAccelErrCode</strong><br>"Array Accelerator Board Error Code.
 
             Use this to determine the status of the write cache operations.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               error code.  You may need to update your software.
 
             Invalid (2)
               Indicates that write cache operations are currently
               configured and enabled for at least one logical drive.
               No write cache errors have occurred.
 
             Bad Configuration (3)
               Indicates that write cache operations are temporarily
               disabled.  The Array Accelerator board was configured
               for a different controller.  This error could be caused
               if boards were switched from one system to another.
               Rerun the configuration utility and ensure that the board
               has been properly configured for this system.
               Note: If data from another system was stored on the board,
               running configuration utility will cause the data to be lost.
 
             Low Battery Power (4)
               Indicates that write cache operations are temporarily
               disabled due to insufficient battery power.  Please view
               the Battery Status object instance for more information.
 
             Disable Command Issued (5)
               Indicates that write cache operations are temporarily
               disabled.  The device driver issues this command when
               the server is taken down.  This condition should not
               exist when the system regains power.
 
             No Resources Available (6)
               Indicates that write cache operations are temporarily
               disabled.  The controller does not have sufficient
               resources to perform write cache operations.
               For example, when a replaced drive is being rebuilt,
               there will not be sufficient resources.  Once the
               operation that requires the resources has completed,
               this condition will clear and write cache operations
               will resume.
 
             Board Not Connected (7)
               Indicates that write cache operations are temporarily
               disabled.  The Array Accelerator board has been
               configured but is not currently attached to the
               controller. Check the alignment of the board and
               connections.
 
             Bad Mirror Data (8)
               Indicates that write cache operations have been
               permanently disabled.  The Array Accelerator board stores
               mirrored copies of all data.  If data exists on the
               board when the system is first powered up, the board
               performs a data compare test between the mirrored copies.
               If the data does not match, an error has occurred.
               Data may have been lost.  Your board may need servicing.
 
             Read Failure (9)
               Indicates that write cache operations have been permanently
               disabled.  The Array Accelerator board stores mirror copies
               of all data.  While reading the data from the board, memory
               parity errors have occurred.  Both copies were corrupted and
               cannot be retrieved.  Data has been lost, and you should
               service the board.
 
             Write Failure (10)
               Indicates that write cache operations have been permanently
               disabled.  This error occurs when an unsuccessful attempt was
               made to write data to the Array Accelerator board.  Data could
               not be written to write cache memory in duplicate due to the
               detection of parity errors.  This error does not indicate data
               loss.  You should service the Array Accelerator board.
 
             Config Command (11)
               Indicates that write cache operations have been permanently
               disabled.  The configuration of the logical drives has changed.
     "
<br>INTEGER {other(1), invalid(2), badConfig(3), lowBattery(4), disableCmd(5), noResources(6), notConnected(7), badMirrorData(8), readErr(9), writeErr(10), configCmd(11), expandInProgress(12), snapshotInProgress(13), redundantLowBattery(14), redundantSizeMismatch(15), redundantCacheFailure(16), excessiveEccErrors(17), adgEnablerMissing(18), postEccErrors(19), batteryHotRemoved(20), capacitorChargeLow(21), notEnoughBatteries(22), cacheModuleNotSupported(23), batteryNotSupported(24), noCapacitorAttached(25), capBasedBackupFailed(26), capBasedRestoreFailed(27), capBasedModuleHWFailure(28), capacitorFailedToCharge(29)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5AccelBadDataTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Bad Data.
 
              This trap signifies that the agent has detected an array
              accelerator cache board that has lost battery power.  If
              data was being stored in the accelerator cache memory when the
              server lost power, that data has been lost.
 
              User Action: Verify that no data has been lost."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5AccelBatteryFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Battery Failed.
 
              This trap signifies that the agent has detected a battery
              failure associated with the array accelerator cache board.
 
              User Action: Replace the Accelerator Cache Board."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v6: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5CntlrStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Controller Status Change.
 
              This trap signifies that the agent has detected a change in
              the status of a drive array controller.  The variable
              cpqDaCntlrBoardStatus indicates the current controller status.
 
              User Action: If the board status is generalFailure(3), you
              may need to replace the controller.  If the board status is
              cableProblem(4), check the cable connections between the
              controller and the storage system."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrSlot</strong><br>"Array Controller Slot.
 
             This identifies the physical slot where the array controller
             resides in the system.  For example, if this value is three,
             the array controller is located in slot three of your computer."
<br>INTEGER (0..255) 
   <br>v4: <strong>cpqDaCntlrBoardStatus</strong><br>"Array Controller Board Status.
 
             The following values are valid:
 
             other (1)
               Indicates that the instrument agent does not recognize the
               status of the controller.  You may need to upgrade the instrument
               agent.
 
             ok (2)
               The array controller is operating properly.
 
             generalFailure (3)
               The array controller is failed.
 
             cableProblem (4)
               The array controller has a cable problem.  Please check
               all cable connections to this controller.
 
             poweredOff (5)
               The array controller is powered off.  Please replace the
               controller and restore power to the slot."
<br>INTEGER {other(1), ok(2), generalFailure(3), cableProblem(4), poweredOff(5)} 
   <br>v5: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v6: <strong>cpqDaCntlrSerialNumber</strong><br>"Array Controller Serial Number.
 
             The serial number of the array controller.  This field will
             be a null (size 0) string if the controller does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v7: <strong>cpqDaCntlrFWRev</strong><br>"Array Controller Firmware Revision.
 
             The firmware revision of the drive array controller. This
             value can be used to help identify a particular revision
             of the controller."
<br>OCTET STRING (0..5) 
   <br>v8: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
 
              User Action: If the physical drive status is failed(3) or
              predictiveFailure(4), replace the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v4: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v6: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>v7: <strong>cpqDaPhyDrvModel</strong><br>"Physical Drive Model.
 
             This is a text description of the physical drive.  The text that
             appears depends upon who manufactured the drive and the drive
             type.
 
             If a drive fails, note the model to identify the type of drive
             necessary for replacement.
 
             If a model number is not present, you may not have properly
             initialized the drive array to which the physical drive is
             attached for monitoring."
<br>OCTET STRING (0..255) 
   <br>v8: <strong>cpqDaPhyDrvFWRev</strong><br>"Physical Drive Firmware Revision.
 
             This shows the physical drive revision number.
 
             If the firmware revision is not present, you have not properly
             initialized the drive array."
<br>OCTET STRING (0..8) 
   <br>v9: <strong>cpqDaPhyDrvSerialNum</strong><br>"Physical Drive Serial Number.
 
             This is the serial number assigned to the physical drive.
             This value is based upon the serial number as returned by the
             SCSI inquiry command but may have been modified due to space
             limitations.  This can be used for identification purposes."
<br>OCTET STRING (0..40) 
   <br>v10: <strong>cpqDaPhyDrvFailureCode</strong><br>"Drive Array Physical Drive Failure Code.
 
              This value is the drive failure reason code returned by the
              array firmware.  It is valid only when the drive is failed.
              If the drive is not failed, 0 is returned."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa5PhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects
              on a drive array has been exceeded.
 
              User Action: Replace the physical drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v4: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaPhyDrvModel</strong><br>"Physical Drive Model.
 
             This is a text description of the physical drive.  The text that
             appears depends upon who manufactured the drive and the drive
             type.
 
             If a drive fails, note the model to identify the type of drive
             necessary for replacement.
 
             If a model number is not present, you may not have properly
             initialized the drive array to which the physical drive is
             attached for monitoring."
<br>OCTET STRING (0..255) 
   <br>v7: <strong>cpqDaPhyDrvFWRev</strong><br>"Physical Drive Firmware Revision.
 
             This shows the physical drive revision number.
 
             If the firmware revision is not present, you have not properly
             initialized the drive array."
<br>OCTET STRING (0..8) 
   <br>v8: <strong>cpqDaPhyDrvSerialNum</strong><br>"Physical Drive Serial Number.
 
             This is the serial number assigned to the physical drive.
             This value is based upon the serial number as returned by the
             SCSI inquiry command but may have been modified due to space
             limitations.  This can be used for identification purposes."
<br>OCTET STRING (0..40) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6CntlrStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Controller Status Change.
 
              This trap signifies that the agent has detected a change in
              the status of a drive array controller.  The variable
              cpqDaCntlrBoardStatus indicates the current controller status.
 
              User Action: If the board status is generalFailure(3), you
              may need to replace the controller.  If the board status is
              cableProblem(4), check the cable connections between the
              controller and the storage system."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaCntlrIndex</strong><br>"Array Controller Index.
 
             This value is a logical number whose meaning is OS dependent.
             Each physical controller has one unique controller number
             associated with it."
<br>INTEGER
   <br>v5: <strong>cpqDaCntlrBoardStatus</strong><br>"Array Controller Board Status.
 
             The following values are valid:
 
             other (1)
               Indicates that the instrument agent does not recognize the
               status of the controller.  You may need to upgrade the instrument
               agent.
 
             ok (2)
               The array controller is operating properly.
 
             generalFailure (3)
               The array controller is failed.
 
             cableProblem (4)
               The array controller has a cable problem.  Please check
               all cable connections to this controller.
 
             poweredOff (5)
               The array controller is powered off.  Please replace the
               controller and restore power to the slot."
<br>INTEGER {other(1), ok(2), generalFailure(3), cableProblem(4), poweredOff(5)} 
   <br>v6: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v7: <strong>cpqDaCntlrSerialNumber</strong><br>"Array Controller Serial Number.
 
             The serial number of the array controller.  This field will
             be a null (size 0) string if the controller does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v8: <strong>cpqDaCntlrFWRev</strong><br>"Array Controller Firmware Revision.
 
             The firmware revision of the drive array controller. This
             value can be used to help identify a particular revision
             of the controller."
<br>OCTET STRING (0..5) 
   <br>v9: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6LogDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Logical Drive Status Change.
 
             This trap signifies that the agent has detected a change in the
             status of a drive array logical drive.  The variable
             cpqDaLogDrvStatus indicates the current logical drive status."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaLogDrvCntlrIndex</strong><br>"Drive Array Logical Drive Controller Index.
 
             This maps the logical drives into their respective controllers.
             Controller index i under the controller group owns the
             associated drives in the logical drive group which use that
             index."
<br>INTEGER
   <br>v5: <strong>cpqDaLogDrvIndex</strong><br>"Drive Array Logical Drive Index.
 
             This logical drive number keeps track of multiple instances of
             logical drives which are on the same controller.  For each
             controller index value, the logical drive index starts at 1 and
             increments for each logical drive."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaLogDrvStatus</strong><br>"Logical Drive Status.
 
             The logical drive can be in one of the following states:
 
             Ok (2)
               Indicates that the logical drive is in normal operation mode.
 
             Failed (3)
               Indicates that more physical drives have failed than the
               fault tolerance mode of the logical drive can handle without
               data loss.
 
             Unconfigured (4)
               Indicates that the logical drive is not configured.
 
             Recovering (5)
               Indicates that the logical drive is using Interim Recovery Mode.
               In Interim Recovery Mode, at least one physical drive has
               failed, but the logical drives fault tolerance mode lets the
               drive continue to operate with no data loss.
 
             Ready Rebuild (6)
               Indicates that the logical drive is ready for Automatic Data
               Recovery.  The physical drive that failed has been replaced,
               but the logical drive is still operating in Interim Recovery
               Mode.
 
             Rebuilding (7)
               Indicates that the logical drive is currently doing Automatic
               Data Recovery.  During Automatic Data Recovery, fault tolerance
               algorithms restore data to the replacement drive.
 
             Wrong Drive (8)
               Indicates that the wrong physical drive was replaced after a
               physical drive failure.
 
             Bad Connect (9)
               Indicates that a physical drive is not responding.
 
             Overheating (10)
               Indicates that the drive array enclosure that contains the
               logical drive is overheating.  The drive array is still
               functioning, but should be shutdown.
 
             Shutdown (11)
               Indicates that the drive array enclosure that contains the
               logical drive has overheated.  The logical drive is no longer
               functioning.
 
             Expanding (12)
               Indicates that the logical drive is currently doing Automatic
               Data Expansion.  During Automatic Data Expansion, fault
               tolerance algorithms redistribute logical drive data to the
               newly added physical drive.
 
             Not Available (13)
               Indicates that the logical drive is currently unavailable.
               If a logical drive is expanding and the new configuration
               frees additional disk space, this free space can be
               configured into another logical volume.  If this is done,
               the new volume will be set to not available.
 
             Queued For Expansion (14)
               Indicates that the logical drive is ready for Automatic Data
               Expansion.  The logical drive is in the queue for expansion.
 
             Multi-path Access Degraded (15)
               Indicates that previously all disk drives of this logical
               drive had more than one I/O path to the controller, but now
               one or few of them have only one I/O path.
 
             Erasing (16)
               Indicates that the logical drive is currently being erased."
<br>INTEGER {other(1), ok(2), failed(3), unconfigured(4), recovering(5), readyForRebuild(6), rebuilding(7), wrongDrive(8), badConnect(9), overheating(10), shutdown(11), expanding(12), notAvailable(13), queuedForExpansion(14), multipathAccessDegraded(15), erasing(16)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6SpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.
 
              User Action: If the spare drive status is failed, replace
              the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaSpareCntlrIndex</strong><br>"Drive Array Spare Controller Index.
 
             This index maps the spare drive back to the controller to which
             it is attached.  The value of this index is the same as the one
             used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaSparePhyDrvIndex</strong><br>"Drive Array Spare Physical Drive Index.
 
             This index maps the spare to the physical drive it represents.
             The value of this index is the same as the one used with the
             physical drive table."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v7: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>v8: <strong>cpqDaSpareBay</strong><br>"Spare Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive."
<br>INTEGER (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
 
              User Action: If the physical drive status is failed(3) or
              predictiveFailure(4), replace the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvIndex</strong><br>"Drive Array Physical Drive Index.
 
             This index is used for selecting the physical drive table entry.
             This number, along with the cpqDaPhyDrvCntlrIndex uniquely
             identify a specific physical drive."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v7: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>v8: <strong>cpqDaPhyDrvModel</strong><br>"Physical Drive Model.
 
             This is a text description of the physical drive.  The text that
             appears depends upon who manufactured the drive and the drive
             type.
 
             If a drive fails, note the model to identify the type of drive
             necessary for replacement.
 
             If a model number is not present, you may not have properly
             initialized the drive array to which the physical drive is
             attached for monitoring."
<br>OCTET STRING (0..255) 
   <br>v9: <strong>cpqDaPhyDrvFWRev</strong><br>"Physical Drive Firmware Revision.
 
             This shows the physical drive revision number.
 
             If the firmware revision is not present, you have not properly
             initialized the drive array."
<br>OCTET STRING (0..8) 
   <br>v10: <strong>cpqDaPhyDrvSerialNum</strong><br>"Physical Drive Serial Number.
 
             This is the serial number assigned to the physical drive.
             This value is based upon the serial number as returned by the
             SCSI inquiry command but may have been modified due to space
             limitations.  This can be used for identification purposes."
<br>OCTET STRING (0..40) 
   <br>v11: <strong>cpqDaPhyDrvFailureCode</strong><br>"Drive Array Physical Drive Failure Code.
 
              This value is the drive failure reason code returned by the
              array firmware.  It is valid only when the drive is failed.
              If the drive is not failed, 0 is returned."
<br>INTEGER
   <br>v12: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6PhyDrvThreshPassedTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Threshold Passed.
 
              This trap signifies that the agent has detected a factory
              threshold associated with one of the physical drive objects
              on a drive array has been exceeded.
 
              User Action: Replace the physical drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvIndex</strong><br>"Drive Array Physical Drive Index.
 
             This index is used for selecting the physical drive table entry.
             This number, along with the cpqDaPhyDrvCntlrIndex uniquely
             identify a specific physical drive."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>v7: <strong>cpqDaPhyDrvBay</strong><br>"Physical Drive Bay Location.
 
             This value matches the bay location where the physical drive has
             been installed.  For a SCSI drive, this is the SCSI ID of the
             drive.  For a SAS or SATA drive, this is the bay number on the
             enclosure."
<br>INTEGER (0..255) 
   <br>v8: <strong>cpqDaPhyDrvModel</strong><br>"Physical Drive Model.
 
             This is a text description of the physical drive.  The text that
             appears depends upon who manufactured the drive and the drive
             type.
 
             If a drive fails, note the model to identify the type of drive
             necessary for replacement.
 
             If a model number is not present, you may not have properly
             initialized the drive array to which the physical drive is
             attached for monitoring."
<br>OCTET STRING (0..255) 
   <br>v9: <strong>cpqDaPhyDrvFWRev</strong><br>"Physical Drive Firmware Revision.
 
             This shows the physical drive revision number.
 
             If the firmware revision is not present, you have not properly
             initialized the drive array."
<br>OCTET STRING (0..8) 
   <br>v10: <strong>cpqDaPhyDrvSerialNum</strong><br>"Physical Drive Serial Number.
 
             This is the serial number assigned to the physical drive.
             This value is based upon the serial number as returned by the
             SCSI inquiry command but may have been modified due to space
             limitations.  This can be used for identification purposes."
<br>OCTET STRING (0..40) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6AccelStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Status Change.
 
              This trap signifies that the agent has detected a change in
              the status of an array accelerator cache board.  The current
              status is represented by the variable cpqDaAccelStatus.
 
              User Action: If the accelerator board status is permDisabled(5),
              you may need to replace the accelerator board."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelCntlrIndex</strong><br>"Array Accelerator Board Controller Index.
 
             This value is a logical number whose meaning is OS dependent.
             The value has a direct mapping to the controller table index
             such that controller i has accelerator table entry i."
<br>INTEGER
   <br>v6: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v7: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>v8: <strong>cpqDaAccelStatus</strong><br>"Array Accelerator Board Status.
 
             This describes the status of the accelerator write cache.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               status of the Array Accelerator.  You may need to upgrade
               the instrument agent.
 
             Invalid (2)
               Indicates that an Array Accelerator board has not been
               installed in this system or is present but not configured.
 
             Enabled (3)
               Indicates that write cache operations are currently configured
               and enabled for at least one logical drive.
 
             Temporarily Disabled (4)
               Indicates that write cache operations have been temporarily
               disabled. View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been
               temporarily disabled.
 
             Permanently Disabled (5)
               Indicates that write cache operations have been permanently
               disabled.  View the Array Accelerator Board Error Code object
               to determine why the write cache operations have been disabled."
<br>INTEGER {other(1), invalid(2), enabled(3), tmpDisabled(4), permDisabled(5)} 
   <br>v9: <strong>cpqDaAccelErrCode</strong><br>"Array Accelerator Board Error Code.
 
             Use this to determine the status of the write cache operations.
 
             The status can be:
 
             Other (1)
               Indicates that the instrument agent does not recognize the
               error code.  You may need to update your software.
 
             Invalid (2)
               Indicates that write cache operations are currently
               configured and enabled for at least one logical drive.
               No write cache errors have occurred.
 
             Bad Configuration (3)
               Indicates that write cache operations are temporarily
               disabled.  The Array Accelerator board was configured
               for a different controller.  This error could be caused
               if boards were switched from one system to another.
               Rerun the configuration utility and ensure that the board
               has been properly configured for this system.
               Note: If data from another system was stored on the board,
               running configuration utility will cause the data to be lost.
 
             Low Battery Power (4)
               Indicates that write cache operations are temporarily
               disabled due to insufficient battery power.  Please view
               the Battery Status object instance for more information.
 
             Disable Command Issued (5)
               Indicates that write cache operations are temporarily
               disabled.  The device driver issues this command when
               the server is taken down.  This condition should not
               exist when the system regains power.
 
             No Resources Available (6)
               Indicates that write cache operations are temporarily
               disabled.  The controller does not have sufficient
               resources to perform write cache operations.
               For example, when a replaced drive is being rebuilt,
               there will not be sufficient resources.  Once the
               operation that requires the resources has completed,
               this condition will clear and write cache operations
               will resume.
 
             Board Not Connected (7)
               Indicates that write cache operations are temporarily
               disabled.  The Array Accelerator board has been
               configured but is not currently attached to the
               controller. Check the alignment of the board and
               connections.
 
             Bad Mirror Data (8)
               Indicates that write cache operations have been
               permanently disabled.  The Array Accelerator board stores
               mirrored copies of all data.  If data exists on the
               board when the system is first powered up, the board
               performs a data compare test between the mirrored copies.
               If the data does not match, an error has occurred.
               Data may have been lost.  Your board may need servicing.
 
             Read Failure (9)
               Indicates that write cache operations have been permanently
               disabled.  The Array Accelerator board stores mirror copies
               of all data.  While reading the data from the board, memory
               parity errors have occurred.  Both copies were corrupted and
               cannot be retrieved.  Data has been lost, and you should
               service the board.
 
             Write Failure (10)
               Indicates that write cache operations have been permanently
               disabled.  This error occurs when an unsuccessful attempt was
               made to write data to the Array Accelerator board.  Data could
               not be written to write cache memory in duplicate due to the
               detection of parity errors.  This error does not indicate data
               loss.  You should service the Array Accelerator board.
 
             Config Command (11)
               Indicates that write cache operations have been permanently
               disabled.  The configuration of the logical drives has changed.
     "
<br>INTEGER {other(1), invalid(2), badConfig(3), lowBattery(4), disableCmd(5), noResources(6), notConnected(7), badMirrorData(8), readErr(9), writeErr(10), configCmd(11), expandInProgress(12), snapshotInProgress(13), redundantLowBattery(14), redundantSizeMismatch(15), redundantCacheFailure(16), excessiveEccErrors(17), adgEnablerMissing(18), postEccErrors(19), batteryHotRemoved(20), capacitorChargeLow(21), notEnoughBatteries(22), cacheModuleNotSupported(23), batteryNotSupported(24), noCapacitorAttached(25), capBasedBackupFailed(26), capBasedRestoreFailed(27), capBasedModuleHWFailure(28), capacitorFailedToCharge(29)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6AccelBadDataTrap',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Bad Data.
 
              This trap signifies that the agent has detected an array
              accelerator cache board that has lost backup power.  If
              data was being stored in the accelerator cache memory when the
              server lost power, that data has been lost. The backup power 
              source is indicated by cpqDaAccelBackupPowerSource.
 
              User Action: Verify that no data has been lost."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelCntlrIndex</strong><br>"Array Accelerator Board Controller Index.
 
             This value is a logical number whose meaning is OS dependent.
             The value has a direct mapping to the controller table index
             such that controller i has accelerator table entry i."
<br>INTEGER
   <br>v6: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v7: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa6AccelBatteryFailed',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Accelerator Board Backup Power Source Failed.
 
              This trap signifies that the agent has detected a backup
              power source failure associated with the array accelerator cache 
              board. The backup power source is indicated by 
              cpqDaAccelBackupPowerSource.
 
              User Action: Replace the Accelerator Cache Board."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaCntlrModel</strong><br>"Array Controller Model.
 
             The type of controller card.  The valid types are:
 
             Other  (1)
               You may need to upgrade your driver software and\or instrument
               agent(s).  You have a drive array controller in the system
               that the instrument agent does not recognize.
 
             IDA (2)
               Compaq 32-Bit Intelligent Drive Array Controller.
               The physical drives are located inside the system.
 
             IDA Expansion (3)
               Compaq 32-Bit Intelligent Drive Array Expansion Controller.
               The physical drives are located in the Array Expansion System
               that is connected to the system by a cable.
 
             IDA - 2 (4)
               Compaq Intelligent Drive Array Controller-2 (IDA-2).
               The physical drives are located inside the system.
 
             SMART (5)
               Compaq SMART Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/E (6)
               Compaq SMART-2/E Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2/P (7)
               Compaq SMART-2/P Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             SMART - 2SL (8)
               Compaq SMART-2SL Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 3100ES (9)
               Compaq Smart Array 3100ES Controller.  The physical drives are
               located inside the system.
 
             Smart - 3200 (10)
               Compaq Smart Array 3200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             SMART - 2DH (11)
               Compaq SMART-2DH Array Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart - 221 (12)
               Compaq Smart Array 221 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 4250ES (13)
               Compaq Smart Array 4250ES Controller.  The physical drives are
               located inside the system.
 
             Smart Array 4200 (14)
               Compaq Smart Array 4200 Controller.  The physical drives can
               be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Integrated Smart Array (15)
               Compaq Integrated Smart Array Controller.  The physical drives
               can be located inside the system or outside the system in a
               ProLiant Storage System that is connected to the system by a
               cable.
 
             Smart Array 431 (16)
               Compaq Smart Array 431 Controller.  The physical drives can be
               located inside the system or outside the system in a ProLiant
               Storage System that is connected to the system by a cable.
 
             Smart Array 5300 (17)
               HP Smart Array 5300 Controller.
 
             RAID LC2 Controller (18)
               Compaq RAID LC2 Controller.
 
             Smart Array 5i (19)
               HP Smart Array 5i Controller.
 
             Smart Array 532 (20)
               Compaq Smart Array"
<br>INTEGER {other(1), ida(2), idaExpansion(3), ida-2(4), smart(5), smart-2e(6), smart-2p(7), smart-2sl(8), smart-3100es(9), smart-3200(10), smart-2dh(11), smart-221(12), sa-4250es(13), sa-4200(14), sa-integrated(15), sa-431(16), sa-5300(17), raidLc2(18), sa-5i(19), sa-532(20), sa-5312(21), sa-641(22), sa-642(23), sa-6400(24), sa-6400em(25), sa-6i(26), sa-generic(27), sa-p600(29), sa-p400(30), sa-e200(31), sa-e200i(32), sa-p400i(33), sa-p800(34), sa-e500(35), sa-p700m(36), sa-p212(37), sa-p410(38), sa-p410i(39), sa-p411(40), sa-b110i(41), sa-p712m(42), sa-p711m(43), sa-p812(44), sw-1210m(45)} 
   <br>v5: <strong>cpqDaAccelCntlrIndex</strong><br>"Array Accelerator Board Controller Index.
 
             This value is a logical number whose meaning is OS dependent.
             The value has a direct mapping to the controller table index
             such that controller i has accelerator table entry i."
<br>INTEGER
   <br>v6: <strong>cpqDaAccelSerialNumber</strong><br>"Array Accelerator Serial Number.
 
             The serial number of the Array Accelerator.  This field will
             be a null (size 0) string if the accelerator does not support
             serial number."
<br>OCTET STRING (0..32) 
   <br>v7: <strong>cpqDaAccelTotalMemory</strong><br>"Total Cache Memory.
 
             This value is the total amount of accelerator memory in
             kilobytes, including both battery-backed and non-battery-backed
             memory."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa7PhyDrvStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Physical Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array physical drive.  The variable
              cpaDaPhyDrvStatus indicates the current physical drive status.
 
              User Action: If the physical drive status is failed(3) or
              predictiveFailure(4), replace the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaPhyDrvCntlrIndex</strong><br>"Drive Array Physical Drive Controller Index.
 
             This index maps the physical drive back to the controller to
             which it is attached. The value of this index is the same as
             the one used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaPhyDrvIndex</strong><br>"Drive Array Physical Drive Index.
 
             This index is used for selecting the physical drive table entry.
             This number, along with the cpqDaPhyDrvCntlrIndex uniquely
             identify a specific physical drive."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaPhyDrvLocationString</strong><br>"Physical Drive Location String.
 
             This string describes the location of the drive in relation to
             the controller.  If the location string cannot be determined,
             the agent will return a NULL string."
<br>OCTET STRING (0..255) 
   <br>v7: <strong>cpqDaPhyDrvType</strong><br>"Physical Drive Type.
 
             The following values are defined:
 
             other(1)
               The agent is unable to determine the type for this drive.
 
             parallelScsi(2)
               The drive type is parallel SCSI.
 
             sata(3)
               The drive type is Serial ATA.
 
             sas(4)
               The drive type is Serial Attached SCSI."
<br>INTEGER {other(1), parallelScsi(2), sata(3), sas(4)} 
   <br>v8: <strong>cpqDaPhyDrvModel</strong><br>"Physical Drive Model.
 
             This is a text description of the physical drive.  The text that
             appears depends upon who manufactured the drive and the drive
             type.
 
             If a drive fails, note the model to identify the type of drive
             necessary for replacement.
 
             If a model number is not present, you may not have properly
             initialized the drive array to which the physical drive is
             attached for monitoring."
<br>OCTET STRING (0..255) 
   <br>v9: <strong>cpqDaPhyDrvFWRev</strong><br>"Physical Drive Firmware Revision.
 
             This shows the physical drive revision number.
 
             If the firmware revision is not present, you have not properly
             initialized the drive array."
<br>OCTET STRING (0..8) 
   <br>v10: <strong>cpqDaPhyDrvSerialNum</strong><br>"Physical Drive Serial Number.
 
             This is the serial number assigned to the physical drive.
             This value is based upon the serial number as returned by the
             SCSI inquiry command but may have been modified due to space
             limitations.  This can be used for identification purposes."
<br>OCTET STRING (0..40) 
   <br>v11: <strong>cpqDaPhyDrvFailureCode</strong><br>"Drive Array Physical Drive Failure Code.
 
              This value is the drive failure reason code returned by the
              array firmware.  It is valid only when the drive is failed.
              If the drive is not failed, 0 is returned."
<br>INTEGER
   <br>v12: <strong>cpqDaPhyDrvStatus</strong><br>"Physical Drive Status.
 
             This shows the status of the physical drive.
 
             The following values are valid for the physical drive status:
 
 
             Other (1)
               Indicates that the instrument agent does not recognize
               the drive.  You may need to upgrade your instrument agent
               and/or driver software.
 
             Ok (2)
               Indicates the drive is functioning properly.
 
             Failed (3)
               Indicates that the drive is no longer operating and
               should be replaced.
 
             Predictive Failure(4)
               Indicates that the drive has a predictive failure error and
               should be replaced.
 
             Erasing(5)
               Indicates that the drive is being erased.
 
             Erase Done(6)
               Indicates that the drive has been erased and is now in an
               offline state.
 
             Erase Queued(7)
               Indicates that an erase operation is currently queued for
               the drive."
<br>INTEGER {other(1), ok(2), failed(3), predictiveFailure(4), erasing(5), eraseDone(6), eraseQueued(7)} 
   <br>v13: <strong>cpqDaPhyDrvBusNumber</strong><br>"Physical Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this physical
             drive is attached.  The first instance is one and increments
             for each SCSI bus on a controller.  A value of -1 will be
             returned if the physical drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers.
             For SAS and SATA drives, the bus number corresponds to the
             enclosure where the drive resides."
<br>INTEGER
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CPQIDA-MIB::cpqDa7SpareStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Spare Drive Status Change.
 
              This trap signifies that the agent has detected a change in the
              status of a drive array spare drive.  The variable
              cpqDaSpareStatus indicates the current spare drive status.
 
              User Action: If the spare drive status is failed, replace
              the drive."
v1: <strong>sysName</strong><br><br><br>v2: <strong>cpqHoTrapFlags</strong><br><br><br>v3: <strong>cpqDaCntlrHwLocation</strong><br>"A text description of the hardware location of the controller.
              A NULL string indicates that the hardware location could not
              be determined or is irrelevant."
<br>OCTET STRING (0..255) 
   <br>v4: <strong>cpqDaSpareCntlrIndex</strong><br>"Drive Array Spare Controller Index.
 
             This index maps the spare drive back to the controller to which
             it is attached.  The value of this index is the same as the one
             used under the controller group."
<br>INTEGER
   <br>v5: <strong>cpqDaSparePhyDrvIndex</strong><br>"Drive Array Spare Physical Drive Index.
 
             This index maps the spare to the physical drive it represents.
             The value of this index is the same as the one used with the
             physical drive table."
<br>INTEGER (0..255) 
   <br>v6: <strong>cpqDaSpareStatus</strong><br>"Spare Status.
 
             This shows the status of the on-line spare drive.
 
             The following values are valid for the spare status:
 
             Failed (3)
               The on-line spare has failed and is no longer available for use.
 
             Inactive (4)
               The monitored system has an on-line spare configured, but is
               not currently in use.
 
             Building (5)
               A physical drive has failed. Automatic Data Recovery
               is in progress to recover data to the on-line spare.
 
             Active (6)
               A physical drive has failed. Automatic Data Recovery is
               complete.  The system is using the on-line spare as a
               replacement for the failed drive."
<br>INTEGER {other(1), invalid(2), failed(3), inactive(4), building(5), active(6)} 
   <br>v7: <strong>cpqDaSpareLocationString</strong><br>"Spare Drive Location String.
 
             This string describes the location of the drive in relation to
             the controller.  If the location string cannot be determined,
             the agent will return a NULL string."
<br>OCTET STRING (0..255) 
   <br>v8: <strong>cpqDaSpareBusNumber</strong><br>"Spare Drive SCSI Bus Number.
 
             The bus number indicates to which SCSI bus this spare drive
             is attached.  The first instance is one and increments for
             each SCSI bus on a controller.  A value of -1 will be
             returned if the spare drive is attached to a controller
             that does not support multiple SCSI busses.  This is not
             supported by the IDA, IDA Expansion, or IDA-2 controllers."
<br>INTEGER
   <br>',
	);

?>
