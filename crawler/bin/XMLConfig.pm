#######################################################################################################
# Fichero: (XMLConfig.pm) $Id: XMLConfig.pm,v 1.3 2004/10/04 10:38:21 fml Exp $
# Revision: Ver $VERSION
# Descripcion:
########################################################################################################
package XMLConfig;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
use XML::Simple;
use Data::Dumper;
require Exporter;

@EXPORT_OK = qw(dump_conf parse_device_txml parse_metric_txml @TASK_SNMP @TASK_TELNET );
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

my $DUMP=0;
my @CONF=();

my %SERVICE=(
	parent=>'nodef',
	name=>'nodef',
	desc=>'nodef',
	range=>[],
	metric=>[],
	entity=>{},
);


#-------------------------------------------------------------------------------------------------------
my %TASK_SNMP = (
	
	host_ip=>'',
	host_name=>'',
	lapse=>0,
	comunity=>'',
	module=>'',
	oid=>'',
	once=>'',
	type=>'',
);

my %TASKS=();
my @TASK_SNMP=();
my @TASK_TELNET=();
my %D_SNMP=();
my %D_TELNET=();


#-------------------------------------------------------------------------------------------------------
# Revisar con mode=1 porque esta obsoleto !!!!!!
sub dump_conf {
my ($cfg,$mode)=@_;

	if ($mode == 0) {	print Dumper($cfg);}
	elsif ($mode == 1) {

      print "-----------------\n";
      print "SNMP\n";
      print "-----------------\n";
      foreach (@TASK_SNMP) {
			my $c=0;
			foreach my $k0 (sort keys %$_) {
				$c++;
				print uc $k0,':',$_->{$k0},"  ";
				if (!($c % 4)){print "\n";}
			}
			print "\n\n";
      }
      print "-----------------\n";
      print "TELNET\n";
      print "-----------------\n";
      foreach (@TASK_TELNET) {
         my $c=0;
         foreach my $k0 (sort keys %$_) {
            $c++;
            print uc $k0,':',$_->{$k0},"  ";
            if (!($c % 4)){print "\n";}
         }
         print "\n\n";
      }
	}
}

#-------------------------------------------------------------------------------------------------------
sub to_array {
my $data=shift;

	return (ref($data) eq "ARRAY") ? $data : [$data];
}


#-------------------------------------------------------------------------------------------------------
sub parse_device_txml {
my $file=shift;

@CONF=();
my $xs1 = XML::Simple->new();
my $universe = $xs1->XMLin($file);
my $device;
my $name;
foreach my $key (keys (%{$universe->{device}})){

	my %item=();
        my $device=$universe->{device}->{$key};
	if (ref($device) ne  "HASH") {next;}
	if ($key eq 'task') {$device=$universe->{device};$name=$universe->{device}->{name}}
	else {$device=$universe->{device}->{$key}; $name=$key;}

	if ($DUMP) {
		print "DEVICE=$device\n";
		print "DEVICE=$key\n";
		print "IP=$device->{ip}\n";
	}

	$item{name}=$name;
	$item{ip}=$device->{ip};
	
	my $t=$device->{task};

	my @TASKS=();
	# Hay mas de uma metrica/app definida ------------------------------------
	if (exists $t->{name}) {

		my $r_task=task_global($t);
		push @TASKS,$r_task;
		my @ITEMS=();
      if (exists $t->{metric}->{name} ) { task_items($t->{type},$t->{metric}); }
      elsif (exists $t->{app}->{name} ) { task_items($t->{type},$t->{app}); }
      else {
         foreach my $item (keys (%{$t->{metric}})){
            if ($DUMP) { print "\t\tTASK_ITEM0=$t->{metric}->{$item}\n";}
				my $r_item=task_items($t->{type},$t->{metric}->{$item},$item);
				push @ITEMS,$r_item;
	
         }

         foreach my $item (keys (%{$t->{app}})){
            if ($DUMP) { print "\t\tTASK_ITEM00=$t->{app}->{$item}\n";}
            my $r_item=task_items($t->{type},$t->{app}->{$item},$item);
            push @ITEMS,$r_item;

         }


      }
		
		$item{tasks}=\@TASKS;

	}
	# Solo una metrica/app definida --------------------------------------------
	else {
		foreach my $task (keys (%{$t})){

			my $r_task=task_global($t->{$task},$task);
			push @TASKS,$r_task;
			my @ITEMS=();
      	if (exists $t->{$task}->{metric}->{name} ) { task_items($t->{$task}->{type},$t->{$task}->{metric}); }
      	elsif (exists $t->{$task}->{app}->{name} ) { task_items($t->{$task}->{type},$t->{$task}->{app}); }
      	else {
         	foreach my $item (keys (%{$t->{$task}->{metric}})){
					if ($DUMP) {
            		print "\t\tTASK_ITEM1=$t->{$task}->{metric}->{$item}\n";
            		print "\t\t\tTASK_ITEM1=$item\n";
					}
					my $r_item=task_items($t->{$task}->{type},$t->{$task}->{metric}->{$item},$item);
					push @ITEMS,$r_item;
         	}


            foreach my $item (keys (%{$t->{$task}->{app}})){
               if ($DUMP) {
                  print "\t\tTASK_ITEM11=$t->{$task}->{app}->{$item}\n";
                  print "\t\t\tTASK_ITEM11=$item\n";
               }
               my $r_item=task_items($t->{$task}->{type},$t->{$task}->{app}->{$item},$item);
               push @ITEMS,$r_item;
            }

      	}

			$item{tasks}=\@TASKS;

		}
		
	}
	push @CONF,\%item;
}

	return \@CONF;

}

