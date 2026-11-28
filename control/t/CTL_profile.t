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
ok(! exists $d[0]{snmp}, 'icmp-basic no fija SNMP: no cambia el de un equipo que ya existe (al crear, version 0)');
{ my ($pn) = check_profile({ version=>1, parameters=>{ name=>{} }, resources=>[ { kind=>'device', name=>'{name}', snmp=>{ version=>0 } } ] });
  my ($rn) = parse_inventory("name\nx\n", $pn); my ($xn) = expand($pn,$rn);
  is($xn->[0]{snmp}{version}, 0, 'los numeros JSON se conservan'); }
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

#--- Views profile: lists with '|', optional cells, origin with the inventory name --------
my ($pv) = check_profile(JSON->new->decode(scalar((read_file("$FindBin::Bin/../profiles/views-basic.json"))[0])));
ok($pv, 'perfil de ejemplo views-basic valido');
my ($rv,$rve) = parse_inventory("name;like;type;parent;users\nSede Madrid;Plantilla;;Sede Norte;noc | operador1|\nSede Norte;;General;Sedes;\n", $pv);
is(scalar(@$rve), 0, 'inventario de vistas sin errores');
my ($xv,$xve) = expand($pv,$rv,'vistas.csv');
is_deeply([ map { { %$_ } } @$xv ], [
	{ kind=>'view', name=>'Sede Madrid', create=>JSON::true, like=>'Plantilla', fields=>{}, parent=>'Sede Norte', users=>['noc','operador1'], _origin=>'vistas.csv linea 2' },
	{ kind=>'view', name=>'Sede Norte', create=>JSON::true, fields=>{ type=>'General' }, parent=>'Sedes', users=>[], _origin=>'vistas.csv linea 3' } ],
	"'|' separa elementos, sin espacios ni vacios; celda vacia = clave o lista fuera; origen con el nombre del inventario");

#--- 0010: BOM and encoding of the inventory ------------------------------------------------
use File::Temp qw(tempdir);
my $td = tempdir(CLEANUP=>1);
sub wr { my ($n,$b)=@_; open(my $f,'>:raw',"$td/$n") or die; print $f $b; close $f; return "$td/$n"; }
my ($tb,$eb) = read_file(wr('bom.csv', "\xEF\xBB\xBFname;ip\nAlcal\xC3\xA1;1.1.1.1\n"));
ok((! $eb) && ($tb =~ /^name;ip\n/), 'BOM de Excel quitado: la primera columna es name');
is(substr((split(/\n/,$tb))[1],0,6), "Alcal\x{e1}", 'UTF-8 leido como caracteres (tildes bien)');
my ($tw,$ew) = read_file(wr('win.csv', "name;ip\nok;1.1.1.1\nAlcal\xE1;1.1.1.2\n"));
ok(! defined $tw, 'fichero en Windows-1252: no se lee');
like($ew, qr/no esta en UTF-8 \(primera linea con problemas: 3\).*iconv -f WINDOWS-1252/, '... y dice la linea y como convertirlo');

#--- 0016: attribute columns, --set, default domain, device.<attr> ---------------------------
my ($pi) = check_profile(JSON->new->decode(scalar((read_file("$FindBin::Bin/../profiles/examples/icmp-basic.json"))[0])));
my ($ra,$ea) = parse_inventory("name;ip;view;critic;status;version;community;custom.Proveedor\nsede-01;10.1.1.1;V;100;;2;c1;ACME\nsede-02;10.1.1.2;V;;2;;;\n", $pi);
is(scalar(@$ea), 0, 'atributos del dispositivo sin declararlos en el perfil: admitidos') or diag(join(' ',@$ea));
my ($xa) = expand($pi,$ra,'s.csv');
my @da = grep { $_->{kind} eq 'device' } @$xa;
is_deeply([ map { { map { $_=>$da[0]{$_} } grep { defined $da[0]{$_} } qw(critic status geodata) } } 0 ], [ { critic=>100 } ], 'fila 1: critic; status vacio no aparece');
is_deeply($da[0]{snmp}, { version=>2, community=>'c1' }, '... version y community van a snmp');
is_deeply([ $da[1]{status}, exists $da[1]{critic} ? 1 : 0, exists $da[1]{snmp} ? 1 : 0 ], [ 2, 0, 0 ], 'fila 2: solo status');
ok($da[0]{_domain_default} && $da[1]{_domain_default}, 'sin columna domain: el dominio es el defecto del perfil (marcado)');
my ($rdd) = parse_inventory("name;ip;view;domain\nsede-01;10.1.1.1;V;es.local\nsede-02;10.1.1.2;V;\n", $pi);
my ($xd) = expand($pi,$rdd); my @dd = grep { $_->{kind} eq 'device' } @$xd;
is_deeply([ $dd[0]{domain}, $dd[0]{_domain_default} ? 1 : 0, $dd[1]{domain}, $dd[1]{_domain_default} ? 1 : 0 ], [ 'es.local', 0, 'local', 1 ],
	'celda domain con valor: explicito; vacia: defecto marcado');
