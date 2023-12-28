#-------------------------------------------------------------------------------------------
# File: CNMScripts/WMIc.pm
# Description: WMI client based on wmiquery.py
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::WMIc;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Data::Dumper;

=pod

=head1 NAME

CNMScripts::WMI - Modulo derivado de CNMScripts que contiene soporte para acceder por WMI a un equipo remoto.

=head1 SYNOPSIS

 use CNMScripts::WMI;
 my $wmi = CNMScripts::WMI->new();

 $wmi->host_status($ip,10);
 $wmi->get_wmi_counters("'SELECT * FROM Win32_ComputerSystem'");
 $wmi->print_counter_value($counters, '001', 'NumberOfProcessors');

 my $ok=$wmi->check_tcp_port($ip,'135',5);
 if (! $ok) { $wmi->host_status($ip,10);}
 $counters = $wmi->get_wmi_counters("'SELECT * FROM Win32_Service'", $property_index);
 $wmi->print_counter_value($counters, '200', 'State', \%STATE_TABLE);

=head1 DESCRIPTION

Modulo para simplificar el desarrollo de scripts en perl para CNM.

=cut

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::WMIc
# If using docker, the command is:
# docker run -v /opt/cnm-local/impacket:/usr/scripts --rm --name testkkk -it impacket:debian-11.3-slim /usr/scripts/wmiquery.py -namespace 'root\CIMV2' -rpc-auth-level integrity -file /usr/scripts/Win32_TerminalService.wsql 'domain/user:pwd@192.168.117.216'
# If not:
# /usr/scripts/wmiquery.py -namespace 'root\CIMV2' -rpc-auth-level integrity -file /usr/scripts/Win32_TerminalService.wsql 'domain/user:pwd@192.168.117.216'
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
	#my $working_dir = '/usr/scripts';
	my $working_dir = '/opt/containers/impacket';
	my $docker_image = 'impacket:debian-11.3-slim';
   #$self->{_cmd} = $arg{cmd} || "docker run -v /opt/containers/impacket:$working_dir --rm --name __CONTAINER_NAME__ -t $docker_image $working_dir/wmiquery.py -rpc-auth-level integrity ";
	$self->{_cmd} = $arg{cmd} || "/usr/local/bin/wmiquery.py -rpc-auth-level integrity ";
	$self->{_working_dir} = $working_dir;
   $self->{_host} = $arg{host} || '';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_domain} = $arg{domain} || '';
   $self->{_namespace} = $arg{namespace} || 'root\CIMV2';
   $self->{_credentials} = $arg{credentials} || '';
   $self->{_host_status} = $arg{host_status} || {};
   $self->{_container} = $arg{container} || '';

	$self->set_credentials();
   return $self;
}

#----------------------------------------------------------------------------
# cmd
#----------------------------------------------------------------------------
sub cmd {
my ($self,$cmd) = @_;
   if (defined $cmd) {
      $self->{_cmd}=$cmd;
   }
   else { return $self->{_cmd}; }
}

#----------------------------------------------------------------------------
# working_dir
#----------------------------------------------------------------------------
sub working_dir {
my ($self,$working_dir) = @_;
   if (defined $working_dir) {
      $self->{_working_dir}=$working_dir;
   }
   else { return $self->{_working_dir}; }
}


#----------------------------------------------------------------------------
# host
#----------------------------------------------------------------------------
sub host {
my ($self,$host) = @_;
   if (defined $host) {
      $self->{_host}=$host;
   }
   else { return $self->{_host}; }
}

#----------------------------------------------------------------------------
# user
#----------------------------------------------------------------------------
sub user {
my ($self,$user) = @_;
   if (defined $user) {
      $self->{_user}=$user;
   }
   else { return $self->{_user}; }
}

#----------------------------------------------------------------------------
# pwd
#----------------------------------------------------------------------------
sub pwd {
my ($self,$pwd) = @_;
   if (defined $pwd) {
      $self->{_pwd}=$pwd;
   }
   else { return $self->{_pwd}; }
}

#----------------------------------------------------------------------------
# domain
#----------------------------------------------------------------------------
sub domain {
my ($self,$domain) = @_;
   if (defined $domain) {
      $self->{_domain}=$domain;
   }
   else { return $self->{_domain}; }
}

