#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Test of the state validation and of diff() for every kind, with current states built by
# hand. No database.
#
#   cd /opt/cnm/control && perl t/CTL_plan.t
#------------------------------------------------------------------------------
use FindBin; use lib "$FindBin::Bin/../lib";
use strict;
use Test::More;
use CNMControl::Core qw(validate_state kinds);
use CNMControl::Kind::View;
use CNMControl::Kind::Device;
use CNMControl::Kind::Metric;

my $V='CNMControl::Kind::View'; my $D='CNMControl::Kind::Device'; my $M='CNMControl::Kind::Metric';

#--- 1. Order of the kinds --------------------------------------------------------
is_deeply([kinds()], ['view','device','metric'], 'orden: view, device, metric');

#--- 2. Validation ----------------------------------------------------------------
my @bad = (
	[ $D, { kind=>'device', name=>'a', domain=>'b' },                          qr/falta "ip"/ ],
	[ $D, { kind=>'device', name=>"a'b", domain=>'b', ip=>'1.1.1.1' },         qr/nombre no valido/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.300' },         qr/ip no valida/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', critic=>60 }, qr/critic/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', snmp=>{version=>3} }, qr/v3/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', snmp=>{version=>2} }, qr/community obligatoria/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', fields=>{X=>'a&|&b'} }, qr/no admitido/ ],
	[ $D, { kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', otra=>1 },  qr/clave desconocida 'otra'/ ],
	[ $M, { kind=>'metric', device=>'a.b' },                                     qr/falta "subtype"/ ],
	[ $M, { kind=>'metric', device=>'a', subtype=>'x' },                          qr/dispositivo no valido/ ],
	[ $M, { kind=>'metric', device=>'a.b', subtype=>'x', instances=>'todas' },   qr/instances/ ],
	[ $M, { kind=>'metric', device=>'a.b', subtype=>'x', instances=>{label_like=>'('} }, qr/expresion valida/ ],
	[ $M, { kind=>'metric', device=>'a.b', subtype=>'x', c_label=>'x' x 256 },    qr/255/ ],
	[ $V, { kind=>'view' },                                                           qr/falta "name"/ ],
	[ $V, { kind=>'view', name=>'V', create=>{} },                                   qr/MVP/ ],
);
foreach my $b (@bad) { my ($n,$e)=$b->[0]->validate($b->[1]); like($e // '', $b->[2], "rechazado: $b->[2]"); }

my ($n,$e) = $M->validate({ kind=>'metric', device=>'a.b', subtype=>'x', c_label=>'' });
ok(exists $n->{c_label} && !defined $n->{c_label}, 'c_label vacio = quitarlo (NULL)');
($n,$e) = $M->validate({ kind=>'metric', device=>'a.b', subtype=>'x' });
ok(!exists $n->{c_label}, 'sin c_label: no se gestiona');
is($n->{instances}, 'ALL', 'instancias por defecto: ALL');

# Repeated resources: identical ones are merged, different ones are an error
my ($bk,$err) = validate_state({ version=>1, resources=>[
	{ kind=>'view', name=>'V' }, { kind=>'view', name=>'V' },
	{ kind=>'metric', device=>'a.b', subtype=>'x', c_label=>'uno' },
	{ kind=>'metric', device=>'A.B', subtype=>'x', c_label=>'dos' } ] });
is(scalar(@{$bk->{view}}), 1, 'vista repetida e identica: una');
like($err->[0] // '', qr/repetido con valores distintos/, 'metrica repetida con c_label distinto: error');
($bk,$err) = validate_state({ version=>1, resources=>[ { kind=>'monitor' } ] });
like($err->[0] // '', qr/kind desconocido 'monitor'/, 'kind desconocido');

#--- 3. diff: device --------------------------------------------------------------
my $ctx = { cid=>'default', pending=>{}, cache=>{ types=>{ Router=>1 }, fields=>{ 'CNM-METRICS'=>'CNM-METRICS', 'PROVEEDOR'=>'Proveedor' },
				field_cols=>{ 'CNM-METRICS'=>'columna1', 'PROVEEDOR'=>'columna2' } } };
my ($r) = $D->validate({ kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.1' });
my ($acc,$er,$wa) = $D->diff($r, { by_ip=>[], by_name=>[] }, $ctx);
is($acc->[0]{op}, 'create', 'dispositivo nuevo: create');
ok($ctx->{pending}{'tda-01.local'}, 'el alta queda anotada para las metricas');
($acc,$er) = $D->diff($r, { by_ip=>[{ id_dev=>7, name=>'otro', domain=>'local', ip=>'10.0.0.1' }], by_name=>[] }, $ctx);
like($er->[0] // '', qr/ya es de otro\.local/, 'IP de otro dispositivo: conflicto');
($acc,$er) = $D->diff($r, { by_ip=>[{ id_dev=>7, name=>'TDA-01', domain=>'local', ip=>'10.0.0.1' }], by_name=>[] }, $ctx);
is(scalar(@$acc)+scalar(@$er), 0, 'ya existe con el mismo nombre: sin cambios');
# Existing device with user fields: warn only about real differences
my ($rf) = $D->validate({ kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.1', fields=>{ proveedor=>'ACME' } });
my $ex = { id_dev=>7, name=>'tda-01', domain=>'local', ip=>'10.0.0.1', custom=>{ columna2=>'ACME' } };
($acc,$er,$wa) = $D->diff($rf, { by_ip=>[$ex], by_name=>[] }, $ctx);
is(scalar(@$acc)+scalar(@$er)+scalar(@$wa), 0, 'existente con los mismos campos: ni acciones ni avisos');
($acc,$er,$wa) = $D->diff($rf, { by_ip=>[{ %$ex, custom=>{ columna2=>'Otro' } }], by_name=>[] }, $ctx);
like(join(' ',@$wa), qr/difiere: proveedor 'Otro' -> 'ACME'/, 'existente con un campo distinto: aviso con el cambio');
($acc,$er,$wa) = $D->diff($rf, { by_ip=>[{ %$ex, custom=>{} }], by_name=>[] }, $ctx);
like(join(' ',@$wa), qr/'-' -> 'ACME'/, 'campo sin valor guardado: se compara con el defecto del motor');
($acc,$er) = $D->diff($r, { by_ip=>[], by_name=>[{ id_dev=>8, ip=>'10.9.9.9' }] }, $ctx);
like($er->[0] // '', qr/ya lo usa la IP 10\.9\.9\.9/, 'nombre usado con otra IP: conflicto');
($r) = $D->validate({ kind=>'device', name=>'x', domain=>'l', ip=>'10.0.0.5', type=>'Switch' });
($acc,$er) = $D->diff($r, { by_ip=>[], by_name=>[] }, $ctx);
like($er->[0] // '', qr/tipo 'Switch' no existe/, 'tipo inexistente');

#--- 4. diff: metric --------------------------------------------------------------
my $views = { Tiendas=>{ id=>162, live_metric=>0, cid=>'default', cid_ip=>'1.1.1.1' }, Viva=>{ id=>5, live_metric=>1 } };
my $cat = { type=>'latency', lapse=>60 };
($r) = $M->validate({ kind=>'metric', device=>'tda-01.local', subtype=>'disp_icmp', c_label=>'D tda-01', views=>['Tiendas'] });

# a) metric that does not exist, on a device created in the same state
($acc,$er) = $M->diff($r, { dev_ids=>[], metric=>undef, in_views=>{}, views=>$views, cat=>$cat }, $ctx);
is(join(',', map { $_->{op} } @$acc), 'provision,c_label,view+', 'nueva: provision, c_label y vista');
is($acc->[0]{lapse}, 60, 'lapse del repositorio');

# b) everything is already as requested
my $met = { id_metric=>900, status=>'0', c_label=>'D tda-01' };
($acc,$er) = $M->diff($r, { dev_ids=>[12], metric=>$met, in_views=>{162=>1}, views=>$views, cat=>$cat }, $ctx);
is(scalar(@$acc)+scalar(@$er), 0, 'idempotente: sin acciones');

# c) only the title changes
($acc) = $M->diff($r, { dev_ids=>[12], metric=>{ %$met, c_label=>'viejo' }, in_views=>{162=>1}, views=>$views, cat=>$cat }, $ctx);
is(join(',', map { "$_->{op}:".($_->{before}//'') } @$acc), 'c_label:viejo', 'solo c_label, con el valor de antes');

# d) errors the plan must report
my @cases = (
	[ { dev_ids=>[], metric=>undef, in_views=>{}, views=>$views, cat=>$cat }, { %$ctx, pending=>{}, failed=>{} }, qr/no existe ni se crea/ ],
	[ { dev_ids=>[1,2], metric=>undef, in_views=>{}, views=>$views, cat=>$cat }, $ctx,              qr/hay 2 dispositivos/ ],
	[ { dev_ids=>[12], metric=>undef, in_views=>{}, views=>$views, cat=>undef }, $ctx,               qr/no existe en el repositorio/ ],
	[ { dev_ids=>[12], metric=>undef, in_views=>{}, views=>$views, cat=>{type=>'snmp'} }, $ctx,      qr/solo provisiona latencia/ ],
	[ { dev_ids=>[12], metric=>undef, in_views=>{}, views=>{}, cat=>$cat }, $ctx,                    qr/vista 'Tiendas' no existe/ ],
);
foreach my $c (@cases) { ($acc,$er) = $M->diff($r, $c->[0], $c->[1]); like(join(' ',@$er), $c->[2], "metrica: $c->[2]"); ok(!@$acc, '... y sin acciones'); }
my ($rv) = $M->validate({ kind=>'metric', device=>'tda-01.local', subtype=>'disp_icmp', views=>['Viva'] });
($acc,$er) = $M->diff($rv, { dev_ids=>[12], metric=>$met, in_views=>{}, views=>$views, cat=>$cat }, $ctx);
like(join(' ',@$er), qr/es viva/, 'vista viva: error');
my ($ri) = $M->validate({ kind=>'metric', device=>'a.b', subtype=>'disp_icmp', instances=>{ label_like=>'^C:' }, watch=>'s_x' });
($acc,$er) = $M->diff($ri, { dev_ids=>[12], metric=>undef, in_views=>{}, views=>{}, cat=>$cat }, $ctx);
like(join(' ',@$er), qr/instances.*MVP.*watch.*MVP/s, 'instancias y watch: formato aceptado, el plan los rechaza');
($acc,$er,$wa) = $M->diff($r, { dev_ids=>[12], metric=>{ %$met, status=>3 }, in_views=>{162=>1}, views=>$views, cat=>$cat }, $ctx);
like(join(' ',@$wa), qr/desactivada/, 'metrica desactivada: aviso');

# e) derived errors: same message, flagged, when the device or view resource already failed
($acc,$er) = $M->diff($r, { dev_ids=>[], metric=>undef, in_views=>{}, views=>$views, cat=>$cat }, { %$ctx, pending=>{}, failed=>{ 'tda-01.local'=>1 } });
ok((ref($er->[0]) eq 'HASH') && $er->[0]{derived} && ($er->[0]{text} =~ /no existe ni se crea/), 'dispositivo que ya fallo: error derivado');
($acc,$er) = $M->diff($r, { dev_ids=>[12], metric=>undef, in_views=>{}, views=>{}, cat=>$cat }, { %$ctx, failed_view=>{ Tiendas=>1 } });
ok((ref($er->[0]) eq 'HASH') && $er->[0]{derived}, 'vista que ya fallo: error derivado');

# f) is the metric to create in the assistant of the existing device?
my $base = { dev_ids=>[12], metric=>undef, in_views=>{162=>1}, views=>$views, cat=>$cat };
($acc,$er,$wa) = $M->diff($r, { %$base, assistant=>{} }, { %$ctx, pending=>{} });
like(join(' ',@$wa), qr/no tiene asistente calculado/, 'existente sin asistente: aviso');
($acc,$er,$wa) = $M->diff($r, { %$base, assistant=>{ mon_icmp=>1 } }, { %$ctx, pending=>{} });
like(join(' ',@$wa), qr/disp_icmp no esta en el asistente/, 'existente cuyo asistente no la ofrece: aviso');
ok(scalar(grep { $_->{op} eq 'provision' } @$acc), '... y se provisiona igualmente');
($acc,$er,$wa) = $M->diff($r, { %$base, assistant=>{ disp_icmp=>1 } }, { %$ctx, pending=>{} });
is(scalar(@$wa), 0, 'existente cuyo asistente la ofrece: sin aviso');
($acc,$er,$wa) = $M->diff($r, { %$base, dev_ids=>[], assistant=>undef }, { %$ctx, pending=>{ 'tda-01.local'=>1 } });
is(scalar(@$wa), 0, 'dispositivo nuevo: sin aviso en el plan (su asistente se calcula al aplicar)');

#--- 5. diff: view ----------------------------------------------------------------
($acc,$er) = $V->diff({ name=>'X' }, undef, $ctx);   like($er->[0], qr/no existe/, 'vista inexistente');
($acc,$er) = $V->diff({ name=>'X' }, { live_metric=>1 }, $ctx); like($er->[0], qr/viva/, 'vista viva');

done_testing();
