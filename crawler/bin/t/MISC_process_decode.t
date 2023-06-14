#!/usr/bin/perl -w
use strict;
use Data::Dumper;


my %pid2cmd=();
# Obtener información sobre los procesos que se están ejecutando
my $ps_output = `ps -eo pid,ppid,cmd`;

# Separar la salida del comando ps en líneas
my @ps_lines = split /\n/, $ps_output;

# Saltar la primera línea (cabecera de la salida)
shift @ps_lines;
my $total_proc = scalar(@ps_lines);

# Inicializar un hash para almacenar el número de procesos hijos de cada proceso padre
my %parent_child_counts;

# Iterar sobre cada línea del resultado de ps
foreach my $line (@ps_lines) {
  
  # Obtener el PID, PPID y comando de la línea
  my ($pid, $ppid, $cmd) = $line =~ /^ *(\d+) +(\d+) (.+)$/;
  $pid2cmd{$pid} = $cmd;

  print "$pid\t$ppid\t$cmd\n";
  
  # Obtener una lista de los procesos hijos del proceso actual
  my @child_pids = get_child_pids($pid, \@ps_lines);
  
  # Añadir el número de procesos hijos al hash
  $parent_child_counts{$ppid} += scalar(@child_pids);
}

print "TOTAL_PROCESOS = $total_proc\n";
# Imprimir los resultados
foreach my $parent_pid (sort {$a <=> $b} keys %parent_child_counts) {
  my $child_count = $parent_child_counts{$parent_pid};
  if ($child_count == 0) { next; }	
  printf "PID %d >> %d childs      || %s\n", $parent_pid, $child_count, $pid2cmd{$parent_pid};
}

# Función recursiva para obtener los procesos hijos de un proceso dado
sub get_child_pids {
  my ($parent_pid, $ps_lines_ref) = @_;
  
  my @child_pids;
  
  foreach my $line (@$ps_lines_ref) {
    # Obtener el PID, PPID y comando de la línea
    my ($pid, $ppid, $cmd) = $line =~ /^ *(\d+) +(\d+) (.+)$/;

    # Si el PPID coincide con el PID del padre dado, añadir el PID a la lista de procesos hijos
    if ($ppid == $parent_pid) {
      push @child_pids, $pid;
      
      # Recursivamente obtener los procesos hijos de este proceso
      push @child_pids, get_child_pids($pid, $ps_lines_ref);
    }
  }
  
  return @child_pids;
}


exit;




# ps -ef output
#UID        PID  PPID  C STIME TTY          TIME CMD
#root         1     0  0 04:15 ?        00:00:32 init [2]
#root         2     0  0 04:15 ?        00:00:00 [kthreadd]
#root      2820     1  0 04:15 tty6     00:00:00 /sbin/getty 38400 tty6
#www-data  1851  1845  0 04:15 ?        00:01:08 /usr/sbin/apache2 -k start

my %PROCS = ('kernel'=>0, 'crawler'=>0, 'notif'=>0, 'actions'=>0, 'other'=>0);
while (<STDIN>) {
	chomp;
	if ($_ =~/^UID/) { next; }
	if ($_ =~/^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\:\d+)\s+(\S+)\s+(\d+\:\d+\:\d+)\s+(.+)$/) {
		my ($UID,$PID,$PPID,$C,$STIME,$TTY,$TIME,$CMD) = ($1,$2,$3,$4,$5,$6,$7,$8);
		#print "$UID >> $CMD\n";

		if ($CMD =~/^\[crawler/) { $PROCS{'crawler'} += 1; }
		elsif ($CMD =~/^\[notif/) { $PROCS{'notif'} += 1; }
		elsif ($CMD =~/^\[actio/) { $PROCS{'actions'} += 1; }
		elsif ($CMD =~/^\[/) { $PROCS{'kernel'} += 1; }
		#elsif ($CMD =~/^/) { $PROCS{''} += 1; }
		else { $PROCS{'other'} += 1; 

print "$UID >> $CMD\n";
}
	}
	#else {print "$_\n"; }
}

print Dumper (\%PROCS);
