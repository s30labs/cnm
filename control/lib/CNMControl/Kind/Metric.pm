#####################################################################################################
# File: (CNMControl::Kind::Metric.pm)
# Description:
#	Kind "metric": a metric of a device (metrics), with its title (c_label) and the static
#	views it belongs to (cfg_views2metrics).
#
#	{ "kind": "metric",
#	  "device": "tda-norte-01.tiendas.local",          name.domain or IP
#	  "subtype": "disp_icmp",                          for latency, cfg_monitor.monitor
#	  "instances": "ALL",                              or {"label_like": "..."} or {"iid": [...]}
#	  "c_label": "Disponibilidad tda-norte-01",        null = remove it; key absent = not managed
#	  "views": ["Tiendas"],                            added to these; never removed from others
#	  "watch": "s_..." }                               monitor (alert_type.monitor)
#
#	Skeleton: it only provisions latency metrics (no instances: name = subtype). The format of
#	"instances" and "watch" is already the final one, but the plan rejects them until the MVP.
#
#	Provisioning: one call to prov_do_set_device_metric per group of devices asking for the
#	same subtypes, in mode 1 with "default", like plite -t 1 -m (crawler/bin/plite:121-146).
#	Devices created in the same apply go without "fast": in that same call the engine first
#	builds their assistant and applications and then the template and the metrics
#	(crawler/bin/ProvisionLite.pm:1109-1116), as when a device is created and then provisioned
#	from the assistant in the web console. Existing devices go with fast=1: their assistant
#	is not rebuilt.
#	c_label and views: the queries of the web console, with placeholders
#	(custom_pro onm/sql/mod_Configure.sql 'modify_metric_custom_fields', 'vista_asociar_metrica',
#	 'cnm_view_get_num_metrics' / 'cnm_view_update_nmetrics').
#	validate, key and diff are pure; catalog, read and apply use $ctx->{dbh} and $ctx->{provision}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2, §4 and §5.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::Metric;
$VERSION='0.10';
use strict;
use JSON;
use CNMControl::Kind::View;

my %KEYS  = map { $_=>1 } qw(kind device subtype instances c_label views watch);
my $IP_RE = qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;

sub order { return 30; }

# An error caused by the failure of another resource of the state is returned as
# { derived=>1, text=>... }; CNMControl::Core shows it grouped under its cause.
sub _maybe_derived { my ($is,$text)=@_; return $is ? { derived=>1, text=>$text } : $text; }

sub _instances_text { my $i=shift; return ref($i) ? JSON->new->canonical(1)->encode($i) : $i; }
sub key { my ($c,$r)=@_; return lc($r->{device})."|$r->{subtype}|"._instances_text($r->{instances}); }

sub validate {
my ($c,$r)=@_;
	foreach my $k (keys %$r) { return (undef,"clave desconocida '$k'") if (! $KEYS{$k}); }
	foreach my $k ('device','subtype') { return (undef,"falta \"$k\"") if ((! defined $r->{$k}) || ($r->{$k} eq '')); }
	return (undef,"dispositivo no valido '$r->{device}'")
		if (($r->{device} !~ $IP_RE) && ($r->{device} !~ /^[A-Za-z0-9][\w\-]*\.[A-Za-z0-9][\w.\-]*$/));
	return (undef,"subtipo no valido '$r->{subtype}'") if ($r->{subtype} !~ /^[\w\-]{1,50}$/);
	my %n = ( kind=>'metric', device=>$r->{device}, subtype=>$r->{subtype} );
	my $i = defined $r->{instances} ? $r->{instances} : 'ALL';
	if (ref($i) eq 'HASH') {
		my @k = keys %$i;
		return (undef,'instances: un objeto con "label_like" o con "iid"') if ((@k != 1) || ($k[0] !~ /^(label_like|iid)$/));
		if ($k[0] eq 'label_like') {
			return (undef,'instances.label_like vacio') if (ref($i->{label_like}) || $i->{label_like} eq '');
			eval { qr/$i->{label_like}/ }; return (undef,"instances.label_like no es una expresion valida") if ($@);
		}
		else { return (undef,'instances.iid tiene que ser una lista') if ((ref($i->{iid}) ne 'ARRAY') || (! @{$i->{iid}})); }
	}
	elsif (ref($i) || $i ne 'ALL') { return (undef,'instances: "ALL", {"label_like": "..."} o {"iid": [...]}'); }
	$n{instances}=$i;
	if (exists $r->{c_label}) {
		return (undef,'c_label tiene que ser texto o null') if (ref($r->{c_label}));
		return (undef,'c_label de mas de 255 caracteres') if (defined $r->{c_label} && length($r->{c_label}) > 255);
		$n{c_label} = (defined $r->{c_label} && $r->{c_label} ne '') ? $r->{c_label} : undef;
	}
	if (defined $r->{views}) {
		return (undef,'views tiene que ser una lista de nombres') if (ref($r->{views}) ne 'ARRAY');
		my %u=(); $n{views} = [ grep { !$u{$_}++ } grep { defined $_ && !ref($_) && $_ ne '' } @{$r->{views}} ];
	}
	if (defined $r->{watch}) {
		return (undef,'watch tiene que ser texto') if (ref($r->{watch}));
		$n{watch}=$r->{watch};
	}
	return (\%n, undef);
}

