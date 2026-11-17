#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba del formato de los ficheros CNM-METRICS (version 2): validacion,
# orden de las listas, default, watch, migracion desde la version 1 y edicion.
# Sin base de datos.
#
#   perl t/PROV_metrics_file.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use JSON;
use ProvisionLite::MetricsFile qw(parse_text check_data decide plan_changes v1_to_v2 encode_data
											 add_entry remove_entry valid_file_name);

sub cfg_of { my ($cfg,$err)=check_data($_[0]); die "fichero de prueba no valido: $err" if ($err); return $cfg; }
sub row { my ($type,$subtype,$label,$status,$watch)=@_;
	return { type=>$type, subtype=>$subtype, label=>$label, status=>$status, watch=>(defined $watch ? $watch : '0') }; }

my $RUN  = row('snmp','disk_mibhost','USO DE DISCO /run/user/0 (prawwerpas02)',0);
my $LOCK = row('snmp','disk_mibhost','USO DE DISCO /run/lock (prawwerpas02)',1);
my $ROOT = row('snmp','disk_mibhost','USO DE DISCO / (prawwerpas02)',0,'w123');
my $ICMP = row('latency','disp_icmp','DISPONIBILIDAD ICMP (prawwerpas02)',1);
my $IF   = row('snmp','traffic_mibii_if','TRAFICO isatap.{ABC} (prawwerpas02)',0);

#------------------------------------------------------------------------------
# 1. Validacion: cada fichero malo se rechaza con su motivo
#------------------------------------------------------------------------------
my $ok = '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":"x"}]}';
my ($c,$e) = parse_text($ok);
ok($c && !$e, 'valido: un fichero correcto se acepta');

my @bad = (
	[ '',                                                              qr/vacio/,              'vacio' ],
	[ '{"version":2,"default":"keep",',                                qr/JSON no valido/,     'JSON cortado' ],
	[ '[1,2]',                                                         qr/no es un objeto/,    'no es un objeto' ],
	[ '{"enable":[]}',                                                 qr/formato antiguo/,    'sin version (formato antiguo)' ],
	[ '{"version":3,"default":"keep","order":["enable","disable"]}',   qr/version no soportada/, 'version 3' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"enabel":[]}', qr/clave desconocida/, 'clave mal escrita' ],
	[ '{"version":2,"order":["enable","disable"]}',                    qr/"default"/,          'sin default' ],
	[ '{"version":2,"default":"enable","order":["enable","disable"]}', qr/"default"/,          'default=enable no existe' ],
	[ '{"version":2,"default":"keep"}',                                qr/"order"/,            'sin order' ],
	[ '{"version":2,"default":"keep","order":["enable"]}',             qr/"order"/,            'order incompleto' ],
	[ '{"version":2,"default":"keep","order":["enable","enable"]}',    qr/"order"/,            'order repetido' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":{}}', qr/tiene que ser una lista/, 'disable no es lista' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"label_like":"x"}]}', qr/falta "type"/, 'sin type' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp"}]}', qr/falta "label_like"/, 'sin label_like' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","subtype":"","label_like":"x"}]}', qr/subtype/, 'subtype vacio' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":"x","watch":"w1"}]}', qr/no admitida: "watch"/, 'watch en disable' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":"(sin cerrar"}]}', qr/expresion regular no valida/, 'regex invalida' ],
	[ '{"version":2,"default":"keep","order":["enable","disable"],"disable":[{"type":"snmp","label_like":["x"]}]}', qr/tiene que ser un texto/, 'label_like no es texto' ],
);
foreach my $b (@bad) {
	my ($cfg,$err) = parse_text($b->[0]);
	ok(!$cfg && defined $err && $err =~ $b->[1], "invalido: $b->[2]") or diag("error=".(defined $err ? $err : 'undef'));
}

