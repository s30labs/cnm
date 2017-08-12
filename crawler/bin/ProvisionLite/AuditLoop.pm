#----------------------------------------------------------------------------
use ProvisionLite;
package ProvisionLite::AuditLoop;
@ISA=qw(ProvisionLite);
$VERSION='1.00';
use strict;
use JSON;
use Data::Dumper;
use POSIX ":sys_wait_h";
use Stdout;
use Nmap::Parser;

#------------------------------------------------------------------------
$SIG{INT} = \&catch_int;
sub catch_int {
   die;
}

#------------------------------------------------------------------------
#$SIG{CHLD} = \&REAPER;
#sub REAPER {
#    my $stiff;
#    while (($stiff = waitpid(-1, &WNOHANG)) > 0) {
#        # do something with $stiff if you want
#    }
#    $SIG{CHLD} = \&REAPER;                  # install *after* calling waitpid
#}
#------------------------------------------------------------------------
my $MAX_CONCURRENT_TASKS=8;
my $RUNNING_TASK_TIMEOUT=300;
my @DATA=();
my %TASKS=();
my %options = (
	create    => 'yes',
   exclusive => 0,
   mode      => 0644,
   destroy   => 'yes',
);


#------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::SNMP
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   BEGIN {  $ENV{'MIBS'}='ALL'; }

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   return $self;

}

#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else { return $self->{_cfg}; }
}