#----------------------------------------------------------------------------
# namespace
#----------------------------------------------------------------------------
sub namespace {
my ($self,$namespace) = @_;
   if (defined $namespace) {
      $self->{_namespace}=$namespace;
   }
   else { return $self->{_namespace}; }
}

#----------------------------------------------------------------------------
# credentials
#----------------------------------------------------------------------------
sub credentials {
my ($self,$credentials) = @_;
   if (defined $credentials) {
      $self->{_credentials}=$credentials;
   }
   else { return $self->{_credentials}; }
}

#----------------------------------------------------------------------------
# container
#----------------------------------------------------------------------------
sub container {
my ($self,$container) = @_;
   if (defined $container) {
      $self->{_container}=$container;
   }
   else { return $self->{_container}; }
}


=head1 METHODS

=over 1

=item B<$wmi-E<gt>host_status($host,$status)>

 Almacena en el objeto (propiedad host_status) el estado de la conexión al host.
 $status = 0 => ok
 $status != 0 => nok

=cut

#----------------------------------------------------------------------------
# host_status
#----------------------------------------------------------------------------
sub host_status {
my ($self,$host,$status) = @_;
   if (defined $host) {
		if (defined $status) {
      	$self->{_host_status}->{$host}=$status;
		}
		else { 
			if (exists $self->{_host_status}->{$host}) {
				return $self->{_host_status}->{$host}; 
			}
			else { return 0; }
		}
   }
   else { return $self->{_host_status}; }
}

#----------------------------------------------------------------------------
# set_credentials
#----------------------------------------------------------------------------
sub set_credentials {
my ($self) = @_;

	my $u = $self->user();
	my $p = $self->pwd();
	my $d = $self->domain();
	#my $c = $u.'%'.$p;
	#if ($d ne '') { $c = "$d\\$u%$p"; }

	my $c = $u.':'.$p;
	if ($d ne '') { $c = "$d\/$u:$p"; }

	$self->{_credentials}=$c;
	return $c;
}


#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip)=@_;

my $REMOTE_PORT='135';
my $TIMEOUT=3;

	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str('WMI_REMOTE_TIMEOUT');
      $self->err_num(1);
	}
	return ($rc,$lapse);
}

#----------------------------------------------------------------------------
# check_remote
#----------------------------------------------------------------------------
sub check_remote {
my ($self,$ip)=@_;

	my $container_dir_in_host = '/opt/containers/impacket';
	my $wsql_file = 'check_Win32_OperatingSystem.wsql';
	my $wsql_file_path = join ('/', $container_dir_in_host, $wsql_file);
	if (! -f $wsql_file_path) {
   	open (F,">$wsql_file_path");
   	print F "SELECT Version FROM Win32_OperatingSystem\n";
   	close F;
	}

	#my $wsql="'SELECT Version from Win32_OperatingSystem'";
	my $lines = $self->get_raw_data($wsql_file);

	my $rc=1;
	my $err_num=$self->err_num();
	my $err_str=$self->err_str();
	if ($err_num) {
		$self->log('info',"check_remote >> **ERROR** [$err_num] >> $err_str");
		$rc=0;
	}
	else { $self->log('info',"check_remote >> OK RES = $lines->[4]"); }

   return $rc;
}


#----------------------------------------------------------------------------
# get_cmd_data
# winexe --user=s30%s30 //10.2.254.72 "w32tm /query /status"
#----------------------------------------------------------------------------
sub get_cmd_data {
my ($self,$cmd)=@_;

   $|=1;
   my @lines = ();
   my $cmd_base='/usr/bin/winexe';
   my $host = $self->host();
   my $status = $self->host_status($host);

   if ($status > 0) {
      $self->log('info',"SALTO HOST $host status=$status cmd=$cmd");
      return;
   }

   my ($rc,$stdout,$stderr)=(0,'','');
   $self->err_str('[OK]');
   $self->err_num(0);

   my $cmdc = $cmd_base.' --user \''.$self->credentials().'\' //'.$self->host().' '.$cmd;
   $self->log('info',"get_cmd_data >> $cmdc");

   capture sub { $rc=system($cmdc); } => \$stdout, \$stderr;

   @lines = split (/\n/, $stdout);

   if ($stderr ne '') {

      # Para evitar salidas espureas
      @lines = ();
      $stderr=~s/\n/ /g;
      $self->err_str($stderr);
      $self->err_num(10);
      $self->log('error',"get_cmd_data >> **ERROR** stderr=$stderr (cmdc=$cmdc)");
   }

   $self->host_status($host,$self->err_num());

   return \@lines;

}