# --set: fills empty cells, the cell wins, it adds a column that is not in the CSV
my ($rs,$es,$us) = parse_inventory("name;ip;critic\nsede-01;10.1.1.1;\nsede-02;10.1.1.2;25\n", $pi, { view=>'Sedes', critic=>75, domain=>'es.local', nada=>1 });
is(scalar(@$es), 0, '--set de columnas que no estan en el CSV: admitido');
is_deeply([ sort keys %$us ], [ qw(critic domain view) ], '... y dice cuales entiende (nada no)');
my ($xs) = expand($pi,$rs); my @ds = grep { $_->{kind} eq 'device' } @$xs; my @vs = grep { $_->{kind} eq 'view' } @$xs;
is_deeply([ $ds[0]{critic}, $ds[1]{critic} ], [ 75, 25 ], '--set rellena la celda vacia; la celda manda');
is_deeply([ $ds[0]{domain}, $ds[0]{_domain_default} ? 1 : 0 ], [ 'es.local', 0 ], '--set domain: explicito');
is($vs[0]{name}, 'Sedes', '--set de un parametro requerido');
# Collisions: views-basic has a parameter "type" that is the type of the view, and no device
my (undef,$ec) = parse_inventory("name;critic\nV;50\n", $pv);
like(join(' ',@$ec), qr/columna 'critic': es un atributo del dispositivo, pero el perfil crea 0 dispositivos/, 'atributo en un perfil sin dispositivo: error');
my ($pt) = check_profile({ version=>1, parameters=>{ name=>{}, ip=>{}, type=>{} },
	resources=>[ { kind=>'device', name=>'{name}', domain=>'local', ip=>'{ip}' }, { kind=>'view', name=>'{type}' } ] });
my ($rt,$et) = parse_inventory("name;ip;type;device.type\na;1.1.1.1;Vista;Router\n", $pt);
is(scalar(@$et), 0, 'parametro type que no es el tipo del dispositivo: type es el parametro, device.type el atributo') or diag(join(' ',@$et));
my ($xt) = expand($pt,$rt);
is_deeply([ (grep { $_->{kind} eq 'device' } @$xt)[0]{type}, (grep { $_->{kind} eq 'view' } @$xt)[0]{name} ], [ 'Router', 'Vista' ], '... cada uno a su sitio');
my (undef,$e2t) = parse_inventory("name;ip;type;device.type\na;1.1.1.1;Router;Switch\n", $pi);
like(join(' ',@$e2t), qr/columna 'device\.type' repetida/, 'type y device.type que son el mismo atributo: columna repetida');
my (undef,$eu) = parse_inventory("name;ip;view;device.sysloc\na;1.1.1.1;V;x\n", $pi);
like(join(' ',@$eu), qr/'sysloc' no es un atributo del dispositivo/, 'device.<algo> que no es atributo: error');

#--- 0017: c_label from the profile is a default; the column and --set accept templates -----
my ($rl,$el) = parse_inventory("name;ip;view;c_label.mon_icmp\nsede-01;10.1.1.1;V;{name} ({ip}) - ICMP Service\nsede-02;10.1.1.2;V;\n", $pi,
										 { 'c_label.disp_icmp'=>'{name} - ICMP Availability' });
is(scalar(@$el), 0, 'c_label.<subtipo> en el CSV y con --set: admitido');
my ($xl,$exl) = expand($pi,$rl);
my %ml = map { ("$_->{device}|$_->{subtype}" => $_) } grep { $_->{kind} eq 'metric' } @$xl;
is($ml{'sede-01.local|mon_icmp'}{c_label}, 'sede-01 (10.1.1.1) - ICMP Service', 'la celda admite plantilla con {name} e {ip}');
ok(! $ml{'sede-01.local|mon_icmp'}{_label_default}, '... y es explicita');
is($ml{'sede-02.local|disp_icmp'}{c_label}, 'sede-02 - ICMP Availability', '--set con plantilla, en cada fila');
ok(! $ml{'sede-02.local|disp_icmp'}{_label_default}, '... explicita');
is($ml{'sede-02.local|mon_icmp'}{c_label}, 'Servicio ICMP sede-02', 'celda vacia sin --set: la plantilla del perfil');
ok($ml{'sede-02.local|mon_icmp'}{_label_default}, '... marcada como valor por defecto');
my ($ru) = parse_inventory("name;ip;view;c_label.mon_icmp\nsede-01;10.1.1.1;V;{nombre} x\n", $pi);
my (undef,$eu2) = expand($pi,$ru);
like(join(' ',@$eu2), qr/c_label\.mon_icmp usa \{nombre\}, que no es un parametro del perfil/, 'plantilla con un parametro que no existe: error');

#--- 0019: name_from, domain_from, ip_from ---------------------------------------------
my ($rf) = parse_inventory("name;ip;view;name_from;ip_from\nsede-10;10.1.1.1;V;sede-01;\nsede-02;10.1.1.50;V;;10.1.1.2\nsede-03;10.1.1.3;V;;\n", $pi);
my ($df) = expand($pi,$rf);
my @fd = grep { $_->{kind} eq 'device' } @$df;
is_deeply([ map { $_->{from} } @fd ], [ { name=>'sede-01' }, { ip=>'10.1.1.2' }, undef ], 'columnas *_from: a "from" del dispositivo; celda vacia = sin from');
my (undef,$ef) = parse_inventory("name;ip_from\nV;1.1.1.1\n", $pv);
like(join(' ',@$ef), qr/columna 'ip_from': el perfil crea 0 dispositivos por fila/, 'ip_from en un perfil sin dispositivo: error');
my $pf = { %$pi, parameters=>{ %{$pi->{parameters}}, ip_from=>{} } };
my ($rf2) = parse_inventory("name;ip;view;ip_from\nsede-01;10.1.1.1;V;9.9.9.9\n", $pf);
is_deeply([ $rf2->[0]{values}{ip_from}, scalar(keys %{$rf2->[0]{from}}) ], [ '9.9.9.9', 0 ], 'un parametro del perfil llamado ip_from: es el parametro');

done_testing();
