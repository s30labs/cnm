#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de Crawler::Store::set_template_metrics_by_custom_file con el formato
# CNM-METRICS version 2: que cambia la plantilla, que avisa, y que NO toca nada
# si el fichero falta o no es valido. Sin base de datos: consultas simuladas.
#
#   perl t/CNM_store_metrics_file_apply.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use File::Temp qw(tempdir);
use Crawler::Store;

#------------------------------------------------------------------------------
my $DIR = tempdir(CLEANUP=>1);
$Crawler::Store::CNM_METRICS_DIR = $DIR;

my $FIELD;		# valor de columna3 del equipo
my @TPL;			# filas de la plantilla: type,subtype,watch,iid,mname,label,status,id_template_metric
my @UPDATES;	# [ \%datos, $where ]
my $SELECT_ERR = 0;	# simula un error de la base al leer la plantilla
{
	no warnings 'redefine';
	*Crawler::Store::sqlSelectAll = sub { $libSQL::err=$SELECT_ERR; return $SELECT_ERR ? undef : [ map { [ @$_ ] } @TPL ]; };
	*Crawler::Store::sqlUpdate    = sub { my ($dbh,$t,$d,$w)=@_; $libSQL::err=0; push @UPDATES, [ { %$d }, $w ]; return 1; };
}
package FakeDBH; sub new { bless {}, shift } sub quote { my ($s,$v)=@_; return "'$v'"; }
package TStore; our @ISA=('Crawler::Store');
sub new { my $c=shift; return bless { qactions=>[], logs=>[] }, $c; }
sub get_from_db_cmd { my ($s,$dbh,$sql)=@_;
	return [[3]] if ($sql =~ /devices_custom_types/);
	return [[$FIELD]]; }
sub log_qactions { my ($s,$dbh,$d)=@_; push @{$s->{qactions}}, $d; return 1; }
sub log { my ($s,$l,$m)=@_; push @{$s->{logs}}, "$l $m"; }
sub manage_db_error { my ($s)=@_; push @{$s->{dberr}}, $s->error(); }
package main;

sub write_file { my ($n,$t)=@_; open(my $f,'>',"$DIR/$n") or die; print $f $t; close $f; }
sub run { @UPDATES=(); my $s=TStore->new(); $s->set_template_metrics_by_custom_file(FakeDBH->new(),49); return $s; }

@TPL = (
	[ 'snmp','disk_mibhost','0','186','disk_mibhost-186','USO DE DISCO /run/user/1000 (prawwerpas02)',0,10 ],
	[ 'snmp','disk_mibhost','0','36','disk_mibhost-36','USO DE DISCO / (prawwerpas02)',0,10 ],
	[ 'snmp','disk_mibhost','0','43','disk_mibhost-43','USO DE DISCO /run/lock (prawwerpas02)',1,10 ],
	[ 'latency','w_mon_ssh-f1282942','0','ALL','w_mon_ssh-f1282942','ACCESO SSH (TCP/22) (prawwerpas02)',0,11 ],
);
my $KEEP = '{"version":2,"default":"keep","order":["enable","disable"],'
	.'"disable":[{"type":"snmp","subtype":"disk_mibhost","label_like":"^USO DE DISCO /run/"}],'
	.'"enable":[{"type":"snmp","subtype":"disk_mibhost","label_like":"^USO DE DISCO /run/lock "}]}';

#------------------------------------------------------------------------------
# 1. Sin fichero asignado: no hace nada
#------------------------------------------------------------------------------
foreach my $v ('-', '', undef) {
	$FIELD=$v; my $s=run();
	is(scalar(@UPDATES)+scalar(@{$s->{qactions}}), 0, 'sin fichero ('.(defined $v ? "'$v'" : 'undef').'): ni cambios ni avisos');
}