#----------------------------------------------------------------------------
# get_raw_data
# /usr/bin/wmic --delimiter='&|&'  -U s30%s30 //10.2.254.71  "SELECT Version from Win32_OperatingSystem"
#----------------------------------------------------------------------------
sub get_raw_data {
my ($self,$wsql_file)=@_;

	$|=1;
	my @lines = ();
	my $host = $self->host();
	my $status = $self->host_status($host);

	if ($status > 0) { 
		$self->log('info',"SALTO HOST $host status=$status wsql_file=$wsql_file");
		return; 
	}
	

	my ($rc,$stdout,$stderr)=(0,'','');
	$self->err_str('[OK]');
	$self->err_num(0);

	my $cmd = $self->cmd();

	my $n1 = $self->host();
	my $n2 = $wsql_file;
	$n1 =~ s/\.//g;
	$n2 =~ s/(.+?)\.\w+$/$1/g;
	my $name = join('-',$n1,$n2,int(100000*rand())); 
	#$cmd =~ s/__CONTAINER_NAME__/$name/;

   my $container_name=$self->container();
   if ($container_name eq '') { 
	   my $n1 = $self->host();
   	my $n2 = $wsql_file;
   	$n1 =~ s/\.//g;
   	$n2 =~ s/(.+?)\.\w+$/$1/g;
   	$container_name = join('-',$n1,$n2,int(100000*rand()));
	}
	$cmd =~ s/__CONTAINER_NAME__/$container_name/;


	my $wsql_file_path = $self->working_dir().'/'.$wsql_file;
	
   my $wmic = $cmd.' -namespace \''.$self->namespace().'\' -file '.$wsql_file_path.' \''.$self->credentials().'@'.$self->host().'\'';

   #$self->wait_for_docker();
   #$self->log('info',"DOCKERRUN >> impacket/wmiquery");

	$self->log('info',"get_raw_data >> wmic=$wmic");

   capture sub { $rc=system($wmic); } => \$stdout, \$stderr;

   @lines = split (/\n/, $stdout);

$stdout=~s/\n/ /g;
$stdout=~s/\r/ /g;
my $stdout300 = substr $stdout,0,300;
$self->log('info',"get_raw_data >> stdout=$stdout300");

	if ($lines[2] =~ /^\[-\]\s+(.+)$/) {
		my $err_msg = $1;
		$self->err_str($err_msg);
		if ($err_msg =~ /timed out/) { $self->err_num(1); }
		elsif ($err_msg =~ /rpc_s_access_denied/) { $self->err_num(2); }
		elsif ($err_msg =~ /WMI Session Error/) { $self->err_num(3); }
		else { $self->err_num(4); }
		$self->log('error',"get_raw_data >> **ERROR** $err_msg");
	}

	$self->host_status($host,$self->err_num());

	return \@lines;
}

=item B<$wmi-E<gt>get_wmi_counters($wsql,$iid)>

 Obtiene los contadores WMI a partir de ua consulta WSQL.
 $wsql contiene la consulta.
 $iid es opcional.
 Devuelve una referencia a un array con los valores obtenidos.
=cut