#----------------------------------------------------------------------------
# Resolve a device by name.domain or IP -> list of id_dev
#----------------------------------------------------------------------------
sub _dev_ids {
my ($dbh,$ref)=@_;
	my $rows = ($ref =~ $IP_RE)
		? $dbh->selectcol_arrayref("SELECT id_dev FROM devices WHERE ip=?", undef, $ref)
		: $dbh->selectcol_arrayref("SELECT id_dev FROM devices WHERE LOWER(CONCAT(name,'.',domain))=?", undef, lc $ref);
	return $rows || [];
}

#----------------------------------------------------------------------------
# catalog($ctx) -> { subtype => {type, lapse} }: where each subtype comes from, and its lapse
#----------------------------------------------------------------------------
sub catalog {
my ($c,$ctx)=@_;
	return $ctx->{cache}{subtypes} if ($ctx->{cache}{subtypes});
	my $dbh=$ctx->{dbh}; my %cat=();
	$cat{$_->[0]} = { type=>'latency', lapse=>$_->[1] } foreach (@{ $dbh->selectall_arrayref("SELECT monitor,lapse FROM cfg_monitor") });
	foreach (@{ $dbh->selectall_arrayref("SELECT subtype,lapse FROM cfg_monitor_snmp") })  { $cat{$_->[0]} ||= { type=>'snmp',   lapse=>$_->[1] }; }
	foreach (@{ $dbh->selectall_arrayref("SELECT subtype,lapse FROM cfg_monitor_agent") }) { $cat{$_->[0]} ||= { type=>'xagent', lapse=>$_->[1] }; }
	return $ctx->{cache}{subtypes} = \%cat;
}

sub read {
my ($c,$ctx,$rs)=@_;
	my $dbh=$ctx->{dbh};
	my $cat = $c->catalog($ctx);
	my %dev=(); $dev{lc $_->{device}} ||= _dev_ids($dbh,$_->{device}) foreach (@$rs);
	my %ids = map { $_->[0]=>1 } grep { @$_ == 1 } values %dev;
	my %subs = map { $_->{subtype}=>1 } @$rs;
	my %met=();
	if (%ids) {
		my @i=sort keys %ids; my @s=sort keys %subs;
		my $q="SELECT id_metric,id_dev,name,status,c_label FROM metrics WHERE id_dev IN (".join(',',('?') x @i).") AND name IN (".join(',',('?') x @s).")";
		$met{"$_->{id_dev}|$_->{name}"}=$_ foreach (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @i, @s) });
	}
	my %in_view=();
	my @idm = map { $_->{id_metric} } values %met;
	if (@idm) {
		my $q="SELECT id_cfg_view,id_metric FROM cfg_views2metrics WHERE id_metric IN (".join(',',('?') x @idm).")";
		$in_view{$_->[1]}{$_->[0]}=1 foreach (@{ $dbh->selectall_arrayref($q, undef, @idm) });
	}
	my $views = CNMControl::Kind::View->find($ctx, [ map { @{$_->{views}||[]} } @$rs ]);
	my %cur=();
	foreach my $r (@$rs) {
		my $ids = $dev{lc $r->{device}};
		my $m = (@$ids == 1) ? $met{"$ids->[0]|$r->{subtype}"} : undef;
		$cur{$c->key($r)} = { dev_ids=>$ids, metric=>$m, in_views=>($m ? ($in_view{$m->{id_metric}}||{}) : {}),
									 views=>$views, cat=>$cat->{$r->{subtype}} };
	}
	return \%cur;
}