#------------------------------------------------------------------------------
# 2. Fichero valido: cambia solo lo que tiene que cambiar y avisa
#------------------------------------------------------------------------------
write_file('m.json',$KEEP); $FIELD='m.json';
my $s=run();
my %upd = map { ($_->[1] =~ /mname='([^']+)'/)[0] => $_->[0]{status} } @UPDATES;
is_deeply(\%upd, { 'disk_mibhost-186'=>1, 'disk_mibhost-43'=>0 }, 'valido: se desactiva /run/user/1000 y se activa /run/lock; lo demas no se toca');
like($UPDATES[0][1], qr/^id_template_metric=10 AND mname='disk_mibhost-/, 'valido: el UPDATE va por id_template_metric y mname');
is(scalar @{$s->{qactions}}, 1, 'valido: un aviso');
is($s->{qactions}[0]{descr}, 'Plantilla ajustada por CNM-METRICS', 'valido: aviso de plantilla ajustada');
is($s->{qactions}[0]{rc}, 0, 'valido: rc=0 (entero)');
is($s->{qactions}[0]{id_dev}, 49, 'valido: el aviso lleva el id_dev');
like($s->{qactions}[0]{rcstr}, qr{^m\.json: desactivadas: USO DE DISCO /run/user/1000; activadas: USO DE DISCO /run/lock$}, 'valido: el aviso dice que cambia, sin el (equipo)');

# Segunda pasada sobre la plantilla ya ajustada: nada que hacer
$TPL[0][6]=1; $TPL[2][6]=0;
$s=run();
is(scalar(@UPDATES)+scalar(@{$s->{qactions}}), 0, 'segunda pasada: ni cambios ni avisos');
$TPL[0][6]=0; $TPL[2][6]=1;

# Etiqueta NULL en la plantilla: se trata como texto vacio, sin avisos de Perl
push @TPL, [ 'snmp','disk_mibhost','0','99','disk_mibhost-99',undef,0,10 ];
{ my @w=(); local $SIG{__WARN__} = sub { push @w, @_ };
  $s=run();
  is(scalar(grep { $_->[1] =~ /disk_mibhost-99/ } @UPDATES), 0, 'etiqueta NULL: no casa con una regla de texto');
  write_file('vacia.json','{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":"^$"}]}');
  $FIELD='vacia.json'; $s=run();
  is(scalar(grep { $_->[1] =~ /disk_mibhost-99/ } @UPDATES), 1, 'etiqueta NULL: casa con "^$"');
  is(scalar @w, 0, 'etiqueta NULL: sin avisos de Perl') or diag(@w); }
pop @TPL; $FIELD='m.json';

# Error de la base al leer la plantilla: no se cambia nada, se registra el error
$SELECT_ERR = 2006; $s=run(); $SELECT_ERR = 0;
is(scalar(@UPDATES)+scalar(@{$s->{qactions}}), 0, 'error al leer la plantilla: ni cambios ni avisos');
is_deeply($s->{dberr}, [2006], 'error al leer la plantilla: manage_db_error recibe el error');

#------------------------------------------------------------------------------
# 3. Fichero que falta o no es valido: NO se toca la plantilla y se avisa
#------------------------------------------------------------------------------
my @bad = (
	[ 'no-existe.json', undef,                                  qr/no existe/ ],
	[ 'cortado.json',   substr($KEEP,0,40),                     qr/JSON no valido/ ],
	[ 'vacio.json',     '',                                     qr/vacio/ ],
	[ 'v1.json',        '{"enable":[{"type":"latency","subtype":"disp_icmp","label_like":"ICMP","watch":""}]}', qr/formato antiguo/ ],
	[ 'regex.json',     '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":"(x"}]}', qr/expresion regular/ ],
	[ '../fuera.json',  undef,                                  qr/nombre de fichero no valido/ ],
);
foreach my $b (@bad) {
	my ($name,$text,$re)=@$b;
	write_file($name,$text) if (defined $text);
	$FIELD=$name; $s=run();
	is(scalar @UPDATES, 0, "$name: no se cambia la plantilla");
	is(scalar @{$s->{qactions}}, 1, "$name: un aviso");
	is($s->{qactions}[0]{descr}, 'CNM-METRICS no aplicado', "$name: aviso de no aplicado");
	is($s->{qactions}[0]{rc}, 1, "$name: rc=1");
	like($s->{qactions}[0]{rcstr}, $re, "$name: el aviso dice por que");
}

done_testing();
