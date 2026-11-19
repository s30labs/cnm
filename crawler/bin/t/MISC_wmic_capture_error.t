#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de CNMScripts::WMIc::capture_error: cuando una consulta WMI falla, el
# script escribe el motivo en STDERR (REG-CNM-Deuda 4.113). No ejecuta WMI: pone
# a mano host_status, err_num y err_str, como los dejan check_tcp_port y
# get_raw_data.
#
#   perl t/MISC_wmic_capture_error.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use CNMScripts::WMIc;

my $IP = '192.0.2.10';
my @WARN = ();
$SIG{__WARN__} = sub { push @WARN, @_; };

sub wmi {
my (%a) = @_;
	my $w = CNMScripts::WMIc->new('host'=>$IP, 'user'=>'u', 'pwd'=>'p');
	$SIG{__WARN__} = sub { push @WARN, @_; };   # new() pone su propio manejador
	$w->host_status($IP, $a{status}) if (exists $a{status});
	$w->err_num($a{err_num}) if (exists $a{err_num});
	$w->err_str($a{err_str}) if (exists $a{err_str});
	$w->{_err_num} = undef if ($a{undef_err});
	$w->{_err_str} = undef if ($a{undef_err});
	return $w;
}

# Sin argumento: solo errores ciertos
is(wmi()->capture_error(), '', 'sin error y sin datos que mirar: vacio');
like(wmi(status=>10)->capture_error(), qr/^sin conectividad WMI con \Q$IP\E \(puerto 135\)$/, 'puerto 135 cerrado');
like(wmi(status=>2, err_num=>2, err_str=>'rpc_s_access_denied')->capture_error(), qr/^error WMI 2 en \Q$IP\E: rpc_s_access_denied$/, 'acceso denegado');
like(wmi(status=>1, err_num=>1, err_str=>'timed out')->capture_error(), qr/^error WMI 1 /, 'timeout');
like(wmi(status=>3)->capture_error(), qr/^WMI no disponible en \Q$IP\E \(estado 3\)$/, 'estado previo sin err_num');
is(wmi(undef_err=>1)->capture_error(), '', 'err_num y err_str sin definir: vacio y sin avisos');

# Con datos: array (sin instancias) y hash (con instancias)
is(wmi()->capture_error([{'PercentProcessorTime'=>'3'}]), '', 'array con datos');
like(wmi()->capture_error([]), qr/^WMI no ha devuelto ningun dato de \Q$IP\E$/, 'array vacio');
like(wmi()->capture_error([{}]), qr/ningun dato/, 'array con un hash vacio');
is(wmi()->capture_error({'C:'=>{'FreeSpace'=>'1'}}), '', 'hash con instancias');
like(wmi()->capture_error({}), qr/ningun dato/, 'hash vacio');
like(wmi(status=>10)->capture_error([{'A'=>1}]), qr/puerto 135/, 'el error manda sobre los datos');

is(scalar(@WARN), 0, 'ningun aviso de perl (irian a STDERR y darian RC=100)') or diag(join('',@WARN));

done_testing();