sub diff {
my ($c,$r,$cur,$ctx)=@_;
my (@acc,@err,@warn);
	my $ref = "$r->{device} $r->{subtype}";
	if (! $cur->{cat}) { push @err, "subtipo '$r->{subtype}' no existe en el repositorio (cnm-control list subtypes)"; }
	elsif ($cur->{cat}{type} ne 'latency') { push @err, "subtipo de tipo $cur->{cat}{type}: el esqueleto solo provisiona latencia (snmp y xagent, en el MVP)"; }
	push @err, 'instances distintas de "ALL": llegan en el MVP' if (ref $r->{instances});
	push @err, '"watch" (monitor): llega en el MVP' if (defined $r->{watch});
	my $n = scalar @{$cur->{dev_ids}};
	if ($n > 1) { push @err, "hay $n dispositivos que responden a '$r->{device}'"; }
	elsif (($n == 0) && (! $ctx->{pending}{lc $r->{device}})) {
		# Derived when the device resource of this state already failed: same cause
		push @err, _maybe_derived($ctx->{failed}{lc $r->{device}}, "el dispositivo '$r->{device}' no existe ni se crea en este estado");
	}
	foreach my $v (@{$r->{views}||[]}) {
		if (! $cur->{views}{$v}) { push @err, _maybe_derived($ctx->{failed_view}{$v}, "la vista '$v' no existe (cnm-control list views)"); }
		elsif ($cur->{views}{$v}{live_metric}) { push @err, _maybe_derived($ctx->{failed_view}{$v}, "la vista '$v' es viva: su recalculo borraria la asociacion"); }
	}
	return ([],\@err,\@warn) if (@err);

	my $m = $cur->{metric};
	if (! $m) {
		my $new = ($ctx->{pending}{lc $r->{device}}) ? 1 : 0;
		push @acc, { kind=>'metric', op=>'provision', ref=>$r->{device}, subtype=>$r->{subtype},
						 type=>$cur->{cat}{type}, lapse=>$cur->{cat}{lapse}, new_device=>$new,
						 text=>"$ref (lapse $cur->{cat}{lapse})".($new ? ' + asistente' : '') };
	}
	elsif ($m->{status} ne '0') { push @warn, "la metrica existe desactivada (status=$m->{status}); el esqueleto no la reactiva"; }
	if (exists $r->{c_label}) {
		my $before = $m ? $m->{c_label} : undef;
		my $same = ((! defined $before) && (! defined $r->{c_label})) || (defined $before && defined $r->{c_label} && $before eq $r->{c_label});
		if (! $same) {
			push @acc, { kind=>'metric', op=>'c_label', ref=>$r->{device}, subtype=>$r->{subtype},
							 before=>$before, after=>$r->{c_label},
							 text=>"$ref: ".(defined $before ? "\"$before\"" : '(vacio)').' -> '.(defined $r->{c_label} ? "\"$r->{c_label}\"" : '(vacio)') };
		}
	}
	foreach my $v (@{$r->{views}||[]}) {
		my $vi = $cur->{views}{$v};
		next if ($m && $cur->{in_views}{$vi->{id}});
		push @acc, { kind=>'metric', op=>'view+', ref=>$r->{device}, subtype=>$r->{subtype},
						 view=>$v, view_id=>$vi->{id}, cid=>$vi->{cid}, cid_ip=>$vi->{cid_ip}, text=>"$ref -> vista \"$v\"" };
	}
	return (\@acc,\@err,\@warn);
}

