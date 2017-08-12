#---------------------------------------------------------------------------
package ENT_34225_CNM;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_34225_CNM::ENTERPRISE_PREFIX='34225';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_34225_CNM::TABLE_APPS =(

);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_34225_CNM::GET_APPS =(


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_34225_CNM::METRICS=(


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_34225_CNM::METRICS_TAB=(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_34225_CNM::REMOTE_ALERTS=(

   {  'type'=>'snmp', 'subtype'=>'CNM-NOTIFICATIONS-MIB::cnmNotifNoLinkSet', 'class'=>'CNM',
      'descr'=>'EL INTERFAZ DE RED NO TIENE LINK', 'severity'=>'1',
      'vardata' =>'cnmNotifCode;cnmNotifMsg;cnmNotifKey', 'enterprise'=>'ent.34225',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'cnmNotifCode', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v2', 'descr'=>'cnmNotifMsg', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v3', 'descr'=>'cnmNotifKey', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'CNM', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CNM-NOTIFICATIONS-MIB::cnmNotiIFDownfSet', 'class'=>'CNM',
      'descr'=>'EL INTERFAZ DE RED ESTA CAIDO', 'severity'=>'1',
      'vardata' =>'cnmNotifCode;cnmNotifMsg;cnmNotifKey', 'enterprise'=>'ent.34225',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'cnmNotifCode', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'cnmNotifMsg', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'cnmNotifKey', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'CNM', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMNoAccessToRemote', 'class'=>'CNM',
      'descr'=>'SIN ACCESO A CNM REMOTO', 'severity'=>'1',
      'vardata' =>'cnmNotifCode;cnmNotifMsg;cnmNotifKey', 'enterprise'=>'ent.34225',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'cnmNotifCode', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'cnmNotifMsg', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'cnmNotifKey', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'CNM', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMBackupFailure', 'class'=>'CNM',
      'descr'=>'ERROR AL HACER EL BACKUP DEL EQUIPO', 'severity'=>'1',
      'vardata' =>'cnmNotifCode;cnmNotifMsg;cnmNotifKey', 'enterprise'=>'ent.34225',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'cnmNotifCode', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'cnmNotifMsg', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'cnmNotifKey', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'CNM', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CNM-NOTIFICATIONS-MIB::cnmNotifNTPSyncFailure', 'class'=>'CNM',
      'descr'=>'ERROR AL SINCRONIZAR LA HORA DEL EQUIPO (NTP)', 'severity'=>'2',
      'vardata' =>'cnmNotifCode;cnmNotifMsg;cnmNotifKey', 'enterprise'=>'ent.34225',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'cnmNotifCode', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'cnmNotifMsg', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'cnmNotifKey', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'CNM', 'itil_type'=>'1'  },

);


1;
__END__
