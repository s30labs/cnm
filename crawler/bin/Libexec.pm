#######################################################################################################
# Fichero: (Libexec.pm) $Id$
# Revision: Ver $VERSION
# Descripcion:
# Contiene las funciones que realizan algun tipo de postprocesado sobre el vector de valores obtenidos 
# del core_snmp_table
########################################################################################################
package Libexec;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw(%Libexec::TuneFunction tune_none tune_mac1 tune_ascii);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#------------------------------------------------------------------------
%Libexec::ifName=();
$Libexec::SNMP='';


#-------------------------------------------------------------------------------------------------------
# tune_none: 
# INPUT: Referencia al vector de datos
# OUTPUT: Referencia al vector de datos modificado
# @data=split(':@:',$l);
# tune_none(\@data);
#-------------------------------------------------------------------------------------------------------
sub tune_none {
my $data=shift;

	return 1;

}


#-------------------------------------------------------------------------------------------------------
# tune_mac1: Afina el formato de la nac obtenida en el campo 1 del vector de datos
# INPUT: Referencia al vector de datos
# OUTPUT: Referencia al vector de datos modificado
# @data=split(':@:',$l);
# mac_tune(\@data);
#-------------------------------------------------------------------------------------------------------
sub tune_mac1 {
my $data=shift;

	$data->[1]=~s/\"(.*?)/$1/;  #mac
	$data->[1]=~s/(.*?)\"/$1/;  #mac
	my @m1 = split(/\:|\s+/,$data->[1]);
	my @m2 = map { $_ } @m1;
	my $mac=join (':',@m2);

	$data->[1]=$mac;
	return 1;
}


#-------------------------------------------------------------------------------------------------------
# tune_ifName: Sustituye el dato del ifDescr del vector de datos por el ifName que se encuentra en
# otro vector de datos (%Libexec::ifName).
# INPUT: Referencia al vector de datos
# OUTPUT: Referencia al vector de datos modificado
# LLAMADA:  (Previamente el vector %Libexec::ifName debe tener datos)
# 		@data=split(':@:',$l);
# 		tune_ifName(\@data);
#-------------------------------------------------------------------------------------------------------
sub tune_ifname {
my $data=shift;

	my $id=$data->[0];
	my $n=$data->[1];
	if (exists $Libexec::ifName{$id}) { $n = $Libexec::ifName{$id}; }
	$data->[1]=$Libexec::SNMP->hex2ascii($n);
   return 1;
}


#-------------------------------------------------------------------------------------------------------
# tune_disk1: Contiene el procesado necesario para sacar em MB los datos de disco de la mib-host.
# INPUT: Referencia al vector de datos
# OUTPUT: Referencia al vector de datos modificado
# LLAMADA:  
#     @data=split(':@:',$l);
#     tune_disk1(\@data);
#-------------------------------------------------------------------------------------------------------
sub tune_disk1 {
my $data=shift;

	#($id,$descr,$units,$size,$used,$perc) ==> ($id,$descr,$size,$used,$perc)
   $data->[2]=~s/(\d+) bytes/$1/i;

  	$data->[3] *= $data->[2]; $data->[3] /= 1048576; $data->[3] = int $data->[3];
   $data->[4] *= $data->[2]; $data->[4] /= 1048576; $data->[4] = int $data->[4];
   $data->[5] = ($data->[3]) ? int (100*$data->[4]/$data->[3]) : '-';

	splice (@$data,2,1);
   return 1;
}


#-------------------------------------------------------------------------------------------------------
# tune_ascii: Hace un hex2ascii sobre todos los valores del vector de datos.
# INPUT: Referencia al vector de datos
# OUTPUT: Referencia al vector de datos modificado
# LLAMADA:  (Previamente el vector %Libexec::ifName debe tener datos)
#     @data=split(':@:',$l);
#     tune_ascii(\@data);
#-------------------------------------------------------------------------------------------------------
sub tune_ascii {
my ($data,$index)=@_;

	if (defined $index) {
		my $d=$data->[$index];
		$data->[$index]=$Libexec::SNMP->hex2ascii($d);
   }
	else {
		my $n =scalar @$data;
		for my $i (0..$n-1) {
		  	my $d=$data->[$i];
		  	$data->[$i]=$Libexec::SNMP->hex2ascii($d);
		}
	}
   return 1;
}


1;
__END__
