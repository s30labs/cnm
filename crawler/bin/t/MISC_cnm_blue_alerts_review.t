#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de support/cnm-blue-alerts-review con mysql y plite simulados:
# codigos de salida, ficheros que deja, y que -R pone PROV_REMAP_BY_LABEL = 1
# solo durante la provision y deja despues lo que habia, tambien si falla o
# se interrumpe. No toca la base ni /cfg/onm.conf.
#
#   perl t/MISC_cnm_blue_alerts_review.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use strict;
use Test::More;
use FindBin;
use File::Temp qw(tempdir);

my $SCRIPT = "$FindBin::Bin/../support/cnm-blue-alerts-review";
my $T = tempdir(CLEANUP=>1);
mkdir "$T/bin"; mkdir "$T/out";

sub write_file { my ($p,$t,$x)=@_; open(my $f,'>',$p) or die "$p: $!"; print $f $t; close $f; chmod 0755,$p if ($x); }
sub read_file  { my ($p)=@_; open(my $f,'<',$p) or return undef; local $/; my $t=<$f>; close $f; return $t; }

# mysql simulado: equipo 49 existe; FAKE_MYSQL_RC fuerza un fallo
write_file("$T/mysql", <<'EOF', 1);
#!/bin/bash
[ -n "${FAKE_MYSQL_RC:-}" ] && exit "$FAKE_MYSQL_RC"
q="${*: -1}"
[ -n "${QLOG:-}" ] && echo "$q" >> "$QLOG"
[ -n "${FAKE_FAIL_ON:-}" ] && [[ "$q" == *"$FAKE_FAIL_ON"* ]] && exit 1
case "$q" in
	*"FROM devices WHERE id_dev=49"*) echo prawwerpas02 ;;
	*"FROM devices WHERE id_dev="*) ;;
	*"FROM prov_template_metrics2iid"*) st=0; [ -e "$CHANGED" ] && st=1; printf 'disk_mibhost\t188\tUSO DE DISCO /run/user/0 (x)\t0\t%s\n' "$st" ;;
	*) echo "fila" ;;
esac
EOF
# plite simulado: apunta lo que ve en onm.conf y sale con FAKE_PLITE_RC
write_file("$T/bin/plite", <<'EOF', 1);
#!/bin/bash
grep -E '^[[:space:]]*PROV_REMAP_BY_LABEL' "$ONM_CONF" > "$SEEN" || echo "(ninguna)" > "$SEEN"
touch "$CHANGED"; sleep "${FAKE_PLITE_SLEEP:-0}"
exit "${FAKE_PLITE_RC:-0}"
EOF

my $CONF = "$T/onm.conf";
my $SEEN = "$T/seen";
my $CHANGED = "$T/changed";
sub run {
	my ($args,%env)=@_;
	my $e = join(' ', map { "$_='$env{$_}'" } sort keys %env);
	my $cmd = "ONM_CONF='$CONF' PLITE_DIR='$T/bin' MYSQL='$T/mysql' SEEN='$SEEN' CHANGED='$CHANGED' $e $SCRIPT $args > $T/stdout 2> $T/stderr";
	system('bash','-c',$cmd);
	return $? >> 8;
}
sub out { return read_file("$T/stdout").read_file("$T/stderr"); }

my $BASE_CONF = "db_name = onm\n#PROV_REMAP_BY_LABEL = 1 (comentado)\nPROV_REMAP_BY_LABEL = 0\nlog_level = info\n";

#------------------------------------------------------------------------------
# 1. Uso
#------------------------------------------------------------------------------
write_file($CONF,$BASE_CONF);
is(run(''), 2, 'sin argumentos: rc=2');
is(run('-h'), 0, '-h: rc=0');
like(out(), qr/run ID \[-R\]/, '-h: muestra la ayuda');
is(run('nada'), 2, 'orden desconocida: rc=2');
is(run('run abc'), 2, 'ID no numerico: rc=2');
is(run('run 49 -X'), 2, 'opcion desconocida: rc=2');
is(run('show'), 2, 'show sin ID: rc=2');
is(run('run 50 -o '.$T.'/out'), 1, 'equipo que no existe: rc=1');
ok(! -e $SEEN, 'equipo que no existe: no se lanza plite');

