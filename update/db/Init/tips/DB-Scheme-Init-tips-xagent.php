<?php
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
// tip_class=0 => De usuario tip_class=1 => De sistema (no se edita ni se borra)
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
//	Metrica de tipo agente ('tip_type' => 'agent')
// El id_ref coincide con el subtype de la metrica xagent
//---------------------------------------------------------------------------------------------------------

      $TIPS[]=array(
         'id_ref' => 'xagt_000000',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el espacio no usado en disco</strong> a partir del atributo <strong>FreeMegabytes</strong> de la clase WMI <strong>Win32_PerfDisk_LogicalDisk</strong>:<br>"Unallocated space on the disk drive in megabytes."<br>V&aacute;lido para sistemas Windows.'
      );


		$TIPS[]=array(
			'id_ref' => 'xagt_000001',				'tip_type' => 'agent',
			'url' => '',		'date' => '',		'tip_class' => 1,
			'name' => 'Descripcion',
			'descr' => 'Mide: <strong>la memoria disponible</strong> a partir del atributo <strong>AvailableBytes</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_Memory</strong>:<br>"Amount of physical memory in bytes available to processes running on the computer. This value is calculated by summing space on the Zeroed, Free, and Standby memory lists. Free memory is ready for use; Zeroed memory is pages of memory filled with zeros to prevent later processes from seeing data used by a previous process. Standby memory is memory removed from a processs working set (its physical memory) on route to disk, but is still available to be recalled."<br>V&aacute;lido para sistemas Windows.'
		);

      $TIPS[]=array(
         'id_ref' => 'xagt_000002',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los errores de cache</strong> a partir del atributo <strong>PageFaultsPersec</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_Memory</strong>:<br>"Number of faults which occur when a page sought in the file system cache is not found there and must be retrieved from elsewhere in memory (soft fault) or from disk (hard fault). The file system cache is an area of physical memory that stores recently used pages of data for applications. Cache activity is a reliable indicator of most application I/O operations. This property counts the number of faults without regard for the number of pages faulted in each operation."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000003',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los cambios de contexto entre threads</strong> a partir del atributo <strong>ContextSwitchesPersec</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"Rate of switches from one thread to another. Thread switches can occur either inside of a single process or across processes. A thread switch can be caused either by one thread asking another for information, or by a thread being preempted by another, higher priority thread becoming ready to run. The operating system uses process boundaries for subsystem protection in addition to the traditional protection of user and privileged modes. These subsystem processes provide additional protection. Therefore, some work done by the operating system on behalf of an application appears in other subsystem processes in addition to the privileged time in the application. Switching to the subsystem process causes one context switch in the application thread. Switching back causes another context switch in the subsystem thread."<br>V&aacute;lido para sistemas Windows.'
      );


      $TIPS[]=array(
         'id_ref' => 'xagt_000004',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>la tasa de escritura a disco en bytes</strong> a partir de los atributos <strong>FileReadBytesPersec, FileWriteBytesPersec y FileControlBytesPersec</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"
Overall rate at which bytes are read to satisfy file system read requests to all devices on the computer, including read requests from the file system cache. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.

Overall rate at which bytes are written to satisfy file system write requests to all devices on the computer, including write requests to the file system cache. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.

Overall rate at which bytes are transferred for all file system operations that are neither read nor write operations, including file system control requests and requests for information about device characteristics or status. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.

"<br>V&aacute;lido para sistemas Windows.'
      );


      $TIPS[]=array(
         'id_ref' => 'xagt_000005',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los accesos a disco</strong> a partir de los atributos <strong>FileReadOperationsPersec, FileWriteOperationsPersec y FileControlOperationsPersec</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"

Combined rate of file system read requests to all devices on the computer, including requests to read from the file system cache. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.
Combined rate of the file system write requests to all devices on the computer, including requests to write to data in the file system cache. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.
Combined rate of file system operations that are neither read nor write operations, such as file system control requests and requests for information about device characteristics or status. This property is the inverse of the FileDataOperationsPerSec property. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval.
<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000006',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de procesos</strong> a partir del atributo <strong>Processes</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"Number of processes in the computer at the time of data collection. This is an instantaneous count, not an average over the time interval. Each process represents a running program."<br>V&aacute;lido para sistemas Windows.'
      );


      $TIPS[]=array(
         'id_ref' => 'xagt_000007',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de threads</strong> a partir del atributo <strong>Threads</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"Number of threads in the computer at the time of data collection. This is an instantaneous count, not an average over the time interval. A thread is the basic executable entity that can execute instructions in a processor."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000008',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de llamadas al sistema</strong> a partir del atributo <strong>SystemCallsPersec</strong> de la clase WMI <strong>Win32_PerfRawData_PerfOS_System</strong>:<br>"Combined rate of calls to system service routines by all processes running on the computer. These routines perform all of the basic scheduling and synchronization of activities on the computer, and provide access to non-graphic devices, memory management, and name space management. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval."<br>V&aacute;lido para sistemas Windows.'
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_000500',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de bytes imprimidos</strong> a partir del atributo <strong>BytesPrintedPersec</strong> de la clase WMI <strong>Win32_PerfRawData_Spooler_PrintQueue</strong>:<br>"Number of bytes per second printed on a print queue."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000501',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el resultado de los trabajos de la cola de impresi&oacute;n</strong> a partir de las siguientes propiedades<strong>Jobs, JobsSpooling y JobErrors</strong> de la clase WMI <strong>Win32_PerfRawData_Spooler_PrintQueue</strong>:<br>"Current number of jobs in a print queue.  Current number of spooling jobs in a print queue.  Total number of job errors in a print queue after the last restart."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000502',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los errores de impresi&oacute;n</strong> a partir de los atributos <strong>NotReadyErrors y OutofPaperErrors</strong> de la clase WMI <strong>Win32_PerfRawData_Spooler_PrintQueue</strong>:<br>"Total number of printer-not-ready errors in a print queue after the last restart.  Total number of out-of-paper errors in a print queue after the last restart."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000503',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de trabajos imprimidos</strong> a partir del atributo <strong>TotalJobsPrinted</strong> de la clase WMI <strong>Win32_PerfRawData_Spooler_PrintQueue</strong>:<br>"Total number of jobs printed on a print queue after the last restart."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000504',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de p&aacute;ginas imprimidas</strong> a partir del atributo <strong>TotalPagesPrinted</strong> de la clase WMI <strong>Win32_PerfRawData_Spooler_PrintQueue</strong>:<br>"Number of pages per second printed on a print queue."<br>V&aacute;lido para sistemas Windows.'
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_000800',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de errores ICMP</strong> a partir de los atributos <strong>MessagesReceivedErrors y MessagesOutboundErrors</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_ICMP</strong>:<br>"Number of ICMP messages that the entity received but that have errors such as bad ICMP checksums, bad length, and so on. 
Number of ICMP messages that this entity did not send due to problems discovered within ICMP such as lack of buffers. This value does not include errors discovered outside the ICMP layer, such as those recording the failure of IP to route the resultant datagram. In some implementations, none of the error types are included in the value of this property.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000801',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de paquetes ICMP que no han llegado a su destino</strong> a partir de los atributos <strong>ReceivedDestUnreachable y SentDestinationUnreachable</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_ICMP</strong>:<br>"Number of ICMP Destination Unreachable messages received.
Number of ICMP destination unreachable messages sent.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000802',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de paquetes ICMP que han llegado con fuera de tiempo</strong> a partir del atributo <strong>ReceivedTimeExceeded</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_ICMP</strong>:<br>"Number of ICMP time exceeded messages received."<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000803',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de paquetes IP descartados</strong> a partir de los atributos <strong>DatagramsReceivedDiscarded, DatagramsOutboundDiscarded y DatagramsOutboundNoRoute</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_IP</strong>:<br>"
Number of input IP datagrams for which no problems were encountered to prevent continued processing, but which were discarded, for example, due to an insufficient buffer size. This property does not include any datagrams discarded while awaiting reassembly.
Number of output IP datagrams that were discarded for reasons such as lack of buffer space, despite having no problems preventing transmission to the destination. This property includes datagrams counted in DatagramsForwardedPerSec if any such packets met this discretionary discard criterion.
Number of IP datagrams discarded because no route could be found to transmit them to the destination. This property includes any packets counted in DatagramsForwarded that meet the "no route" criterion.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000804',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de errores en paquetes IP</strong> a partir de los atributos <strong>DatagramsReceivedAddressErrors, DatagramsReceivedHeaderErrors y DatagramsReceivedUnknownProtocol</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_IP</strong>:<br>"
Number of input datagrams discarded because the IP address in the header of the IPdestination field was not a valid address to be received at this entity. This count includes invalid addresses (for example, 0.0. 0.0) and addresses of unsupported Classes (for example, Class E). For entities that are not IP Gateways and therefore do not forward datagrams, this property includes datagrams discarded because the destination address was not a local address.
Number of input datagrams discarded due to errors in the IP headers, including bad checksums, version number mismatch, other format errors, time-to-live exceeded, errors discovered in processing IP options, and so on.
Number of locally-addressed datagrams received successfully but are discarded because of an unknown or unsupported protocol.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000805',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>la fragmentaci&oacute;n en los paquetes IP</strong> a partir de los atributos <strong>FragmentationFailures y FragmentReassemblyFailures</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_IP</strong>:<br>"
Number of IP datagrams that have been discarded because they must be fragmented at this entity, but cannot be, for example, because the "Do not Fragment" flag was set.
Number of failures detected by the IP re-assembly algorithm for any reason, such as time out, errors, and so on. This is not necessarily a count of discarded IP fragments because some algorithms (notably RFC 815) can lose track of the number of fragments by combining them as they are received.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000806',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el estado de las conexiones TCP</strong> a partir de los atributos <strong>ConnectionsEstablished, ConnectionsActive y ConnectionsPassive</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_TCP</strong>:<br>"
Number of TCP connections for which the current state is either ESTABLISHED or CLOSE-WAIT.
Number of times TCP connections have made a direct transition from the CLOSED state to the SYN-SENT state.
Number of times TCP connections have made a direct transition from the LISTEN state to the SYN-RCVD state.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000807',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>errores en las conexiones TCP</strong> a partir de los atributos <strong>ConnectionFailures|ConnectionsReset</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_TCP</strong>:<br>"
Number of times TCP connections have made a direct transition to the CLOSED state from the SYN-SENT state or the SYN-RCVD state, plus the number of times TCP connections have made a direct transition from the SYN-RCVD state to the LISTEN state.
Number of times TCP connections have made a direct transition from the LISTEN state to the SYN-RCVD state.
"<br>V&aacute;lido para sistemas Windows.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_000808',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>errores UDP</strong> a partir del atributo <strong>DatagramsReceivedErrors</strong> de la clase WMI <strong>Win32_PerfRawData_Tcpip_UDP</strong>:<br>"Number of received UDP datagrams that could not be delivered for reasons other than the lack of an application at the destination port."<br>V&aacute;lido para sistemas Windows.'
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_001000',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de ficheros presentes en un directorio</strong> mediante el script linux_metric_num_files_in_dir.sh. <br>V&aacute;lido para sistemas Linux. '
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_003000',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los tiempos de respuesta de transacciones WEB con IMACROS-Sensor</strong> Utiliza el script win32_imacros_base.vbs <br>Permite ejecutar navegaciones complejas '
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_004000',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el tiempo de caducidad (en segundos) de un certificado SSL</strong>'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_004001',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el tiempo de caducidad (en horas) de un certificado SSL</strong>'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_004010',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Se trata de una metrica compleja que implementa un <strong>bucle de correo con envio por protocolo SMTP y recepcion mediante POP3</strong>. Requiere lo siguiente:<br>1. Poder enviar correos por SMTP desde el servidor o relay de correo que se quiera validar.<br>2. Disponer de una cuenta de correo en internet donde se haya configurado un reenvio a la direccion interna.<br>3. Disponer de acceso al buzon de recepcion de estos correos en el servidor POP3'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004100',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el porcentaje uso del buffer internode la BBDD MySQL</strong> a lo largo del tiempo.<br> A partir de <strong>((Key_blocks_used*key_cache_block_size)/key_buffer_size)*100</strong><br>Key_blocks_used se obtiene mediante el comando SHOW status y key_cache_block_size,key_buffer_size se obtienen mediante el comando SHOW variables.'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_004101',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el porcentaje uso de la cache interna de la BBDD MySQL</strong> a lo largo del tiempo.<br>A partir de: <strong>(Key_reads/Key_read_requests)*100</strong> y de <strong>(Key_writes/Key_write_requests)*100</strong> obtenidos mediante el comando SHOW status.'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_004102',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el porcentaje maximo de conexiones consumidas por la BBDD MySQL</strong> a lo largo del tiempo.<br>A partir de  <strong>(Max_used_connections/max_connections)*100</strong><br>Max_used_connections/max_connections se obtiene mediante el comando SHOW status y max_connections mediante el comando SHOW variables.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004200',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de ficheros/subdirectorios</strong> presentes en el directorio especificado.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004201',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de ficheros abiertos por el proceso especificado.</strong>'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004202',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>los cambios producidos en los routers intermedios</strong> que permiten el acceso a un host especificado.<br>Para ello se calculan los saltos necesarios para llegar al destino mediante el comando traceroute y se obtiene el hash MD5 de dicha lista de IPs. Un cambio en dicho valor significa un cambio en las rutas obtenidas.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004203',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de routers intermedios</strong> necesarios para llegar a un host especificado.<br>Se obtienen a partir del comando traceroute.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004300',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de procesos en ejecucion</strong> de un determinado proceso en diferentes equipos.<br>Se obtiene la suma de procesos en ambos equipos por SNMP a partir de la MIB-HOST.'
      );

