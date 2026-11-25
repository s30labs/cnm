#####################################################################################################
# File: (CNMControl::Kind::View.pm)
# Description:
#	Kind "view" (cfg_views). Key: the name, unique per cid (PRIMARY KEY (name,cid)).
#
#	{ "kind": "view", "name": "Tiendas" }
#
#	Skeleton: it only checks that the view exists and is static (live_metric=0). Creating it
#	(copying another view as a model, with its users) comes with the MVP.
#	A live view is rejected: recalculating it deletes all its metrics and fills it again
#	from its search (api/src/inc/mod_common.php:2608-2616).
#	validate, key and diff are pure; find and read use $ctx->{dbh}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::View;
$VERSION='0.10';
use strict;

my %KEYS = map { $_=>1 } qw(kind name create);

sub order { return 10; }
sub key   { my ($c,$r)=@_; return $r->{name}; }

sub validate {
my ($c,$r)=@_;
	foreach my $k (keys %$r) { return (undef,"clave desconocida '$k'") if (! $KEYS{$k}); }
	return (undef,'falta "name"') if ((! defined $r->{name}) || ($r->{name} !~ /\S/));
	return (undef,'"create" todavia no esta soportado (llega en el MVP)') if (exists $r->{create});
	return ({ kind=>'view', name=>$r->{name} }, undef);
}

#----------------------------------------------------------------------------
# find($ctx, \@names) -> { name => {id, live_metric, cid, cid_ip} }
# Also used by the metric kind to resolve "views".
#----------------------------------------------------------------------------
sub find {
my ($c,$ctx,$names)=@_;
	my %u = map { $_=>1 } @$names;
	my @n = sort keys %u;
	return {} if (! @n);
	my $sql = "SELECT id_cfg_view,name,live_metric,cid,cid_ip FROM cfg_views WHERE cid=? AND name IN (".join(',',('?') x @n).")";
	my $rows = $ctx->{dbh}->selectall_arrayref($sql, { Slice=>{} }, $ctx->{cid}, @n);
	return { map { $_->{name} => { id=>$_->{id_cfg_view}, live_metric=>$_->{live_metric}, cid=>$_->{cid}, cid_ip=>$_->{cid_ip} } } @$rows };
}

sub read {
my ($c,$ctx,$rs)=@_;
	return $c->find($ctx, [ map { $_->{name} } @$rs ]);
}

sub diff {
my ($c,$r,$cur,$ctx)=@_;
	$ctx->{failed_view}{$r->{name}}=1 if ((! $cur) || $cur->{live_metric});	# for the derived errors of the metrics
	return ([], [ "no existe en cid=$ctx->{cid} (cnm-control list views; crearla llega en el MVP)" ], []) if (! $cur);
	return ([], [ "es una vista viva (live_metric=1): su recalculo borraria lo que se asocie" ], []) if ($cur->{live_metric});
	return ([], [], []);
}

sub apply { return []; }

1;
