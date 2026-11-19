#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba: CNMScripts::WMIc y CNMScripts::WMI no escriben la contrasena WMI en el
# log (REG-CNM-Seguridad 4.114). Sustituye log() para guardar los mensajes y
# capture() para no ejecutar nada; crea el objeto y lanza get_raw_data.
#
#   perl t/MISC_wmi_log_sin_credenciales.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use CNMScripts::WMIc;
use CNMScripts::WMI;

my $PWD = 'Pr0ba-NoDebeSalir_9';
my @LOG = ();
{
	no warnings 'redefine';
	*CNMScripts::log = sub { my ($self,$level,@arg)=@_; push @LOG, join(' ',@arg); };
	my $fake = sub { my ($code,$out,$err)=@_; $$out="Impacket\n\n| A |\n"; $$err=''; return; };
	*CNMScripts::WMIc::capture = $fake;
	*CNMScripts::WMI::capture = $fake;
}

for my $mod ('CNMScripts::WMIc','CNMScripts::WMI') {
	for my $domain ('', 'midominio') {
		@LOG = ();
		my $w = $mod->new('host'=>'192.0.2.10', 'user'=>'usuario', 'pwd'=>$PWD, 'domain'=>$domain);
		$w->get_raw_data('Prueba.wsql');
		my $txt = join("\n",@LOG);
		my $d = ($domain eq '') ? 'sin dominio' : 'con dominio';
		ok(scalar(@LOG) > 0, "$mod ($d): hay mensajes de log que mirar");
		unlike($txt, qr/\Q$PWD\E/, "$mod ($d): la contrasena no sale en el log");
		my $q = quotemeta($PWD);
		unlike($txt, qr/\Q$q\E/, "$mod ($d): ni escapada con quotemeta");
		like($txt, qr/wmic=.*\*\*\*/, "$mod ($d): la orden sale en el log con la contrasena tapada");
		like($txt, qr/usuario/, "$mod ($d): el usuario sigue saliendo");
	}
}
done_testing();
