#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de los modulos de designer/testbed (cnm-testbed): Testbed::Agent,
# Testbed::SnmpdConf y Testbed::Snapshot. No necesita base de datos ni snmpd.
#
#   perl t/MISC_testbed.t            (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use FindBin;
use lib "$FindBin::Bin/../../../designer/testbed/lib", "/opt/cnm/designer/testbed/lib";
use strict;
use Test::More;
use Testbed::Agent qw(BASE_OID parse_scenario check_scenario scenario_text table_rows oid_cmp
							 walk_kind read_step parse_reads reads_text answer_get answer_getnext);
use Testbed::SnmpdConf qw(has_block set_block remove_block block_names);
use Testbed::Battery qw(cases select_cases parse_modes expected set_guard_line evaluate split_blues NOTICE_SKIP NOTICE_REREAD);
use Testbed::Engine qw(parse_ps crawlers stale_crawlers);
use Testbed::Ucd qw(UCD_ENTERPRISE is_ucd_monitor ucd_subtypes_in_use);
use Testbed::Snapshot qw(inactive_mnames label_keyed diff_snapshots diff_is_empty diff_lines restore_plan);

my $E = BASE_OID.'.1.1';	# cnmTestbedEntry

# Recorre una columna como snmpwalk: getnext desde la columna hasta salir de ella.
# Devuelve las etiquetas o valores y simula el contador de lecturas del agente.
my $READS = 0; my $ST = { reads=>0, labels=>0 };
sub walk {
my ($s,$col)=@_;
	my $base = "$E.$col";
	my $oid = $base;
	my @out = ();
	$ST = read_step($ST,$oid); $READS = $ST->{reads};
	while (1) {
		my $vb = answer_getnext($s,$oid,$READS);
		last if ((! $vb) || (index($vb->[0],"$base.") != 0));
		push @out, $vb->[2];
		$oid = $vb->[0];
	}
	return \@out;
}

#--- Agent: escenarios ----------------------------------------------------------
my $s = parse_scenario(undef);
is($s->{mode}, 'complete', 'escenario por defecto: complete');
is(check_scenario($s), '', 'escenario por defecto: valido');
like(check_scenario(parse_scenario("mode = nada\n")), qr/modo desconocido/, 'modo desconocido');
like(check_scenario(parse_scenario("rows = 0\n")), qr/rows/, 'rows 0 no vale');
like(check_scenario(parse_scenario("rows = 3\ncut_at = 4\n")), qr/cut_at/, 'cut_at > rows no vale');
like(check_scenario(parse_scenario("rows = 3\nmode = drop\ndrop = 5\n")), qr/drop/, 'drop fuera de rango');
my $t = parse_scenario(scenario_text(parse_scenario("mode = drop\nrows = 6\ndrop = 2,4\ndelay = 1\n")));
is_deeply([$t->{mode},$t->{rows},$t->{drop},$t->{delay}], ['drop',6,[2,4],1], 'scenario_text ida y vuelta');

is(oid_cmp('.1.3.6.1.10','.1.3.6.1.9'), 1, 'oid_cmp numerico, no de texto');
is(oid_cmp('.1.3.6','.1.3.6.1'), -1, 'oid_cmp: el prefijo va antes');

$READS=0;
is_deeply(walk(parse_scenario("mode = complete\nrows = 4\n"),2), ['fila-1','fila-2','fila-3','fila-4'], 'complete: 4 etiquetas');
is_deeply(walk(parse_scenario("mode = complete\nrows = 4\n"),3), [10,20,30,40], 'complete: 4 valores');
is_deeply(walk(parse_scenario("mode = empty\n"),2), [], 'empty: ninguna fila');
is_deeply(walk(parse_scenario("mode = drop\nrows = 5\ndrop = 2,4\n"),2), ['fila-1','fila-3','fila-5'], 'drop: faltan 2 y 4');
is_deeply(walk(parse_scenario("mode = reorder\nrows = 3\n"),2), ['fila-3','fila-2','fila-1'], 'reorder: mismas etiquetas, otros indices');

# Una lectura como la de snmp_get_iid: primero la columna de valores, luego la de etiquetas
sub iid_read { my $s=shift; my $v=walk($s,3); my $l=walk($s,2); return [ $v, $l ]; }
my $once = parse_scenario("mode = cut-once\nrows = 5\ncut_at = 2\n");
$ST={reads=>0,labels=>0};
is_deeply(iid_read($once), [[10,20],['fila-1','fila-2']], 'cut-once: la primera lectura se corta en 2, valores y etiquetas');
is_deeply(iid_read($once), [[10,20,30,40,50],['fila-1','fila-2','fila-3','fila-4','fila-5']], 'cut-once: la segunda sale entera, valores y etiquetas');
is($READS, 2, 'cut-once: dos lecturas contadas');
my $always = parse_scenario("mode = cut-always\nrows = 5\ncut_at = 3\n");
$ST={reads=>0,labels=>0};
is_deeply(iid_read($always), [[10,20,30],['fila-1','fila-2','fila-3']], 'cut-always: primera lectura cortada');
is_deeply(iid_read($always), [[10,20,30],['fila-1','fila-2','fila-3']], 'cut-always: segunda lectura cortada igual');
# El crawler recorre solo la columna de valores: no hace avanzar la cuenta
$ST={reads=>0,labels=>0};
is_deeply(walk($once,3), [10,20], 'crawler antes de la provision: recibe la lectura 1, cortada');
is_deeply(walk($once,3), [10,20], 'crawler otra vez: sigue en la lectura 1');
is_deeply(iid_read($once), [[10,20],['fila-1','fila-2']], 'la provision recibe su lectura cortada aunque el crawler haya leido antes');
is_deeply(walk($once,3), [10,20,30,40,50], 'crawler entre la primera lectura y la segunda: ya es la lectura 2');
is_deeply(iid_read($once), [[10,20,30,40,50],['fila-1','fila-2','fila-3','fila-4','fila-5']], 'la segunda lectura de la provision sale entera');
is($READS, 2, 'crawler + provision: dos lecturas');