#----------------------------------------------------------------------------
# get_wmi_counters
#----------------------------------------------------------------------------
sub get_wmi_counters {
my ($self,$wsql_file,$iid)=@_;

	my $lines = $self->get_raw_data($wsql_file);

	if ($self->err_num() != 0) {
	   if (! $iid) { return []; }
		else { return {};}
   }

	my @k=();	
   my @data=();
	my $more_lines = 1;
	# Skip two first lines (blank and caption)	
   shift @$lines;
   shift @$lines;
	my $newdata=0;
	while ($more_lines) {
		
		# Skips query
		my $wql=substr $lines->[0],0,4;
		if ((defined $wql) && ($wql eq 'WQL>')) {
		#if ($lines->[0] =~ /^WQL\>/) { 
			$self->log('debug',"get_wmi_counters >> START BLOQUE ELIMINO WSQL $lines->[0]");
			shift @$lines; 
		}

		# Parse header
		@k=();
		if (scalar @$lines > 0) {
			$lines->[0] =~ s/\r/ /g;
			$lines->[0] =~ s/\n/ /g;
	   	chomp $lines->[0];
			$lines->[0] =~ s/^\s*\|\s+//;
			$lines->[0] =~ s/\s+\|\s+$//;

			$self->log('debug',"get_wmi_counters >> PROCESO HEADER  $lines->[0]");
	   	@k = split /\s+\|\s+/, $lines->[0];
		   shift @$lines;
		}
		else { $more_lines=0; }

		# Parse data
		$newdata=0;
	   foreach my $l (@$lines) {
			if ($l =~ /^WQL\>/) { 
				$self->log('debug',"get_wmi_counters >> DETECTO NUEVO WSQL $l");
				last; 
			}

			$self->log('debug',"get_wmi_counters >> PROCESO DATOS  $l");
   	   $l =~ s/\r/ /g;
      	$l =~ s/\n/ /g;
   	   chomp $l;
			$l =~ s/^\s*\|\s+//;
			$l =~ s/\s+\|\s+$//;
   	   my %h=();
      	my @v = split /\s+\|\s+/, $l;
	      my $i=0;
   	   foreach my $x (@v) {
      	   chomp $x;
				if (exists $k[$i]) { $h{$k[$i]} = $x; }
				else {
					$self->log('error',"get_wmi_counters >> **ERROR** l=$l i=$i k=@k");
				}
         	$i+=1;
      	}
      	push @data,{%h};
			$newdata+=1;
   	}
		while ($newdata > 0) {
			shift @$lines;
			$newdata-=1;
		}

	}

   if (! $iid) {
      return \@data;
   }

   #Tiene instancias
   my %data=();
   foreach my $l (@data) {
      if (exists $l->{$iid}) { $data{$l->{$iid}}=$l; }
   }
   return \%data;
}

=item B<$wmi-E<gt>print_counter_value($values, $id, $tag, $map_table)>
 
 $wmi->print_counter_value($counters, '200', 'AlignmentFixupsPersec');
 $values es la referencia al array con los contadores obtenidos con get_wmi_counters.
 $id es el tag de la métrica.
 $map_table 

=cut

#--------------------------------------------------------------------------------------
sub print_counter_value {
my ($self,$values, $id, $tag, $map_table) = @_;

	my %rval=();
   if (ref($values) eq "ARRAY") {
      if (exists $values->[0]->{$tag}) {
			my $val = $values->[0]->{$tag};
			if ((defined $map_table) && (ref($map_table) eq "HASH") ) {
				if (exists $map_table->{$values->[0]->{$tag}}) { 
					$val = $map_table->{$values->[0]->{$tag}}; 
				}
			}
         print "<$id> $tag = ".$val ."\n";
			$rval{'ALL'}=$val;
      }
      else {
         print "<$id> $tag = U\n";
			$rval{'ALL'}='U';
      }
   }
   elsif (ref($values) eq "HASH") {
      foreach my $iid (sort keys %$values) {
         if (exists $values->{$iid}->{$tag}) {
				my $val = $values->{$iid}->{$tag};
		      if ((defined $map_table) && (ref($map_table) eq "HASH") ) {
   	         if (exists $map_table->{$values->{$iid}->{$tag}}) {
						$val = $map_table->{$values->{$iid}->{$tag}};
					}
	         }
            print "<$id.$iid> $tag = ".$val ."\n";
				$rval{$iid}=$val;
         }
         else {
            print "<$id.$iid> $tag = U\n";
				$rval{$iid}='U';
         }
      }
   }
   else {
      print "<$id> $tag = U\n";
		$rval{'ALL'}='U';
   }

	return \%rval;
}


