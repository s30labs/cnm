#####################################################################################################
# Fichero: WSCommon.pm
#####################################################################################################
package WSCommon;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw( %WS_DATA_WHAT %WS_DATA_FROM );
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


%WSCommon::WS_DATA_WHAT = (

	'devices' => 'id_dev,name,domain,ip,sysloc,sysdesc,sysoid,type,app,status,mode,community,version,refresh,wbem_user,wbem_pwd,aping,aping_date,id_cfg_op,host_idx,background',

	'metrics' => 'id_metric,name,id_dev,type,subtype,label,items,lapse,file_path,file,host,vlabel,graph,top_value,mtype,mode,module,status,crawler_idx,crawler_pid,watch,refresh,disk, c_label,c_items,c_vlabel,c_mtype,severity,size,host_idx,iid',

);


%WSCommon::WS_DATA_FROM = (

   'devices' => 'devices',
   'metrics' => 'metrics',

);






1;