# El corte es silencioso: tras la ultima fila cortada viene la otra columna, no un error
my $vb = answer_getnext($always,"$E.2.3",1);
is($vb->[0], "$E.3.1", 'corte silencioso: despues viene la columna de valores');
# Un get de una fila concreta responde aunque la lectura vaya cortada
my $g5 = answer_get($always,"$E.3.5");
is((defined $g5) ? $g5->[2] : undef, 50, 'get de la fila 5 con cut-always: responde');
is(answer_get($always,"$E.3.9"), undef, 'get de una fila que no existe: NONE');
is(walk_kind("$E.3"), 'value', 'walk_kind: columna de valores');
is(walk_kind("$E.2"), 'label', 'walk_kind: columna de etiquetas');
is(walk_kind(BASE_OID), 'branch', 'walk_kind: la tabla');
is(walk_kind("$E.3.2"), undef, 'walk_kind: a mitad de recorrido, nada');
is(walk_kind('.1.3.6.1.2.1.1'), undef, 'walk_kind: fuera de la tabla, nada');
is_deeply(read_step({reads=>0,labels=>0},"$E.2"), {reads=>1,labels=>1}, 'read_step: etiquetas sin lectura empezada: lectura 1');
is_deeply(read_step({reads=>1,labels=>0},"$E.2"), {reads=>1,labels=>1}, 'read_step: etiquetas detras de los valores: misma lectura');
is_deeply(read_step({reads=>1,labels=>1},BASE_OID), {reads=>2,labels=>1}, 'read_step: recorrido de toda la tabla: lectura nueva y completa');
is_deeply(read_step({reads=>1,labels=>0},BASE_OID), {reads=>1,labels=>1}, 'read_step: toda la tabla sin haber recorrido etiquetas: misma lectura');
is_deeply(parse_reads("4\n"), {reads=>4,labels=>0}, 'parse_reads: formato antiguo');
is_deeply(parse_reads(reads_text({reads=>3,labels=>1})), {reads=>3,labels=>1}, 'reads_text y parse_reads: ida y vuelta');
is_deeply(parse_reads(undef), {reads=>0,labels=>0}, 'parse_reads: sin fichero');
is(answer_getnext($always,"$E.3.5",1), undef, 'fin de la tabla: NONE');

#--- SnmpdConf ------------------------------------------------------------------
my $conf = "rocommunity x\nview all included .1\n";
my $c1 = set_block($conf,'agent',['pass_persist .1.3 /usr/bin/perl /x']);
ok(has_block($c1,'agent'), 'set_block: el bloque esta');
like($c1, qr/^rocommunity x\nview all included \.1\n/, 'set_block: el resto no cambia');
is(remove_block($c1,'agent'), $conf, 'remove_block: vuelve al texto original');
my $c2 = set_block($c1,'agent',['otra linea']);
is(scalar(() = $c2 =~ /cnm-testbed:agent begin/g), 1, 'set_block sustituye, no duplica');
like($c2, qr/otra linea/, 'set_block: contenido nuevo');
unlike($c2, qr/pass_persist/, 'set_block: el contenido viejo ya no esta');
my $c3 = set_block($c2,'view',['view all excluded .1.3.6.1.2.1.25.2']);
is_deeply([block_names($c3)], ['agent','view'], 'block_names: los dos bloques');
is(remove_block(remove_block($c3,'view'),'agent'), $conf, 'quitar los dos bloques: vuelve al original');
ok(! has_block($conf,'agent'), 'has_block: sin bloque');
is(remove_block(set_block('','agent',['x']),'agent'), '', 'bloque en un fichero vacio: al quitarlo queda vacio');
is(remove_block($conf,'agent'), $conf, 'remove_block sin bloque: no cambia nada');
unlike(remove_block($c3,'agent'), qr/otra linea/, 'remove_block quita solo su bloque');
like(remove_block($c3,'agent'), qr/excluded/, 'remove_block deja los demas bloques');

#--- Snapshot -------------------------------------------------------------------
my $A = { parents => { d=>{subtype=>'d',id_template_metric=>7} },
	template => {
		'd|1' => { subtype=>'d', iid=>1, hiid=>'h1', mname=>'d-1', watch=>'s_m', label=>'L1', status=>0, id_template_metric=>7 },
		'd|2' => { subtype=>'d', iid=>2, hiid=>'h2', mname=>'d-2', watch=>'0',   label=>'L2', status=>0, id_template_metric=>7 } },
	metrics => { 'd-1' => { name=>'d-1', c_label=>'C1', watch=>'s_m', status=>0 },
					 'd-2' => { name=>'d-2', c_label=>'',   watch=>'0',   status=>0 } },
	blue => [ 'd-2' ] };
