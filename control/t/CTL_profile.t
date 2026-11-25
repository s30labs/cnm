#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Test of CNMControl::Profile: profile validation, inventory parsing, chained defaults,
# optional parameters and expansion. No database.
#
#   cd /opt/cnm/control && perl t/CTL_profile.t
#------------------------------------------------------------------------------
use FindBin; use lib "$FindBin::Bin/../lib";
use strict;
use Test::More;
use JSON;
use CNMControl::Profile qw(check_profile parse_inventory expand read_file);

my ($t,$e) = read_file("$FindBin::Bin/../profiles/examples/icmp-basic.json");
ok(!$e, 'se lee el perfil de ejemplo');
my ($p,$ep) = check_profile(JSON->new->decode($t));
ok($p && !$ep, 'el perfil de ejemplo es valido') or diag($ep);

#--- 1. Bad profiles: each one is rejected with its reason ----------------------
my @bad = (
	[ '{"version":1,"parameters":{},"resources":[]}',                                  qr/lista no vacia/ ],
	[ '{"version":2,"parameters":{},"resources":[{"kind":"view"}]}',                 qr/version/ ],
	[ '{"version":1,"parameters":{},"resources":[{"kind":"view","name":"{v}"}]}',  qr/\{v\}.*parameters/ ],
	[ '{"version":1,"parameters":{"V":{}},"resources":[{"kind":"view"}]}',           qr/no valido 'V'/ ],
	[ '{"version":1,"parameters":{"v":{"x":1}},"resources":[{"kind":"view"}]}',      qr/clave desconocida 'x'/ ],
	[ '{"version":1,"otra":1,"parameters":{},"resources":[{"kind":"view"}]}',        qr/clave desconocida 'otra'/ ],
);
foreach my $b (@bad) { my ($x,$err)=check_profile(JSON->new->decode($b->[0])); like($err // '', $b->[1], "perfil rechazado: $b->[1]"); }

#--- 2. Inventory -----------------------------------------------------------------
my $inv = "# comentario\nname;ip;view;type\ntda-01;10.0.0.1;Tiendas;\ntda-02;10.0.0.2;Tiendas;Router\n\n";
my ($rows,$err) = parse_inventory($inv,$p);
is(scalar(@$err), 0, 'inventario valido') or diag(join("\n",@$err));
is(scalar(@$rows), 2, 'dos filas (comentarios y vacias fuera)');
is($rows->[0]{values}{domain}, 'local', 'defecto aplicado');
my ($pd) = check_profile(JSON->new->decode('{"version":1,"parameters":{"n":{},"fqdn":{"default":"{n}.example.local"}},"resources":[{"kind":"view","name":"{fqdn}"}]}'));
my ($rd) = parse_inventory("n\ntda-01\n",$pd);
is($rd->[0]{values}{fqdn}, 'tda-01.example.local', 'defecto que usa otro parametro');
is($rows->[0]{line}, 3, 'numero de linea real');

($rows,$err) = parse_inventory("name;ip;view;columna_rara\nx;10.0.0.1;V;1\n",$p);
like($err->[0] // '', qr/columna_rara.*no es un parametro/, 'columna desconocida');
($rows,$err) = parse_inventory("name;ip\nx;10.0.0.1\n",$p);
like($err->[0] // '', qr/linea 2: falta 'view'/, 'obligatorio sin valor ni defecto');
($rows,$err) = parse_inventory("name;ip;view\nx;10.0.0.1;V;sobra\n",$p);
like($err->[0] // '', qr/mas columnas/, 'fila con columnas de mas');
($rows,$err) = parse_inventory("",$p);
like($err->[0] // '', qr/no tiene cabecera/, 'inventario vacio');

#--- 3. Expansion -----------------------------------------------------------------
($rows,$err) = parse_inventory($inv,$p);
my ($res,$e3) = expand($p,$rows);
is(scalar(@$res), 8, '4 recursos por fila x 2 filas');
my @d = grep { $_->{kind} eq 'device' } @$res;
ok(!exists $d[0]{type}, 'tipo vacio: la clave desaparece');
is($d[1]{type}, 'Router', 'tipo con valor se mantiene');
is($d[0]{snmp}{version}, 0, 'los numeros JSON se conservan');
my @m = grep { $_->{kind} eq 'metric' && $_->{subtype} eq 'mon_icmp' } @$res;
is($m[0]{device}, 'tda-01.local', 'referencia al dispositivo');
is($m[0]{c_label}, 'Servicio ICMP tda-01', 'c_label del perfil, con el nombre de la fila');
is_deeply($m[0]{views}, ['Tiendas'], 'lista de vistas');
like($res->[0]{_origin}, qr/linea 3/, 'cada recurso sabe de que linea sale');

# A list whose only element ends up empty becomes empty
my ($p2) = check_profile(JSON->new->decode('{"version":1,"parameters":{"d":{},"v":{}},"resources":[{"kind":"metric","device":"{d}","subtype":"x","views":["{v}"]}]}'));
my ($r2,$e2) = parse_inventory("d;v\na.b;\n", $p2);
is(scalar(@$e2), 0, 'fila con la vista vacia es valida');
my ($x2) = expand($p2,$r2);
is_deeply($x2->[0]{views}, [], 'vista vacia: lista vacia');

#--- 4. custom.<field> columns: user fields of the device of the row ---------------
my $ci = "Custom.Proveedor;name;ip;custom.CNM-METRICS;view\nACME;tda-01;10.0.0.1;;Tiendas\n;tda-02;10.0.0.2;icmp.json;Tiendas\n";
my ($cr,$ce) = parse_inventory($ci,$p);
is(scalar(@$ce), 0, 'custom.* en cualquier orden y con mayusculas: valido') or diag(join("\n",@$ce));
is_deeply($cr->[0]{custom}, { Proveedor=>'ACME' }, 'fila 1: solo los campos con valor (la celda vacia no se toca)');
is_deeply($cr->[1]{custom}, { 'CNM-METRICS'=>'icmp.json' }, 'fila 2: el otro campo');
my ($cx,$cxe) = expand($p,$cr);
is(scalar(@$cxe), 0, 'expansion sin errores');
my @cd = grep { $_->{kind} eq 'device' } @$cx;
is_deeply($cd[0]{fields}, { Proveedor=>'ACME' }, 'los campos van al dispositivo de su fila');
is_deeply($cd[1]{fields}, { 'CNM-METRICS'=>'icmp.json' }, '... y no se mezclan entre filas');
ok(!grep({ exists $_->{fields} } grep { $_->{kind} ne 'device' } @$cx), 'ni van a otras clases');

($cr,$ce) = parse_inventory("name;ip;view;custom.X;CUSTOM.x\na;10.0.0.1;V;1;2\n",$p);
like($ce->[0] // '', qr/custom\.x' repetida/i, 'custom repetido (sin distinguir mayusculas): error');
($cr,$ce) = parse_inventory("name;ip;view;provedor\na;10.0.0.1;V;1\n",$p);
like($ce->[0] // '', qr/ni custom\.<campo>/, 'columna sin prefijo que no es parametro: error que sugiere custom.');

# The inventory wins over the same field set by the profile
my ($p3) = check_profile(JSON->new->decode('{"version":1,"parameters":{"n":{}},"resources":[{"kind":"device","name":"{n}","domain":"d","ip":"10.0.0.1","fields":{"PROVEEDOR":"perfil","Otro":"x"}}]}'));
my ($r3) = parse_inventory("n;custom.Proveedor\na;inventario\n",$p3);
my ($x3) = expand($p3,$r3);
is_deeply($x3->[0]{fields}, { Proveedor=>'inventario', Otro=>'x' }, 'el inventario gana al perfil en el mismo campo');

# A profile without exactly one device per row cannot take custom.* columns
my ($p4) = check_profile(JSON->new->decode('{"version":1,"parameters":{"v":{}},"resources":[{"kind":"view","name":"{v}"}]}'));
my ($r4) = parse_inventory("v;custom.Proveedor\nV;ACME\n",$p4);
my ($x4,$e4) = expand($p4,$r4);
like($e4->[0] // '', qr/crea 0 dispositivos por fila/, 'perfil sin dispositivo y columnas custom.*: error');
($r4) = parse_inventory("v;custom.Proveedor\nV;\n",$p4);
($x4,$e4) = expand($p4,$r4);
is(scalar(@$e4), 0, '... pero si las celdas van vacias, no hay nada que asignar');

#--- 5. c_label.<subtype> columns: title of each metric of the row -----------------
my $li = "name;ip;view;C_LABEL.mon_icmp;c_label.disp_icmp\ntda-01;10.0.0.1;Tiendas;Enlace 4G;\ntda-02;10.0.0.2;Tiendas;;Disp tda-02\n";
my ($lr,$le) = parse_inventory($li,$p);
is(scalar(@$le), 0, 'c_label.<subtipo> en cualquier orden y con mayusculas: valido') or diag(join("\n",@$le));
my ($lx,$lxe) = expand($p,$lr);
is(scalar(@$lxe), 0, 'expansion sin errores') or diag(join("\n",@$lxe));
my %t = map { ("$_->{device}|$_->{subtype}" => $_->{c_label}) } grep { $_->{kind} eq 'metric' } @$lx;
is_deeply(\%t, { 'tda-01.local|mon_icmp'=>'Enlace 4G', 'tda-01.local|disp_icmp'=>'Disponibilidad ICMP tda-01',
					  'tda-02.local|mon_icmp'=>'Servicio ICMP tda-02', 'tda-02.local|disp_icmp'=>'Disp tda-02' },
	'cada titulo va a su metrica; la celda vacia deja el del perfil');
($lr,$le) = parse_inventory("name;ip;view;c_label.mon_icmp;c_label.MON_ICMP\na;10.0.0.1;V;x;y\n",$p);
like($le->[0] // '', qr/c_label\.mon_icmp' repetida/i, 'c_label.<subtipo> repetido: error');
($lr,$le) = parse_inventory("name;ip;view;c_label.disk_mibhost\na;10.0.0.1;V;Disco\n",$p);
($lx,$lxe) = expand($p,$lr);
like($lxe->[0] // '', qr/c_label\.disk_mibhost, pero el perfil crea 0 metricas/, 'subtipo que el perfil no crea: error');
($lr,$le) = parse_inventory("name;ip;view;c_label.disk_mibhost\na;10.0.0.1;V;\n",$p);
($lx,$lxe) = expand($p,$lr);
is(scalar(@$lxe), 0, '... salvo si la celda va vacia');
my ($p5) = check_profile(JSON->new->decode('{"version":1,"parameters":{"n":{}},"resources":[{"kind":"metric","device":"a.b","subtype":"x"},{"kind":"metric","device":"c.d","subtype":"x"}]}'));
my ($r5) = parse_inventory("n;c_label.x\n1;T\n",$p5);
my ($x5,$e5) = expand($p5,$r5);
like($e5->[0] // '', qr/crea 2 metricas x/, 'dos metricas del mismo subtipo en la fila: no se sabe a cual, error');

done_testing();
