#####################################################################################################
# Fichero: (Metrics::Base::novell_nw_disk_dir.pm)   $Id$
# Descripcion: Metrics::Base::novell_nw_disk_dir.pm
# Set Tab=3
#####################################################################################################
package Metrics::Novell::novell_nw_disk_dir;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('novell_nw_disk_dir','NOVELL',300,'USO DE DIRECTORIOS','Directorios Totales|Directorios en Uso','.1.3.6.1.4.1.23.2.28.2.14.1.11|.1.3.6.1.4.1.23.2.28.2.14.1.12','./support/iid_netware_disk',NULL,NULL,'public',NULL,NULL,NULL);
#----------------------------------------------------------------------------
=head1 novell_nw_disk_dir

 OIDs: .1.3.6.1.4.1.23.2.28.2.14.1.11.IID |.1.3.6.1.4.1.23.2.28.2.14.1.12.IID
 TIPO: STD_AREA
 VALUES: DirTotal|DirInUse
 VLABEL: num
 DESCR: Directorios Totales y en uso por volumen de disco.

=cut

#----------------------------------------------------------------------------
sub novell_nw_disk_dir {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASEIP1</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>--METRIC_VAL_USADO--</values>
         <oid>.1.3.6.1.4.1.23.2.28.2.14.1.12.--METRIC_IID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

	@Metrics::Base::OIDs=qw(.1.3.6.1.4.1.23.2.28.2.14.1.12);
	@Metrics::Base::IIDs=();
	$Metrics::Base::Info='';
	#%Metrics::Base::Desc=();
	#BEGIN { $ENV{'MIBS'}='HOST-RESOURCES-MIB'; }
   #$snmpcfg{oid}='nwVolID_nwVolPhysicalName_nwVolUsedDirEntries';
   $snmpcfg{oid}='nwVolPhysicalName_nwVolUsedDirEntries';
   $snmpcfg{last}='nwVolSegmentCount';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {

		my ($id,$descr1,$used)=split(':@:',$l);

		#if (&Metrics::Base::skip_metric($id)) {next;}

      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);

		if (skip_novell_nw_disk_dir($descr2)) {next;}

		my $descr = &Metrics::Base::escape($descr2);
		#my $descr=desc_novell_nw_disk_dir($descr2);

		my $DESC="Directorios NW en $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,'','');

		#my $label="Directorios NW en $descr ($Metrics::Base::METRIC{name})";
		##my $label="Disco $descr";
      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_USADO--/Entradas Dir ($id)/g;

      $M .= $m;
		push @Metrics::Base::IIDs, $id;
		#my $n="$subtype-$id";
		#$Metrics::Base::Desc{$n}->{label}=$label;
		$Metrics::Base::Info=$descr;
   }

   return $M;
}


#------------------------------------------------
sub skip_novell_nw_disk_dir {
my $desc=shift;
my $rc=0;

	#No se que saltarme ??
	return $rc;
}

#------------------------------------------------
#sub desc_novell_nw_disk_dir {
#my $desc=shift;
#
#   #$desc=~s/\s*Serial\s*Number\s*\w+//;
#	
#   $desc=substr($desc,0,22);
#   return $desc;
#}


1;
__END__

