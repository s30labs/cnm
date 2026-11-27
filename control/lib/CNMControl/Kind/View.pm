#####################################################################################################
# File: (CNMControl::Kind::View.pm)
# Description:
#	Kind "view" (cfg_views). Key: the name, unique per cid (PRIMARY KEY (name,cid)).
#
#	{ "kind": "view", "name": "Sede Madrid",
#	  "create":  true,                     create it if it does not exist
#	  "like":    "Sede Plantilla",         copy type, itil_type and global from this view
#	  "fields":  { "type": "Sedes", "itil_type": 1, "global": 0 },   override like
#	  "parent":  "Sedes",                  its parent view (cfg_views2views): a view has one parent
#	  "users":   ["operador1", "noc"] }    users with access (cfg_user2view); added, never removed
#
#	{ "kind": "view", "name": "Tiendas" } alone is a reference: the view must exist. It merges
#	with a full definition of the same view coming from another input (see merge).
#	A view has one parent (criterion of the project management, 27-nov-2026; the console
#	draws the tree with one parent per view, custom_pro onm/custom/mod_vistas_layout.php:170):
#	a view without parent gets it (parent+); a view with another parent is moved (move: the
#	old link is deleted, the new one inserted); a view that already has two or more parents
#	is an error if the state gives it a parent, and a warning otherwise.
#	Without "create", a missing view is an error, as before. "parent" and "users" also work on
#	existing views. Modify, phase 1 (PROY §9, 26-nov-2026): in an existing view, the fields
#	that "like" or "fields" give and that differ are changed (action "update"): UPDATE of
#	type, itil_type and global ('update_view' of the console, only those columns) and, as
#	save() does with a view that is not live, the two search store clears. Checked against
#	the value before of the plan, in the same transaction as the rest of the views.
#
#	What creating writes, like the console (custom_pro onm/inc/class.cnmview.php, save(), and
#	the named queries of onm/sql/mod_Configure.sql):
#	  cfg_views         'create_view' (ruled, live_metric, live_remote and sla = 0, internal = 1;
#	                    the SLA columns keep the table default: no SLA in this phase)
#	                    then 'clear_search_store2cfg_views2metrics1' and '...remote_alerts1'
#	  cfg_views2views   'vista_asociar_subvista', then the parent's nsubviews
#	                    ('cnm_view_get_num_subviews' and 'cnm_view_update_nsubviews')
#	  cfg_user2view     'asoc_user', with the login_name of cfg_users
#	All of it in one transaction. Live views (live_metric), views with rules (ruled) and SLA
#	views are not created in this phase.
#
#	cid_ip of a new view: the IP of the interface of /cfg/onm.if, given by $ctx->{local_ip}
#	(ONMConfig::my_ip). It is checked before writing: it must be the only cid_ip of the views
#	of that cid (ignoring '' and 127.0.0.1) and there must be a row (cid, host_ip) in
#	cnm.cfg_cnms, because the console lists views joining cfg_views.cid_ip with
#	cnm.cfg_cnms.host_ip (query 'vistas_admin'). Design: PROY §9, 26-nov-2026.
#
#	Names are compared by the database (utf8_spanish_ci: no case, no accents), one query per
#	name, so "tiendas" finds "Tiendas".
#	validate, key, merge and diff are pure; find and read use $ctx->{dbh}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2 and §9.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::View;
$VERSION='0.40';
use strict;
use JSON;

my %KEYS   = map { $_=>1 } qw(kind name create like fields parent users);
my %FIELDS = map { $_=>1 } qw(type itil_type global);

sub order { return 10; }
sub key   { my ($c,$r)=@_; return lc $r->{name}; }		# the database compares without case
sub label { my ($c,$r)=@_; return $r->{name}; }