ok(diff_is_empty(diff_snapshots($A,$A)), 'diff de una foto consigo misma: vacio');
ok(! diff_is_empty(diff_snapshots($A, { %$A, blue=>[] })), 'diff solo de azules: no vacio');

my $B = { parents => { d=>{subtype=>'d',id_template_metric=>7}, x=>{subtype=>'x',id_template_metric=>9} },
	template => {
		'd|1' => { %{$A->{template}{'d|1'}}, watch=>'0' },
		'd|3' => { subtype=>'d', iid=>3, hiid=>'h3', mname=>'d-3', watch=>'0', label=>'L3', status=>0, id_template_metric=>7 } },
	metrics => { 'd-1' => { name=>'d-1', c_label=>'', watch=>'0', status=>0 },
					 'd-3' => { name=>'d-3', c_label=>'', watch=>'0', status=>0 } },
	blue => [ 'd-3' ] };
my $d = diff_snapshots($A,$B);
ok(! diff_is_empty($d), 'diff con cambios: no vacio');
is_deeply($d->{template}{removed}, ['d|2'], 'diff: instancia quitada');
is_deeply($d->{template}{added}, ['d|3'], 'diff: instancia nueva');
is_deeply($d->{template}{changed}, [['d|1','watch','s_m','0']], 'diff: monitor perdido');
is_deeply($d->{metrics}{changed}, [['d-1','c_label','C1',''],['d-1','watch','s_m','0']], 'diff: c_label y monitor de la metrica');
is_deeply($d->{blue}, { removed=>['d-2'], added=>['d-3'] }, 'diff: azules');
ok(scalar(diff_lines($d)) >= 6, 'diff_lines: una linea por diferencia');

my $p = restore_plan($A,$B);
is(scalar(@{$p->{template_insert}}), 1, 'plan: repone una instancia');
is($p->{template_insert}[0]{hiid}, 'h2', 'plan: repone la que falta');
is(scalar(@{$p->{template_update}}), 1, 'plan: una instancia que cambia');
is_deeply($p->{template_update}[0][1], ['watch'], 'plan: solo cambia el monitor');
is(scalar(@{$p->{template_delete}}), 1, 'plan: quita una instancia que sobra');
is($p->{template_delete}[0]{hiid}, 'h3', 'plan: quita la que sobra');
is_deeply([map { $_->{subtype} } @{$p->{parents_delete}}], ['x'], 'plan: quita la plantilla de subtipo que sobra');
is(scalar(@{$p->{parents_insert}}), 0, 'plan: ninguna plantilla de subtipo que falte');
is_deeply($p->{c_label}, [['d-1','C1'],['d-2','']], 'plan: el c_label de cada metrica de la foto');
my $p0 = restore_plan($A,$A);
is(scalar(@{$p0->{template_insert}})+scalar(@{$p0->{template_update}})+scalar(@{$p0->{template_delete}})
	+scalar(@{$p0->{parents_insert}})+scalar(@{$p0->{parents_delete}}), 0, 'plan sobre la misma foto: no hace nada');

# Instancias inactivas (status distinto de 0): sus metricas no se comparan
my $I = { %$A, template => { %{$A->{template}},
		'd|9' => { subtype=>'d', iid=>9, hiid=>'h9', mname=>'d-9', watch=>'0', label=>'L9', status=>1, id_template_metric=>7 } },
	metrics => { %{$A->{metrics}}, 'd-9' => { name=>'d-9', c_label=>'', watch=>'0', status=>0 } } };
my $I2 = { %$I, metrics => { %{$A->{metrics}} } };
is_deeply(inactive_mnames($I), { 'd-9'=>1 }, 'inactive_mnames: solo la instancia con status 1');
is_deeply(inactive_mnames($A), {}, 'inactive_mnames: ninguna si todas estan activas');
ok(diff_is_empty(diff_snapshots($I,$I2)), 'diff: falta la metrica de una instancia inactiva: no cuenta');
ok(diff_is_empty(diff_snapshots($I2,$I)), 'diff: aparece la metrica de una instancia inactiva: no cuenta');
my $IA = { %$I, metrics => { 'd-1' => $A->{metrics}{'d-1'}, 'd-9' => $I->{metrics}{'d-9'} } };
is_deeply(diff_snapshots($I,$IA)->{metrics}{removed}, ['d-2'], 'diff: la metrica de una instancia activa que falta si cuenta');
my $IB = { %$I, template => { %{$I->{template}}, 'd|9' => { %{$I->{template}{'d|9'}}, status=>0 } } };
is_deeply(diff_snapshots($IB,$I)->{template}{changed}, [['d|9','status','0','1']], 'diff: el cambio de status de la plantilla si cuenta');
my $IC = { %$I2 };
is_deeply(diff_snapshots($IB,$IC)->{metrics}{removed}, [], 'diff: la instancia pasa a inactiva y su metrica se va: no cuenta como metrica perdida');
is_deeply(diff_snapshots($IC,$IB)->{metrics}{added}, [], 'diff: la instancia pasa a activa y aparece su metrica: no cuenta como metrica nueva');

