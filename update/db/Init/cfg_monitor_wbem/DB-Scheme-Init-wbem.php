<?php

//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------

	$CFG_MONITOR_WBEM=array(

//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_PerfDisk_LogicalDisk
//---------------------------------------------------------------------------------------------------------
      array(
            'subtype' => 'wmi_free_megabytes',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfDisk_LogicalDisk',
            'class_label' => 'Win32_Disk',
            'lapse' => '300',
            'descr' => 'ESPACIO NO USADO en DISCO',
            'items' => 'FreeMegabytes',
            'property' => 'FreeMegabytes',
            'get_iid' => '1',
            'property_info' => 'Win32_PerfRawData_PerfDisk_LogicalDisk|FreeMegabytess|GAUGE|   ',

            'label' => '',
            'vlabel' => 'MBytes',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '2',
      ),



//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_PerfOS_Memory
//---------------------------------------------------------------------------------------------------------
      array(
         	'subtype' => 'wmi_memory_available',
            'namespace' => '/root/cimv2',
         	'class' => 'Win32_PerfRawData_PerfOS_Memory',
            'class_label' => 'Win32_OS',
         	'lapse' => '300',
	         'descr' => 'MEMORIA DISPONIBLE',
   	      'items' => 'AvailableBytes',
      	   'property' => 'AvailableBytes',
         	'get_iid' => '0',
   	      'property_info' => 'Win32_PerfRawData_PerfOS_Memory|AvailableBytes|Integer32|   ',

				'label' => '',
				'vlabel' => 'bytes',
				'mode' => 'GAUGE',
				'mtype' => 'STD_AREA',
				'top_value' => '1',
				'module' => 'mod_wbem_get',
		
				'severity' => '1',
				'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_cache_faults',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_Memory',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'MANEJO DE LA CACHE',
            'items' => 'CacheFaultsPersec|PageFaultsPersec',
            'property' => 'CacheFaultsPersec|PageFaultsPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_Memory|CacheFaultsPersec|Integer32|   <br>Win32_PerfRawData_PerfOS_Memory|PageFaultsPersec|Integer32|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_PerfOS_System
//---------------------------------------------------------------------------------------------------------
      array(
            'subtype' => 'wmi_context_switches',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'CAMBIOS DE CONTEXTO',
            'items' => 'ContextSwitchesPersec',
            'property' => 'ContextSwitchesPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|ContextSwitchesPersec|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_file_read_write_bytes',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'LECTURAS/ESCRITURAS A FICHERO - BYTES',
            'items' => 'FileReadBytesPersec|FileWriteBytesPersec|FileControlBytesPersec',
            'property' => 'FileReadBytesPersec|FileWriteBytesPersec|FileControlBytesPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|FileReadBytesPersec|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|FileWriteBytesPersec|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|FileControlBytesPersec|    ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),


      array(
            'subtype' => 'wmi_file_read_write_oper',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'LECTURAS/ESCRITURAS A FICHERO - ACCESOS',
            'items' => 'FileReadOperationsPersec|FileWriteOperationsPersec|FileControlOperationsPersec',
            'property' => 'FileReadOperationsPersec|FileWriteOperationsPersec|FileControlOperationsPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|FileReadOperationsPersec|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|FileWriteOperationsPersec|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|FileControlOperationsPersec|    ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_num_processes',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'NUMERO DE PROCESOS',
            'items' => 'Processes',
            'property' => 'Processes',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|Processes|GAUGE|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_num_threads',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'NUMERO DE THREADS',
            'items' => 'Threads',
            'property' => 'Threads',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|Threads|GAUGE|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),


      array(
            'subtype' => 'wmi_system_calls',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_PerfOS_System',
            'class_label' => 'Win32_OS',
            'lapse' => '300',
            'descr' => 'LLAMADAS AL SISTEMA',
            'items' => 'SystemCallsPersec',
            'property' => 'SystemCallsPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|SystemCallsPersec|GAUGE|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),


//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_Spooler_PrintQueue
//---------------------------------------------------------------------------------------------------------
      array(
            'subtype' => 'wmi_bytes_printed',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Spooler_PrintQueue',
            'class_label' => 'Win32_Spooler',
            'lapse' => '300',
            'descr' => 'SPOOLER: BYTES IMPRIMIDOS',
            'items' => 'BytesPrintedPersec',
            'property' => 'BytesPrintedPersec',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|BytesPrintedPersec|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_job_control',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Spooler_PrintQueue',
            'class_label' => 'Win32_Spooler',
            'lapse' => '300',
            'descr' => 'SPOOLER: CONTROL DE TRABAJOS',
            'items' => 'Jobs|JobsSpooling|JobErrors',
            'property' => 'Jobs|JobsSpooling|JobErrors',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|Jobs|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|JobsSpooling|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|JobErrors|    ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_printer_errors',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Spooler_PrintQueue',
            'class_label' => 'Win32_Spooler',
            'lapse' => '300',
            'descr' => 'SPOOLER: ERRORES DE IMPROSION',
            'items' => 'NotReadyErrors|OutofPaperErrors',
            'property' => 'NotReadyErrors|OutofPaperErrors',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|NotReadyErrors|COUNTER|   <br>Win32_PerfRawData_PerfOS_System|OutofPaperErrors|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_jobs_printed',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Spooler_PrintQueue',
            'class_label' => 'Win32_Spooler',
            'lapse' => '300',
            'descr' => 'SPOOLER: TRABAJOS IMPRIMIDOS',
            'items' => 'TotalJobsPrinted',
            'property' => 'TotalJobsPrinted',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|TotalJobsPrinted|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_pages_printed',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Spooler_PrintQueue',
            'class_label' => 'Win32_Spooler',
            'lapse' => '300',
            'descr' => 'SPOOLER: PAGINAS IMPRIMIDAS',
            'items' => 'TotalPagesPrinted',
            'property' => 'TotalPagesPrinted',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_PerfOS_System|TotalPagesPrinted|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_Tcpip_ICMP
//---------------------------------------------------------------------------------------------------------
      array(
            'subtype' => 'wmi_icmp_errors',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_ICMP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'ERRORES ICMP',
            'items' => 'MessagesReceivedErrors|MessagesOutboundErrors',
            'property' => 'MessagesReceivedErrors|MessagesOutboundErrors',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_ICMP|MessagesReceivedErrors|COUNTER|   <br>Win32_PerfRawData_Tcpip_ICMP|MessagesOutboundErrors|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_icmp_dest_unreachable',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_ICMP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'PAQUETES ICMP DESTINO INALCANZABLE',
            'items' => 'ReceivedDestUnreachable|SentDestinationUnreachable',
            'property' => 'ReceivedDestUnreachable|SentDestinationUnreachable',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_ICMP|ReceivedDestUnreachable|COUNTER|   <br>Win32_PerfRawData_Tcpip_ICMP|SentDestinationUnreachable|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_icmp_time_exceeded',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_ICMP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'PAQUETES ICMP TIEMPO EXCEDIDO',
            'items' => 'ReceivedTimeExceeded|ReceivedTimeExceeded',
            'property' => 'ReceivedTimeExceeded|ReceivedTimeExceeded',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_ICMP|ReceivedTimeExceeded|COUNTER|   <br>Win32_PerfRawData_Tcpip_ICMP|ReceivedTimeExceeded|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_Tcpip_IP
//---------------------------------------------------------------------------------------------------------
      array(
            'subtype' => 'wmi_ip_datagram_discard',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_IP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'PAQUETES IP DESCARTADOS',
            'items' => 'DatagramsReceivedDiscarded|DatagramsOutboundDiscarded|DatagramsOutboundNoRoute',
            'property' => 'DatagramsReceivedDiscarded|DatagramsOutboundDiscarded|DatagramsOutboundNoRoute',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_IP|DatagramsReceivedDiscarded|COUNTER|   <br>Win32_PerfRawData_Tcpip_IP|DatagramsOutboundDiscarded|COUNTER|   <br>Win32_PerfRawData_Tcpip_IP|DatagramsOutboundNoRoute|COUNTER|  ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_ip_datagram_error',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_IP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'PAQUETES IP CON ERRORES',
            'items' => 'DatagramsReceivedAddressErrors|DatagramsReceivedHeaderErrors|DatagramsReceivedUnknownProtocol',
            'property' => 'DatagramsReceivedAddressErrors|DatagramsReceivedHeaderErrors|DatagramsReceivedUnknownProtocol',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_IP|DatagramsReceivedAddressErrors|COUNTER|   <br>Win32_PerfRawData_Tcpip_IP|DatagramsReceivedHeaderErrors|COUNTER|   <br>Win32_PerfRawData_Tcpip_IP|DatagramsReceivedUnknownProtocol|COUNTER|  ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_ip_datagram_fragmentation',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_IP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'PAQUETES IP CON ERRORES DE FRAGMENTACION',
            'items' => 'FragmentationFailures|FragmentReassemblyFailures',
            'property' => 'FragmentationFailures|FragmentReassemblyFailures',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_IP|FragmentationFailures|COUNTER|   <br>Win32_PerfRawData_Tcpip_IP|FragmentReassemblyFailures|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_Tcpip_TCP
//---------------------------------------------------------------------------------------------------------

      array(
            'subtype' => 'wmi_tcp_connect_detail1',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_TCP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'DETALLE(1) DE CONEXIONES TCP',
            'items' => 'ConnectionsEstablished|ConnectionsActive|ConnectionsPassive',
            'property' => 'ConnectionsEstablished|ConnectionsActive|ConnectionsPassive',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_TCP|ConnectionsEstablished|COUNTER|   <br>Win32_PerfRawData_Tcpip_TCP|ConnectionsActive|COUNTER|   <br>Win32_PerfRawData_Tcpip_TCP|ConnectionsPassive|  ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),

      array(
            'subtype' => 'wmi_tcp_connect_detail2',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_TCP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'DETALLE(2) DE CONEXIONES TCP',
            'items' => 'ConnectionFailures|ConnectionsReset',
            'property' => 'ConnectionFailures|ConnectionsReset',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_TCP|ConnectionFailures|COUNTER|   <br>Win32_PerfRawData_Tcpip_TCP|ConnectionsReset|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),


//---------------------------------------------------------------------------------------------------------
// WMI: Win32_PerfRawData_Tcpip_UDP
//---------------------------------------------------------------------------------------------------------

      array(
            'subtype' => 'wmi_udp_received_errors',
            'namespace' => '/root/cimv2',
            'class' => 'Win32_PerfRawData_Tcpip_UDP',
            'class_label' => 'Win32_TCPIP',
            'lapse' => '300',
            'descr' => 'ERRORES EN DATAGRAMAS UDP RECIBIDOS',
            'items' => 'DatagramsReceivedErrors',
            'property' => 'DatagramsReceivedErrors',
            'get_iid' => '0',
            'property_info' => 'Win32_PerfRawData_Tcpip_UDP|DatagramsReceivedErrors|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'COUNTER',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '1',
      ),


//---------------------------------------------------------------------------------------------------------
// WMI: ExchangeServerState
//---------------------------------------------------------------------------------------------------------

      array(
            'subtype' => 'wmi_exchange_queues_state',
            'namespace' => '/root/cimv2/applications/exchange',
            'class' => 'ExchangeServerState',
            'class_label' => 'Exchange_ServerState',
            'lapse' => '300',
            'descr' => 'ESTADO DE LAS COLAS',
            'items' => 'QueuesState',
            'property' => 'QueuesState',
            'get_iid' => '1',
            'property_info' => 'ExchangeServerState|QueuesState|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '2',
      ),


      array(
            'subtype' => 'wmi_exchange_server_state',
            'namespace' => '/root/cimv2/applications/exchange',
            'class' => 'ExchangeServerState',
            'class_label' => 'Exchange_ServerState',
            'lapse' => '300',
            'descr' => 'ESTADO DEL SERVIDOR',
            'items' => 'ServerState',
            'property' => 'ServerState',
            'get_iid' => '1',
            'property_info' => 'ExchangeServerState|Server|COUNTER|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '2',
      ),

      array(
            'subtype' => 'wmi_exchange_queue_messages',
            'namespace' => '/root/cimv2/applications/exchange',
            'class' => 'ExchangeQueue',
            'class_label' => 'Exchange_Queue',
            'lapse' => '300',
            'descr' => 'NUMERO DE MENSAJES EN LA COLA',
            'items' => 'NumberOfMessages',
            'property' => 'NumberOfMessages',
            'get_iid' => '1',
            'property_info' => 'QueueNumberOfMessages|NumberOfMessages|GAUGE|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '2',
      ),

      array(
            'subtype' => 'wmi_exchange_connector_state',
            'namespace' => '/root/cimv2/applications/exchange',
            'class' => 'ExchangeConnectorState',
            'class_label' => 'Exchange_ConectorState',
            'lapse' => '300',
            'descr' => 'ESTADO DEL CONECTOR',
            'items' => 'IsUp',
            'property' => 'IsUp',
            'get_iid' => '1',
            'property_info' => 'ExchangConnectoreState|IsUp|GAUGE|   ',

            'label' => '',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',
            'top_value' => '1',
            'module' => 'mod_wbem_get',

            'severity' => '1',
            'cfg' => '2',
      ),



   );


?>