#----------------------------------------------------------------------------
# validate($r) -> ($normalized, $error)
#----------------------------------------------------------------------------
sub validate {
my ($c,$r)=@_;
	return (undef,'"parents" ya no se admite: una vista tiene un solo padre; usar "parent"') if (exists $r->{parents});
	foreach my $k (keys %$r) { return (undef,"clave desconocida '$k'") if (! $KEYS{$k}); }
	return (undef,'falta "name"') if ((! defined $r->{name}) || ref($r->{name}) || ($r->{name} !~ /\S/));
	return (undef,'"name" de mas de 255 caracteres') if (length($r->{name}) > 255);
	my %n = (kind=>'view', name=>$r->{name});
	if (exists $r->{create}) {
		my $v = $r->{create};
		my $ok = (ref($v) && JSON::is_bool($v)) ? ($v ? 1 : 0) : ((defined $v && ! ref($v) && $v =~ /^[01]$/) ? $v : undef);
		return (undef,'"create" tiene que ser true o false') if (! defined $ok);
		$n{create}=1 if ($ok);
	}
	if (exists $r->{like}) {
		return (undef,'"like" tiene que ser el nombre de una vista') if ((! defined $r->{like}) || ref($r->{like}) || ($r->{like} !~ /\S/));
		$n{like}=$r->{like};
	}
	if (exists $r->{fields}) {
		return (undef,'"fields" tiene que ser un objeto') if (ref($r->{fields}) ne 'HASH');
		my %f=();
		foreach my $k (keys %{$r->{fields}}) {
			return (undef,"fields: campo '$k' no admitido (validos: ".join(', ',sort keys %FIELDS).")") if (! $FIELDS{$k});
			my $v = $r->{fields}{$k};
			return (undef,"fields: '$k' sin valor") if ((! defined $v) || ref($v) || ($v eq ''));
			return (undef,"fields: itil_type tiene que ser 1 a 5") if (($k eq 'itil_type') && ($v !~ /^[1-5]$/));
			return (undef,"fields: global tiene que ser 0 o 1") if (($k eq 'global') && ($v !~ /^[01]$/));
			return (undef,"fields: type de mas de 100 caracteres") if (($k eq 'type') && (length($v) > 100));
			$f{$k} = "$v";
		}
		$n{fields}=\%f if (%f);
	}
	if (defined $r->{parent}) {
		return (undef,'"parent" tiene que ser el nombre de una vista') if (ref($r->{parent}) || ($r->{parent} !~ /\S/));
		return (undef,'una vista no puede ser padre de si misma') if (lc($r->{parent}) eq lc($n{name}));
		$n{parent}=$r->{parent};
	}
	foreach my $l (qw(users)) {
		next if (! exists $r->{$l});
		return (undef,"\"$l\" tiene que ser una lista de nombres") if (ref($r->{$l}) ne 'ARRAY');
		my %u=();
		my @v = grep { !$u{lc $_}++ } grep { defined $_ && !ref($_) && /\S/ } @{$r->{$l}};
		$n{$l}=[ @v ] if (@v);
	}
	return (\%n, undef);
}

#----------------------------------------------------------------------------
# merge($a, $b) -> ($merged, $error)
# Called by Core when the same view comes twice with different content. A bare reference
# ({kind,name}) takes the other one. Otherwise create, like and fields must be equal, the
# parent too if both give it, and the users are joined (they are only added, so joining them
# asks for the same thing).
#----------------------------------------------------------------------------
sub merge {
my ($c,$a,$b)=@_;
	my $bare = sub { my $x=shift; return ! grep { $_ ne 'kind' && $_ ne 'name' && $_ ne '_origin' } keys %$x; };
	return ({ %$b, name=>$a->{name} }, undef) if ($bare->($a));
	return ({ %$a }, undef) if ($bare->($b));
	my $j = JSON->new->canonical(1);
	foreach my $k (qw(create like fields)) {
		return (undef,"'$k' distinto en las dos definiciones")
			if ($j->encode([ $a->{$k} ]) ne $j->encode([ $b->{$k} ]));
	}
	return (undef,"'parent' distinto en las dos definiciones")
		if (defined $a->{parent} && defined $b->{parent} && (lc $a->{parent} ne lc $b->{parent}));
	my %m = %$a;
	$m{parent} = $b->{parent} if ((! defined $m{parent}) && defined $b->{parent});
	foreach my $l (qw(users)) {
		my %u=(); my @v = grep { !$u{lc $_}++ } (@{$a->{$l}||[]}, @{$b->{$l}||[]});
		$m{$l}=\@v if (@v);
	}
	return (\%m, undef);
}