#--- Ucd: si hay que esperar tras reiniciar snmpd --------------------------------
# Filas como las de cnm-test (cfg_monitor_snmp, consulta del 2026-11-21)
my $cpu  = { subtype=>'ucd_cpu_usage', status=>0, enterprise=>2021, oid=>'.1.3.6.1.4.1.2021.11.11.0|.1.3.6.1.4.1.2021.11.9.0|.1.3.6.1.4.1.2021.11.10.0' };
my $disk = { subtype=>'disk_mibhost', status=>0, enterprise=>0, oid=>'.1.3.6.1.2.1.25.2.3.1.5.IID|.1.3.6.1.2.1.25.2.3.1.6.IID' };
my $tb   = { subtype=>'cnm_testbed_rows', status=>0, enterprise=>0, oid=>'.1.3.6.1.4.1.8072.9999.9999.7.1.1.3.IID' };
ok(is_ucd_monitor($cpu), 'is_ucd_monitor: ucd_cpu_usage');
ok(! is_ucd_monitor($disk), 'is_ucd_monitor: disk_mibhost (HOST-RESOURCES) no');
ok(! is_ucd_monitor($tb), 'is_ucd_monitor: la tabla de prueba (8072) no');
ok(is_ucd_monitor({ enterprise=>'02021', oid=>'' }), 'is_ucd_monitor: enterprise con 5 cifras (02021)');
ok(is_ucd_monitor({ enterprise=>0, oid=>'.1.3.6.1.4.1.2021.4.6.0' }), 'is_ucd_monitor: subtipo a medida sin enterprise, por el OID');
ok(is_ucd_monitor({ enterprise=>0, oid=>'.1.3.6.1.2.1.1.3.0|1.3.6.1.4.1.2021.10.1.3.1' }), 'is_ucd_monitor: OID UCD en segundo lugar y sin punto inicial');
ok(! is_ucd_monitor({ enterprise=>20210, oid=>'.1.3.6.1.4.1.20210.1.0' }), 'is_ucd_monitor: 20210 no es 2021');
ok(! is_ucd_monitor({ enterprise=>undef, oid=>undef }), 'is_ucd_monitor: sin datos, no');
is_deeply([ucd_subtypes_in_use([$disk,$tb,$cpu,{%$cpu}])], ['ucd_cpu_usage'], 'ucd_subtypes_in_use: el subtipo UCD una vez');
is_deeply([ucd_subtypes_in_use([$disk,$tb])], [], 'ucd_subtypes_in_use: sin UCD, no se espera');
is_deeply([ucd_subtypes_in_use([{%$cpu, status=>1}, $disk])], [], 'ucd_subtypes_in_use: fila UCD inactiva, no se espera');
is_deeply([ucd_subtypes_in_use([])], [], 'ucd_subtypes_in_use: plantilla vacia');

#--- Agent: drop junto con el corte ------------------------------------------------
my $cd = { mode=>'cut-once', rows=>5, cut_at=>2, drop=>[5], delay=>0 };
is_deeply([map { $_->[1] } @{Testbed::Agent::table_rows($cd,1,0)}], ['fila-1','fila-2'], 'cut-once con drop: la primera lectura cortada');
is_deeply([map { $_->[1] } @{Testbed::Agent::table_rows($cd,2,0)}], ['fila-1','fila-2','fila-3','fila-4'], 'cut-once con drop: la segunda sin la fila 5');
is_deeply([map { $_->[1] } @{Testbed::Agent::table_rows({ %$cd, mode=>'complete' },1,0)}], ['fila-1','fila-2','fila-3','fila-4'], 'complete con drop: sin la fila 5');

#--- Battery ------------------------------------------------------------------------
my @CS = cases();
is(scalar(@CS), 11, 'battery: 11 casos');
is_deeply([map { $_->{id} } @CS], [1..11], 'battery: numerados del 1 al 11');
is_deeply([map { $_->{id} } @{(select_cases(''))[0]}], [1..10], 'select_cases: por defecto, sin el exploratorio');
is_deeply([map { $_->{id} } @{(select_cases('11'))[0]}], [11], 'select_cases: el exploratorio, si se pide');
ok(! grep({ Testbed::Agent::check_scenario($_->{scenario}) ne '' } @CS), 'battery: todos los escenarios son validos para el agente');
my ($sel,$se) = select_cases('reorder,4');
is_deeply([map { $_->{id} } @$sel], [4,7], 'select_cases: por nombre y numero, en el orden de la bateria');
is((select_cases('99'))[1], 'caso desconocido: 99', 'select_cases: caso desconocido');
is_deeply((parse_modes(undef))[0], ['0','2','1'], 'parse_modes: por defecto 0,2,1');
is_deeply((parse_modes('1,1,0'))[0], ['1','0'], 'parse_modes: sin repetir');
like((parse_modes('3'))[1], qr/no valido/, 'parse_modes: 3 no vale');
my ($c2)  = grep { $_->{name} eq 'empty' } @CS;
is_deeply(expected($c2,'2'), expected($c2,'0'), 'expected: con 2 se espera lo mismo que con 0');
isnt(scalar(@{expected($c2,'1')->{rows}}), scalar(@{expected($c2,'0')->{rows}}), 'expected: con 1, otra cosa');
is(set_guard_line("a = 1\n#PROV_GUARD = 9\nPROV_GUARD = 2\nb = 2\n", 1), "a = 1\n#PROV_GUARD = 9\nb = 2\nPROV_GUARD = 1\n", 'set_guard_line: una linea activa al final, la comentada se queda');
is(set_guard_line("a = 1", 0), "a = 1\nPROV_GUARD = 0\n", 'set_guard_line: fichero sin salto final');
is(set_guard_line(set_guard_line("a = 1\n",2),1), "a = 1\nPROV_GUARD = 1\n", 'set_guard_line dos veces: una sola linea');

