#-------------------------------------------------------------------------------------------
# Fichero: Crawler/LogManager/SNMPTrap.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::LogManager::SNMPTrap;
use Crawler::LogManager;
@ISA=qw(Crawler::LogManager);
use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

#-------------------------------------------------------------------------------------------
my %TRAP2HOOK=();
#$TRAP2HOOK{'9.9.26.2.6..3'} = '/opt/crawler/apps/trap_manager/trap_hook_rdsi_level2';

my $FILE_EVENTS_EXCLUDED='/cfg/excluded_events';
#------------------------------------------------------------------------------------------
# reconfigure
# Actualiza configuracion de B.D
#------------------------------------------------------------------------------------------
sub check_configuration {
my ($self)=@_;

   my $reload_file = $self->reload_file();
   if (-f $reload_file) { unlink $reload_file; }

   $self->log('info',"check_configuration:: **RELOAD** ($reload_file)");
   my $store=$self->store();
   my $dbh=$self->dbh();

   my ($trap2alert,$trap2alert_patterns)=$store->get_cfg_snmp_remote_alerts($dbh);
	$self->event2alert($trap2alert);
	$self->event2alert_patterns($trap2alert_patterns);

my $kk = Dumper($trap2alert);
$kk =~ s/\n/\. /g;
$self->log('debug',"check_configuration:: trap2alert=$kk");

	# Obtengo lista de eventos (o patrones) que no se almacenan en BBDD.
	my @evlist=();
	if (-f $FILE_EVENTS_EXCLUDED) {
		open (F,"<$FILE_EVENTS_EXCLUDED");
		while (<F>) {
			chomp;
			push @evlist,$_;
		}
	}
	$self->eventexcluded(\@evlist);

	# Mapeo de eventos: evkey ==> txt_custom
   my $event2data=$store->get_cfg_events_data($dbh);
	$self->event2data($event2data);

	# Mapeo IP a nombre
   my $ip2name=$store->get_ip2name_vector($dbh);
   $self->ip2name($ip2name);

   #----------------------------------------------------------------------------------
   # EXPR en traps
   #----------------------------------------------------------------------------------
#SELECT a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr FROM cfg_remote_alerts a, cfg_remote_alerts2expr b WHERE a.id_remote_alert=b.id_remote_alert and a.type='snmp';

   my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'snmp');
	$self->alert2expr($alert2expr);

   my $rv=$store->get_from_db($dbh,'c.id_remote_alert,d.ip','cfg_views2remote_alerts c, devices d',"c.id_dev=d.id_dev");
   my %alerts2views=();
   foreach my $i (@$rv) {
		my $key = $i->[0].'.'.$i->[1];
		$alerts2views{$key}=1;
   }
	$self->alert2views(\%alerts2views);

}




