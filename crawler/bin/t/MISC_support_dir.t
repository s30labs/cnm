#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de SupportDir.pm: donde escriben las herramientas de soporte y la purga
# de sus ejecuciones (REF-CNM-Estilo-Scripts §2.9). Usa un directorio temporal
# como raiz (CNM_SUPPORT_DIR); no toca /store/data/support.
#
#   perl t/MISC_support_dir.t            (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use File::Temp qw(tempdir);
use POSIX qw(strftime);
use SupportDir qw(SUPPORT_ROOT RETENTION_DAYS support_root valid_tool support_dir new_run_dir
						run_stamp purge_candidates purge_runs);

delete $ENV{'CNM_SUPPORT_DIR'};
is(support_root(), '/store/data/support', 'raiz por defecto');
is(RETENTION_DAYS, 30, '30 dias por defecto');

my $T = tempdir(CLEANUP=>1);
$ENV{'CNM_SUPPORT_DIR'} = $T;
is(support_root(), $T, 'raiz con CNM_SUPPORT_DIR');

ok(valid_tool('cnm-testbed'), 'nombre valido');
ok(! valid_tool('../etc'), 'nombre con .. no vale');
ok(! valid_tool('Cnm'), 'nombre con mayusculas no vale');
ok(! valid_tool(''), 'nombre vacio no vale');
ok(! eval { support_dir('../x','state'); 1 }, 'support_dir con un nombre malo muere');
ok(! eval { support_dir('t','tmp'); 1 }, 'support_dir con un tipo que no existe muere');

is(support_dir('t','state'), "$T/t/state", 'support_dir sin crear');
ok(! -d "$T/t/state", 'sin $create no crea nada');
is(support_dir('t','state',1), "$T/t/state", 'support_dir con crear');
ok(-d "$T/t/state", 'con $create lo crea');
is((stat("$T/t/state"))[2] & 07777, 0700, 'modo 0700');

my $now = time();
my $r1 = new_run_dir('t','setup',$now);
like($r1, qr{^\Q$T\E/t/runs/\d{8}-\d{6}-setup$}, 'new_run_dir: runs/FECHA-etiqueta');
ok(-d $r1, 'new_run_dir: lo crea');
my $r2 = new_run_dir('t','setup',$now);
is($r2, "$r1.1", 'new_run_dir en el mismo segundo: .1');
ok(! eval { new_run_dir('t','a/b',$now); 1 }, 'etiqueta con / no vale');

is(run_stamp('20261121-111641-setup'), POSIX::mktime(41,16,11,21,10,126), 'run_stamp: fecha del nombre');
is(run_stamp('cosa'), undef, 'run_stamp: nombre sin fecha');

#--- purge_candidates (pura) ----------------------------------------------------
my $d = 86400;
my $old = strftime('%Y%m%d-%H%M%S', localtime($now-40*$d));
my $new = strftime('%Y%m%d-%H%M%S', localtime($now-10*$d));
my @E = (
	{ path=>'r/a', name=>"$old-x",  isdir=>1, mtime=>$now, keep=>0 },	# viejo por nombre: se borra
	{ path=>'r/b', name=>"$new-x",  isdir=>1, mtime=>$now-90*$d, keep=>0 },	# nuevo por nombre: se queda
	{ path=>'r/c', name=>"$old-k",  isdir=>1, mtime=>$now, keep=>1 },	# con KEEP: se queda
	{ path=>'r/d', name=>'suelto',   isdir=>1, mtime=>$now-40*$d, keep=>0 },	# sin fecha: por mtime, se borra
	{ path=>'r/e', name=>'otro',     isdir=>1, mtime=>$now-5*$d,  keep=>0 },	# sin fecha, reciente: se queda
	{ path=>'r/f', name=>"$old.txt", isdir=>0, mtime=>$now-90*$d, keep=>0 },	# fichero: no se toca
);
is_deeply([purge_candidates(\@E,30,$now)], ['r/a','r/d'], 'purge_candidates: viejos sin KEEP, solo directorios');
is_deeply([purge_candidates(\@E,60,$now)], [], 'purge_candidates con 60 dias: ninguno');

#--- purge_runs sobre disco -----------------------------------------------------
my $R = "$T/t/runs";
mkdir "$R/$old-viejo"; open(my $f,'>',"$R/$old-viejo/x.txt"); close $f;
mkdir "$R/$old-guardado"; open($f,'>',"$R/$old-guardado/KEEP"); close $f;
mkdir "$R/$new-reciente";
mkdir "$T/t/state/$old-no-es-run";
open($f,'>',"$R/$old-suelto.txt"); close $f; utime($now-90*$d,$now-90*$d,"$R/$old-suelto.txt");
my @dry = purge_runs(30,1,$now);
is_deeply(\@dry, ["$R/$old-viejo"], 'purge_runs en seco: dice cual borraria');
ok(-d "$R/$old-viejo", 'purge_runs en seco: no borra');
my @done = purge_runs(30,0,$now);
is_deeply(\@done, ["$R/$old-viejo"], 'purge_runs: borra el viejo');
ok(! -e "$R/$old-viejo", 'purge_runs: ya no esta');
ok(-d "$R/$old-guardado", 'purge_runs: respeta KEEP');
ok(-d "$R/$new-reciente", 'purge_runs: respeta el reciente');
ok(-d "$T/t/state/$old-no-es-run", 'purge_runs: no toca state/');
ok(-e "$R/$old-suelto.txt", 'purge_runs: no toca ficheros sueltos en runs/');
ok(-d $r1, 'purge_runs: no toca las ejecuciones de hoy');

$ENV{'CNM_SUPPORT_DIR'} = "$T/no-existe";
is_deeply([purge_runs(30,0,$now)], [], 'purge_runs sin raiz: no hace nada');

done_testing();
