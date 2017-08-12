#---------------------------------------------------------------------------
package Values;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $TABLE $OID_COLS $OID_LAST $NAME $DESCR $XML_FILE $PARAMS $RANGE $ENTERPRISE @ITEMS $CMD);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# MODO TABLA/MODO GET
#---------------------------------------------------------------------------
$TABLE=0;
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# MODO TABLA PARA APLICACIONES
#---------------------------------------------------------------------------
#my $OID_COLS='cikeTunLocalType_cikeTunLocalValue_cikeTunLocalAddr_cikeTunLocalName_cikeTunRemoteType_cikeTunRemoteValue_cikeTunRemoteAddr_cikeTunRemoteName_cikeTunNegoMode_cikeTunDiffHellmanGrp_cikeTunEncryptAlgo_cikeTunHashAlgo_cikeTunAuthMethod_cikeTunLifeTime_cikeTunActiveTime_cikeTunSaRefreshThreshold_cikeTunTotalRefreshes_cikeTunInOctets_cikeTunInPkts_cikeTunInDropPkts_cikeTunInNotifys_cikeTunInP2Exchgs_cikeTunInP2ExchgInvalids_cikeTunInP2ExchgRejects_cikeTunInP2SaDelRequests_cikeTunOutOctets_cikeTunOutPkts_cikeTunOutDropPkts_cikeTunOutNotifys_cikeTunOutP2Exchgs_cikeTunOutP2ExchgInvalids_cikeTunOutP2ExchgRejects_cikeTunOutP2SaDelRequests_cikeTunStatus';
#my $OID_LAST='CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunnelTable';

#$OID_COLS='cpmProcessPID_cpmProcessName_cpmProcessuSecs_cpmProcessTimeCreated_cpmProcessAverageUSecs_cpmProcExtMemAllocated_cpmProcExtMemFreed_cpmProcExtInvoked_cpmProcExtRuntime_cpmProcExtUtil5Sec_cpmProcExtUtil1Min_cpmProcExtUtil5Min_cpmProcExtPriority_cpmProcExtMemAllocatedRev_cpmProcExtMemFreedRev_cpmProcExtInvokedRev_cpmProcExtRuntimeRev_cpmProcExtUtil5SecRev_cpmProcExtUtil1MinRev_cpmProcExtUtil5MinRev_cpmProcExtPriorityRev';
#$OID_LAST='CISCO-PROCESS-MIB::cpmProcessTable';

$OID_COLS='bgpPeerIdentifier_bgpPeerState_bgpPeerAdminStatus_bgpPeerNegotiatedVersion_bgpPeerLocalAddr_bgpPeerLocalPort_bgpPeerRemoteAddr_bgpPeerRemotePort_bgpPeerRemoteAs_bgpPeerInUpdates_bgpPeerOutUpdates_bgpPeerInTotalMessages_bgpPeerOutTotalMessages_bgpPeerLastError_bgpPeerFsmEstablishedTransitions_bgpPeerFsmEstablishedTime_bgpPeerConnectRetryInterval_bgpPeerHoldTime_bgpPeerKeepAlive_bgpPeerHoldTimeConfigured_bgpPeerKeepAliveConfigured_bgpPeerMinASOriginationInterval_bgpPeerMinRouteAdvertisementInterval_bgpPeerInUpdateElapsedTime';
$OID_LAST='BGP4-MIB::bgpPeerTable';

#---------------------------------------------------------------------------
$NAME='TABLA DE PEERS BGP ';
$DESCR='Muestra la tabla de peers BGP. ';
$XML_FILE='00000-MIB2-BGP4-PEER_TABLE.xml';
$PARAMS='';
$RANGE=$OID_LAST;
$ENTERPRISE='00000';		#5 CIFRAS !!!!

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# MODO GET PARA METRICAS Y APLICACIONES
# MODO TABLA PARA METRICAS (PRIMERA APROXIMACION)
#---------------------------------------------------------------------------
@ITEMS=(
	{	'name'=> 'Uso de CPU (%)',	'oid'=>'ASYNCOS-MAIL-MIB::perCentCPUUtilization.0', 'subtype'=>'xxx', 'class'=>'yyy' },
	{	'name'=> 'Uso de Memoria (%)',	'oid'=>'ASYNCOS-MAIL-MIB::perCentMemoryUtilization.0', 'subtype'=>'xxx', 'class'=>'yyy' },
	{	'name'=> 'Memoria asignada',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResMemAllocate.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Memoria libre',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResMemLeft.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Memoria Fragmentada',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResMemFrag.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Sesiones asignadas',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResSessAllocate.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Sesiones Maximas',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResSessMaxium.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Sesiones Falladas',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResSessFailed.0', 'subtype'=>'xxx', 'class'=>'yyy'},
	{	'name'=> 'Uso de CPU (%)',	'oid'=>'NETSCREEN-RESOURCE-MIB::nsResCpuLast5Min.0|NETSCREEN-RESOURCE-MIB::nsResCpuLast15Min.0', 'subtype'=>'xxx', 'class'=>'yyy'}
);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
$CMD="/opt/crawler/bin/libexec/snmptable -f $XML_FILE -w xml ";


1;
__END__