#------------------------------------------------------------------------------------------
# message2event
# 1. Parsea la linea de syslog
# 2. Almacena el evento correspondiente
# 1. Parsea la linea generada por snmptrapd en el formato acordado y rellena los hashes
# %MSG y @VDATA
# 2. Si el dispositivo (ip) esta baneado, termina
# 3. En caso contrario almacena el evento e incrementa el contador de traps recibidos
#
# OUT: 1 (Ha almacenado evento) | 0 (No ha almacenado evento)
#
# /usr/local/sbin/snmptrapd -Ls 1
#   -F "%V|%DATE>>%y%m%l %02.2h:%02.2j:%02.2k; HOST>>%A; IPv1>>%a; NAMEv1>>%A; IPv2>>%b; NAMEv2>>%B; OID>>%N; TRAP>>%w.%q; DESC>>%W; VDATA>>%v
#
#   %T  the value of the sysUpTime.0 varbind in seconds
#
#   %a  the contents of the agent-addr field of the PDU (v1 TRAPs only)
#   %A  the hostname corresponding to the contents of the agent-addr field of the PDU, if available, otherwise the contents of the agent-
#       addr field of the PDU (v1 TRAPs only).
#
#   %b  PDU source address (Note: this is not necessarily an IPv4 address)
#   %B  PDU source hostname if available, otherwise PDU source address (see note above)
#
#   %N  enterprise string
#
#   %w  trap type (numeric, in decimal)
#   %q  trap sub-type (numeric, in decimal)
#
#   %W  trap description
#
#   %P  security information from the PDU (community name for v1/v2c, user and context for v3)
#
#   %v  list  of trapâvariable-bindings. These will be separated by a tab, or by a comma and a blank if the alternate form is requested
#       See also %V
#
#   %V  specifies the variable-bindings separator. This takes a sequence of characters, up to the next % (to embed a % in the string, use
#       \%)
#
#------------------------------------------------------------------------------------------
# TRAP v1:  IPv1 viene en la PDU.  NAMEv1 Se obtiene del DNS de IPv1
#           DESC Incluye la descripcion del trap
#           El id del trap es:  TRAP compuesto por tipo + subtipo
#
# TRAP v2:  IPv2 viene de la IP que envia el trap.  NAMEv2 Se obtiene del DNS de IPv2
#           DESC Incluye la descripcion del trap
#           El id del trap se obtiene del valor del varbind data:
#           SNMPv2-MIB::snmpTrapOID.0 = OID: UCD-SNMP-MIB::ucdavis.991.17
#
# Para diferenciar v1/v2:  Si IPv1>>0.0.0.0 ==> Es TRAPv1
#
# Valor de retorno: 0 -> No hay dato de snmptrapd ; 1-> Si hay dato.
#
# snmptrap -v 1 -c public localhost SNMPv2-MIB::snmp localhost 0 0 '' IF-MIB::ifIndex i 1  => cold start
# ----------------------------------------------------------------
# snmptrap  -c public  -v 1 localhost  TRAP-TEST-MIB::demotraps localhost 6 17 '' SNMPv2-MIB::sysLocation.0 s "TRAP V1"
# ----------------------------------------------------------------
# Sep 18 19:54:48 cnm-devel2 snmptrapd[21752]: DATE>>2009918 19:54:48; HOST>>cnm-devel2; IPv1>>127.0.0.1; NAMEv1>>cnm-devel2; IPv2>>UDP: [127.0.0.1]:43442; NAMEv2>>cnm-devel2; OID>>UCD-SNMP-MIB::ucdExperimental.990; TRAP>>6..17; DESC>>Enterprise Specific; VDATA>>SNMPv2-MIB::sysLocation.0 = STRING: TRAP V1
# ----------------------------------------------------------------
# snmptrap -v 2c -c public localhost '' NOTIFICATION-TEST-MIB::demo-notif SNMPv2-MIB::sysLocation.0 s "TRAP V2"
# ----------------------------------------------------------------
# Sep 18 19:55:02 cnm-devel2 snmptrapd[21752]: DATE>>2009918 19:55:02; HOST>>0.0.0.0; IPv1>>0.0.0.0; NAMEv1>>0.0.0.0; IPv2>>UDP: [127.0.0.1]:43442; NAMEv2>>cnm-devel2; OID>>.; TRAP>>0.0; DESC>>Cold Start; VDATA>>DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (57471021) 6 days, 15:38:30.21|SNMPv2-MIB::snmpTrapOID.0 = OID: UCD-SNMP-MIB::ucdavis.991.17|SNMPv2-MIB::sysLocation.0 = STRING: TRAP V2
#------------------------------------------------------------------------------------------
sub check_event {
my ($self,$line) = @_;

   my %MSG=();
   my @VDATA=();
	$self->event(\%MSG);
   my $store=$self->store();
   my $dbh=$self->dbh();

   if ($line !~ /snmptrapd/) {
      $self->log('info',"check_event::[DEBUG] line is not from snmptrapd => NOK");
      $self->log('info',"check_event::[DEBUG] line is >> $line");
      return 0;
   }

   $self->log('debug',"check_event::[DEBUG] line from snmptrapd => OK");


   #----------------------------------------
   #Parsea la linea ==> Hash campo valor
   my @data=split(/\;/,$line);
   foreach (@data) {
   	if (/.*?\s*(\S+)\>\>(.+)/) { $MSG{$1}=$2; }
   }

	if ((! exists $MSG{'IPv1'}) || (! exists $MSG{'IPv2'})) {
		$self->log('info',"check_event::[DEBUG] line from snmptrapd => NOK");
      return 0;
   }

	
   #Jul 18 10:17:57 bcncnma0001 snmptrapd
   my $IPR='-';
   if ($line =~ /\:\d+\s+(.*?)\s+snmptrapd/) { $IPR=$1; }

#   #Parsea el varbind data ==> Hash campo valor
#   if (exists $MSG{'VDATA'}) {
#      my @vd=split(/\|/,$MSG{'VDATA'});
#      foreach my $v (@vd) {
#         if ($v=~ /(\S+)\s*\=\s*(.+)$/) { push @VDATA, {'k'=>$1, 'v'=>$2}; }
#      }
#      my $txt='check_event::[DEBUG] Global fields='.scalar @data.' VDATA fields='.scalar @vd;
#      $self->log('debug',$txt);
#   }
#   else { $MSG{'VDATA'}=''; }

   $MSG{'v'}=1;

   #----------------------------------------
   # Las claves del hash son:
   # HOST>>%A; IPv1>>%a; NAMEv1>>%A; IPv2>>%b; NAMEv2>>%B; OID>>%N; TRAP>>%w.%q; DESC>>%W; VDATA>>%v
   #----------------------------------------
   if ($MSG{'IPv1'} =~ /(\d+\.\d+\.\d+\.\d+)/ ) { $MSG{'ip'}=$1; }
   if ($MSG{'NAMEv1'} =~ /^\s*(\d+\.\d+\.\d+\.\d+)\s*$/ ) { $MSG{'name'}=$1; $MSG{'domain'}=''; }
   elsif ($MSG{'NAMEv1'} =~ /^(\S+)\.([\.+|\S+]+)$/ ) { $MSG{'name'}=$1;  $MSG{'domain'}=$2; }
   else { $MSG{'name'}=$MSG{'NAMEv1'};  $MSG{'domain'}=''; }
   $MSG{'full_name'}=$MSG{'NAMEv1'};
   $MSG{'proccess'}='TRAP-SNMP';

   #Traps estandard
   if ( $MSG{'TRAP'} !~ /^6/ ) { $MSG{'subtype'}= $MSG{'TRAP'};  }
   #Traps enterprise especific
   else {
      if ( $MSG{'OID'}=~ /.*?enterprises\.([\d+|\.+]+)/) {
         $MSG{'subtype'}=$1.'.'.$MSG{'TRAP'};
      }
      else { $MSG{'subtype'}=$MSG{'OID'}.':'.$MSG{'TRAP'};  }
		if ($MSG{'TRAP'} =~ /^6\.(\S+)/) { $MSG{'subtype_v1'}=$1; }
   }

   #---------------------------------------------------
   # TRAPS V2

#Apr  7 00:41:29 cnm snmptrapd[15798]: DATE>>200947 00:41:29; HOST>>sdch03001.sscc.intranet.local; IPv1>>10.125.16.56; NAMEv1>>sdch03001.sscc.intranet.local; IPv2>>UDP: [10.125.16.56]:1113; NAMEv2>>sdch03001.sscc.intranet.local; OID>>SNMPv2-SMI::enterprises.232; TRAP>>6..22004; DESC>>Enterprise Specific; VDATA>>SNMPv2-MIB::sysName.0 = STRING: SMETXP03|SNMPv2-SMI::enterprises.232.11.2.11.1.0 = INTEGER: 0|SNMPv2-SMI::enterprises.232.22.2.2.1.1.2.1.0 = STRING: "Rack-Blade02"|SNMPv2-SMI::enterprises.232.22.2.2.1.1.3.1.0 = STRING: "805AJTK71T02"|SNMPv2-SMI::enterprises.232.22.2.3.1.1.1.9.1.0 = ""|SNMPv2-SMI::enterprises.232.22.2.3.1.1.1.3.1.0 = ""|SNMPv2-SMI::enterprises.232.22.2.3.1.1.1.7.1.0 = ""|SNMPv2-SMI::enterprises.232.22.2.3.1.1.1.6.1.0 = ""|SNMPv2-SMI::enterprises.232.22.2.3.1.1.1.15.1.0 = INTEGER: 132
#Apr  7 01:03:24 cnm-devel2 snmptrapd[12306]: DATE>>200947 01:03:23; HOST>>0.0.0.0; IPv1>>0.0.0.0; NAMEv1>>0.0.0.0; IPv2>>UDP: [127.0.0.1]:32830; NAMEv2>>cnm-devel2; OID>>.; TRAP>>0.0; DESC>>Cold Start; VDATA>>DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (24781355) 2 days, 20:50:13.55|SNMPv2-MIB::snmpTrapOID.0 = OID: UCD-SNMP-MIB::ucdavis.991.17|SNMPv2-MIB::sysLocation.0 = STRING: TRAP V2

   # En los traps v2 no se incluye el campo IP en la PDU
   if ($MSG{'ip'} eq '0.0.0.0') {

      $MSG{'v'}=2;
      #IPv2>>UDP: [10.125.16.56]:1113
      if ($MSG{'IPv2'} =~ /UDP\:\s*\[(\d+\.\d+\.\d+\.\d+)\]\:\d+/) {  $MSG{'ip'} = $1;  }

      if ($MSG{'NAMEv2'} =~ /UDP\:\s*\[(\d+\.\d+\.\d+\.\d+)\]\:\d+/) {
         $MSG{'full_name'} = $1 ;
         $MSG{'name'} = $1;
      }
      else {
         $MSG{'full_name'} = $MSG{'NAMEv2'} ;
         $MSG{'name'} = $MSG{'NAMEv2'};
      }

#      if ( $MSG{'VDATA'} =~ /SNMPv2-MIB\:\:snmpTrapOID\.0\s*=\s*OID\:\s*(\S+)\|/) {   $MSG{'subtype'}=$1;  }
   }


   #Parsea el varbind data ==> Hash campo valor
	# Si es v2 siempre hay VDATA (por lo menos uptime+oid)
   if (exists $MSG{'VDATA'}) {
      my @vd=split(/\|/,$MSG{'VDATA'});

		# En v2 los dos primeros campos son uptime+oid del trap
		if ($MSG{'v'}==2) {
			my $uptime = shift @vd;
			my $trap_oid = shift @vd;

#$self->log('info',"check_event::[DEBUG] ++++ trap_oid=$trap_oid");
			#SNMPv2-MIB::snmpTrapOID.0 = OID: CISCO-SYSLOG-MIB::clogMessageGenerated
			if ( $trap_oid =~ /SNMPv2-MIB\:\:snmpTrapOID\.0\s*=\s*OID\:\s*(\S+)/) {   $MSG{'subtype'}=$1;  }			
			$self->log('info',"check_event:: subtype=$MSG{'subtype'}  ($trap_oid)");
		}

		$MSG{'msg'} = join ('|', @vd);
      foreach my $v (@vd) {
         if ($v=~ /(\S+)\s*\=\s*(.+)$/) { push @VDATA, {'k'=>$1, 'v'=>$2}; }
      }
      my $txt='check_event::[DEBUG] Global fields='.scalar @data.' VDATA fields='.scalar @vd;
      $self->log('debug',$txt);
   }
   else { $MSG{'VDATA'}=''; }

   #$MSG{'msg'}=$MSG{'VDATA'};
	$MSG{'vardata'} = \@VDATA;

   #---------------------------------------------------
   #  A. PARA TRAPS v1, el valor de subtype es:
   #---------------------------------------------------
   #  1. Para OIDs sin MIB es del tipo: 30861.5.3.6..2
   #  Siendo los valores recibidos
   #     OID>>SNMPv2-SMI::enterprises.30861;
   #     TRAP>>6..22003;
   #  2. Para OIDs con MIB es del tipo: UCD-SNMP-MIB::ucdExperimental.990:6..17
   #  Siendo los valores recibidos
   #     OID>>UCD-SNMP-MIB::ucdExperimental.990;
   #     TRAP>>6..17
   #---------------------------------------------------
   #  B. PARA TRAPS v2, el valor de subtype es:
   #---------------------------------------------------
   #  1. Para los OIDs sin MIB será el valor numerico de:
   #        SNMPv2-MIB::snmpTrapOID.0 = OID: x.x.x.x.x
   #  2. Para OIDs con MIB es del tipo: Para OIDs con MIB es del tipo:
   #     Se extrae del varbind data (en este caso OID y TRAP no tienen valor):
   #        SNMPv2-MIB::snmpTrapOID.0 = OID: UCD-SNMP-MIB::ucdavis.991.17
   #---------------------------------------------------
   my $evkey=$MSG{'subtype'};
	my $event2data=$self->event2data();
   if (exists $event2data->{$evkey}) {
      my $txt_custom = $event2data->{$evkey};
      my @v=split(/\|/,$MSG{'VDATA'});
      for (my $i=1; $i<=scalar @v; $i++) {

         my $j=$i-1;
         $v[$j]=~/.*?[STRING|INTEGER|UNSIGNED|COUNTER32|HEX STRING|DECIMAL STRING|NULLOBJ|OBJID|TIMETICKS|IPADDRESS|BITS]\:\s*(.*)$/;
         my $vdata=$1;
         $txt_custom=~s/\{v$i\}/$vdata/;

         $self->log('debug',"check_event::[DEBUG] ***** I=$i V[j]=$v[$j]");
         $self->log('debug',"check_event::[DEBUG] ***** TXT=$txt_custom");

      }
      $MSG{'msg_custom'}=$txt_custom;
   }
   #else { $MSG{'msg_custom'}=$MSG{'msg'};  }
   else { $MSG{'msg_custom'}='';  }

   #---------------------------------------------------
	# Caso  Hex-STRING
	if ( ($MSG{'msg_custom'} eq '') && ($MSG{'msg'}=~/^(.*?Hex-STRING\:\s*)([\w{2}|\s{1}]+)/)) {
		my ($a,$b)=($1,$2);
		my $msg_conv=$self->hex2ascii($b);
		#$msg_conv =~ s/([[:ascii:]])/$1/g;
		$MSG{'msg_custom'}=$a.$msg_conv;
	}

   my $ip2name=$self->ip2name();
	$MSG{'id_dev'} = (exists $ip2name->{$MSG{'ip'}}->{'id_dev'}) ? $ip2name->{$MSG{'ip'}}->{'id_dev'} : 0;
	$MSG{'critic'} = (exists $ip2name->{$MSG{'ip'}}->{'critic'}) ? $ip2name->{$MSG{'ip'}}->{'critic'} : 50;

   #---------------------------------------------------
   # En traps v1 si no hay nombre, full_name=ip
   # En traps v2 si no hay nombre, full_name=<UNKNOWN>
   if ( ($MSG{'full_name'} =~ /\d+\.\d+\.\d+\.\d+/) || ($MSG{'full_name'} =~ /UNKNOWN/) || ($MSG{'ip'} eq '127.0.0.1') ) {
      if (exists $ip2name->{$MSG{'ip'}}) {
         $MSG{'full_name'} = $ip2name->{$MSG{'ip'}}->{'name'}.'.'.$ip2name->{$MSG{'ip'}}->{'domain'};
         $MSG{'name'} = $ip2name->{$MSG{'ip'}}->{'name'};
         $MSG{'domain'} = $ip2name->{$MSG{'ip'}}->{'domain'};
      }
   }
   # Caso especial. El trap llega con la ip del interfaz del cnm pero esta dado de alta en devices con '127.0.0.1'
   my $cid_ip=$self->cid_ip();
   if (($MSG{'full_name'} eq '.') && ($MSG{'ip'} eq $cid_ip) ) {
      $MSG{'full_name'} = $ip2name->{'127.0.0.1'}->{'name'}.'.'.$ip2name->{'127.0.0.1'}->{'domain'};
      $MSG{'name'} = $ip2name->{'127.0.0.1'}->{'name'};
      $MSG{'domain'} = $ip2name->{'127.0.0.1'}->{'domain'};
   }


   #---------------------------------------------------
	my $banned_file = $self->banned_file();
	my $dev_banned=$self->get_banned_devices($banned_file);
   if (exists $dev_banned->{$MSG{'ip'}}) { 
	   $self->log('info',"check_event::[INFO] **BANNED** fname=$MSG{'full_name'} ip=$MSG{'ip'} proc=$MSG{'proccess'} msg=$MSG{'msg'} subtype=$MSG{'subtype'} msg_custom=$MSG{'msg_custom'}");
		return 0; 
	}

   $self->log('info',"check_event::[INFO] fname=$MSG{'full_name'} ip=$MSG{'ip'} proc=$MSG{'proccess'} msg=$MSG{'msg'} subtype=$MSG{'subtype'} msg_custom=$MSG{'msg_custom'}");

   # Almaceno el evento ---------------------------------------------------------------------
   my $t=time;

   # Miro si el evento no debe almacenarse en BBDD
   my $excluded=$self->eventexcluded();
   my $to_db=1;
   foreach my $ex (@$excluded) {
      if ($MSG{'subtype'} =~ /$ex/) {
         $to_db=0;
         last;
      }
   }

   if ($to_db) {
      my $rv=$store->store_event($dbh, { date=>$t, code=>1, proccess=>$MSG{'proccess'}, msg=>$MSG{'msg'}, ip=>$MSG{'ip'}, name=>$MSG{'name'}, domain=>$MSG{'domain'}, evkey=>$MSG{'subtype'}, msg_custom=>$MSG{'msg_custom'}, id_dev=>$MSG{'id_dev'} });
   }

	$self->event(\%MSG);

   # Incremento el contador de traps recibidos del dispositivo ------------------------------
   my $cfg=$self->cfg();
   my $store_path=$cfg->{'store_path'}->[0];
   my $cnt_path=$store_path.'trap_counter';
   my $file_path=$cnt_path.'/'.$MSG{'ip'};
   if (-e $file_path) { $self->modify_counter($file_path,1); }


   return 1;


#DATE>>2006124 12:51:42;
#HOST>>VPNROTE1.CM.ES;
#IPv1>>192.168.16.200;
#NAMEv1>>VPNROTE1.CM.ES;
#OID>>SNMPv2-MIB::snmp;
#TRAP>>2.0;
#DESC>>Link Down;
#
#VDATA>>IF-MIB::ifIndex = INTEGER: 67657|IF-MIB::ifAdminStatus = INTEGER: down(2)|IF-MIB::ifOperStatus = INTEGER: down(2)|IF-MIB::ifDescr = STRING: BOS(NU)::Type=IPSecLE:213.164.164.9RE:217.149.152.9|IF-MIB::ifType = INTEGER: tunnel(131)|SNMPv2-SMI::enterprises.2505.1.14.2.1 = INTEGER: 10|SNMPv2-SMI::enterprises.2505.1.14.2.2 = INTEGER: 1|SNMPv2-SMI::enterprises.2505.1.14.2.3 = INTEGER: 1|SNMPv2-SMI::enterprises.2505.1.14.2.4 = IpAddress: 213.164.164.9|SNMPv2-SMI::enterprises.2505.1.14.2.5 = STRING: "ONCE"|SNMPv2-SMI::enterprises.2505.1.14.2.6 = IpAddress: 217.149.152.9|SNMPv2-MIB::sysObjectID = OID: SNMPv2-SMI::enterprises.2505.1740|SNMPv2-MIB::sysName = STRING: VPNROTE1


#SNMPv2-SMI::enterprises.2505.1.7 = INTEGER: 1
#SNMPv2-SMI::enterprises.2505.1.4.1 = STRING: "Failed Login Attempt: Username=fml: Date/Time=01/11/2007 01:05:45"
#SNMPv2-SMI::enterprises.2505.1.8 = STRING: "CONTITELSYS"
#SNMPv2-SMI::enterprises.2505.1.9 = STRING: "01/11/2007"
#SNMPv2-SMI::enterprises.2505.1.10 = STRING: "01:05:45"
#SNMPv2-SMI::enterprises.2505.1.11 = Timeticks: (504146131) 58 days, 8:24:21.31



}