#----------------------------------------------------------------------------
# find($ctx, \@names) -> { requested name => {id, name, live_metric, cid, cid_ip, ...} }
# One query per name: the database compares (utf8_spanish_ci). Also used by the metric kind.
#----------------------------------------------------------------------------
sub find {
my ($c,$ctx,$names)=@_;
	my %u = map { $_=>1 } @$names;
	my %r=();
	foreach my $n (sort keys %u) {
		my $rows = $ctx->{dbh}->selectall_arrayref(
			"SELECT id_cfg_view,name,type,itil_type,global,ruled,live_metric,sla,cid,cid_ip FROM cfg_views WHERE cid=? AND name=?",
			{ Slice=>{} }, $ctx->{cid}, $n);
		next if (! @$rows);
		my $x = $rows->[0];
		$r{$n} = { id=>$x->{id_cfg_view}, name=>$x->{name}, type=>$x->{type}, itil_type=>$x->{itil_type}, global=>$x->{global},
					  ruled=>$x->{ruled}, live_metric=>$x->{live_metric}, sla=>$x->{sla}, cid=>$x->{cid}, cid_ip=>$x->{cid_ip} };
	}
	return \%r;
}

#----------------------------------------------------------------------------
# read($ctx, \@resources) -> { lc name => current }
# current = { view, parents_now, users, like, cycle } plus, shared by every view of the
# state, the view types, the users, the parent views and the cid_ip check.
#----------------------------------------------------------------------------
sub read {
my ($c,$ctx,$rs)=@_;
	my $dbh=$ctx->{dbh};
	my @names = map { ($_->{name}, (defined $_->{parent} ? ($_->{parent}) : ()), ($_->{like} ? ($_->{like}) : ())) } @$rs;
	my $views = $c->find($ctx, \@names);

	# Links between views of this cid: parent id => [child ids], child id => [parent ids].
	# Read always: a view of the state with two parents is reported even without "parent"
	my (%children, %parents_of);
	foreach my $e (@{ $dbh->selectall_arrayref("SELECT id_cfg_view,id_cfg_subview FROM cfg_views2views WHERE cid_view=? AND cid_subview=?",
														 undef, $ctx->{cid}, $ctx->{cid}) }) {
		push @{$children{$e->[0]}}, $e->[1];
		push @{$parents_of{$e->[1]}}, $e->[0];
	}
	my %vname = map { $_->[0] => $_->[1] } @{ $dbh->selectall_arrayref("SELECT id_cfg_view,name FROM cfg_views WHERE cid=?", undef, $ctx->{cid}) };

	# Users: one query per login (the database compares), and the users already in each view
	my %logins = map { $_=>1 } map { @{$_->{users}||[]} } @$rs;
	my %user=();
	foreach my $l (sort keys %logins) {
		my $u = $dbh->selectrow_hashref("SELECT id_user,login_name FROM cfg_users WHERE login_name=?", undef, $l);
		$user{$l}=$u if ($u);
	}
	my %has_user=();
	foreach my $r (grep { $_->{users} } @$rs) {
		my $v = $views->{$r->{name}} or next;
		my $rows = $dbh->selectall_arrayref("SELECT login_name FROM cfg_user2view WHERE id_cfg_view=? AND cid=? AND cid_ip=?",
														undef, $v->{id}, $v->{cid}, $v->{cid_ip});
		$has_user{$r->{name}}{lc $_->[0]}=1 foreach (@$rows);
	}

	my $types = { map { lc($_->[0]) => $_->[0] } @{ $dbh->selectall_arrayref("SELECT name FROM cfg_views_types") } };

	my $check = (grep { $_->{create} && ! $views->{$_->{name}} } @$rs) ? $c->_check_cid_ip($ctx) : undef;

	my $cycles = _cycles($rs, $views, \%children);
	# Views this state creates: a parent may come after its child in the input
	my %will = map { lc($_->{name}) => 1 } grep { $_->{create} && ! $views->{$_->{name}} } @$rs;

	my %cur=();
	foreach my $r (@$rs) {
		my $v = $views->{$r->{name}};
		$cur{lc $r->{name}} = { view=>$v, views=>$views, users=>\%user, types=>$types, cid_ip=>$check,
									parents_now=>($v ? [ map { { id=>$_, name=>(defined $vname{$_} ? $vname{$_} : "id $_") } } sort { $a <=> $b } @{$parents_of{$v->{id}}||[]} ] : []),
									has_user=>($has_user{$r->{name}}||{}),
									cycle=>$cycles->{lc $r->{name}}, will_create=>\%will };
	}
	return \%cur;
}