#----------------------------------------------------------------------------
# apply: 1) provisioning by groups  2) c_label and views in one transaction  3) nmetrics
#----------------------------------------------------------------------------
sub apply {
my ($c,$ctx,$acc)=@_;
my @err=();
	my $dbh=$ctx->{dbh};
	my %id_dev=();
	foreach my $x (@$acc) {
		next if (exists $id_dev{lc $x->{ref}});
		my $ids=_dev_ids($dbh,$x->{ref});
		if (@$ids != 1) { push @err, "$x->{ref}: ".scalar(@$ids)." dispositivos"; $id_dev{lc $x->{ref}}=undef; }
		else { $id_dev{lc $x->{ref}}=$ids->[0]; }
	}
	return \@err if (@err);

	# 1) Provisioning: group the devices that ask for the same set of subtypes and are all new
	#    (assistant built in the same call) or all existing (fast=1)
	my %wants=(); my %new=();
	foreach my $x (grep { $_->{op} eq 'provision' } @$acc) {
		my $d = $id_dev{lc $x->{ref}};
		$wants{$d}{$x->{subtype}} = "1.$x->{lapse}.$x->{type}.$x->{subtype}";
		$new{$d} = 1 if ($x->{new_device});
	}
	my %group=();
	foreach my $d (keys %wants) {
		my $def = join(',', map { $wants{$d}{$_} } sort keys %{$wants{$d}});
		push @{$group{ ($new{$d} ? 0 : 1)."|$def" }}, $d;
	}
	foreach my $g (sort keys %group) {
		my ($fast,$def) = split(/\|/,$g,2);
		my $ids = join(',', sort { $a <=> $b } @{$group{$g}});
		my %in = ( 'id_dev'=>$ids, 'init'=>1, 'cid'=>$ctx->{cid}, 'default'=>$def );
		$in{'fast'}=1 if ($fast);
		my $prov = $ctx->{provision}->();
		eval { $prov->prov_do_set_device_metric(\%in); };
		push @err, "prov_do_set_device_metric id_dev=$ids: $@" if ($@);
	}
	return \@err if (@err);

	# 2) id_metric of every action (the ones just provisioned included)
	foreach my $x (@$acc) {
		my $m = $dbh->selectrow_hashref("SELECT id_metric FROM metrics WHERE id_dev=? AND name=?", undef, $id_dev{lc $x->{ref}}, $x->{subtype});
		if (! $m) { push @err, "$x->{ref} $x->{subtype}: la metrica no existe tras la provision"; next; }
		$x->{id_metric}=$m->{id_metric}; $x->{id_dev}=$id_dev{lc $x->{ref}};
	}
	return \@err if (@err);

	my %views=();
	eval {
		$dbh->begin_work();
		foreach my $x (@$acc) {
			if ($x->{op} eq 'c_label') {
				$dbh->do("UPDATE metrics SET c_label=? WHERE id_metric=?", undef, $x->{after}, $x->{id_metric});
			}
			elsif ($x->{op} eq 'view+') {
				$dbh->do("INSERT IGNORE INTO cfg_views2metrics (id_cfg_view,id_metric,id_device) VALUES (?,?,?)", undef,
							$x->{view_id}, $x->{id_metric}, $x->{id_dev});
				$views{$x->{view_id}} = $x;
			}
		}
		# 3) View counter, like cnmview::view_update_nmetrics (onm/inc/class.cnmview.php:703-712)
		foreach my $v (values %views) {
			my ($n) = $dbh->selectrow_array("SELECT count(DISTINCT a.id_metric) FROM cfg_views2metrics a,devices b WHERE a.id_device=b.id_dev AND a.id_cfg_view=?", undef, $v->{view_id});
			$dbh->do("UPDATE cfg_views SET nmetrics=? WHERE id_cfg_view=? AND cid=? AND cid_ip=?", undef, $n, $v->{view_id}, $v->{cid}, $v->{cid_ip});
		}
		$dbh->commit();
	};
	if ($@) { my $e=$@; eval { $dbh->rollback(); }; push @err, "c_label/vistas (deshecho): $e"; }
	return \@err;
}

1;