//---------------------------------------------------------------------------------------------------------
      $TIPS[]=array(
         'id_ref' => 'xagt_005000',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el estado de las colas de Exchange</strong> a partir del atributo <strong>QueuesState</strong> de la clase WMI <strong>ExchangeServerState</strong>:<br>"The QueuesState property specifies the current state of the queues on the computer running Exchange 2000 Server."<br>V&aacute;lido para MS Exchange Server.'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_005001',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el estado del servidor de Exchange</strong> a partir del atributo <strong>ServerState</strong> de la clase WMI <strong>ExchangeServerState</strong>:<br>"The ServerState property specifies the current state of the computer running Exchange 2000 Server."<br>V&aacute;lido para MS Exchange Server.'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_005002',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el n&uacute;mero de mensajes en la cola de Exchange</strong> a partir del atributo <strong>NumberOfMessages</strong> de la clase WMI <strong>ExchangeQueue</strong>:<br>"The NumberOfMessages property specifies the number of messages that are waiting for transmission by the queue."<br>V&aacute;lido para MS Exchange Server.'
      );
      $TIPS[]=array(
         'id_ref' => 'xagt_005003',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el estado del conector de Exchange</strong> a partir del atributo <strong>IsUp</strong> de la clase WMI <strong>ExchangeConnectorState</strong>:<br>"The IsUp property, when True, specifies that the Exchange Connector is operating normally."<br>V&aacute;lido para MS Exchange Server.'
      );