#----------------------------------------------------------------------------
# _check_cid_ip($ctx) -> { ip, error }
#----------------------------------------------------------------------------
sub _check_cid_ip {
my ($c,$ctx)=@_;
	my $ip = $ctx->{local_ip} ? $ctx->{local_ip}->() : undef;
	return { error=>"no se puede saber la IP del interfaz de /cfg/onm.if (ONMConfig::my_ip)" } if ((! defined $ip) || ($ip !~ /^\d+\.\d+\.\d+\.\d+$/));
	my $rows = $ctx->{dbh}->selectall_arrayref(
		"SELECT DISTINCT cid_ip FROM cfg_views WHERE cid=? AND cid_ip NOT IN ('','127.0.0.1')", undef, $ctx->{cid});
	my @db = map { $_->[0] } @$rows;
	return { error=>"las vistas de cid=$ctx->{cid} tienen mas de un cid_ip (".join(', ',@db)."): no se sabe cual usar" } if (@db > 1);
	return { error=>"la IP de /cfg/onm.if ($ip) no es el cid_ip de las vistas que ya hay ($db[0])" } if ((@db == 1) && ($db[0] ne $ip));
	my $n = eval { ($ctx->{dbh}->selectrow_array("SELECT COUNT(*) FROM cnm.cfg_cnms WHERE cid=? AND host_ip=?", undef, $ctx->{cid}, $ip))[0] };
	return { error=>"no se puede leer cnm.cfg_cnms: $@" } if ($@);
	return { error=>"cnm.cfg_cnms no tiene (cid=$ctx->{cid}, host_ip=$ip): la consola no listaria la vista" } if (! $n);
	return { ip=>$ip };
}

#----------------------------------------------------------------------------
# _cycles(\@resources, \%views, \%children) -> { lc name => [parents that close a cycle] }
# Nodes: "i<id>" for existing views, "n<lc name>" for the ones created in this state. The new
# links of the whole state replace the existing links of their children (one parent: giving a
# parent moves the view); a link parent->child closes a cycle when the parent can be reached
# going down from the child.
#----------------------------------------------------------------------------
sub _cycles {
my ($rs,$views,$children)=@_;
	my $node = sub { my $n=shift; return $views->{$n} ? "i$views->{$n}{id}" : 'n'.lc($n); };
	my %down = ();
	foreach my $p (keys %$children) { $down{"i$p"}{"i$_"}=1 foreach (@{$children->{$p}}); }
	my @new = ();
	foreach my $r (grep { defined $_->{parent} } @$rs) { push @new, [ $node->($r->{parent}), $node->($r->{name}), $r->{name}, $r->{parent} ]; }
	foreach my $e (@new) { delete $down{$_}{$e->[1]} foreach (keys %down); }
	$down{$_->[0]}{$_->[1]}=1 foreach (@new);
	my %out=();
	foreach my $e (@new) {
		my ($p,$ch) = ($e->[0], $e->[1]);
		my %seen=(); my @stack=($ch); my $found=0;
		while (@stack) {
			my $x = pop @stack;
			next if ($seen{$x}++);
			if ($x eq $p) { $found=1; last; }
			push @stack, keys %{$down{$x}||{}};
		}
		push @{$out{lc $e->[2]}}, $e->[3] if ($found);
	}
	return \%out;
}