# Fotos sinteticas: base con las 5 filas, monitor en 2 y 4, c_label en 1 y 3, y otras filas
sub tb_snap {
	my (%o)=@_;
	my %t = ( 'disk_mibhost|35' => { subtype=>'disk_mibhost', iid=>35, watch=>'0', status=>0, label=>'USO DE DISCO /run' },
				 'ucd_cpu_usage|ALL' => { subtype=>'ucd_cpu_usage', iid=>'ALL', watch=>'0', status=>0, label=>'USO DE CPU (%)' } );
	foreach my $i (@{$o{rows}}) {
		my $lab = $o{labels} ? $o{labels}{$i} : $i;
		$t{"cnm_testbed_rows|$i"} = { subtype=>'cnm_testbed_rows', iid=>$i, label=>"CNM-TESTBED fila-$lab (x)",
			watch=>(defined $o{watch}{$i} ? $o{watch}{$i} : (($i==2)||($i==4) ? 's_m' : '0')), status=>(defined $o{status}{$i} ? $o{status}{$i} : 0) };
	}
	delete $t{'ucd_cpu_usage|ALL'} if ($o{no_ucd});
	delete $t{'disk_mibhost|35'} if ($o{no_disk});
	my %m = map { ("cnm_testbed_rows-$_" => { name=>"cnm_testbed_rows-$_", c_label=>'', status=>0 }) } 1..6;
	$m{"cnm_testbed_rows-$_"}{status}=3 foreach (@{$o{retired} || []});
	delete $m{"cnm_testbed_rows-$_"} foreach (@{$o{gone} || []});
	$m{'cnm_testbed_rows-1'}{c_label}='CL1'; $m{'cnm_testbed_rows-3'}{c_label}='CL3';
	$m{$_}{c_label}=$o{clab}{$_} foreach (keys %{$o{clab} || {}});
	return { template=>\%t, metrics=>\%m };
}
my $BS = tb_snap(rows=>[1..5]);
my ($c1,$c3,$c4,$c5,$c6,$c7,$c8,$c9,$c10) = map { my $n=$_; (grep { $_->{name} eq $n } @CS)[0] }
	qw(complete empty-forced cut-once drop cut-always reorder cut-once-drop new-row snmpd-restart);
sub ev { my ($c,$m,$after,%x)=@_; return [ evaluate({ case=>$c, mode=>$m, remap=>$x{remap}||0, base=>$BS, after=>$after, notices=>$x{n}||[] }) ]; }
my $SKIP = { descr=>NOTICE_SKIP, rcstr=>'x cnm_testbed_rows: sin datos' };
my $SKIPO = { descr=>NOTICE_SKIP, rcstr=>'Observacion, no se aplica: x cnm_testbed_rows: sin datos' };
my $RER = { descr=>NOTICE_REREAD, rcstr=>'x cnm_testbed_rows: faltaban' };
my $REO = { descr=>NOTICE_REREAD, rcstr=>'Observacion, no se aplica: x' };

