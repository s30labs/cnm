#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de ProvisionLite::LabelRemap::remap_by_label (PROY-CNM-Alertas-Azules §7, P1).
# Casos reales (2557, cnm-areas, 49) y simulados. Cada caso se pasa tambien por el
# comportamiento de hoy (los valores se quedan en el iid y lo nuevo entra inactivo):
# los casos de desplazamiento tienen que FALLAR con el comportamiento de hoy.
#
#   perl t/PROV_label_remap.t            (desde /opt/crawler/bin, o con -I)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use ProvisionLite::LabelRemap qw(remap_by_label has_monitor_or_c_label);

sub o { my ($label,$watch,$c_label,$status)=@_; return { label=>$label, watch=>$watch//'0', c_label=>$c_label, status=>$status//0 }; }

# El comportamiento de hoy en el modo 0: cada iid conserva lo suyo; lo nuevo entra con status=1
sub by_iid {
my ($old,$new)=@_;
	my %a;
	foreach my $iid (keys %$new) {
		if (exists $old->{$iid}) { $a{$iid} = { watch=>$old->{$iid}{watch}, status=>$old->{$iid}{status}, c_label=>$old->{$iid}{c_label} }; }
		else { $a{$iid} = { watch=>'0', status=>1, c_label=>undef }; }
	}
	return { assign=>\%a };
}

my @CASES = (
 { name => '2557: se retira E: y la memoria baja un iid',
   desplaza => 1,
   old => { 1=>o('C:\ Label:SISTEMA','mC'), 2=>o('D:\ Label:Data'), 3=>o('E:\\','mE','KPI E'), 4=>o('Virtual Memory','mVM','KPI0328 Memory usage'), 5=>o('Physical Memory') },
   new => { 1=>'C:\ Label:SISTEMA', 2=>'D:\ Label:Data', 3=>'Virtual Memory', 4=>'Physical Memory' },
   want => { 1=>['mC',undef,0], 2=>['0',undef,0], 3=>['mVM','KPI0328 Memory usage',0], 4=>['0',undef,0] },
   vanished => ['3'], vanished_important => ['3'] },
 { name => 'cnm-areas: cambio de maquina virtual',
   desplaza => 1,
   old => { 31=>o('/','m31'), 36=>o('/var'), 37=>o('/run/lock'), 41=>o('/boot'), 43=>o('/home','m43') },
   new => { 36=>'/', 43=>'/run/lock', 52=>'/boot' },
   want => { 36=>['m31',undef,0], 43=>['0',undef,0], 52=>['0',undef,0] },
   vanished => ['36','43'], vanished_important => ['43'] },
 { name => '49: /run/user/1116 del 188 al 186',
   desplaza => 1,
   old => { 188=>o('/run/user/1116') },
   new => { 186=>'/run/user/1116' },
   want => { 186=>['0',undef,0] },
   vanished => [], vanished_important => [] },
 { name => 'intercambio: A y B cambian de iid entre si',
   desplaza => 1,
   old => { 1=>o('A','mA','cA'), 2=>o('B','mB') },
   new => { 1=>'B', 2=>'A' },
   want => { 1=>['mB',undef,0], 2=>['mA','cA',0] },
   vanished => [], vanished_important => [] },
 { name => 'cambio de descripcion en el mismo iid: se queda',
   old => { 1=>o('C:\ Label:OS','m1','c1') },
   new => { 1=>'C:\ Label:SISTEMA' },
   want => { 1=>['m1','c1',0] },
   vanished => [], vanished_important => [] },
 { name => 'instancia excluida por el usuario (status=1) que no se mueve',
   old => { 1=>o('eth0'), 2=>o('eth1','0',undef,1) },
   new => { 1=>'eth0', 2=>'eth1' },
   want => { 1=>['0',undef,0], 2=>['0',undef,1] },
   vanished => [], vanished_important => [] },
 { name => 'etiqueta repetida: se trata por iid',
   old => { 10=>o('Vl10'), 11=>o('Vl10','m11') },
   new => { 10=>'Vl10', 12=>'Vl10' },
   want => { 10=>['0',undef,0], 12=>['0',undef,0] },
   vanished => ['11'], vanished_important => ['11'], repeated => ['Vl10'] },
 { name => 'instancia nueva: activa y sin monitor',
   old => { },
   new => { 5=>'eth5' },
   want => { 5=>['0',undef,0] },
   vanished => [], vanished_important => [] },
 { name => 'nada cambia',
   old => { 1=>o('/','m1','raiz'), 2=>o('/var') },
   new => { 1=>'/', 2=>'/var' },
   want => { 1=>['m1','raiz',0], 2=>['0',undef,0] },
   vanished => [], vanished_important => [] },
);

sub cumple {
my ($r,$c)=@_;
	my @err;
	foreach my $iid (sort keys %{$c->{want}}) {
		my ($w,$cl,$st)=@{$c->{want}{$iid}};
		my $a=$r->{assign}{$iid};
		if (! $a) { push @err,"iid $iid sin asignar"; next; }
		push @err,"iid $iid watch=$a->{watch} (esperado $w)" if $a->{watch} ne $w;
		push @err,"iid $iid c_label=".($a->{c_label}//'undef')." (esperado ".($cl//'undef').")" if (($a->{c_label}//'') ne ($cl//''));
		push @err,"iid $iid status=$a->{status} (esperado $st)" if $a->{status} != $st;
	}
	return @err;
}

my $hoy_falla_en_desplazamientos = 1;
foreach my $c (@CASES) {
	my $r = remap_by_label($c->{old}, $c->{new});
	my @err = cumple($r,$c);
	ok(!@err, $c->{name}) or diag(join("\n",@err));

	my @van = map { $_->{iid} } @{$r->{vanished}};
	is_deeply([sort @van], [sort @{$c->{vanished}}], "$c->{name}: desaparecidas");
	my @imp = map { $_->{iid} } grep { has_monitor_or_c_label($_) } @{$r->{vanished}};
	is_deeply([sort @imp], [sort @{$c->{vanished_important}}], "$c->{name}: desaparecidas con monitor o c_label (avisos)");
	is_deeply($r->{repeated}, $c->{repeated} || [], "$c->{name}: repetidas") ;

	# Control: el comportamiento de hoy tiene que fallar en los desplazamientos
	if ($c->{desplaza}) {
		my @err_hoy = cumple(by_iid($c->{old},$c->{new}), $c);
		ok(scalar(@err_hoy) > 0, "$c->{name}: el comportamiento de hoy falla (la prueba sabe ponerse en rojo)");
	}
}
done_testing();