#--------------------------------------------------------------------------------------
sub print_counter_all {
my ($self,$values, $extra_tag) = @_;

	print '-'x60 ."\n";
	if ($extra_tag) { print "$extra_tag\n"; }
	print '-'x60 ."\n";
   if (ref($values) eq "ARRAY") {
		foreach my $l (@$values) {
			foreach my $tag (sort keys %$l) {
				if ($extra_tag) { print "[$extra_tag] $tag = ".$l->{$tag} ."\n"; }
         	else { print "$tag = ".$l->{$tag} ."\n"; }
			}
      }
   }
   elsif (ref($values) eq "HASH") {
      foreach my $iid (sort keys %$values) {
	      foreach my $tag (sort keys %{$values->{$iid}}) {
				if ($extra_tag) { print "[$extra_tag][$iid] $tag = ".$values->{$iid}->{$tag} ."\n"; }
				else { print "[$iid] $tag = ".$values->{$iid}->{$tag} ."\n"; }
			}
      }
   }

}

=item B<$wmi-E<gt>get_wmi_lines($wsql)>

 Devuelve un array con los datos devueltos por una consulta WSQL.
 Util cuando no se trata de contadores.
 $wsql contiene la consulta.
=cut

#----------------------------------------------------------------------------
# get_wmi_lines
#----------------------------------------------------------------------------
sub get_wmi_lines {
my ($self,$wsql_file)=@_;

	my @data=();
   my $lines = $self->get_raw_data($wsql_file);

# Category|CategoryString|ComputerName|Data|EventCode|EventIdentifier|EventType|InsertionStrings|Logfile|Message|RecordNumber|SourceName|TimeGenerated|TimeWritten|Type|User
# 0|(null)|XPGW|NULL|7035|1073748859|3|(Adobe Flash Player Update Service,iniciar)|System|Se ha enviado satisfactoriamente un control iniciar al servicio Adobe Flash Player Update Service.

	$self->log('debug',"get_wmi_lines BBB wsql=$wsql_file)");
	if (scalar @$lines == 0) { return \@data; }

   my @k=();
   shift @$lines;
   shift @$lines;
   shift @$lines;
   if (scalar @$lines > 0) {
      $lines->[0] =~ s/\r/ /g;
      $lines->[0] =~ s/\n/ /g;
      chomp $lines->[0];
      $lines->[0] =~ s/^\s*\|\s+//;
      $lines->[0] =~ s/\s+\|\s+$//;

      @k = split /\s+\|\s+/, $lines->[0];
      shift @$lines;
   }

   my $total_fields = scalar (@k);
   my $i=0;
   my %h=();
   foreach my $l (@$lines) {
      $l =~ s/\r/ /g;
      $l =~ s/\n/ /g;
      #$l =~ s/\s+$//g;
      chomp $l;
      $l =~ s/^\s*\|\s+//;
      $l =~ s/\s+\|\s+$//;
      my %h=();
      my @v = split /\s+\|\s+/, $l;
		my $inline=scalar(@v);

      my $multiline=0;
      if ($inline != scalar(@k)) { $multiline=1; }

      if (!$multiline) {

	      foreach my $x (@v) {
   	      chomp $x;
				if (! exists $k[$i]) { next; }
				$h{$k[$i]} = $x;
				$i+=1;
			}
      	push @data,{%h};
         $i=0;
         %h=();
      }
      else {

			# Esta parte se mantiene de la version con wmic, pero no creo que tenga sentido
         if ($inline<=1) { $h{$k[$i]} .= $l; }
         else {
            foreach my $x (@v) {
               chomp $x;
               if ( exists $h{$k[$i]}) { $h{$k[$i]} .= $x; }
               else { $h{$k[$i]} = $x; }
               $i+=1;
            }
            if ($i<$total_fields) { $i-=1; }
         }
         if ($i>=$total_fields) {
            push @data,{%h};
            $i=0;
            %h=();
         }
      }
   }
   return \@data;
}


