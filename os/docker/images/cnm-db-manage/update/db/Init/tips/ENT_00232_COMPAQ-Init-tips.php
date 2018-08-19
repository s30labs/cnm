<?php
      $TIPS[]=array(
         'id_ref' => 'cpq_fan_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHeThermalSystemFanStatus.0</strong> a partir de los siguientes atributos de la mib CPQHLTH-MIB:<br><br><strong>CPQHLTH-MIB::cpqHeThermalSystemFanStatus.0 (GAUGE):</strong> "The status of the fan(s) in the system.
 
             This value will be one of the following:
             other(1)
               Fan status detection is not supported by this system or driver.
 
             ok(2)
               All fans are operating properly.
 
             degraded(3)
               A non-required fan is not operating properly.
 
             failed(4)
               A required fan is not operating properly.
 
             If the cpqHeThermalDegradedAction is set to shutdown(3) the
             system will be shutdown if the failed(4) condition occurs."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_tmp_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHeThermalTempStatus.0</strong> a partir de los siguientes atributos de la mib CPQHLTH-MIB:<br><br><strong>CPQHLTH-MIB::cpqHeThermalTempStatus.0 (GAUGE):</strong> "The status of the systems temperature sensors:
 
             This value will be one of the following:
             other(1)
               Temp sensing is not supported by this system or driver.
 
             ok(2)
               All temp sensors are within normal operating range.
 
             degraded(3)
               A temp sensor is outside of normal operating range.
 
             failed(4)
               A temp sensor detects a condition that could permanently
               damage the system.
 
             The system will automatically shutdown if the failed(4) condition
             results, so it is unlikely that this value will ever be returned
             by the agent.  If the cpqHeThermalDegradedAction is set to
             shutdown(3) the system will be shutdown if the degraded(3)
             condition occurs."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_cpu_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHeThermalCpuFanStatus.0</strong> a partir de los siguientes atributos de la mib CPQHLTH-MIB:<br><br><strong>CPQHLTH-MIB::cpqHeThermalCpuFanStatus.0 (GAUGE):</strong> "The status of the processor fan(s) in the system.
 
             This value will be one of the following:
             other(1)
               Fan status detection is not supported by this system or driver.
 
             ok(2)
               All fans are operating properly.
 
             failed(4)
               A fan is not operating properly.
 
             The system will be shutdown if the failed(4) condition occurs."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_os_threads',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsSystemThreads.0</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsSystemThreads.0 (GAUGE):</strong> "Threads is the number of threads in the computer at the time of data
             collection. Notice that this is an instantaneous count, not an average
             over the time interval. A thread is the basic executable entity that can
             execute instructions in a processor."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_os_context',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsSysContextSwitchesPersec.0</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsSysContextSwitchesPersec.0 (GAUGE):</strong> "Context Switches/sec is the combined rate at which all processors on the
             computer are switched from one thread to another. Context switches occur
             when a running thread voluntarily relinquishes the processor, is preempted
             by a higher priority ready thread, or switches between user-mode and
             privileged (kernel) mode to use an Executive or subsystem service. It is
             the sum of Thread: Context Switches/sec for all threads running on all
             processors in the computer and is measured in numbers of switches. There
             are context switch counters on the System and Thread objects."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_os_cpu_queue',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsSysCpuQueueLength.0</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsSysCpuQueueLength.0 (GAUGE):</strong> "Processor Queue Length is the number of threads in the processor queue.
             There is a single queue for processor time even on computers with multiple
             processors. Unlike the disk counters, this counter counts ready threads
             only, not threads that are running. A sustained processor queue of greater
             than two threads generally indicates processor congestion."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_os_processes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsSysProcesses.0</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsSysProcesses.0 (GAUGE):</strong> "Processes is the number of processes in the computer at the time of data
             collection. Notice that this is an instantaneous count, not an average
             over the time interval. Each process represents the running of a program."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_processor_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsProcessorStatus.0</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsProcessorStatus.0 (GAUGE):</strong> "This value specifies the overall condition of Processor Object
             instances."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_tcp_errors',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsTcpConnectionFailures.1</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsTcpConnectionFailures.1 (GAUGE):</strong> "Connection Failures is the number of times TCP connections have made a
             direct transition to the CLOSED state from the SYN-SENT state or the
             SYN-RCVD state, plus the number of times TCP connections have made a
             direct transition to the LISTEN state from the SYN-RCVD state."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_powersup_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHeFltTolPowerSupplyCondition</strong> a partir de los siguientes atributos de la mib CPQHLTH-MIB:<br><br><strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyCondition (GAUGE):</strong> "The condition of the power supply.
 
             This value will be one of the following:
 
             other(1)
               The status could not be determined or not present.
 
             ok(2)
               The power supply is operating normally.
 
             degraded(3)
               A temperature sensor, fan or other power supply component is
               outside of normal operating range.
 
             failed(4)
               A power supply component detects a condition that could
               permanently damage the system."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_powersup_capacity',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHeFltTolPowerSupplyCapacityUsed</strong> a partir de los siguientes atributos de la mib CPQHLTH-MIB:<br><br><strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyCapacityUsed (GAUGE):</strong> "The currently used capacity of the power supply in watts."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_cpu_usage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHoCpuUtilFiveMin</strong> a partir de los siguientes atributos de la mib CPQHOST-MIB:<br><br><strong>CPQHOST-MIB::cpqHoCpuUtilFiveMin (GAUGE):</strong> "The CPU utilization as a percentage of the theoretical
             maximum during the last five minutes.  A value of -1 indicates
             that no CPU utilization information is available for this
             processor."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_disk_usage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqHoFileSysSpaceUsed|cpqHoFileSysSpaceTotal</strong> a partir de los siguientes atributos de la mib CPQHOST-MIB:<br><br><strong>CPQHOST-MIB::cpqHoFileSysSpaceUsed (GAUGE):</strong> "The megabytes of file system space currently in use.
 
              This item will be set to -1 if the agent is unable to determine
              this information."
<strong>CPQHOST-MIB::cpqHoFileSysSpaceTotal (GAUGE):</strong> "The file system size in megabytes.
 
              This item will be set to -1 if the agent is unable to determine
              this information."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_cpu_interrupts',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqOsCpuInterruptsPerSec</strong> a partir de los siguientes atributos de la mib CPQOS-MIB:<br><br><strong>CPQOS-MIB::cpqOsCpuInterruptsPerSec (GAUGE):</strong> "Interrupts/sec is the average number of hardware interrupts the processor
             is receiving and servicing in each second. It does not include DPCs, which
             are counted separately. This value is an indirect indicator of the
             activity of devices that generate interrupts, such as the system clock,
             the mouse, disk drivers, data communication lines, network interface cards
             and other peripheral devices. These devices normally interrupt the
             processor when they have completed a task or require attention. Normal
             thread execution is suspended during interrupts. Most system clocks
             interrupt the processor every 10 milliseconds, creating a background of
             interrupt activity."
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_da_log_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqDaLogDrvStatus</strong> a partir de los siguientes atributos de la mib CPQIDA-MIB:<br><br><strong>CPQIDA-MIB::cpqDaLogDrvStatus (GAUGE):</strong> "Logical Drive Status.
 
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
',
      );


      $TIPS[]=array(
         'id_ref' => 'cpq_da_phy_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>cpqDaPhyDrvStatus</strong> a partir de los siguientes atributos de la mib CPQIDA-MIB:<br><br><strong>CPQIDA-MIB::cpqDaPhyDrvStatus (GAUGE):</strong> "Physical Drive Status.
 
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
',
      );


?>