#------------------------------------------------------------------------------
# 2. run sin -R: no toca onm.conf
#------------------------------------------------------------------------------
unlink $CHANGED;
is(run("run 49 -o $T/out"), 0, 'run sin -R: rc=0');
is(read_file($CONF), $BASE_CONF, 'run sin -R: onm.conf no cambia');
is(read_file($SEEN), "PROV_REMAP_BY_LABEL = 0\n", 'run sin -R: plite ve el valor que habia');
my @f = map { s{.*/}{}r } glob("$T/out/49-*");
is(scalar(grep { /-(antes|despues|diff|avisos)\.txt$|-plite\.log$/ } @f), 5, 'run: deja antes, despues, diff, avisos y log');
is(scalar(@f), 5, 'run: no deja ningun otro fichero');
like(out(), qr{^Provision: \(cd \S+/bin && \./plite -r 49 -t 0\) > \S+/49-\d{8}-\d{6}-plite\.log 2>&1$}m, 'run: muestra el comando exacto de plite');
like(out(), qr/plantilla: 1 filas solo antes, 1 filas solo despues/, 'run: resumen de diferencias de la plantilla');
unlike(out(), qr/^[<>] /m, 'run sin -v: no saca el diff completo');
unlink $CHANGED; run("run 49 -v -o $T/out");
like(out(), qr/^< disk_mibhost/m, 'run -v: saca el diff completo');
like(read_file((glob("$T/out/49-*-antes.txt"))[0]), qr/^# plantilla:.*\n.*188.*\n# metricas:/s, 'run: la foto lleva plantilla y metricas');

#------------------------------------------------------------------------------
# 3. run -R: 1 durante la provision, y despues lo que habia
#------------------------------------------------------------------------------
unlink $SEEN;
is(run("run 49 -R -o $T/out"), 0, 'run -R: rc=0');
is(read_file($SEEN), "PROV_REMAP_BY_LABEL = 1\n", 'run -R: plite ve PROV_REMAP_BY_LABEL = 1 (una sola linea)');
my $after = read_file($CONF);
like($after, qr/^PROV_REMAP_BY_LABEL = 0$/m, 'run -R: despues vuelve a 0');
is(scalar(() = $after =~ /^\s*PROV_REMAP_BY_LABEL/mg), 1, 'run -R: despues hay una sola linea activa');
like($after, qr/^#PROV_REMAP_BY_LABEL = 1 \(comentado\)$/m, 'run -R: el comentario no se toca');
like($after, qr/^db_name = onm$/m, 'run -R: el resto no se toca');

write_file($CONF,"db_name = onm\n");
is(run("run 49 -R -o $T/out"), 0, 'run -R sin la linea: rc=0');
is(read_file($CONF), "db_name = onm\n", 'run -R sin la linea: despues sigue sin ella');

#------------------------------------------------------------------------------
# 4. Fallos: provision con error, interrupcion, base caida
#------------------------------------------------------------------------------
write_file($CONF,$BASE_CONF);
is(run("run 49 -R -o $T/out", FAKE_PLITE_RC=>3), 1, 'plite con rc=3: rc=1');
like(out(), qr/plite rc=3/, 'plite con rc=3: lo dice');
like(read_file($CONF), qr/^PROV_REMAP_BY_LABEL = 0$/m, 'plite con rc=3: onm.conf vuelve a 0');

write_file($CONF,$BASE_CONF);
my $pid = fork();
if ($pid == 0) { exec('bash','-c',"ONM_CONF='$CONF' PLITE_DIR='$T/bin' MYSQL='$T/mysql' SEEN='$SEEN' CHANGED='$CHANGED' FAKE_PLITE_SLEEP=2 exec $SCRIPT run 49 -R -o $T/out > /dev/null 2>&1"); }
select(undef,undef,undef,0.8);
like(read_file($CONF), qr/^PROV_REMAP_BY_LABEL = 1$/m, 'interrumpido: durante la provision esta a 1');
kill 'TERM', $pid; waitpid($pid,0);
is($? >> 8, 1, 'interrumpido: rc=1');
like(read_file($CONF), qr/^PROV_REMAP_BY_LABEL = 0$/m, 'interrumpido: onm.conf vuelve a 0');

write_file($CONF,$BASE_CONF); unlink $SEEN;
is(run("run 49 -R -o $T/out", FAKE_MYSQL_RC=>1), 1, 'base caida: rc=1');
ok(! -e $SEEN, 'base caida: no se lanza plite');
is(read_file($CONF), $BASE_CONF, 'base caida: onm.conf no cambia');

write_file($CONF,$BASE_CONF); unlink $SEEN;
is(run("run 49 -R -o $T/out", FAKE_FAIL_ON=>'prov_template_metrics2iid'), 1, 'falla la foto de antes: rc=1');
ok(! -e $SEEN, 'falla la foto de antes: no se lanza plite');
is(read_file($CONF), $BASE_CONF, 'falla la foto de antes: onm.conf no cambia');

#------------------------------------------------------------------------------
# 5. Purga de DIR: solo sus ficheros y solo los viejos
#------------------------------------------------------------------------------
write_file($CONF,$BASE_CONF);
my $P = "$T/purga"; mkdir $P;
my @old  = map { "$P/12-20251001-101010-$_" } qw(antes.txt despues.txt diff.txt avisos.txt plite.log);
my @keep = ("$P/12-20251001-101010-otro.txt", "$P/notas.txt", "$P/ajeno-20251001-101010-antes.txt");
my $new  = "$P/13-20261101-101010-antes.txt";
write_file($_,"x") foreach (@old,@keep,$new);
system('touch','-d','30 days ago',@old,@keep);
system('touch','-d','2 days ago',$new);
is(run("run 49 -o $P"), 0, 'purga: rc=0');
is(scalar(grep { -e } @old), 0, 'purga: borra los cinco ficheros de run de mas de 15 dias');
is(scalar(grep { -e } @keep), 3, 'purga: no toca ficheros que no son suyos, aunque sean viejos');
ok(-e $new, 'purga: no toca los de menos de 15 dias');
like(out(), qr/Purga: 5 ficheros de mas de 15 dias/, 'purga: dice cuantos ha borrado');
system('touch','-d','30 days ago',$new);
is(run("run 49 -k 60 -o $P"), 0, '-k 60: rc=0');
ok(-e $new, '-k 60: no borra uno de 30 dias');
is(run("run 49 -k x -o $P"), 2, '-k sin numero: rc=2');

#------------------------------------------------------------------------------
# 6. check
#------------------------------------------------------------------------------
my $QLOG = "$T/qlog"; unlink $QLOG;
is(run("check 49", QLOG=>$QLOG), 0, 'check: rc=0');
like(out(), qr/--- Metricas sin fila en la plantilla/, 'check: seccion de metricas sin plantilla');
like(read_file($QLOG), qr/FROM metrics m LEFT JOIN prov_template_metrics2iid t ON t\.id_dev=m\.id_dev AND t\.mname=m\.name WHERE m\.id_dev=49 AND t\.mname IS NULL/, 'check: busca las metricas del equipo sin fila en la plantilla');
like(read_file($QLOG), qr/WHERE id_dev=49 AND status=3/, 'check: busca las de status 3');
is(run("check abc"), 2, 'check con ID no numerico: rc=2');

done_testing();
