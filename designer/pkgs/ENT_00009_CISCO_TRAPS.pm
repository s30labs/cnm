#---------------------------------------------------------------------------
package ENT_00009_CISCO_TRAPS;
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00009_CISCO_TRAPS::ENTERPRISE_PREFIX='00009';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%ENT_00009_CISCO_TRAPS::TABLE_APPS =(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_TRAPS::METRICS=(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_TRAPS::METRICS_TAB=(


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_TRAPS::REMOTE_ALERTS=(

   {  'type'=>'snmp', 'subtype'=>'CISCO-SYSLOG-MIB::clogMessageGenerated', 'class'=>'CISCO', 'set_hiid'=>'56cb05e1a6',
      'descr'=>'CISCO SYSLOG - MENSAJE CRITICO', 'severity'=>'1', 'enterprise'=>'ent.9',
		'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'remote2expr'=>[ {'v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'<=', 'expr'=>'3'} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CISCO-SYSLOG-MIB::clogMessageGenerated', 'class'=>'CISCO', 'set_hiid'=>'26f1085a97',
      'descr'=>'CISCO SYSLOG - MENSAJE IMPORTANTE', 'severity'=>'2', 'enterprise'=>'ent.9',
		'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'remote2expr'=>[ {'v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'=', 'expr'=>'4'} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CISCO-SYSLOG-MIB::clogMessageGenerated', 'class'=>'CISCO',
      'descr'=>'CISCO SYSLOG - AVISO', 'severity'=>'2', 'enterprise'=>'ent.9',
      'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'remote2expr'=>[ {'v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'=', 'expr'=>'5'} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO', 'itil_type'=>'1'  },

);


1;
__END__