#------------------------------------------------------------------------------
# 2. default
#------------------------------------------------------------------------------
my $keep = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'] });
is(decide($keep,$RUN)->{status}, 0, 'default keep: una activa sigue activa');
is(decide($keep,$LOCK)->{status}, 1, 'default keep: una inactiva sigue inactiva');
is(decide($keep,$RUN)->{by}, 'default', 'default keep: lo decide default');
my $dis = cfg_of({ version=>2, default=>'disable', order=>['enable','disable'] });
is(decide($dis,$RUN)->{status}, 1, 'default disable: lo que no casa queda inactivo');
is(scalar @{ plan_changes($keep,[$RUN,$LOCK,$ROOT,$ICMP,$IF]) }, 0, 'default keep sin entradas: no cambia nada');

#------------------------------------------------------------------------------
# 3. El orden decide cuando una etiqueta casa con las dos listas
#------------------------------------------------------------------------------
my %both = ( version=>2, default=>'keep',
	disable => [ { type=>'snmp', subtype=>'disk_mibhost', label_like=>'^USO DE DISCO /run/' } ],
	enable  => [ { type=>'snmp', subtype=>'disk_mibhost', label_like=>'^USO DE DISCO /run/lock ' } ] );
my $en_first = cfg_of({ %both, order=>['enable','disable'] });
my $di_first = cfg_of({ %both, order=>['disable','enable'] });
is(decide($en_first,$LOCK)->{status}, 0, 'orden enable,disable: /run/lock (casa con las dos) queda activa');
is(decide($en_first,$LOCK)->{by}, 'enable #1', 'orden enable,disable: decide la entrada de enable');
is(decide($en_first,$RUN)->{status}, 1, 'orden enable,disable: el resto de /run/ queda inactivo');
is(decide($di_first,$LOCK)->{status}, 1, 'orden disable,enable: /run/lock queda inactiva');
is(decide($di_first,$LOCK)->{by}, 'disable #1', 'orden disable,enable: decide la entrada de disable');
is(decide($en_first,$ROOT)->{status}, 0, 'lo que no casa con ninguna sigue como estaba');

#------------------------------------------------------------------------------
# 4. type, subtype y watch
#------------------------------------------------------------------------------
my $any = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'],
	disable => [ { type=>'snmp', label_like=>'isatap|Teredo' } ] });
is(decide($any,$IF)->{status}, 1, 'sin subtype: casa con cualquier subtipo del type');
my $lat = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'],
	disable => [ { type=>'latency', label_like=>'isatap' } ] });
is(decide($lat,$IF)->{status}, 0, 'el type tiene que coincidir');
my $sub = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'],
	disable => [ { type=>'snmp', subtype=>'status_mibii_if', label_like=>'isatap' } ] });
is(decide($sub,$IF)->{status}, 0, 'con subtype: solo ese subtipo');

my $w = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'],
	enable => [ { type=>'latency', subtype=>'disp_icmp', label_like=>'ICMP', watch=>'w9' },
	            { type=>'snmp', subtype=>'disk_mibhost', label_like=>'^USO DE DISCO / ', watch=>'' } ] });
my $d = decide($w,$ICMP);
is_deeply([$d->{status},$d->{watch}], [0,'w9'], 'enable con watch: activa y con ese monitor');
is(decide($w,$ROOT)->{watch}, 'w123', 'enable con watch vacio: conserva el monitor');
my $disroot = cfg_of({ version=>2, default=>'keep', order=>['enable','disable'],
	disable => [ { type=>'snmp', subtype=>'disk_mibhost', label_like=>'^USO DE DISCO / ' } ] });
is(decide($disroot,$ROOT)->{watch}, 'w123', 'disable no toca el monitor');

my $ch = plan_changes($w,[$ICMP,$ROOT,$RUN]);
is(scalar @$ch, 1, 'plan_changes: solo aparece lo que cambia');
is($ch->[0]{row}, $ICMP, 'plan_changes: la que cambia es la de ICMP');

