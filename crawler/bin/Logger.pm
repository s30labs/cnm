#####################################################################################################
# Fichero: (Logger.pm) $Id: Logger.pm,v 1.3 2004/10/04 10:38:21 fml Exp $
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# Descripción: Módulo que encapsula las funciones de Syslog
#####################################################################################################
package Logger;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

use POSIX qw(:signal_h setsid WNOHANG);
use Carp 'croak','cluck';
use Carp::Heavy;
use File::Basename;
use IO::File;
use Cwd;
use Sys::Syslog qw(:DEFAULT setlogsock);
require Exporter;

@EXPORT_OK = qw( init_log log_debug log_notice log_info log_warn log_die );
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#----------------------------------------------------------------------------
use constant FACILITY => 'local0';
use constant FACILITY_NOTIFICATIONSD => 'lpr';
use constant FACILITY_ACTIONSD => 'daemon';
use constant FACILITY_CRON => 'cron';
use constant FACILITY_LOG_MANAGER => 'news';
use constant FACILITY_TRAP_MANAGER => 'uucp';
use constant FACILITY_MAIL_MANAGER => 'ftp';

#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: init_log
# Descripcion: Inicializa el volcado a syslog en la facility FACILITY. Tambien
# redirige los warnings y errores de perl
#----------------------------------------------------------------------------
sub init_log {
  	setlogsock('unix');
  	my $basename = basename($0);
	my $facility=FACILITY;
	if ($basename =~ /notificationsd\.010/) { $facility=FACILITY_NOTIFICATIONSD;}
	elsif ($basename =~ /notificationsd\.020/) { $facility=FACILITY_NOTIFICATIONSD;}
	elsif ($basename =~ /actionsd\.000/) { $facility=FACILITY_ACTIONSD;}
	elsif (($basename eq 'cnm-watch') || ($basename eq 'cnm-daily') || ($basename eq 'cnm-hourly')) { $facility=FACILITY_CRON;}
	elsif ($basename eq 'log_manager') { $facility=FACILITY_LOG_MANAGER;}
	elsif ($basename eq 'trap_manager') { $facility=FACILITY_TRAP_MANAGER;}
	elsif ($basename eq 'mail_manager') { $facility=FACILITY_MAIL_MANAGER;}

  	openlog($basename,'pid',$facility);
  	$SIG{__WARN__} = \&log_warn;
  	$SIG{__DIE__}  = \&log_die;
}


#----------------------------------------------------------------------------
# Funcion: log_debug
# Descripcion: Se ocupa de registrar mensajes de debug
#----------------------------------------------------------------------------
sub log_debug  { eval { syslog('debug','%s',_msg(@_)); };  }

#----------------------------------------------------------------------------
# Funcion: log_notice
# Descripcion: Se ocupa de registrar mensajes informativos
#----------------------------------------------------------------------------
sub log_notice { eval { syslog('notice','%s',_msg(@_)); }; }

#----------------------------------------------------------------------------
# Funcion: log_info
# Descripcion: Se ocupa de registrar mensajes informativos
#----------------------------------------------------------------------------
sub log_info { eval { syslog('info','%s',_msg(@_)); }; }

#----------------------------------------------------------------------------
# Funcion: log_warn
# Descripcion: Se ocupa de registrar mensajes de warning
#----------------------------------------------------------------------------
sub log_warn   { eval { syslog('warning','%s',_msg(@_)); }; }

#----------------------------------------------------------------------------
# Funcion: log_die
# Descripcion: Se ocupa de registrar mensajes de terminacion del programa
#----------------------------------------------------------------------------
sub log_die {
  syslog('crit','%s',_msg(@_)) unless $^S;
  die @_;
}

#----------------------------------------------------------------------------
# Funcion: _msg
# Descripcion: Funcion auxiliar para componer el mensaje
#----------------------------------------------------------------------------
sub _msg {
  my $msg = join('',@_) || "Registro de log";
  my ($pack,$filename,$line) = caller(1);
  $msg .= " en $filename linea $line\n" unless $msg =~ /\n$/;
  $msg;
}


1;
__END__