#----------------------------------------------------------------------------
# date_format
#----------------------------------------------------------------------------
sub date_format {
my ($self,$date_win)=@_;

#TimeGenerated = 20130122141400.000000+060
#TimeWritten = 20130122141400.000000+060
#substr EXPR,OFFSET,LENGTH

	my $date = $date_win;
	if ($date !~ /\d{14}\.\d{6}([\+|-]+)(\d{3})/) {
		$self->log('info',"date_format >> **FORMATO NO SOPORTADO** date_win=$date_win");
		print "------------------------------------date_win=$date_win\n";	
		return '';
	}

	my ($sign,$offset)=($1,$2);
#20131029080403.484503-000

	my $year=substr $date,0,4;
	my $month=substr $date,4,2;
	my $day= substr $date,6,2;
	my $h= substr $date,8,2;
	my $m= substr $date,10,2;
	my $s= substr $date,12,2;
#	my $newdate = "$day/$month/$year $h:$m:$s";
#	return $newdate;

  #  proto: $time = timegm($sec,$min,$hour,$mday,$mon,$year);
  my $epoch = timegm (0,0,$h,$day,$month-1,$year);

  #  proto: ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
  #          localtime(time);
  my ($lyear,$lmonth,$lday,$lhour,$isdst) =
            (localtime($epoch))[5,4,3,2,-1];

  $lyear += 1900;  # year is 1900 based
  $lmonth++;       # month number is zero based
  #print "isdst: $isdst\n"; #debug flag day-light-savings time
  return ( sprintf("%02d/%02d/%04d %02d:%02d:%02d",
           $lday,$lmonth,$lyear,$lhour,$m,$s) );


}

#----------------------------------------------------------------------------
# time2date 
#----------------------------------------------------------------------------
sub time2date {
my ($self,$ts)=@_;

#TimeGenerated = 20130122141400.000000+060
#TimeWritten =   20130122141400.000000+060
#substr EXPR,OFFSET,LENGTH

   if ($ts !~ /\d+/) { $ts=time(); }
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;
	my $datef = sprintf("%04d%02d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min,$sec).'.000000+060';

   return $datef;
}

#----------------------------------------------------------------------------
# date2time
#----------------------------------------------------------------------------
sub date2time {
my ($self,$date_win)=@_;

#					  20140212023317.000000-000
#TimeGenerated = 20130122141400.000000+060
#TimeWritten =   20130122141400.000000+060
#substr EXPR,OFFSET,LENGTH

	my $date = $date_win;
	if ($date !~ /\d{14}\.\d{6}([\+|-]+)(\d{3})/) { return 0; }

	my ($sign,$offset)=($1,$2);
   my $year=substr $date,0,4;
   my $month=substr $date,4,2;
   my $day= substr $date,6,2;
   my $h= substr $date,8,2;
   my $m= substr $date,10,2;
   my $s= substr $date,12,2;

#	if ($sign eq '+') { $h += $offset/3; }
#	elsif ($sign eq '-') { $h -= $offset/3; }
#
#   $year -= 1900;
#   $month -= 1;

  	#  proto: $time = timegm($sec,$min,$hour,$mday,$mon,$year);
  	my $epoch = timegm ($s,$m,$h,$day,$month-1,$year);
	  
	return $epoch;

#	my $t = timelocal($s,$m,$h,$day,$month,$year);
#
#   return $t;
}


#----------------------------------------------------------------------------
# win_translator
#----------------------------------------------------------------------------
sub win_translator   {
my ($self,$str)=@_;

   my $check_extra='';
	my $new_str='';
   my @a = unpack('C*',$str);
   foreach my $x (@a) {

      my $s=pack('C',$x);
      if ($x < '128') { $new_str .= $s; }
      elsif ($check_extra) {

         if ( ($check_extra eq '194') && ($x eq '190')) {  $new_str .= 'ó';}

         $check_extra='';
      }
      else {
         $check_extra=$x;
         next;
      }
     # printf ("%d : %x (%s)\n",$x,$x,$s);
   }

   return $new_str;
}

#----------------------------------------------------------------------------
# event_type
#----------------------------------------------------------------------------
sub event_type {
my ($self,$int_val)=@_;

	my %EVENT_TYPES = ( '1'=>'Error', '2'=>'Warning', '3'=>'Information', '4'=>'Security Audit Success', '5'=>'Security Audit Failure' );
	if (exists $EVENT_TYPES{$int_val}) { return $EVENT_TYPES{$int_val}; }
	else { return 'Unknown'; }
}


1;

__END__

=back

=head1 LICENSE

This is released under the GPLv2 License.

=head1 AUTHOR

fmarin@s30labs.com - L<http://www.s30labs.com/>

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>

=cut