#------------------------------------------------------------------------------
# 5. Migracion: el fichero migrado decide lo mismo que el codigo antiguo
#------------------------------------------------------------------------------
# Copia de la logica de la version 1 (Crawler/Store.pm, antes del cambio)
sub v1_decide {
	my ($rules,$r)=@_;
	my ($watch,$st) = ($r->{watch},1);
	foreach my $x (@{ $rules->{enable} || [] }) {
		my $ll = $x->{label_like};
		if (($r->{subtype} eq $x->{subtype}) && ($r->{type} eq $x->{type}) && ($r->{label} =~ /$ll/)) {
			$st=0; if ($x->{watch} ne '') { $watch=$x->{watch}; } last;
		}
	}
	return [$st,$watch];
}
my $v1 = { enable => [
	{ type=>'latency', subtype=>'disp_icmp', label_like=>'ICMP', watch=>'' },
	{ type=>'snmp', subtype=>'disk_mibhost', label_like=>'/run/lock', watch=>'w7' },
	{ type=>'snmp', subtype=>'traffic_mibii_if', label_like=>'Tunnel0', watch=>'' } ] };
my ($v2,$merr) = v1_to_v2($v1);
ok($v2 && !$merr, 'migracion: un fichero antiguo se migra') or diag($merr);
is($v2->{default}, 'disable', 'migracion: default=disable (lista de inclusion)');
ok(! exists $v2->{enable}[0]{watch}, 'migracion: el watch vacio se quita');
my $v2cfg = cfg_of($v2);
foreach my $r ($RUN,$LOCK,$ROOT,$ICMP,$IF) {
	my $n = decide($v2cfg,$r);
	is_deeply([$n->{status},$n->{watch}], v1_decide($v1,$r), "migracion: misma decision que la version 1 para '$r->{label}'");
}
my ($x,$xe) = v1_to_v2({ enable=>[ { type=>'snmp', label_like=>'x' } ] });
ok(!$x && $xe =~ /subtype/, 'migracion: una entrada sin subtype no se adivina');
($x,$xe) = v1_to_v2({ version=>2 });
ok(!$x && $xe =~ /ya tiene version/, 'migracion: un fichero ya migrado no se toca');
($x,$xe) = v1_to_v2({ enable=>[], disable=>[ { type=>'snmp', subtype=>'a', label_like=>'x' } ] });
ok(!$x && $xe =~ /disable/, 'migracion: un disable con entradas no se migra a ciegas');

#------------------------------------------------------------------------------
# 6. Edicion y escritura
#------------------------------------------------------------------------------
my $base = { version=>2, default=>'keep', order=>['enable','disable'], enable=>[], disable=>[] };
my $entry = { type=>'snmp', subtype=>'disk_mibhost', label_like=>'^USO DE DISCO /run/user/' };
my ($e1,$m1) = add_entry($base,'disable',$entry);
is(scalar @{$e1->{disable}}, 1, 'anadir: entra una');
is(scalar @{$base->{disable}}, 0, 'anadir: no modifica el original');
my ($e2,$m2) = add_entry($e1,'disable',$entry);
is(scalar @{$e2->{disable}}, 1, 'anadir: la misma entrada no se duplica');
like($m2, qr/ya estaba/, 'anadir: avisa de que ya estaba');
my ($e3,$m3) = remove_entry($e2,'disable',$entry);
is(scalar @{$e3->{disable}}, 0, 'quitar: sale');
my ($e4,$m4) = remove_entry($e3,'disable',$entry);
like($m4, qr/no estaba/, 'quitar: avisa si no estaba');

my $txt = encode_data($e1);
my ($back,$berr) = parse_text($txt);
ok($back && !$berr, 'encode_data: lo escrito se vuelve a leer como valido');
is_deeply(JSON->new->decode($txt), $e1, 'encode_data: el contenido no cambia al escribirlo');
like($txt, qr/^\{\n  "version": 2,\n  "default": "keep",\n  "order":/, 'encode_data: version, default y order arriba');
like(encode_data({ %$e1, version=>'2' }), qr/"version": 2,/, 'encode_data: version se escribe como numero aunque llegue como texto');

ok(valid_file_name('cnm-metrics-tpvs-aena.json'), 'nombre: valido');
ok(!valid_file_name('../etc/passwd.json'), 'nombre: sin rutas');
ok(!valid_file_name('fichero.txt'), 'nombre: tiene que acabar en .json');
ok(!valid_file_name('-'), 'nombre: "-" no es un fichero');

done_testing();