//---------------------------------------------------------------------------------------------------------
/*      $TIPS[]=array(
         'id_ref' => 'xagt_004500',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de Procesos del Sistema Operativo</strong> a partir del atributo <strong>Processes</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>:<br>"Number of processes in the computer at the time of data collection. This is an instantaneous count, not an average over the time interval. Each process represents a running program."'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004501',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de hilos del Sistema Operativo</strong> a partir del atributo<strong>Threads</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>:<br>"Number of threads in the computer at the time of data collection. This is an instantaneous count, not an average over the time interval. A thread is the basic executable entity that can execute instructions in a processor."'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004502',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de llamadas al Sistema Operativo</strong> a partir del atributo<strong>SystemCallsPersec</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>:<br>"Combined rate of calls to Windows NT system service routines by all processes running on the computer. These routines perform all of the basic scheduling and synchronization of activities on the computer, and provide access to non-graphic devices, memory management, and namespace management. This property displays the difference between the values observed in the last two samples, divided by the duration of the sample interval."'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004503',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>el numero de cambios de contexto en el Sistema Operativo</strong> a partir del atributo<strong>ContextSwitchesPersec</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>:<br>"Rate of switches from one thread to another. Thread switches can occur either inside of a single process or across processes. A thread switch can be caused either by one thread asking another for information, or by a thread being preempted by another, higher priority thread becoming ready to run. The operating system uses process boundaries for subsystem protection in addition to the traditional protection of user and privileged modes. These subsystem processes provide additional protection. Therefore, some work done by the operating system on behalf of an application appears in other subsystem processes in addition to the privileged time in the application. Switching to the subsystem process causes one context switch in the application thread. Switching back causes another context switch in the subsystem thread."'
      );

      $TIPS[]=array(
         'id_ref' => 'xagt_004504',          'tip_type' => 'agent',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mide: <strong>la longitud de la cola de proceso del Sistema Operativo</strong> a partir del atributo<strong>ProcessorQueueLength</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>:<br>"Number of threads in the processor queue. There is a single queue for processor time even on computers with multiple processors. Unlike the disk counters, this property counts ready threads only, not threads that are running. A sustained processor queue of greater than two threads generally indicates processor congestion. This property displays the last observed value only; it is not an average.
"'
      );

*/

//---------------------------------------------------------------------------------------------------------
// Aplicacion de agente
// El id_ref coincide con el name de la aplicacion xagent
//---------------------------------------------------------------------------------------------------------

      $TIPS[]=array(
         'id_ref' => 'xapp_000001',          'tip_type' => 'xapp',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Mira el propietario del directorio',
      );


?>