#----------------------------------------------------------------------------
# diff($r, $cur, $ctx) -> (\@actions, \@errors, \@warnings)
#----------------------------------------------------------------------------
sub diff {
my ($c,$r,$cur,$ctx)=@_;
my (@acc,@err,@warn);
	my $v = $cur->{view};
	my $name = $r->{name};
	my $views = $cur->{views} || {};
	if ((! $v) && (! $r->{create})) {
		$ctx->{failed_view}{lc $name}=1;		# for the derived errors of the metrics
		return ([], [ "no existe en cid=$ctx->{cid} (cnm-control list views; para crearla, \"create\": true)" ], []);
	}

	# Fields of a new view: defaults < like < fields
	my %want=();
	if ($r->{like}) {
		my $m = $views->{$r->{like}};
		if (! $m) { push @err, "la vista modelo '$r->{like}' no existe (\"like\"; tiene que existir antes, no vale una que se crea en este estado)"; }
		else {
			push @err, "la vista modelo '$r->{like}' es viva, con reglas o con SLA: no se copia en esta fase"
				if ($m->{live_metric} || $m->{ruled} || $m->{sla});
			%want = map { $_ => $m->{$_} } qw(type itil_type global);
		}
	}
	%want = (%want, %{$r->{fields}||{}});
	if ($r->{create} && (! $v)) {
		$want{itil_type} = 1 if (! defined $want{itil_type});
		$want{global}    = 0 if (! defined $want{global});
		push @err, 'falta el tipo de la vista ("fields": {"type": ...} o "like")' if ((! defined $want{type}) || ($want{type} eq ''));
	}
	if (defined $want{type} && ($want{type} ne '')) {
		if (my $t = $cur->{types}{lc $want{type}}) { $want{type}=$t; }
		else { push @err, "el tipo de vista '$want{type}' no existe (cnm-control list viewtypes)"; }
	}

	# Parent and users
	my @pnow = @{$cur->{parents_now}||[]};
	if (@pnow > 1) {
		my $t = "tiene ".scalar(@pnow)." padres (".join(', ', map { "'$_->{name}'" } @pnow)."): una vista tiene un solo padre; corrigelo en la consola";
		if (defined $r->{parent}) { push @err, $t; } else { push @warn, $t; }
	}
	if (defined(my $p = $r->{parent})) {
		push @err, _derived($ctx->{failed_view}{lc $p}, "la vista padre '$p' no existe ni se crea en este estado")
			if (! ($views->{$p} || $cur->{will_create}{lc $p}));
	}
	push @err, "crearia un ciclo en el arbol de vistas con ".join(', ', map { "'$_'" } @{$cur->{cycle}}) if ($cur->{cycle});
	foreach my $l (@{$r->{users}||[]}) { push @err, "el usuario '$l' no existe (cnm-control list users)" if (! $cur->{users}{$l}); }

	if ($r->{create} && (! $v) && $cur->{cid_ip} && $cur->{cid_ip}{error}) {
		push @err, _derived($ctx->{failed_cid_ip}, $cur->{cid_ip}{error});
		$ctx->{failed_cid_ip}=1;
	}
	if (@err) { $ctx->{failed_view}{lc $name}=1 if (! $v); return ([], \@err, \@warn); }

	if (! $v) {
		$ctx->{pending_view}{lc $name}=1;
		push @acc, { kind=>'view', op=>'create', ref=>$name, name=>$name, fields=>{ %want }, cid_ip=>$cur->{cid_ip}{ip},
						 text=>"\"$name\" (type \"$want{type}\", itil_type $want{itil_type}, global $want{global}".
								 ($r->{like} ? ", como \"$r->{like}\"" : '').")" };
	}
	else {
		my %chg = map { $_ => [ (defined $v->{$_} ? "$v->{$_}" : ''), "$want{$_}" ] }
					 grep { defined $want{$_} && ((! defined $v->{$_}) || ("$v->{$_}" ne "$want{$_}")) } qw(type itil_type global);
		push @acc, { kind=>'view', op=>'update', ref=>$name, name=>$name, id=>$v->{id}, cid=>$v->{cid}, cid_ip=>$v->{cid_ip},
						 live=>($v->{live_metric} ? 1 : 0), changes=>\%chg,
						 text=>"\"$name\" ".join(', ', map { "$_ '$chg{$_}[0]' -> '$chg{$_}[1]'" } sort keys %chg) } if (%chg);
	}
	if (defined(my $p = $r->{parent})) {
		my $pv = $views->{$p};
		if ((! @pnow) || (! $v)) {
			push @acc, { kind=>'view', op=>'parent+', ref=>$name, name=>$name, parent=>$p, text=>"\"$name\" -> padre \"$p\"" };
		}
		elsif ((! $pv) || ($pnow[0]{id} != $pv->{id})) {
			push @acc, { kind=>'view', op=>'move', ref=>$name, name=>$name, parent=>$p, from_id=>$pnow[0]{id}, from=>$pnow[0]{name},
							 text=>"\"$name\" padre \"$pnow[0]{name}\" -> \"$p\"" };
		}
	}
	foreach my $l (@{$r->{users}||[]}) {
		my $u = $cur->{users}{$l};
		next if ($cur->{has_user}{lc $u->{login_name}});
		push @acc, { kind=>'view', op=>'user+', ref=>$name, name=>$name, id_user=>$u->{id_user}, login=>$u->{login_name},
						 text=>"\"$name\" -> usuario \"$u->{login_name}\"" };
	}
	return (\@acc, [], \@warn);
}