#-------------------------------------------------------------------------------------------
# audit_general_loop
#-------------------------------------------------------------------------------------------
sub audit_general_loop {
my ($self,$range_ip)=@_;

	my $MAX_CHUNK_SIZE=300;
   @DATA=();
	$SIG{CHLD} = 'IGNORE';

   my @COL_KEYS = (
      { 'width'=>'10' , 'name_col'=>'name',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'ip',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'5' , 'name_col'=>'ping',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'10' , 'name_col'=>'tcp',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'community',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'5' , 'name_col'=>'version',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'20' , 'name_col'=>'sysoid',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'sysname',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'20' , 'name_col'=>'sysloc',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'30' , 'name_col'=>'sysdesc',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'30' , 'name_col'=>'mac',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
   );


   my %COL_MAP=('name'=>'NOMBRE', 'ip'=>'IP', 'ping'=>'PING', 'tcp'=>'TCP-PORTS', 'community'=>'COMMUNITY', 'version'=>'VERSION', 'sysoid'=>'SYSOID', 'sysname'=>'SYSNAME', 'sysloc'=>'SYSLOC', 'sysdesc'=>'SYSDESC', 'mac'=>'MAC' );


	my $tag=$self->tag();
	my $serial_file='/tmp/'.$tag;
	if (-f $serial_file) { unlink $serial_file; }

	$self->log('info',"audit_general_loop:: [$tag] rangos=@$range_ip");
   my $IPS = $self->validate_range($range_ip);
	$self->log('info',"audit_general_loop:: [$tag] rangos=@$range_ip IPS=@$IPS");

   #----
   #my $CHECKED_IPS=$self->check_range($IPS);
	my @INTERESTING_IPS=();
   my $checked=$self->check_range($IPS);
   foreach my $k (keys %$checked) {
		if ((! $checked->{$k}->{'icmp'}) && (!$checked->{$k}->{'snmp'}) && (!$checked->{$k}->{'tcp'})) {
			$self->audit_general_host($k,$serial_file,0,0,0);
		}
		else { push @INTERESTING_IPS, $k; }
	}
   #----


	my $TOTAL_RANGE_ALL = scalar(@$IPS);
	my $TOTAL_RANGE = scalar(@INTERESTING_IPS);
	$self->log('info',"audit_general_loop:: [$tag] rangos=@$range_ip TOTAL IPS=$TOTAL_RANGE_ALL INTERESTING_IPS=$TOTAL_RANGE");
	my $start_chunk_index=0;
	my $range_counter=$TOTAL_RANGE;
	my $global_counter=0;

	while ($range_counter>0) {

	   # Se compone %TASKS a partir de @$IPS
   	%TASKS=();
		my $c=0;
   	foreach my $i ($start_chunk_index..$TOTAL_RANGE-1) {
			#my $ip=$IPS->[$i];
			my $ip=$INTERESTING_IPS[$i];
	      $ip=~s/(\d+\.\d+\.\d+\.\d+)\/32/$1/;
   	   $TASKS{$ip}=0;
			$c+=1;
			if ($c > $MAX_CHUNK_SIZE) { last;  }
   	}
		$start_chunk_index += $MAX_CHUNK_SIZE;
		$range_counter -= $MAX_CHUNK_SIZE;

	   my $TOTAL_TASKS = scalar (keys %TASKS);
	   #my $TOTAL_TASKS = $c;

    	$self->log('info',"audit_general_loop:: [$tag] START CHUNK TOTAL_TASKS=$TOTAL_TASKS TOTAL_RANGE=$TOTAL_RANGE range_counter=$range_counter start_chunk_index=$start_chunk_index");


		my %RUNNING=();
		
   	while (1) {


			my $tnow=time;
			foreach my $key (keys %RUNNING) {
				my $pid=$RUNNING{$key}->{'pid'};
				my $exists = kill 0, $pid;
				if (! $exists) { $TASKS{$key} = 2; }
				else {
					if (($tnow - $RUNNING{$key}->{'time'}) > $RUNNING_TASK_TIMEOUT) {
						$self->log('info',"audit_general_loop:: [$tag] pid=$pid SUPERA UMBRAL DE TIEMPO");
						kill 9, $pid;
					}
				
				}
			}


      	#print Dumper(\%TASKS);
	      #------------------------------------
   	   my ($ready,$working,$end)=(0,0,0);
      	foreach my $key (keys %TASKS) {
				if ($TASKS{$key} !~ /^\d+$/) { next; }
				if ($TASKS{$key} == 0) { $ready+=1; }
				elsif ($TASKS{$key} == 1) {$working+=1;}
				elsif ($TASKS{$key} == 2) { 
					$end += 1;
					delete $RUNNING{$key};
				}
      	}

	      if ($end == $TOTAL_TASKS) { last; }
   	   #------------------------------------
			my $tasks_to_launch = $ready;
			if ($ready > $MAX_CONCURRENT_TASKS-$working) { $tasks_to_launch = $MAX_CONCURRENT_TASKS-$working; }

   	   $self->log('info',"audit_general_loop:: [$tag] LOOPING ready=$ready working=$working end=$end available=$tasks_to_launch");
	
      	if (! $tasks_to_launch) {
				sleep 1;
				next;
			}
	
	      foreach my $key (sort keys %TASKS) {

				# El vector %TASKS puede tener valores antiguos con resultados previos del tipo:
				# '-,10.3.254.120,NO,,-,0,-,-,-,-'
   	      #if ($TASKS{$key} !~ /^\d+$/) { next;}
      	   #if ($TASKS{$key} != 0) { next;}


      	   if ($TASKS{$key} != 0) { next;}

         	if ($tasks_to_launch <=0) {last; }

				$global_counter +=1;
$self->log('info',"audit_general_loop:: [$tag] EN CURSO key=$key c=$global_counter start_chunk_index=$start_chunk_index TOTAL=$TOTAL_RANGE (rangos=@$range_ip)");
	         $TASKS{$key} = 1;
   	      my $child = fork();
      	   if ($child == 0) {

					my ($is_icmp,$is_snmp,$is_tcp) = ($checked->{$key}->{'icmp'}, $checked->{$key}->{'snmp'}, $checked->{$key}->{'tcp'}); 
         	   $self->audit_general_host($key,$serial_file,$is_icmp,$is_snmp,$is_tcp);
					my $istore=$self->istore();
					my $dbh=$self->dbh();
$self->log('info',"audit_general_loop:: [$tag] ****FML***** VOY A CERRAR DB $dbh");
					$istore->close_db($dbh);	
            	exit;
         	}
				my $t=time;
				$RUNNING{$key} = { 'pid' => $child, 'time' => $t } ;
	         $tasks_to_launch-=1;
   	   }
   	}
   }

   open (R,"<$serial_file");
   my @sdata=<R>;
   close R;
	chomp @sdata;
	my $json = '['.join(',', @sdata).']';
	my $rc = unlink $serial_file;

   $self->log('info',"audit_general_loop:: [$tag] json=$json rc=$rc");

	return $json;

}

#-------------------------------------------------------------------------------------------
# check_range
#-------------------------------------------------------------------------------------------
sub check_range {
my ($self,$range)=@_;

	my %new_range=();
	my $np = new Nmap::Parser;
$self->log('info',"audit_general_loop:: check_range START");

	foreach my $ip (@$range) {
		$ip=~s/(\d+\.\d+\.\d+\.\d+)\/32/$1/;
		$new_range{$ip} = { 'icmp'=>0, 'tcp'=>0, 'snmp'=>0 };
	}

	$np->parsescan('/usr/bin/nmap','-sU -p161',@$range);

	for my $host ($np->all_hosts()) {
      my $ip=$host->addr();
$self->log('info',"audit_general_loop:: check_range snmp ip=$ip");
		$new_range{$ip}->{'snmp'}=1;
	}

	$np->parsescan('/usr/bin/nmap','-sP',@$range);
	for my $host ($np->all_hosts()) {
		if ($host->status() eq 'up') { 
	      my $ip=$host->addr();
$self->log('info',"audit_general_loop:: check_range icmp ip=$ip");
   	   $new_range{$ip}->{'icmp'}=1;
		}
	}

	$np->parsescan('/usr/bin/nmap','-sS -p22,25,53,80,111,113,139,389,443,445',@$range);
	for my $host ($np->all_hosts()) {
		my $ip=$host->addr();
$self->log('info',"audit_general_loop:: check_range tcp ip=$ip");
      $new_range{$ip}->{'tcp'}=1;
   }

	return \%new_range;
}


#-------------------------------------------------------------------------------------------
# audit_general_host
# Para un host concreto:
# a. Obtiene nombre dns
# b. Valida si responde por icmp
# c. Valida puertos tcp
# d. Valida snmp
#-------------------------------------------------------------------------------------------
sub audit_general_host {
my ($self,$host_ip,$serial_file,$is_icmp,$is_snmp,$is_tcp)=@_;

	my $tag=$self->tag();
   $self->log('debug',"audit_general_host::[DEBUG] [$tag] START IP=$host_ip");

   my $SNMP_VERSION=0;
   my $F;
#   my ($dnsname,$sysname,$ping,$uptime,$community,$oid,$sysoid,$snmp_data,$rc,$rcstr,$res,$sysloc,$sysdesc,$mac) =
#      ('-'    ,'-'     ,'NO' ,0      ,'-'        ,''  ,'-'     ,'',     ,'0', 'OK',  '' , '-',  '-', '-');

   my %host_data=( 'name'=>'', 'ip'=>'', 'ping'=>'NO', 'tcp'=>'', 'community'=>'', 'version'=>0, 'sysoid'=>'-', 'sysname'=>'-', 'sysloc'=>'-', 'sysdesc'=>'-', 'mac'=>'-' );

	$host_data{'ip'}=$host_ip;
	$host_data{'name'}=$self->get_dns_name($host_ip);


	# ----------------------
	if ($is_icmp) {
		$self->log('debug',"audit_general_host::[DEBUG] [$tag] IP=$host_ip voy a hacer ping");
   	my $ping_ok=$self->check_icmp_base($host_ip);
		if ($ping_ok) { $host_data{'ping'} = 'SI'; }
	}

	# ----------------------
	my $PORTS_TCP=[];
   my $tcp_ports=join(' ',@$PORTS_TCP);
   #if ( (scalar(@$PORTS_TCP)==0) && (! $ping_ok)){
	if ($is_tcp) { 
		$self->log('debug',"audit_general_host::[DEBUG] [$tag] IP=$host_ip voy a hacer scan tcp");
   	$PORTS_TCP=$self->check_tcp_ports_base($host_ip, {'name'=>$host_data{'name'}, 'ip'=>$host_ip});
   	$tcp_ports=join(' ',@$PORTS_TCP);
		$self->log('debug',"audit_general_host::[DEBUG] [$tag] IP=$host_ip hecho scan tcp ($tcp_ports)");
  	}
	$host_data{'tcp'}=$tcp_ports;

#   my $PORTS_UDP=$self->check_udp_ports($host_ip,{'name'=>$host_data{'name'}, 'ip'=>$host_ip});
#$self->log('debug',"audit_general_host::[DEBUG] IP=$host_ip hecho scan udp");


	# ----------------------
	if ($is_snmp) {
	   my $snmp=$self->snmp();
		
   	#---------------------------------------------------
   	$host_data{'version'}=1;
   	foreach my $c (@ProvisionLite::default_snmp_communties) {
      	my %snmp_info=();
	      #$oSNMP->timeout(1000000);
   	   #$self->log('info',"audit_general:: IP=$ip *******>C=$c ---> V=$SNMP_VERSION");

      	$snmp_info{'host_ip'} = $host_ip;
	      $snmp_info{'community'} = $c;
   	   $snmp_info{'version'} = $host_data{'version'};

      	#sysDescr_sysObjectID_sysName_sysLocation
	      my ($rc, $rcstr, $res)=$snmp->verify_snmp_data(\%snmp_info);

$self->log('debug',"audit_general_host::[DEBUG] [$tag] check snmp IP=$host_ip C=$c V=$SNMP_VERSION RES=($rc, $rcstr, $res)");
   	   if ($rc==0) {
      	   foreach my $l (@$res) {
         	   my @rd=split(':@:', $l);
            	$host_data{'sysdesc'} = $rd[1];
	            $host_data{'sysoid'} = $rd[2];
   	         $host_data{'sysname'} =$rd[3];
      	      $host_data{'sysloc'} = $rd[4];
         	}
				$host_data{'community'}=$c;

				($host_data{'mac'},$host_data{'mac_vendor'}) = $snmp->snmp_get_mac(\%snmp_info, $host_ip);
      	   last;
      	}
	      elsif ($rc==2) { $host_data{'sysname'} ='U'; }
   	   else { $host_data{'sysname'} = '-'; }
   	}

	}

my $aux=Dumper(\%host_data);
$aux=~s/\n/ /g;
$self->log('info',"audit_general_host::[DEBUG] [$tag] **HOST DATA** ip=$host_ip file=$serial_file (icmp,snmp,tcp=$is_icmp,$is_snmp,$is_tcp) $aux");

   open ($F,">>$serial_file");
	$self->lock($F);
   print $F encode_json(\%host_data). "\n";
	$self->unlock($F);
   close $F;

}


1;