#------------------------------------------------------------------------------------------
# event2alert
# Comprueba si el evento recibido por syslog debe generar una alerta.
#------------------------------------------------------------------------------------------
sub check_alert {
my ($self)=@_;

   my $store=$self->store();
   my $dbh=$self->dbh();
	my $event=$self->event();
	my $vardata=$event->{'vardata'};

   my $trap2alert=$self->event2alert();
   my $trap2alert_patterns=$self->event2alert_patterns();
   my $alert2expr=$self->alert2expr();
   my $alert2views=$self->alert2views();

   # Compruebo si el trap recibido tiene mapeo a alerta -----------------------------------
   #OID>>SNMPv2-MIB::snmp;
   #TRAP>>2.0;
   #$ev=SNMPv2-MIB::snmp:2.0
   my $ev=$event->{'subtype'};
	my ($is_mapped,$is_pattern)=(0,0);
	if (exists $trap2alert->{$ev}) { $is_mapped=1; }
	else {
		if (exists $event->{'subtype_v1'}) {
			my $ev1=$event->{'subtype_v1'};
			if (exists $trap2alert->{$ev1}) {
				$is_mapped=1;
				$ev=$ev1;
 				$self->log('debug',"check_alert::[INFO] is_mapped=$is_mapped ev=subtype_v1=$ev1)");
			}
		}
	}

 	$self->log('debug',"check_alert::[INFO] is_mapped=$is_mapped ev=$ev)");

	# ----------------------------------------------------------------------------
	# PATRONES
	# ----------------------------------------------------------------------------
	# trap2alert_patterns contiene los oids con '*' (familia de oids). 
	# Por eso hay que aplicar una regexp y no se utiliza directamente como clave
   foreach my $ev_pattern  (keys %$trap2alert_patterns) {

  		$self->log('debug',"check_alert::[INFO] check pattern $ev <-> $ev_pattern");
      #EV=3401.12.2.1.1.4.1.1.13931.6..1 PATTERN=3401.12.2.1.1.4.1.1.*
      if ($ev =~ /$ev_pattern/) {
         $is_pattern=$ev_pattern;
         last;
      }
   }

	# ----------------------------------------------------------------------------
	# solo debug
	# SE ELIMINA POR SER MUY INTENSIVO EN CPU
	# ----------------------------------------------------------------------------
#	$self->log('debug',"check_alert::[DEBUG] ******* ev=$ev (pattern=$is_pattern)");
#	foreach my $k (sort keys %$trap2alert) {
#		foreach my $evc (@{$trap2alert->{$k}}) {
#			my ($id, $mode, $descr, $target, $action, $sev) = 
#				($evc->{'id_remote_alert'}, $evc->{'mode'},$evc->{'descr'},$evc->{'target'},$evc->{'action'},$evc->{'severity'});
#			$self->log('debug',"check_alert::[DEBUG] trap2alert >> EVKEY=$k : id=$id [$target] $descr ($mode|$action|$sev)");
#		}
#	}
	# ----------------------------------------------------------------------------


#	foreach my $x (sort keys %$trap2alert) {
#		$self->log('debug',"check_alert::[DEBUG] **EVENTO MAPEADO** ev=$x ");
#	}

	
	# Si no coincide con una familia de oids ni con un oid mapeado directamente termino
   #if ( (!$is_pattern) && (! exists $trap2alert->{$ev}) ) { return; }
   if ( (!$is_pattern) && (!$is_mapped) ) { return; }

   $self->log('info',"check_alert::[INFO] DEFINIDA ALERTA PARA ev=$ev (pattern=$is_pattern)");

   if ($is_pattern) { $ev = $is_pattern; }

   # Compruebo si la alerta esta asociada al dispositivo en cuestion ---------------------
   # Campo $MSG{'ip'}

   if ( ref($trap2alert->{$ev}) ne "ARRAY")  {return; }


# 'UCD-SNMP-MIB::ucdExperimental.990:6..17' => [
#                                                {
#                                                 'id_remote_alert' => '15',
#                                                 'script' => '',
#                                                 'target' => '10.2.254.228',
#                                                 'expr' => '',
#                                                 'mode' => 'INC',
#                                                 'action' => 'SET',
#                                                 'monitor' => '',
#                                                 'severity' => '2',
#                                                 'descr' => 'ALERTA TEST V1',
#                                                 'vdata' => ''
#                                                },
#                                                {
#                                                 'id_remote_alert' => '21',
#                                                 'script' => '',
#                                                 'target' => '10.2.254.228',
#                                                 'expr' => 'v1>100',
#                                                 'mode' => 'INC',
#                                                 'action' => 'SET',
#                                                 'monitor' => '',
#                                                 'severity' => '1',
#                                                 'descr' => 'ALERTA TEST V1 (V1>100)',
#                                                 'vdata' => ''
#                                                }
#                                              ],
#
#


   my $ip2name=$self->ip2name();

   foreach my $a (@{$trap2alert->{$ev}}) {

      my $ip_mapped=$a->{'target'};
     	my $id_remote_alert=$a->{'id_remote_alert'};

		#Si es un trap de un dispositivo dado de alta pero no activo => No se genera la alerta
		if ((exists $ip2name->{$ip_mapped}) && ($ip2name->{$ip_mapped}->{'status'} !=0)) {
  			$self->log('debug',"check_alert::[INFO] id_remote_alert=$id_remote_alert ip=$ip_mapped **SALTO DISPOSITIVO NO ACTIVO**");
			next;
		}

  		$self->log('debug',"check_alert::[INFO] id_remote_alert=$id_remote_alert IP recibida=$event->{'ip'} IP asignada=$ip_mapped");
      #Si se trata de otra IP paso al siguiente
      if ( ($ip_mapped ne $event->{'ip'})) { next; }

  		$self->log('debug',"check_alert::[INFO] id_remote_alert=$id_remote_alert IP=$ip_mapped MAPEADA");
      # Compruebo si la alerta tiene una expr asociada para los parametros  -----------------
		my $expr_logic='AND';

print Dumper($alert2expr);

		# Guardo en @event_vals los valores (v1,v2 ...) del evento recibido.
		my @event_vals=();
      foreach my $item (@$vardata) {
         if ($item->{'v'} =~ /^\S+\:\s*(.+)$/) {  push @event_vals, $1; }
         else { push @event_vals, $item->{'v'}; }
      }


      if (exists $alert2expr->{$id_remote_alert}) {

  			$self->log('debug',"check_alert::[INFO] WATCH EVAL START id_remote_alert=$id_remote_alert expr_logic=$expr_logic");

#print Dumper($alert2expr);
#print Dumper($a);
#foreach my $v (@event_vals) { print "v=$v\n"; }


         my $condition=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@event_vals);
  			$self->log('debug',"check_alert::[INFO] WATCH EVAL END id_remote_alert=$id_remote_alert expr_logic=$expr_logic condition=$condition");
         if (! $condition) { next; }
      }

      $self->log('debug',"check_alert::[INFO] IP mapped=$ip_mapped  IPv1=$event->{IPv1} IPv2=$event->{IPv2}");


      my $severity=$a->{'severity'};
      my $cause=$a->{'descr'};
      my $id_metric=$a->{'id_remote_alert'};
      my $ip=$event->{'ip'};
      my $hname=$event->{'name'};
      my $hdomain=$event->{'domain'};
      my $full_name=$event->{'full_name'};
      my $monitor=0;
      my $type='snmp-trap';
      my $mname=$a->{'subtype'};
      my $subtype=$a->{'subtype'};
      #my $msg = ($event->{'msg'}) ? $event->{'msg'} : $event->{'msg_custom'};
      my $msg = '';
      if ((exists $event->{'msg_custom'}) && ($event->{'msg_custom'} ne '')) { $msg = $event->{'msg_custom'}.'|'; }
      #elsif (exists $event->{'msg'}) { $msg = $event->{'msg'}; }
		$msg .= $event->{'msg'};
      my $cfg_mode=$a->{'mode'};
      my $mode=$a->{'id_remote_alert'};
		my $ts=time();
      if ($cfg_mode ne 'INC') { $mode .= '.'.$ts; }


		# CASO ESPECIAL
		# Para traps de CNM-NOTIFICATIONS-MIB, se utiliza el valor de cnmNotifKey como clave en el campo mode
		# Esto permite incrementar la alerta en base a esta clave y no a IP/subtype
		if ($subtype =~ /CNM-NOTIFICATIONS-MIB/) { $mode = $event_vals[2]; }
		# -------------------------------------------------------------------------------

      my $action=$a->{'action'};
      my $vdata=$a->{'vdata'};
		my $cid=$self->cid();
		my $cid_ip=$self->cid_ip();
		my $critic=$event->{'critic'};
		my $id_device=$event->{'id_dev'};

      # Procesado de alertas. SET ---------------------------------------------------------------
      # store_mode: 0->Insert 1->Update
      if ( $action =~ /SET/i ) {
         #my $alert_id=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'cause'=>$cause, 'type'=>$type, 'id_alert_type'=>10, 'id_metric'=>$id_metric, 'mode'=>$mode, 'name'=>$hname, 'domain'=>$hdomain, 'subtype'=>$subtype, 'date_last'=>$ts, 'critic'=>$critic, 'id_device'=>$id_device, 'cid'=>$cid, 'notif'=>0 }, 1);
         my $alert_id=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'cause'=>$cause, 'type'=>$type, 'id_alert_type'=>10, 'id_metric'=>$id_metric, 'mode'=>$mode, 'name'=>$hname, 'domain'=>$hdomain, 'subtype'=>$subtype, 'date_last'=>$ts, 'critic'=>$critic, 'id_device'=>$id_device, 'cid'=>$cid }, 1);

			my $response = $store->response();

			## Se actualizan las tablas del interfaz
			#$store->store_alerts_read_local_set($dbh,$alert_id);
			my $vk=$id_remote_alert.'.'.$ip;
			if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid,$cid_ip);  }

         # Se actualiza notif_alert_set (notificationsd evalua si hay que enviar aviso)
         # a. SET de alerta que no incrementa contador
         # b. SET de alerta que incrementa contador solo la primera vez (insert)
         if (($cfg_mode ne 'INC') || ($response =~ /insert/)){

         	$store->store_notif_alert($dbh, 'set', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>10, 'cause'=>$cause, 'name'=>$hname, 'domain'=>$hdomain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$ts  });
			}

         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_set($dbh,$alert_id);


         $self->log('notice',"check_alert::[INFO] $monitor [SET-ALERT: $alert_id IP=$ip/$full_name id_metric=$id_metric | cfg_mode=$cfg_mode | mode=$mode | EV=$ev | MSG=$msg] response=$response");


      }
	
      # Procesado de alertas. CLEAR -------------------------------------------------------------
      #elsif ( $action =~ /CLR\((\S+)\)/ ) {
      #   $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip/$full_name | EV=$ev | MSG=$msg]");
      #   $store->clear_alert($dbh,{ 'ip'=>$ip, 'mname'=>$1 });
      #}
      # Procesado de alertas. CLEAR -------------------------------------------------------------
		# En este caso vdata contiene el id de la alerta remota que tiene que borrar (id_remote_alert)
		# Este id se almacena en alerts en el campo id_metric
      #elsif ( ($action =~ /CLR/) && ($vdata=~ /id=(\d+)/) ) {
      elsif ($action =~ /CLR/) {
			my ($match_set_clear,$id_metric)=(1,0);
			# Se borra la original a partir del set_id.  Si no existe set_id, lo busco a partir de subtype + hiid
			if (($a->{'set_id'} =~ /^\d+$/) && ($a->{'set_id'}>0)) { $id_metric=$a->{'set_id'}; }
			elsif ($a->{'set_subtype'} ne '') { 
				my $cond = 'subtype="'.$a->{'set_subtype'}.'" && hiid="'.$a->{'set_hiid'}.'"';
            my $rv=$store->get_from_db($dbh,'id_remote_alert','cfg_remote_alerts',$cond);
            $id_metric=$rv->[0][0];
			}

			# fml Esperar a que este bien la BBDD
			# Si vdata tiene valor, habria que ver que matchea el campo especificado en vdata del set y del clear para poder borrar la alerta
			# vdata contiene los valores que deben coincidir en set/clr separados por comas
			# v1,v2....
			#if ($vdata ne '') {
			if ($vdata eq 'v1') {

				$match_set_clear = 0;
		   	my $rv=$store->get_from_db($dbh,'event_data','alerts',"id_metric=$id_metric");
				my $event_data=$rv->[0][0];
				if ((defined $event_data) && ($event_data ne '')) {
					#RFC1213-MIB::ifIndex = INTEGER: 22|RFC1213-MIB::ifAdminStatus = INTEGER: 0|RFC1213-MIB::ifOperStatus = INTEGER: 0
					my @set_vals_raw=split(/\|/,$event_data);
			      my %set_vals=();
					my $n=1;
					$self->log('debug',"check_alert::[INFO] match_set_clear >> id_metric=$id_metric event_data=$event_data");
		      	foreach my $v (@set_vals_raw) {
					$self->log('debug',"check_alert::[INFO] match_set_clear >> n=$n v=$v");
	      		   if ($v=~ /^(\S+)\s*\=\s*\S+\:\s*(.+)$/) { 
							my $k='v'.$n;
							$set_vals{$k}= $2; 
						}
						$n +=1;
      			}

					my @match_vals=split(',', $vdata);
					my $nok=0;
					foreach my $vm (@match_vals) {
						my $index = substr $vm,1;
						if ($set_vals{$vm} ne $event_vals[$index-1]) { $nok=1 };
$self->log('info',"check_alert::[INFO] match_set_clear >> vm=$vm COMPARO $set_vals{$vm} CON $event_vals[$index-1] (nok=$nok)");

					}
					if (!$nok) { $match_set_clear = 1; }
				}
			}

			if ($match_set_clear) {	
   	      my $alert_id=$store->clear_alert($dbh,{ 'ip'=>$ip, 'id_metric'=>$id_metric });
	         $self->log('info',"check_alert::[INFO] [$alert_id] [CLEAR-ALERT: IP=$ip/$full_name id_metric=$id_metric| EV=$ev | MSG=$msg]");

	         #Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
   	      $store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>10, 'cause'=>$cause, 'name'=>$hname, 'domain'=>$hdomain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$ts  });


      	   # Se actualizan las tablas del interfaz
         	$store->store_alerts_read_local_clr($dbh,$alert_id);
         	my $vk=$id_remote_alert.'.'.$ip;
         	if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }
			}
			else { $self->log('info',"check_alert::[INFO] $monitor [NO-CLEAR-ALERT: IP=$ip/$full_name id_metric=$id_metric| EV=$ev | MSG=$msg]"); }
      }

      else {
         $self->log('warning',"check_alert::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip/$full_name | EV=$ev | MSG=$msg]");
      }

   }


}