is_deeply(ev($c1,'0',$BS), [], 'evaluate complete 0: OK');
is_deeply(ev($c1,'1',$BS), [], 'evaluate complete 1: OK');
is_deeply(ev($c2,'1',$BS, n=>[$SKIP]), [], 'evaluate empty 1: filas y aviso: OK');
is(scalar(@{ev($c2,'1',$BS)}), 1, 'evaluate empty 1 sin aviso: FALLA');
is(scalar(grep { /tenia que quedar/ } @{ev($c2,'1',tb_snap(rows=>[]), n=>[$SKIP])}), 5, 'evaluate empty 1 sin filas: FALLA por cada fila');
is(scalar(grep { /quitada: su metrica sigue/ } @{ev($c2,'1',tb_snap(rows=>[]), n=>[$SKIP])}), 5, 'evaluate empty 1 sin filas: y por cada metrica sin retirar');
is_deeply(ev($c2,'0',tb_snap(rows=>[])), [], 'evaluate empty 0: se pierden, como hoy: OK');
is_deeply(ev($c2,'2',tb_snap(rows=>[]), n=>[$SKIPO]), [], 'evaluate empty 2: como hoy y con aviso de observacion: OK');
ok(grep({ /Observacion/ } @{ev($c2,'2',tb_snap(rows=>[]), n=>[$SKIP])}), 'evaluate empty 2 con aviso sin "Observacion": FALLA');
ok(grep({ /Observacion/ } @{ev($c2,'1',$BS, n=>[$SKIPO])}), 'evaluate empty 1 con aviso de observacion: FALLA');
ok(grep({ /PROV_GUARD 0 no tenia/ } @{ev($c2,'0',tb_snap(rows=>[]), n=>[$SKIP])}), 'evaluate con 0 y un aviso: FALLA');
is_deeply(ev($c3,'1',tb_snap(rows=>[], retired=>[1..5])), [], 'evaluate empty-forced 1: se pierden y sus metricas se retiran: OK');
is_deeply(ev($c4,'1',$BS, n=>[$RER]), [], 'evaluate cut-once 1: se recuperan: OK');
is_deeply(ev($c4,'0',tb_snap(rows=>[1,2])), [], 'evaluate cut-once 0: quedan 1 y 2: OK');
is_deeply(ev($c4,'2',tb_snap(rows=>[1,2]), n=>[$REO]), [], 'evaluate cut-once 2: como hoy, con aviso: OK');
ok(grep({ /aviso que no se esperaba/ } @{ev($c4,'1',$BS, n=>[$RER,$SKIP])}), 'evaluate: un aviso de otro tipo: FALLA');
is_deeply(ev($c5,'1',tb_snap(rows=>[1,3,5], retired=>[2,4])), [], 'evaluate drop 1: se van 2 y 4, y sus metricas se retiran: OK');
is_deeply(ev($c5,'1',tb_snap(rows=>[1,3,5], retired=>[2], gone=>[4])), [], 'evaluate drop 1: una retirada y otra ya borrada por cnm-watch: OK');
ok(grep({ /fila 4 quitada: su metrica sigue con status 0/ } @{ev($c5,'1',tb_snap(rows=>[1,3,5], retired=>[2]))}), 'evaluate drop 1 con la metrica de la 4 activa: FALLA (4.107)');
is_deeply(ev($c5,'0',tb_snap(rows=>[1,3,5])), [], 'evaluate drop 0: se van 2 y 4, sus metricas se quedan (como hoy): OK');
ok(grep({ /fila 2 quitada: con PROV_GUARD 0 su metrica no se tenia que retirar/ } @{ev($c5,'0',tb_snap(rows=>[1,3,5], retired=>[2]))}), 'evaluate drop 0 con una metrica retirada: FALLA');
ok(grep({ /con PROV_GUARD 2 su metrica no/ } @{ev($c5,'2',tb_snap(rows=>[1,3,5], retired=>[4]))}), 'evaluate drop 2 con una metrica retirada: FALLA');
is_deeply(ev($c6,'1',tb_snap(rows=>[1,2], retired=>[3..5])), [], 'evaluate cut-always 1: limite aceptado (se retiran 3 a 5): OK');
is_deeply(ev($c8,'1',tb_snap(rows=>[1..4], retired=>[5]), n=>[$RER]), [], 'evaluate cut-once-drop 1: vuelven 3 y 4, la 5 se va y se retira: OK');
ok(grep({ /fila 5: no tenia/ } @{ev($c8,'1',$BS, n=>[$RER])}), 'evaluate cut-once-drop 1 con la fila 5: FALLA');
is_deeply(ev($c9,'0',tb_snap(rows=>[1..6], status=>{6=>1})), [], 'evaluate new-row: fila 6 inactiva: OK');
ok(grep({ /status 0 en vez de 1/ } @{ev($c9,'0',tb_snap(rows=>[1..6]))}), 'evaluate new-row con la fila 6 activa: FALLA');
ok(grep({ /monitor s_m en vez de ninguno/ } @{ev($c9,'0',tb_snap(rows=>[1..6], status=>{6=>1}, watch=>{6=>'s_m'}))}), 'evaluate new-row con monitor en la 6: FALLA');
ok(grep({ /fila 2: watch 0 en vez de s_m/ } @{ev($c1,'0',tb_snap(rows=>[1..5], watch=>{2=>'0'}))}), 'evaluate: monitor perdido: FALLA');
ok(grep({ /fila 1: status 1 en vez de 0/ } @{ev($c1,'0',tb_snap(rows=>[1..5], status=>{1=>1}))}), 'evaluate: status cambiado: FALLA');
ok(grep({ /disk_mibhost\|label=USO DE DISCO \/run ha desaparecido/ } @{ev($c1,'0',tb_snap(rows=>[1..5], no_disk=>1))}), 'evaluate: otra fila de la plantilla desaparece: FALLA');
ok(grep({ /ucd_cpu_usage\|ALL ha desaparecido/ } @{ev($c1,'0',tb_snap(rows=>[1..5], no_ucd=>1))}), 'evaluate: ucd_cpu_usage desaparece en otro caso: FALLA');
is_deeply(ev($c10,'0',tb_snap(rows=>[1..5], no_ucd=>1)), [], 'evaluate snmpd-restart 0: se pierde ucd_cpu_usage: OK');
is_deeply(ev($c10,'1',$BS, n=>[{ descr=>NOTICE_SKIP, rcstr=>'x ucd_cpu_usage: sin datos' }]), [], 'evaluate snmpd-restart 1: se queda, con aviso: OK');
ok(grep({ /ucd_cpu_usage\|ALL: no esta/ } @{ev($c10,'1',tb_snap(rows=>[1..5], no_ucd=>1), n=>[$SKIP])}), 'evaluate snmpd-restart 1 sin ucd: FALLA');
ok(grep({ /no se puede evaluar/ } @{[ evaluate({ case=>$c10, mode=>'1', base=>tb_snap(rows=>[1..5], no_ucd=>1), after=>$BS, notices=>[] }) ]}), 'evaluate snmpd-restart sin ucd en la base: no se puede evaluar');
# reorder: con remap el c_label de fila-1 pasa al iid 5
my $RO = tb_snap(rows=>[1..5], labels=>{1=>5,2=>4,3=>3,4=>2,5=>1});
is_deeply(ev($c7,'0',tb_snap(rows=>[1..5], labels=>{1=>5,2=>4,3=>3,4=>2,5=>1}, clab=>{'cnm_testbed_rows-1'=>'', 'cnm_testbed_rows-5'=>'CL1'}), remap=>1), [], 'evaluate reorder con remap: c_label en el iid 5: OK');
ok(grep({ /tenia que pasar/ } @{ev($c7,'0',$RO, remap=>1)}), 'evaluate reorder con remap y el c_label quieto: FALLA');
is_deeply(ev($c7,'0',$RO, remap=>0), [], 'evaluate reorder sin remap: el c_label se queda en el iid 1: OK');
ok(grep({ /tenia que tener la etiqueta fila-1/ } @{ev($c7,'0',tb_snap(rows=>[1..5], clab=>{'cnm_testbed_rows-1'=>'', 'cnm_testbed_rows-5'=>'CL1'}), remap=>1)}), 'evaluate reorder con remap sin cambio de etiquetas: FALLA');