#------------------------------------------------------
sub task_global {

my ($t,$name)=@_;

	my $n= (defined $name) ? $name : $t->{name};
	if ($t->{type} =~ /app$/)  {

	   if ($DUMP) {
   	   print "\tTASK_NAME=$n\n";
      	print "\tTASK_TYPE=$t->{type}\n";
	      print "\tTASK_LAPSE=$t->{lapse}\n";
   	   print "\tTASK_ONCE=$t->{once}\n";
      	print "\tTASK_ITEM=$t->{app}\n";
   	}
      return {name=>$n,type=>$t->{type},lapse=>$t->{lapse},once=>$t->{once},app=>$t->{app}};
   }

	else {

      if ($DUMP) {
         print "\tTASK_NAME=$n\n";
         print "\tTASK_TYPE=$t->{type}\n";
         print "\tTASK_LAPSE=$t->{lapse}\n";
         print "\tTASK_ONCE=$t->{once}\n";
         print "\tTASK_ITEM=$t->{metric}\n";
      }
      return {name=>$n,type=>$t->{type},lapse=>$t->{lapse},once=>$t->{once},metric=>$t->{metric}};
   }
}


#------------------------------------------------------
sub task_items {

my ($type,$i,$name)=@_;

	my $n= (defined $name) ? $name : $i->{name};
	if ($DUMP) { print "\t\tNAME=$n\n";}
	

	if ($type eq 'snmp') {
		if ($DUMP) {
		   print "\t\tMODULE=$i->{module}\n";
   		print "\t\tOID=$i->{oid}\n";
   		print "\t\tCOMMUNITY=$i->{community}\n";
		}
		return {name=>$n,module=>$i->{module},oid=>$i->{oid},community=>$i->{community}};	
	}
#	elsif ($type eq 'telnet') {
#		if ($DUMP) {
#   		print "\t\tMODULE=$i->{module}\n";
#   		print "\t\tUSER=$i->{user}\n";
#   		print "\t\tPASSWORD=$i->{password}\n";
#   		print "\t\tCMD=$i->{cmd}\n";
#		}
#		return {name=>$n,module=>$i->{module},user=>$i->{user},password=>$i->{password},cmd=>$i->{cmd}};	
#	}
	

}


#-------------------------------------------------------------------------------------------------------
sub parse_metric_txml {
my $file=shift;

	if ( (! defined $file) || (! -e $file)) { return undef; }
	my $xs1 = XML::Simple->new();
	my $metric = $xs1->XMLin($file);
	return $metric;

}



1;
__END__
