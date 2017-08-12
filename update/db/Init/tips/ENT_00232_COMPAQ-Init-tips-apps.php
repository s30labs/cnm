<?php
      $TIPS[]=array(
         'id_ref' => 'app_compaq_power_supply_table',  'tip_type' => 'app', 'url' => '',
         'date' => 1430851648,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor</strong><br>Utiliza la tabla SNMP CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable (Enterprise=00232)<br><br><strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyChassis (GAUGE):</strong><br>"The system chassis number."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyBay (GAUGE):</strong><br>"The bay number to index within this chassis."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyPresent (GAUGE):</strong><br>"Indicates whether the power supply is present in the chassis."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyCondition (GAUGE):</strong><br>"The condition of the power supply.
 
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
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyStatus (GAUGE):</strong><br>"The status of the power supply."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyMainVoltage (GAUGE):</strong><br>"The input main voltage of the power supply in volts."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyCapacityUsed (GAUGE):</strong><br>"The currently used capacity of the power supply in watts."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyCapacityMaximum (GAUGE):</strong><br>"The maximum capacity of the power supply in watts."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyRedundant (GAUGE):</strong><br>"The redundancy state of the power supply.
 
             This value will be one of the following:
             other(1)
               The redundancy state could not be determined.
 
             notRedundant(2)
               The power supply is not operating in a redundant state.
 
             redundant(3)
               The power supply is operating in a redundant state."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyModel (GAUGE):</strong><br>"The power supply model name."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplySerialNumber (GAUGE):</strong><br>"The power supply serial number."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyAutoRev (GAUGE):</strong><br>"The power supply auto revision number."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyHotPlug (GAUGE):</strong><br>"This indicates if the power supply is capable of being
             removed and/or inserted while the system is in an operational
             state.
 
             If the value is hotPluggable(3), the power supply can be safely
             removed if and only if the cpqHeFltTolPowerSupplyRedundant
             field is in a redundant(3) state.
 
             This value will be one of the following:
             other(1)
               The state could not be determined.
 
             nonHotPluggable(2)
               The power supply is not hot plug capable.
 
             hotPluggable(3)
               The power supply is hot plug capable and can be removed if
               the system is operating in a redundant state.  A power
               supply may be added to an empty power supply bay."
<strong>CPQHLTH-MIB::cpqHeFltTolPowerSupplyFirmwareRev (GAUGE):</strong><br>"The power supply firmware revision.  This field will be left
             blank if the firmware revision is unknown."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_compaq_processes_table',  'tip_type' => 'app', 'url' => '',
         'date' => 1430851648,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra la tabla de procesos del Sistema Operativo</strong><br>Utiliza la tabla SNMP CPQOS-MIB::cpqOsProcessTable (Enterprise=00232)<br><br><strong>CPQOS-MIB::cpqOsProcessInstance (GAUGE):</strong><br>"The Process Instance Name."
<strong>CPQOS-MIB::cpqOsProcessThreadCount (GAUGE):</strong><br>"The number of threads currently active in this process.  An instruction
             is the basic unit of execution in a processor, and a thread is the object
             that executes instructions.  Every running process has at least one
             thread."
<strong>CPQOS-MIB::cpqOsProcessPrivateBytes (GAUGE):</strong><br>"Private Bytes is the current number of bytes this process has allocated
             that cannot be shared with other processes."
<strong>CPQOS-MIB::cpqOsProcessPageFileBytes (GAUGE):</strong><br>"Page File Bytes is the current number of bytes this process has used in
             the paging file(s).  Paging files are used to store pages of memory used
             by the process that are not contained in other files.  Paging files are
             shared by all processes, and lack of space in paging files can prevent
             other processes from allocating memory."
<strong>CPQOS-MIB::cpqOsProcessWorkingSet (GAUGE):</strong><br>"Working Set is the current number of bytes in the Working Set of this
             process. The Working Set is the set of memory pages touched recently by
             the threads in the process.  If free memory in the computer is above a
             threshold, pages are left in the Working Set of a process even if they
             are not in use.  When free memory falls below a threshold, pages are
             trimmed from Working Sets.  If they are needed they will then be
             soft-faulted back into the Working Set before they leave main memory."
<strong>CPQOS-MIB::cpqOsProcessCpuTimePercent (GAUGE):</strong><br>"% Processor Time is the percentage of elapsed time that all of the
             threads of this process used the processor to execute instructions.
             An instruction is the basic unit of execution in a computer, a thread
             is the object that executes instructions, and a process is the object
             created when a program is run.  Code executed to handle some hardware
             interrupts and trap conditions are included in this count.  On
             Multi-processor machines the maximum value of the counter is 100 % times
             the number of processors."
<strong>CPQOS-MIB::cpqOsProcessPrivilegedTimePercent (GAUGE):</strong><br>"% Privileged Time is the percentage of elapsed time that the threads of
             the process have spent executing code in privileged mode.  When a Windows
             NT system service is called, the service will often run in Privileged Mode
             to gain access to system-private data.  Such data is protected from access
             by threads executing in user Mode.  Calls to the system can be explicit or
             implicit, such as page faults or interrupts.  Unlike some early operating
             systems, Windows NT uses process boundaries for subsystem protection in
             addition to the traditional protection of user and privileged modes.
             These subsystem processes provide additional protection.  Therefore, some
             work done by Windows NT on behalf of your application might appear in
             other subsystem processes in addition to the privileged time in your
             process."
<strong>CPQOS-MIB::cpqOsProcessPageFaultsPerSec (GAUGE):</strong><br>"Page Faults/sec is the rate Page Faults occur in the threads executing
             in this process.  A page fault occurs when a thread refers to a virtual
             memory page that is not in its working set in main memory.  This will
             not cause the page to be fetched from disk if it is on the standby list
             and hence already in main memory, or if it is in use by another process
             with whom the page is shared."
<strong>CPQOS-MIB::cpqOsProcessCondition (GAUGE):</strong><br>"The condition of this Process Object Instance."
',
      );


      $TIPS[]=array(
         'id_ref' => 'app_compaq_pci_table',  'tip_type' => 'app', 'url' => '',
         'date' => 1430851648,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra informacion sobre el uso de los slots PCI definidos en el sistema</strong><br>Utiliza la tabla SNMP CPQSTDEQ-MIB::cpqSePciSlotTable (Enterprise=00232)<br><br><strong>CPQSTDEQ-MIB::cpqSePciSlotBusNumberIndex (GAUGE):</strong><br>"A number that uniquely identifies this device on its PCI bus. 
              Values greater than 255 are considered dummy bus numbers for empty PCI slots.
              For systems supporting multiple PCI segments, the segment will be encoded into the high order
              word of this value (Bit16 to Bit31). If PCI segment is not supported, the high order word will be 0."
<strong>CPQSTDEQ-MIB::cpqSePciSlotDeviceNumberIndex (GAUGE):</strong><br>"A number that uniquely identifies this device on its PCI bus."
<strong>CPQSTDEQ-MIB::cpqSePciPhysSlot (GAUGE):</strong><br>"The physical PCI slot number of this device.  Embedded devices
                will return 0 for this variable."
<strong>CPQSTDEQ-MIB::cpqSePciSlotSubSystemID (GAUGE):</strong><br>"Uniquely identifies the board configured in this slot. A zero
             length ID indicates the Subsystem ID is not supported and the
             (Device ID/Vendor ID) should be used for identification purposes.
             An ID of all 0xFFh indicates an empty slot."
<strong>CPQSTDEQ-MIB::cpqSePciSlotBoardName (GAUGE):</strong><br>"The product name (or other suitable description) of this PCI
              board. This field may be empty if no descriptive information
              is known about the board."
<strong>CPQSTDEQ-MIB::cpqSePciSlotWidth (GAUGE):</strong><br>"The maximum data width supported by this PCI slot."
<strong>CPQSTDEQ-MIB::cpqSePciSlotSpeed (GAUGE):</strong><br>"The maximum speed supported by this PCI slot."
',
      );


?>