# La metrica de una fila activa
my $NOM = tb_snap(rows=>[1..5]); delete $NOM->{metrics}{'cnm_testbed_rows-1'};
ok(grep({ /fila 1: activa en la plantilla y sin su metrica/ } @{ev($c1,'0',$NOM)}), 'evaluate: fila activa sin metrica (borrada por azul): FALLA');
my $NOM6 = tb_snap(rows=>[1..6], status=>{6=>1}); delete $NOM6->{metrics}{'cnm_testbed_rows-6'};
is_deeply(ev($c9,'0',$NOM6), [], 'evaluate new-row: la fila nueva inactiva no necesita metrica');

my $BI = tb_snap(rows=>[1..5], status=>{5=>1}); my $AI = tb_snap(rows=>[1..5], status=>{5=>1}); delete $AI->{metrics}{'cnm_testbed_rows-5'};
is_deeply([ evaluate({ case=>$c1, mode=>'0', base=>$BI, after=>$AI, notices=>[] }) ], [], 'evaluate: fila inactiva en la base y despues, sin metrica: OK');

#--- Engine: crawlers anteriores a la MIB ----------------------------------------------
my $PS = "  101  40000 [crawler.4000.snmp.300]\n  102    100 [crawler.4001.latency.60]\n  103  50000 /usr/bin/perl /opt/crawler/bin/cnm-watch\n  104  50000 [notificationsd.010]\nbasura\n";
my $pr = parse_ps($PS, 100000);
is(scalar(@$pr), 4, 'parse_ps: 4 procesos, ignora lineas raras');
is($pr->[0]{start}, 60000, 'parse_ps: arranque = ahora - etimes');
is_deeply([map { $_->{pid} } @{crawlers($pr)}], [101,102], 'crawlers: solo los [crawler.*], no los que llevan /opt/crawler en la ruta');
is_deeply([map { $_->{pid} } @{stale_crawlers($pr, 99000)}], [101], 'stale_crawlers: el que arranco antes de la MIB');
is_deeply(stale_crawlers($pr, 50000), [], 'stale_crawlers: ninguno si la MIB es anterior a todos');
is_deeply(stale_crawlers(parse_ps('',1), 1), [], 'stale_crawlers: sin procesos');

my ($bm,$bo) = split_blues(['cnm_testbed_rows-3','disk_mibhost-35','cnm_testbed_rows-12','xcnm_testbed_rows-1','cnm_testbed_rows-x']);
is_deeply($bm, ['cnm_testbed_rows-3','cnm_testbed_rows-12'], 'split_blues: las de la tabla de prueba');
is_deeply($bo, ['disk_mibhost-35','xcnm_testbed_rows-1','cnm_testbed_rows-x'], 'split_blues: el resto, sin confundir nombres parecidos');

# cut-labels: valores enteros, etiquetas cortadas en la primera lectura
my $cl = parse_scenario("mode = cut-labels\nrows = 5\ncut_at = 2\n");
$ST={reads=>0,labels=>0};
is_deeply(iid_read($cl), [[10,20,30,40,50],['fila-1','fila-2']], 'cut-labels: primera lectura con todos los valores y 2 etiquetas');
is_deeply(iid_read($cl), [[10,20,30,40,50],['fila-1','fila-2','fila-3','fila-4','fila-5']], 'cut-labels: la segunda, entera');
my ($c11) = grep { $_->{name} eq 'label-cut' } @CS;
is_deeply(ev($c11,'1',$BS), [], 'evaluate label-cut: nada cambia: OK');
my $LC = tb_snap(rows=>[1..5]); $LC->{template}{'cnm_testbed_rows|3'}{label}='CNM-TESTBED  (x)'; $LC->{metrics}{'cnm_testbed_rows-3'}{c_label}='';
my $lf = ev($c11,'1',$LC);
ok((grep { /fila 3: etiqueta/ } @$lf) && (grep { /fila 3: c_label/ } @$lf), 'evaluate label-cut: etiqueta vacia y c_label perdido: FALLA');