sub _derived { my ($is,$text)=@_; return $is ? { derived=>1, text=>$text } : $text; }

#----------------------------------------------------------------------------
# apply($ctx, \@actions) -> \@errors
# One transaction: creates, then links (the parent may be new), then users, then nsubviews.
#----------------------------------------------------------------------------
sub apply {
my ($c,$ctx,$acc)=@_;
	my $dbh=$ctx->{dbh};
	my %parents_touched=();
	eval {
		$dbh->begin_work();
		foreach my $x (grep { $_->{op} eq 'create' } @$acc) {
			my $f = $x->{fields};
			# 'create_view' (onm/sql/mod_Configure.sql:451); SLA columns: table default
			$dbh->do("INSERT INTO cfg_views (name,type,itil_type,ruled,global,cid,cid_ip,internal,live_metric,live_remote,sla) VALUES (?,?,?,0,?,?,?,1,0,0,0)",
						undef, $x->{name}, $f->{type}, $f->{itil_type}, $f->{global}, $ctx->{cid}, $x->{cid_ip});
			my ($id) = $dbh->selectrow_array("SELECT LAST_INSERT_ID()");
			die "sin id_cfg_view tras crear '$x->{name}'\n" if (! $id);
			# save() with live_metric=0 and live_remote=0 (onm/inc/class.cnmview.php)
			$dbh->do("DELETE FROM search_store2cfg_views2metrics WHERE id_cfg_view=?", undef, $id);
			$dbh->do("DELETE FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view=?", undef, $id);
		}
		foreach my $x (grep { $_->{op} eq 'update' } @$acc) {
			my $now = $dbh->selectrow_hashref("SELECT type,itil_type,global FROM cfg_views WHERE id_cfg_view=? AND cid=? AND cid_ip=? FOR UPDATE",
														 undef, $x->{id}, $x->{cid}, $x->{cid_ip});
			die "la vista '$x->{name}' ya no existe\n" if (! $now);
			foreach my $a (sort keys %{$x->{changes}}) {
				my $n = defined $now->{$a} ? "$now->{$a}" : '';
				die "vista '$x->{name}': $a vale '$n' y el plan esperaba '$x->{changes}{$a}[0]'; ha cambiado desde el plan\n" if ($n ne $x->{changes}{$a}[0]);
			}
			my @a = sort keys %{$x->{changes}};
			# 'update_view' (onm/sql/mod_Configure.sql:441), only the columns that change
			$dbh->do("UPDATE cfg_views SET ".join(',', map { "$_=?" } @a)." WHERE id_cfg_view=? AND cid=? AND cid_ip=?", undef,
						(map { $x->{changes}{$_}[1] } @a), $x->{id}, $x->{cid}, $x->{cid_ip});
			if (! $x->{live}) {		# save() (onm/inc/class.cnmview.php)
				$dbh->do("DELETE FROM search_store2cfg_views2metrics WHERE id_cfg_view=?", undef, $x->{id});
				$dbh->do("DELETE FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view=?", undef, $x->{id});
			}
		}
		my %v = ();
		my $get = sub {
			my $n=shift;
			return $v{lc $n} if ($v{lc $n});
			my $r = $dbh->selectrow_hashref("SELECT id_cfg_view,cid,cid_ip FROM cfg_views WHERE cid=? AND name=?", undef, $ctx->{cid}, $n);
			die "la vista '$n' no existe al aplicar\n" if (! $r);
			return $v{lc $n}=$r;
		};
		foreach my $x (grep { ($_->{op} eq 'parent+') || ($_->{op} eq 'move') } @$acc) {
			my ($p,$ch) = ($get->($x->{parent}), $get->($x->{name}));
			# Precondition: the parents of the view are still the ones of the plan
			my @now = map { $_->[0] } @{ $dbh->selectall_arrayref("SELECT id_cfg_view FROM cfg_views2views WHERE id_cfg_subview=? AND cid_subview=? FOR UPDATE",
																				undef, $ch->{id_cfg_view}, $ch->{cid}) };
			my $want = ($x->{op} eq 'move') ? $x->{from_id} : '';
			die "vista '$x->{name}': sus padres han cambiado desde el plan\n" if (join(',',sort @now) ne $want);
			if ($x->{op} eq 'move') {
				my $old = $dbh->selectrow_hashref("SELECT id_cfg_view,cid,cid_ip FROM cfg_views WHERE id_cfg_view=?", undef, $x->{from_id});
				# 'vista_desasociar_subvista' (onm/sql/mod_Configure.sql:525)
				$dbh->do("DELETE FROM cfg_views2views WHERE id_cfg_view=? AND id_cfg_subview=? AND cid_view=? AND cid_subview=?",
							undef, $x->{from_id}, $ch->{id_cfg_view}, $ctx->{cid}, $ch->{cid});
				$parents_touched{$x->{from_id}} = $old if ($old);
			}
			# 'vista_asociar_subvista' (onm/sql/mod_Configure.sql:522)
			$dbh->do("INSERT INTO cfg_views2views (id_cfg_view,id_cfg_subview,cid_view,cid_ip_view,cid_subview,cid_ip_subview) VALUES (?,?,?,?,?,?)",
						undef, $p->{id_cfg_view}, $ch->{id_cfg_view}, $p->{cid}, $p->{cid_ip}, $ch->{cid}, $ch->{cid_ip});
			$parents_touched{$p->{id_cfg_view}}=$p;
		}
		foreach my $x (grep { $_->{op} eq 'user+' } @$acc) {
			my $w = $get->($x->{name});
			# 'asoc_user' (onm/sql/mod_Configure.sql:444)
			$dbh->do("INSERT IGNORE INTO cfg_user2view (id_cfg_view,id_user,cid,cid_ip,login_name) VALUES (?,?,?,?,?)",
						undef, $w->{id_cfg_view}, $x->{id_user}, $w->{cid}, $w->{cid_ip}, $x->{login});
		}
		# 'cnm_view_get_num_subviews' and 'cnm_view_update_nsubviews' (onm/sql/mod_Configure.sql:2452-2453)
		foreach my $p (values %parents_touched) {
			my ($n) = $dbh->selectrow_array("SELECT count(DISTINCT a.id_cfg_subview) FROM cfg_views2views a WHERE a.id_cfg_view=?", undef, $p->{id_cfg_view});
			$dbh->do("UPDATE cfg_views SET nsubviews=? WHERE id_cfg_view=? AND cid=? AND cid_ip=?", undef, $n, $p->{id_cfg_view}, $p->{cid}, $p->{cid_ip});
		}
		$dbh->commit();
	};
	if ($@) { my $e=$@; chomp $e; eval { $dbh->rollback(); }; return [ "vistas (deshecho): $e" ]; }
	return [];
}

1;
