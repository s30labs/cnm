#####################################################################################################
# Fichero: (ProvisionLite::LabelRemap.pm)
# Descripcion:
#	Reordena c_label, watch y status de las instancias de UNA metrica de UN dispositivo
#	cuando sus iids cambian (desplazamientos de instancias).
#
#	Regla: un c_label y un monitor siguen a su etiqueta mientras esa etiqueta exista
#	en el equipo. Si ya no existe, se quedan en su iid (cambio de descripcion).
#	Las etiquetas repetidas no se mueven: se tratan por iid, como hasta ahora.
#
#	Es una funcion pura: no lee ni escribe la base. La llama ProvisionLite.pm.
#	Diseno: cnm-docs, PROY-CNM-Alertas-Azules §6.
# Set Tab=3
#####################################################################################################
package ProvisionLite::LabelRemap;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(remap_by_label has_monitor_or_c_label);

#----------------------------------------------------------------------------
# remap_by_label($old, $new)
#
# $old: { iid => { label=>, watch=>, status=>, c_label=> } }   (foto previa)
# $new: { iid => label }                                      (lo que responde el equipo)
#
# Devuelve un hash con:
#	assign   => { iid => { watch=>, status=>, c_label=>, from=> } } para cada iid de $new.
#	            from es el iid antiguo del que vienen los valores, o undef si la instancia es nueva.
#	moved    => [ { from=>, to=>, label=> } ]   etiquetas que han cambiado de iid
#	vanished => [ { iid=>, label=>, watch=>, c_label=> } ]   etiquetas antiguas que ya no estan
#	repeated => [ label, ... ]   etiquetas repetidas: se han tratado por iid
#
# Una instancia nueva entra con watch='0', status=0 (activa) y sin c_label.
#----------------------------------------------------------------------------
sub remap_by_label {
my ($old,$new)=@_;

	# Cuantas veces aparece cada etiqueta, antes y ahora
	my (%n_old,%n_new);
	$n_old{$old->{$_}->{'label'}}++ foreach keys %$old;
	$n_new{$new->{$_}}++ foreach keys %$new;

	my %repeated = map { $_ => 1 } grep { $n_old{$_} > 1 } keys %n_old;
	$repeated{$_} = 1 foreach grep { $n_new{$_} > 1 } keys %n_new;

	# Etiqueta antigua (sin repetir) -> iid antiguo
	my %old_iid_by_label = map { $old->{$_}->{'label'} => $_ }
	                       grep { ! $repeated{$old->{$_}->{'label'}} } keys %$old;

	my (%assign,@moved,%used);
	foreach my $iid (sort keys %$new) {
		my $label = $new->{$iid};
		my $from;

		if (! $repeated{$label} && exists $old_iid_by_label{$label}) {
			# La etiqueta ya existia: sus valores la siguen, este en el iid que este
			$from = $old_iid_by_label{$label};
		}
		elsif (exists $old->{$iid} && ! _label_still_exists($old->{$iid}->{'label'},\%n_new,\%repeated)) {
			# El iid existia y su etiqueta antigua ya no esta en ningun sitio (o esta repetida):
			# cambio de descripcion de lo mismo. Los valores se quedan en el iid.
			$from = $iid;
		}

		if (defined $from) {
			my $o = $old->{$from};
			$assign{$iid} = { 'watch'=>$o->{'watch'}, 'status'=>$o->{'status'}, 'c_label'=>$o->{'c_label'}, 'from'=>$from };
			$used{$from} = 1;
			push @moved, { 'from'=>$from, 'to'=>$iid, 'label'=>$label } if ($from ne $iid);
		}
		else {
			$assign{$iid} = { 'watch'=>'0', 'status'=>0, 'c_label'=>undef, 'from'=>undef };
		}
	}

	# Lo que habia y no ha ido a ningun sitio
	my @vanished = map { { 'iid'=>$_, 'label'=>$old->{$_}->{'label'}, 'watch'=>$old->{$_}->{'watch'}, 'c_label'=>$old->{$_}->{'c_label'} } }
	               grep { ! $used{$_} } sort keys %$old;

	return { 'assign'=>\%assign, 'moved'=>\@moved, 'vanished'=>\@vanished, 'repeated'=>[ sort keys %repeated ] };
}

#----------------------------------------------------------------------------
# Una etiqueta antigua sigue existiendo si aparece ahora una sola vez.
# Si aparece repetida no se puede saber a donde ha ido: se trata como si no existiera.
#----------------------------------------------------------------------------
sub _label_still_exists {
my ($label,$n_new,$repeated)=@_;
	return 0 if $repeated->{$label};
	return (exists $n_new->{$label}) ? 1 : 0;
}

#----------------------------------------------------------------------------
# has_monitor_or_c_label($entry): si la instancia tenia algo que el usuario configuro.
#----------------------------------------------------------------------------
sub has_monitor_or_c_label {
my ($e)=@_;
	my $w = (defined $e->{'watch'}) ? $e->{'watch'} : '0';
	my $c = (defined $e->{'c_label'}) ? $e->{'c_label'} : '';
	return (($w ne '0' && $w ne '') || $c ne '') ? 1 : 0;
}

1;
__END__