#--- Renumeracion de instancias en otro subtipo (hrStorage tras reiniciar snmpd) ----------
sub ren_snap {
	my (%o)=@_;	# lab: iid => etiqueta; watch: iid => monitor; clab: iid => c_label
	my (%t,%m);
	foreach my $i (57,58) {
		$t{"disk_mibhost|$i"} = { subtype=>'disk_mibhost', iid=>$i, label=>$o{lab}{$i}, watch=>($o{watch}{$i}||'0'), status=>0, mname=>"disk_mibhost-$i" };
		$m{"disk_mibhost-$i"} = { name=>"disk_mibhost-$i", c_label=>($o{clab}{$i}||''), watch=>($o{watch}{$i}||'0'), status=>0 };
	}
	$t{'cnm_testbed_rows|1'} = { subtype=>'cnm_testbed_rows', iid=>1, label=>'CNM-TESTBED fila-1 (x)', watch=>'0', status=>0, mname=>'cnm_testbed_rows-1' };
	$m{'cnm_testbed_rows-1'} = { name=>'cnm_testbed_rows-1', c_label=>'', watch=>'0', status=>0 };
	return { template=>\%t, metrics=>\%m, blue=>[] };
}
my $RB = ren_snap(lab=>{57=>'journald', 58=>'/mnt/cnm-testbed'}, watch=>{58=>'s_m'}, clab=>{58=>'CL'});
my $RF = ren_snap(lab=>{57=>'/mnt/cnm-testbed', 58=>'journald'}, watch=>{57=>'s_m'}, clab=>{57=>'CL'});	# renumera y el monitor sigue a su disco
my $RS = ren_snap(lab=>{57=>'/mnt/cnm-testbed', 58=>'journald'}, watch=>{58=>'s_m'}, clab=>{58=>'CL'});	# renumera y el monitor se queda en el iid
my $CMPO = { by_label=>1, iid_subtypes=>['cnm_testbed_rows','ucd_cpu_usage'] };
ok(! diff_is_empty(diff_snapshots($RB,$RF)), 'renumeracion: por iid, hay diferencias');
ok(diff_is_empty(diff_snapshots($RB,$RF,$CMPO)), 'renumeracion: por etiqueta, el monitor y el c_label siguen a su disco: sin diferencias');
my $dS = diff_snapshots($RB,$RS,$CMPO);
ok((grep { $_->[0] eq 'disk_mibhost|label=/mnt/cnm-testbed' && $_->[1] eq 'watch' } @{$dS->{template}{changed}}), 'renumeracion: por etiqueta, el monitor que se queda en el iid sale como cambio');
ok((grep { $_->[0] eq 'metric:disk_mibhost|label=/mnt/cnm-testbed' && $_->[1] eq 'c_label' } @{$dS->{metrics}{changed}}), 'renumeracion: por etiqueta, el c_label que se queda en el iid sale como cambio');
my $RT = ren_snap(lab=>{57=>'journald', 58=>'/mnt/cnm-testbed'}, watch=>{58=>'s_m'}, clab=>{58=>'CL'}); $RT->{template}{'cnm_testbed_rows|1'}{label}='CNM-TESTBED fila-9 (x)';
ok(grep({ $_->[0] eq 'cnm_testbed_rows|1' } @{diff_snapshots($RB,$RT,$CMPO)->{template}{changed}}), 'renumeracion: la tabla de prueba sigue comparandose por iid');
my $LK = label_keyed({ template=>{ 'd|1'=>{label=>'A',mname=>'d-1'}, 'd|2'=>{label=>'A',mname=>'d-2'}, 'd|3'=>{label=>'',mname=>'d-3'} }, metrics=>{} }, []);
is_deeply([sort keys %{$LK->{template}}], ['d|3','d|label=A','d|label=A#2'], 'label_keyed: etiquetas repetidas numeradas; sin etiqueta, por iid');
# Battery: el resto de la plantilla por etiqueta
my $BB = tb_snap(rows=>[1..5]); my $BA = tb_snap(rows=>[1..5]);
$BB->{template}{'disk_mibhost|57'} = { subtype=>'disk_mibhost', iid=>57, label=>'journald', watch=>'0', status=>0, mname=>'disk_mibhost-57' };
$BB->{template}{'disk_mibhost|58'} = { subtype=>'disk_mibhost', iid=>58, label=>'/mnt/t', watch=>'s_d', status=>0, mname=>'disk_mibhost-58' };
$BA->{template}{'disk_mibhost|57'} = { subtype=>'disk_mibhost', iid=>57, label=>'/mnt/t', watch=>'s_d', status=>0, mname=>'disk_mibhost-57' };
$BA->{template}{'disk_mibhost|58'} = { subtype=>'disk_mibhost', iid=>58, label=>'journald', watch=>'0', status=>0, mname=>'disk_mibhost-58' };
is_deeply([ evaluate({ case=>$c1, mode=>'1', base=>$BB, after=>$BA, notices=>[] }) ], [], 'evaluate: renumeracion de otro subtipo con el monitor detras de su etiqueta: OK');
$BA->{template}{'disk_mibhost|57'}{watch}='0'; $BA->{template}{'disk_mibhost|58'}{watch}='s_d';
ok(grep({ /otras filas/ } evaluate({ case=>$c1, mode=>'1', base=>$BB, after=>$BA, notices=>[] })), 'evaluate: renumeracion con el monitor en el disco equivocado: FALLA');

done_testing();
