#####################################################################################################
# Fichero: (Metrics::Base::disk_mibhost.pm)   $Id$
# Descripcion: Metrics::Base::disk_mibhost.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::disk_mibhost;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('disk_mibhost', 'MIB-HOST - rfc2790',300, 'USO DE DISCO', 'Disco Total|Disco Usado','.1.3.6.1.2.1.25.2.3.1.4.IID|.1.3.6.1.2.1.25.2.3.1.5.IID|.1.3.6.1.2.1.25.2.3.1.6.IID','./support/iid_mibhost_disk');
#----------------------------------------------------------------------------
=head1 disk_mibhost

 OIDs: .1.3.6.1.2.1.25.2.3.1.4.IID/.1.3.6.1.2.1.25.2.3.1.5.IID/.1.3.6.1.2.1.25.2.3.1.6.IID
 TIPO: STD_AREA
 VALUES: Disco Total | Disco Usado
 VLABEL: bits/sg
 DESCR: Numero Total de octetos rx/tx por el interfaz incluyendo cabeceras.

=cut

#----------------------------------------------------------------------------
sub disk_mibhost {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>bytes</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get_ext:ext_mibhost_disk</module>
         <values>--METRIC_VAL_TOTAL--|--METRIC_VAL_USADO--</values>
         <oid>.1.3.6.1.2.1.25.2.3.1.4.--METRIC_IID--|.1.3.6.1.2.1.25.2.3.1.5.--METRIC_IID--|.1.3.6.1.2.1.25.2.3.1.6.--METRIC_IID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
			<severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

	@Metrics::Base::OIDs=qw(.1.3.6.1.2.1.25.2.3.1.4 .1.3.6.1.2.1.25.2.3.1.5 .1.3.6.1.2.1.25.2.3.1.6);
	@Metrics::Base::IIDs=();
	$Metrics::Base::Info='';
	#%Metrics::Base::Desc=();
	#BEGIN { $ENV{'MIBS'}='HOST-RESOURCES-MIB'; }
   $snmpcfg{oid}='hrStorageDescr_hrStorageAllocationUnits_hrStorageSize_hrStorageUsed';
   $snmpcfg{last}='hrStorageAllocationFailures';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {

		my ($id,$descr1,$units,$size,$used,$perc)=split(':@:',$l);

		#if (&Metrics::Base::skip_metric($id)) {next;}

      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);

		#if (skip_disk_mibhost($descr2)) {}

		my $descr3=desc_disk_mibhost($descr2);
		my $descr = &Metrics::Base::escape($descr3);

		my $DESC="Disco $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$descr2,\&Metrics::Base::get_status_mibhost_disk);

		#if (skip_disk_mibhost($descr2)) { $m=~s/--STATUS--/1/g; }
		#else { $m=~s/--STATUS--/0/g; }

		#my $label="Disco $descr ($Metrics::Base::METRIC{name})";
		#my $label="Disco $descr";
      #$m=~s/--METRIC_LABEL--/$label/g;

      $m=~s/--METRIC_VAL_TOTAL--/Espacio total ($id)/g;
      $m=~s/--METRIC_VAL_USADO--/Espacio usado ($id)/g;
		$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

      $M .= $m;
		push @Metrics::Base::IIDs, $id;
		#my $n="$subtype-$id";
		#$Metrics::Base::Desc{$n}->{label}=$label;
		$Metrics::Base::Info=$descr;
   }

   return $M;
}


#------------------------------------------------
sub skip_disk_mibhost {
my $desc=shift;
my $rc=0;

	if ($desc =~ /A\:\\.*/i) {$rc=1;}
   elsif ($desc =~ /\/dev\/shm/) {$rc=1;}
   elsif ($desc =~ /\/proc\/bus\/usb/) {$rc=1;}
	return $rc;
}

#------------------------------------------------
sub desc_disk_mibhost {
my $desc=shift;

   $desc=~s/\s*Serial\s*Number\s*\w+//;
   $desc=substr($desc,0,28);
   return $desc;
}


1;
__END__