#------------------------------------------------------------------------------------------
# trap2engine
# Procesa los traps recibidos
#------------------------------------------------------------------------------------------
sub trap2engine {
my ($self)=@_;

	my $event=$self->event();
	my $vardata=$event->{'vardata'};

   #OID>>SNMPv2-MIB::snmp;
   #TRAP>>2.0;
   #$ev=SNMPv2-MIB::snmp:2.0
   my $ev=$event->{'subtype'};

   # HOOKS
   if (exists $TRAP2HOOK{$ev}) {
      my $sep1=';;;';
      my $msg="$event->{'DATE'} $sep1 $event->{'ip'} $sep1 $event->{'v'} $sep1 $ev $sep1 ";
      my @vals=();
      foreach my $item (@$vardata) {
         #INTEGER: 312:::INTEGER: 3
         $item->{'v'} =~ s/^.*?\:\s*(.*)$/$1/;
         push @vals, $item->{'v'};
      }
      $msg .= join (':::', @vals);
      my $k=md5_hex($msg);
      my $fname='/tmp/traph_'.time().'-'.$k;
      #my $fname='/tmp/traph_'.time();
      open (F, ">$fname");
      print F "$msg\n";
      close F;
      system ("$TRAP2HOOK{$ev} $fname");
   }
}

#------------------------------------------------------------------------------
sub hex2ascii {
my ($self,$data)=@_;

   if ($data !~ /(\w{2}\s{1}){8}/) { return $data;}
   $data =~ s/\"//g;
   $data =~ s/^\s+//g;
   my @l=split(/\s+/,$data);
   #El ultimo valor suele estar mal sen w2k
   pop @l;
   my $newdata=pack("C*",map(hex,@l));
   return $newdata;

}


1;
__END__
