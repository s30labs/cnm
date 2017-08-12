#####################################################################################################
# Fichero: (Metrics::SAgent/sagent.pm)   $Id$
# Descripcion: Metrics::SAgent/sagent.pm
# Set Tab=3
#####################################################################################################
package Metrics::SAgent/sagent.pm;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
=head1 sagent 

 DESCR: Agentes remotos

=cut

#----------------------------------------------------------------------------
sub sagent {
my ($device,$rcfg,$subtype)=@_;
my $M='';
my $txml='
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>

';

	my $cnt=$device->{metric_cnt};
	my $name=$device->{name} || $device->{ip};

	if (! defined $device->{mdata}) {
		return;
	}

	foreach my $l (@{$device->{mdata}}) {

	   my $mname=$l->[0];
	   my $mtype=$l->[1];
   	my $vlabel=$l->[2];
	   my $label=$l->[3];
   	my $items=$l->[4];
	   my $mode=$l->[5];
   	my $module=$l->[6];
	   my $top_value=$l->[7];
   	my $watch=$l->[8];

		$M .= $txml;
		
	   $M=~s/--METRIC_NAME--/$mname/g;
   	$M=~s/--MTYPE--/$mtype/g;
   	$M=~s/--SUBTYPE--/$subtype/g;
   	$M=~s/--VLABEL--/$vlabel/g;
   	$M=~s/--METRIC_LABEL--/$label/g;
   	$M=~s/--VALUES--/$items/g;
   	$M=~s/--MODE--/$mode/g;
   	$M=~s/--TOP_VALUE--/$top_value/g;
   	$M=~s/--WATCH--/$watch/g;
   	$M=~s/--METRIC_POSITION--/$cnt/g;

		#Esto lo mete el usuario si quiere en metric_label en DB
   	$M=~s/__NAME__/$name/g;

   	$cnt+=1;
   	$device->{metric_cnt}=$cnt;
	}

   return $M;

}


1;
__END__

