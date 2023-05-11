#######################################################################################################
# Fichero: System.pm
# Contiene las funciones necesarias para el mantenimiento y verificacion del software de systema
########################################################################################################
package System;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use ExtUtils::Installed;
use ExtUtils::Installed;
use File::Copy;
use Cwd;
use Data::Dumper;

@EXPORT_OK = qw( os2system osbase2system pre_system_configuration post_system_configuration do_updates set_key get_input create_dir check_os do_apt_install do_perl_module_check_all perl_module_install do_init_store php_post_config prepare_git_dirs my_if check_ntp_config check_dns_config);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#-------------------------------------------------------------------------------------------
my $DIR_PERL_MODULES='/opt/cnm-extras/perl_modules';
#-------------------------------------------------------------------------------------------
my $RM='/bin/rm';
my $CP='/bin/cp';

my $KILLALL='/usr/bin/killall';
my $FIND='/usr/bin/find';
my $LDCONFIG='/sbin/ldconfig';

my ($RC,$ROK,$RNOK);
my $DEBUG=0;
my $www_user='apache';


#-------------------------------------------------------------------------------------------
# create_dir
# Si no existe el directorio especificado, lo crea.
# Es una funcion publica, para exportar
#-------------------------------------------------------------------------------------------
sub create_dir {
my ($opt,$dir,$perm,$ug) = @_;

   ($RC,$ROK,$RNOK)=(0,0,0);

	if (! -d $dir) {
		$RC=_mymkdir($opt,$dir,\$ROK,\$RNOK);
	}
	if ($perm) { $RC=_mychmod($perm, $dir,\$ROK,\$RNOK); }
	if ($ug) { $RC=_mychown("-R $ug", $dir,\$ROK,\$RNOK); }

}

#-------------------------------------------------------------------------------------------
# Copia los directorios /os/root, /os/etc, /os/usr, /os/home y /os/lib a la raiz
# En el directorio /os estan los ficheros de sistema que son imprescindibles bajo SVN.
# Hay dos tipos:
#  1. Ficheros sin personalizacion. Se guardan bajo svn y se copian en esta funcion
#  2. Ficheros con personalizacion. Requieren la ejecucion de chk-host
#-------------------------------------------------------------------------------------------
sub os2system{

	($RC,$ROK,$RNOK)=(0,0,0);

   my @directories=('etc','usr','root','home','lib');
	my $cfiles=0;
	my $cdir=scalar @directories;
	my $os=check_os();
   foreach my $dir (@directories){
		if (!-d "/os/$os/$dir") { next; }
      my $cmd="$FIND /os/$os/$dir";
      my @rcstr_cmd=`$cmd`;
      # print Dumper(@rcstr_cmd);
      foreach my $file (@rcstr_cmd) {
         if ($file=~/\.svn/){next;}
         if ($file=~/\.base/){next;}
         chomp($file);
         if (-d $file){next};
         $file=~/\/os\/$os(.+)/;
			my $file_dest=$1;
			my $dir_dest = '/';
			if ($file_dest=~/^(.+)\/.+$/) { $dir_dest = $1; }
			if (! -d $dir_dest) {
				 $RC=_mymkdir('-p',$dir_dest,\$ROK,\$RNOK);
			}
			if ($os eq 'fc') {
				_mycp('-fr --reply=yes', $file, $file_dest, \$ROK, \$RNOK);
			}
			else {
            _mycp('-fr', $file, $file_dest, \$ROK, \$RNOK);
         }
			$cfiles++;
      }
   }

	if ( (-f '/etc/cron.daily/logrotate') && (-f '/etc/cron.daily12/logrotate')) { unlink '/etc/cron.daily/logrotate'; }

#	#PARCHE para debian6
#	#El fichero sources.list es diferente
#   my $version=slurp_file('/etc/debian_version');
#   chomp $version;
#   if ($version eq '6.0') { _mycp('-fr', '/os/deb/etc/apt/sources6.list', '/etc/apt/sources.list', \$ROK, \$RNOK); }

   print "[ DONE ] >> Ficheros de /os (dir=$cdir, files=$cfiles) [OK=$ROK, NOK=$RNOK]\n";

}

#-------------------------------------------------------------------------------------------
# Copia los ficheros .base de /os/etc, /cfg y /os/usr a la raiz
# Son ficheros con personalizacion. Requieren la ejecucion de chk-host
#-------------------------------------------------------------------------------------------
sub osbase2system{
my ($globals,$file_cfg)=@_;

   ($RC,$ROK,$RNOK)=(0,0,0);
	my $tpl='';

	#----------------------------------
   my $file_db_credentials='/cfg/onm.conf';
   open (F,"<$file_db_credentials");
   while (<F>) {
      chomp;
      if (/^#/) {next;}
      if (/\bDB_PWD\s*\=\s*(.*)$/) {
         $globals->{'__DB_PWD__'}=$1;
         last;
      }
   }
   close F;

	$globals->{'__SDX__'} = get_store_dev();

   my @directories=('etc','usr','cfg');
   my $cfiles=0;
   my $cdir=scalar @directories;
	my $os=check_os();
   foreach my $dir (@directories){
		if (!-d "/os/$os/$dir") { next; }
      my $cmd="$FIND /os/$os/$dir";
      my @rcstr_cmd=`$cmd`;
      # print Dumper(@rcstr_cmd);
      foreach my $file (@rcstr_cmd) {
         if ($file=~/\.svn/){next;}
         if ($file !~ /\.base/){next;}
         chomp($file);
         if (-d $file){next};

			# Si se espeifica un fichero determinado como parametro
			# solo se va amodificar ese fichero
			if ((defined $file_cfg) && ($file_cfg ne $file)) { next; }

			# Leo el fichero en una variable
			$tpl='';
		   if (open (F,"<$file")) {
      		local $/=undef;
      		$tpl=<F>;
      		close F;
			}
			# Personalizao el fichero con el hash $globals (ref)
			if ($tpl ne '') {
				while (my ($k,$v) = each %$globals) {
					#$k = __IPADDR__ ; $v= 1.1.1.1 (p.ej)
					$tpl =~ s/$k/$v/g;
				}
			}
			else {
				$RNOK++;
				next;
			}
			# Almaceno el resultado
         if ( $file=~/\/os\/$os(.+)\.base$/ ) {
				my $file_res=$1;
   	     	if (open (F,">$file_res")) {
      	      print F $tpl;
         	   close F;
					$ROK++;
				}
         }
         $cfiles++;
      }
   }

	$www_user = ($os eq 'fc') ? 'apache' : 'www-data';
	if (-f '/cfg/onm.conf') {
		$RC=_mychown("root:$www_user",'/cfg/onm.conf',\$ROK,\$RNOK);
		$RC=_mychmod('776','/cfg/onm.conf',\$ROK,\$RNOK);
	}

   $RC=_mychown("root:$www_user",'/etc/cron.hourly/ntpdate',\$ROK,\$RNOK);
   $RC=_mychmod('775','/etc/cron.hourly/ntpdate',\$ROK,\$RNOK);
	if (-f '/etc/cron.hourly/logrotate') { 
		if (! -d '/etc/cron.hourly12') { $RC=_mymkdir('-p','/etc/cron.hourly12',\$ROK,\$RNOK); }
		move('/etc/cron.hourly/logrotate', '/etc/cron.hourly12');
	}

   $RC=_mychown("root:$www_user",'/etc/resolv.conf',\$ROK,\$RNOK);
   $RC=_mychmod('664','/etc/resolv.conf',\$ROK,\$RNOK);

	my $hname=$globals->{'__HOSTNAME__'};
	`/bin/hostname $hname`; 

	if (!defined $file_cfg) {
   	print "[ DONE ] >> Ficheros de /os (dir=$cdir, files=$cfiles) [OK=$ROK, NOK=$RNOK]\n";
	}
	else { print "$cfiles\n"; }

	#------------------------------------------------------
  	#Caso especial para MV routed y no bridged
	#------------------------------------------------------
my $INTERFACES_NAT='# Auto generated lo interface
auto lo
iface lo inet loopback

# Auto generated venet0 interface
auto venet0
iface venet0 inet manual
        up ifconfig venet0 up
        up ifconfig venet0 __GATEWAY__
        up route add default dev venet0
        down route del default dev venet0
        down ifconfig venet0 down


iface venet0 inet6 manual
        up route -A inet6 add default dev venet0
        down route -A inet6 del default dev venet0

auto venet0:0
iface venet0:0 inet static
        address __IPADDR__
        netmask 255.255.255.255
';

	my $if=my_if();
	if ($if eq 'venet0:0') {
		my $tpl=$INTERFACES_NAT;
      while (my ($k,$v) = each %$globals) {
	      $tpl =~ s/$k/$v/g;
      }
		open (F,">/etc/network/interfaces");
		print F $tpl;
		close F;
	}

}

#-------------------------------------------------------------------------------------------
# Crea directorios/ficheros + permisos
#-------------------------------------------------------------------------------------------
sub pre_system_configuration {

   ($RC,$ROK,$RNOK)=(0,0,0);
	my $os=check_os();
	$www_user = ($os eq 'fc') ? 'apache' : 'www-data';

	#----------------------------------------------------------------------------------------
   # SO (Crea/Modifica permisos en ficheros/directorios.
   $RC=_mymkdir('-p','/etc/cron.fast/',\$ROK,\$RNOK);				# Crea directorio /etc/cron.fast/
	$RC=_mymkdir('-p','/etc/cron.daily12/',\$ROK,\$RNOK);       # Crea directorio /etc/cron.daily12/
   $RC=_mymkdir('-p','/usr/local/etc/snmp',\$ROK,\$RNOK);		# Crea directorio /usr/local/etc/snmp
   $RC=_mychmod('664','/etc/resolv.conf',\$ROK,\$RNOK);			# Permiso para modificar los DNSs
   $RC=_mychmod('751','/root',\$ROK,\$RNOK);							# svn
	if ($os eq 'fc') {
	   $RC=_mychmod('666','/root/.subversion/servers',\$ROK,\$RNOK);	#svn
	}
	else {
      $RC=_mychmod('666','/etc/subversion/servers',\$ROK,\$RNOK);  #svn
		if ( (! -f '/opt/rrdtool/bin/rrdtool') && (-f '/usr/bin/rrdtool')) {
			$RC=_mymkdir('-p','/opt/rrdtool/bin/',\$ROK,\$RNOK);
			$RC=_myln('-s','/usr/bin/rrdtool','/opt/rrdtool/bin',\$ROK,\$RNOK);
		}
   }

	#----------------------------------------------------------------------------------------
   # Backup (Usuario cnm + directorios + permisos)
   $RC=_myadduser('cnm',\$ROK,\$RNOK);

   $RC=_mymkdir('-p','/opt/data/mdata',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/mdata/cache',\$ROK,\$RNOK);
   $RC=_mychmod('-R 777','/opt/data/mdata/cache/',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/mdata/scripts',\$ROK,\$RNOK);
   $RC=_mychmod('-R 775','/opt/data/mdata/scripts/',\$ROK,\$RNOK);
   $RC=_mychown("-R root:$www_user",'/opt/data/mdata/scripts/',\$ROK,\$RNOK);

   $RC=_mymkdir('-p','/opt/data/rrd/elements',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/rrd/trap_counter',\$ROK,\$RNOK);
   $RC=_mychown("-R root:$www_user",'/opt/data/rrd/',\$ROK,\$RNOK);
   $RC=_mychmod('-R 775','/opt/data/rrd/',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/home/cnm/backup',\$ROK,\$RNOK);
   $RC=_mychown("-R cnm:$www_user",'/home/cnm',\$ROK,\$RNOK);
   $RC=_mychmod('710','/home/cnm',\$ROK,\$RNOK);
   $RC=_mychmod('777','/home/cnm/backup',\$ROK,\$RNOK);

   #----------------------------------------------------------------------------------------
   # Directorio de datos para buzones
   $RC=_mymkdir('-p','/opt/data/buzones/cnmnotifier/new',\$ROK,\$RNOK);
   $RC=_mychown("-R $www_user:$www_user",'/opt/data/buzones/',\$ROK,\$RNOK);
   $RC=_mychmod('775','/opt/data/buzones',\$ROK,\$RNOK);

   #----------------------------------------------------------------------------------------
   # Directorio de datos para proxy
   $RC=_mymkdir('-p','/opt/data/proxy/idx',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/proxy/scripts',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/proxy/out',\$ROK,\$RNOK);
   $RC=_mychown("-R $www_user:$www_user",'/opt/data/proxy/',\$ROK,\$RNOK);
   $RC=_mychmod('775','/opt/data/proxy',\$ROK,\$RNOK);

	#----------------------------------------------------------------------------------------
	# Se crean los directorios para el repositorio de scripts del agente remoto
   #$RC=_mymkdir('-p','/opt/data/xagent/base/metrics',\$ROK,\$RNOK);
   #$RC=_mymkdir('-p','/opt/data/xagent/base/apps',\$ROK,\$RNOK);
   #$RC=_mymkdir('-p','/opt/data/xagent/custom/metrics',\$ROK,\$RNOK);
   #$RC=_mymkdir('-p','/opt/data/xagent/custom/apps',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 775','/opt/data/xagent/base/metrics',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 775','/opt/data/xagent/base/apps',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 775','/opt/data/xagent/custom/metrics',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 775','/opt/data/xagent/custom/apps',\$ROK,\$RNOK);

   $RC=_mymkdir('-p','/opt/data/xagent/base',\$ROK,\$RNOK);
   $RC=_mychmod('-R 775','/opt/data/xagent/base',\$ROK,\$RNOK);
	$RC=_mychown("-R root:$www_user",'/opt/data/xagent/',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	$RC=_mymkdir('-p','/opt/data/app-data/remote_cfgs',\$ROK,\$RNOK);
   $RC=_mychown("-R $www_user:$www_user",'/opt/data/app-data/',\$ROK,\$RNOK);

#   #----------------------------------------------------------------------------------------
#   # Se hace que /bin/sh apunte a /bin/bash
#   my $rc=system ("/bin/rm /bin/sh");
#   $RC=_myln('-s','/bin/bash','/bin/sh',\$ROK,\$RNOK);


	#----------------------------------------------------------------------------------------
	# Crea/Modifica permisos en ficheros/directorios de CNM
	create_dir('-p','/cfg/','770',"root:$www_user");

   #----------------------------------------------------------------------------------------
   # Crea/Modifica permisos en ficheros/directorios de CNM
   if (! -d '/opt/data/mibs') { create_dir('-p','/opt/data/mibs','755',"root:root"); }
   if (! -d '/opt/data/app-data/mibs_private') { create_dir('-p','/opt/data/app-data/mibs_private','755',"root:root"); }
#   if (! -d '/opt/custom_pro/mibs000') { create_dir('-p','/opt/custom_pro/mibs000','755',"root:root"); }
   if (! -d '/opt/custom_pro002/mibs002') { create_dir('-p','/opt/custom_pro002/mibs002','755',"root:root"); }

	if (! -l '/usr/share/snmp/mibs') {
		$RC=_myln('-s','/opt/data/mibs','/usr/share/snmp/mibs',\$ROK,\$RNOK);
	}
   if ( -d '/opt/cnm-mibs-pro') {
		unlink '/opt/data/mibs000';
      $RC=_myln('-s','/opt/cnm-mibs-pro','/opt/data/mibs000',\$ROK,\$RNOK);
   }	

#	if (! -l '/opt/data/mibs000') {
#		$RC=_myln('-s','/opt/custom_pro/mibs000','/opt/data/mibs000',\$ROK,\$RNOK);
#	}
	if (! -l '/opt/data/mibs002') {
		$RC=_myln('-s','/opt/custom_pro002/mibs002','/opt/data/mibs002',\$ROK,\$RNOK);
	}

   # ---------------------------------------------------------------------------------------
	if ($os eq 'fc') {
	   if (! -d '/var/www/cgi-bin') { $RC=_myln('-s','/usr/local/http/cgi-bin','/var/www/cgi-bin',\$ROK,\$RNOK); }
   	if (! -d '/var/www/html') { $RC=_myln('-s','/usr/local/http/htdocs','/var/www/html',\$ROK,\$RNOK);  }
   	if (! -d '/var/www/logs') { $RC=_myln('-s','/usr/local/http/logs','/var/www/logs',\$ROK,\$RNOK);  }
	}
	else {
      if (! -d '/var/www/cgi-bin') { $RC=_mymkdir('-p','/var/www/cgi-bin',\$ROK,\$RNOK); }
      if (! -d '/var/www/html') { $RC=_mymkdir('-p','/var/www/html',\$ROK,\$RNOK);  }
      if (! -d '/var/www/logs') { $RC=_mymkdir('-p','/var/www/logs',\$ROK,\$RNOK);  }
		if ((! -l '/usr/local/bin/snmpwalk') && (-f '/usr/bin/snmpwalk')) {
			$RC=_myln('-s','/usr/bin/snmpwalk','/usr/local/bin/snmpwalk',\$ROK,\$RNOK);
		}
      if ((! -l '/usr/local/bin/snmpget') && (-f '/usr/bin/snmpget')) {
         $RC=_myln('-s','/usr/bin/snmpget','/usr/local/bin/snmpget',\$ROK,\$RNOK);
      }
      if ((! -l '/usr/local/bin/snmptranslate') && (-f '/usr/bin/snmptranslate')) {
         $RC=_myln('-s','/usr/bin/snmptranslate','/usr/local/bin/snmptranslate',\$ROK,\$RNOK);
      }

		my $old_mysql_file='/etc/logrotate.d/mysql';
		if (-f $old_mysql_file) { unlink $old_mysql_file; }
		my $old_snmptrap_file='/etc/init.d/snmptrapd';
		if (-f $old_snmptrap_file) { unlink $old_snmptrap_file; }

   }

   # ---------------------------------------------------------------------------------------
	$RC=_mychown("$www_user:$www_user",'/var/www',\$ROK,\$RNOK);
	$RC=_mychmod('700','/var/www',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
   $RC=_mymkdir('-p','/var/log/tmark/',\$ROK,\$RNOK);          # Crea directorio /var/log/tmark/ (para marcas de tiempo)

   # ---------------------------------------------------------------------------------------
   $RC=_mytouch('/var/log/backup.log',\$ROK,\$RNOK);
	$RC=_mychown("root:$www_user",'/var/log/backup.log',\$ROK,\$RNOK);
	$RC=_mychmod('664','/var/log/backup.log',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
   $RC=_mytouch('/var/log/traps.log',\$ROK,\$RNOK);
   $RC=_mytouch('/var/log/remote_channel2.log',\$ROK,\$RNOK);
   $RC=_mytouch('/var/log/remote_channel3.log',\$ROK,\$RNOK);
   $RC=_mytouch('/var/log/remote_channel4.log',\$ROK,\$RNOK);
   $RC=_mytouch('/var/log/remote_channel5.log',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
   $RC=_mytouch('/var/log/apache2/cnm_gui.log',\$ROK,\$RNOK);
	$RC=_mychown(" $www_user:$www_user",'/var/log/apache2/cnm_gui.log',\$ROK,\$RNOK);
	$RC=_mychmod('-R 755','/var/log/apache2',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	$RC=_mytouch('/var/www/html/index.html',\$ROK,\$RNOK);
	$RC=_mytouch('/var/www/logs/error_cgi.log',\$ROK,\$RNOK);
	$RC=_mychown("-R root:$www_user",'/var/www/logs/',\$ROK,\$RNOK);
	$RC=_mychmod('-R 774','/var/www/logs/*',\$ROK,\$RNOK);

	#/var/www/cache
	$RC=_mymkdir('-p','/var/www/cache',\$ROK,\$RNOK);
	$RC=_mychown("-R $www_user:$www_user",'/var/www/cache/',\$ROK,\$RNOK);
	$RC=_mychmod('-R 766','/var/www/cache/',\$ROK,\$RNOK);

	#/store/tmp
	$RC=_mymkdir('-p','/store/tmp',\$ROK,\$RNOK);

	#/store/mysql_tmp
   $RC=_mymkdir('-p','/store/mysql_tmp',\$ROK,\$RNOK);
   $RC=_mychown('-R mysql:mysql','/store/mysql_tmp',\$ROK,\$RNOK);
   $RC=_mychmod('775','/store/mysql_tmp',\$ROK,\$RNOK);


   #/store/remote_logs
   $RC=_mymkdir('-p','/store/remote_logs',\$ROK,\$RNOK);
	$RC=_mychown("-R root:mysql",'/store/remote_logs',\$ROK,\$RNOK);
   $RC=_mychmod('-R 775','/store/remote_logs',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	php_post_config();

   # ---------------------------------------------------------------------------------------
   # Se activa mod_deflate en apache2
	$RC=_myln('-sf','/etc/apache2/mods-available/deflate.conf','/etc/apache2/mods-enabled/deflate.conf',\$ROK,\$RNOK);
	$RC=_myln('-sf','/etc/apache2/mods-available/deflate.load','/etc/apache2/mods-enabled/deflate.load',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
   # Se activa ssl en apache2
   $RC=_myln('-sf','/etc/apache2/mods-available/ssl.conf','/etc/apache2/mods-enabled/ssl.conf',\$ROK,\$RNOK);
   $RC=_myln('-sf','/etc/apache2/mods-available/ssl.load','/etc/apache2/mods-enabled/ssl.load',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
   # Se activa http-proxy en apache2
   $RC=_myln('-sf','/etc/apache2/mods-available/proxy_http.load','/etc/apache2/mods-enabled/proxy_http.load',\$ROK,\$RNOK);
   $RC=_myln('-sf','/etc/apache2/mods-available/proxy.load','/etc/apache2/mods-enabled/proxy.load',\$ROK,\$RNOK);
   $RC=_myln('-sf','/etc/apache2/mods-available/headers.load','/etc/apache2/mods-enabled/headers.load',\$ROK,\$RNOK);

   # Reinicio de procesos
   #$RC=_mychmod('-R 777','/var/www/html/onm/FORMer_DATA/shtml/.tmp.shtml',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 777','/var/www/html/onm/FORMer_DATA/shtml/.tmp2.shtml',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 777','/var/www/html/onm/FORMer_DATA/shtml/.tmp3.shtml',\$ROK,\$RNOK);

   # Metricas y aplicaciones de dispositivos registrados en interfaz de Agente
   #$RC=_mychmod('777','/var/www/html/onm/xml_server/sql_server/xml.log',\$ROK,\$RNOK);
   #$RC=_mychmod('777','/var/www/html/onm/xml_server/sql_server/logs.txt',\$ROK,\$RNOK);

	$RC=_mymkdir('-p','/var/www/html/onm/reload/',\$ROK,\$RNOK);
   $RC=_mychmod('-R 777','/var/www/html/onm/reload/',\$ROK,\$RNOK);


   if (! -d "/store/www-user/background") { $RC=_mymkdir('-p','/store/www-user/background',\$ROK,\$RNOK); }
   if (! -d "/store/www-user/images") { $RC=_mymkdir('-p','/store/www-user/images',\$ROK,\$RNOK); }
   if (! -d "/store/www-user/gui_templates") { $RC=_mymkdir('-p','/store/www-user/gui_templates',\$ROK,\$RNOK); }
   if (! -d "/store/www-user/resources") { $RC=_mymkdir('-p','/store/www-user/resources',\$ROK,\$RNOK); }
   if (! -d "/store/www-user/tmp") { $RC=_mymkdir('-p','/store/www-user/tmp',\$ROK,\$RNOK); }
   if (! -d "/store/www-user/files") { $RC=_mymkdir('-p','/store/www-user/files',\$ROK,\$RNOK); }

	if (! -l '/var/www/html/onm/user/background') {
		$RC=_myln('-s','/store/www-user/background','/var/www/html/onm/user/background',\$ROK,\$RNOK);
	}
	if (! -l '/var/www/html/onm/user/images') {
		$RC=_myln('-s','/store/www-user/images','/var/www/html/onm/user/images',\$ROK,\$RNOK);
	}
	if (! -l '/var/www/html/onm/user/gui_templates') {
		$RC=_myln('-s','/store/www-user/gui_templates','/var/www/html/onm/user/gui_templates',\$ROK,\$RNOK);
	}
	if (! -l '/var/www/html/onm/user/resources') {
		$RC=_myln('-s','/store/www-user/resources','/var/www/html/onm/user/resources',\$ROK,\$RNOK);
	}
	if (! -l '/var/www/html/onm/user/tmp') { 
		$RC=_myln('-s','/store/www-user/tmp','/var/www/html/onm/user/tmp',\$ROK,\$RNOK);
	}
   if (! -l '/var/www/html/onm/user/files') {
      $RC=_myln('-s','/store/www-user/files','/var/www/html/onm/user/files',\$ROK,\$RNOK);
   }

   if (! -l '/var/www/html/onm/user/remote_cfgs') {
      $RC=_myln('-s','/store/data/app-data/remote_cfgs','/var/www/html/onm/user/remote_cfgs',\$ROK,\$RNOK);
   }

   $RC=_mychmod('-R 755','/var/www/html/onm/user/',\$ROK,\$RNOK);
	$RC=_mychown("-R $www_user:$www_user",'/var/www/html/onm/user/',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/var/www/html/onm/files/provision',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/var/www/html/onm/files/store',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/var/www/html/onm/files/tasks',\$ROK,\$RNOK);
   $RC=_mychmod('-R 755','/var/www/html/onm/files/',\$ROK,\$RNOK);
	$RC=_mychown("-R $www_user:$www_user",'/var/www/html/onm/files/',\$ROK,\$RNOK);

   # Directorio tmp en la ruta del web
	# ojo pasa a ser un link a /store/www-user/tmp
   #$RC=_mymkdir('-p','/var/www/html/onm/tmp/',\$ROK,\$RNOK);
   #$RC=_mychmod('-R 777','/var/www/html/onm/tmp',\$ROK,\$RNOK);

	#$RC=_mychown('-R root:apache','/var/www/html/onm/',\$ROK,\$RNOK);

	# Se copia magic.gif como fondo por defecto a la ruta de fondos de usuarios
	_mycp('-fra ', '/var/www/html/onm/images/magic.gif', '/store/www-user/background', \$ROK, \$RNOK);
	_mycp('-fra ', '/var/www/html/onm/favicon.ico', '/var/www/html', \$ROK, \$RNOK);

   # Crear los directorios /opt/data/idx/register y /opt/data/idx/tmp
   $RC=_mymkdir('-p','/opt/data/idx/register',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/idx/tmp',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/idx/scratch',\$ROK,\$RNOK);

   # Crear los directorios de /opt/data/provision/
   $RC=_mymkdir('-p','/opt/data/provision/devices',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/provision/cfg',\$ROK,\$RNOK);
   $RC=_mymkdir('-p','/opt/data/provision/views',\$ROK,\$RNOK);

   # Crear los directorios de /opt/openvpn/client
   $RC=_mymkdir('-p','/etc/openvpn/client',\$ROK,\$RNOK);
	$RC=_mychown("-R root:root",'/etc/openvpn',\$ROK,\$RNOK);

	# ---------------------------------------------
	# LINKS GIT
	#prepare_runtime_dirs('/opt/crawler/bin', '/opt/cnm/bin');
	prepare_git_dirs();
	# ---------------------------------------------


   print "[ DONE ] >> pre_system_configuration [OK=$ROK NOK=$RNOK] \n";
}


#-------------------------------------------------------------------------------------------
sub prepare_runtime_dirs {
my ($dirx,$dirx_repo)=@_;

   if (-d $dirx) {
      my $dirx_previo=$dirx.'.previo';
      system ("mv $dirx $dirx_previo");
   }

   if (! -l $dirx) {
      $RC=_myln('-s',$dirx_repo,$dirx,\$ROK,\$RNOK);
   }
}

#-------------------------------------------------------------------------------------------
# Crear los directorios y links necesarios para que el CNM funcione con el esquema de
# directorios de GIT
#-------------------------------------------------------------------------------------------
sub prepare_git_dirs {

   # Directorios que deben crearse
   my @dirs=(
      '/var/www/html',
      '/opt/data',
   );
   foreach my $dir (@dirs){
      if (! -d $dir) {
         system ("mkdir -p $dir");
      }
   }

   # Links que deben crearse
   my @links=(
      ['/os','/opt/cnm/os'],
      ['/var/www/html/onm','/opt/cnm/onm'],
      ['/var/www/cgi-bin','/opt/cnm/cgi-bin'],
      ['/opt/crawler','/opt/cnm/crawler'],
      ['/opt/data/mibs','/opt/cnm/mibs'],
      ['/opt/data/xagent','/opt/cnm/xagent'],
      ['/update','/opt/cnm/update']
   );

   foreach my $dir (@links){
      my $dirx=$dir->[0];
      my $dirx_previo=$dir->[1];

      if (! -l $dirx) {
         if (-d $dirx) {
            my $dirx_previo=$dirx.'.previo';
            system ("mv $dirx $dirx_previo");
         }
         system ("ln -s $dirx_previo $dirx");
      }
   }
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Configuracion de sistema
#-------------------------------------------------------------------------------------------
sub post_system_configuration {

	($RC,$ROK,$RNOK)=(0,0,0);
   my $os=check_os();
   $www_user = ($os eq 'fc') ? 'apache' : 'www-data';

   #----------------------------------------------------------------------------------------
   # Modificamos permisos de ficheros generados en chk-host (osbase2system)
   $RC=_mychmod('-R 775','/cfg/',\$ROK,\$RNOK);
	if (-f '/cfg/onm.conf') {
	   $RC=_mychown("root:$www_user",'/cfg/onm.conf',\$ROK,\$RNOK);
   	$RC=_mychmod('776','/cfg/onm.conf',\$ROK,\$RNOK);
	}

   $RC=_mychown("root:$www_user",'/etc/resolv.conf',\$ROK,\$RNOK);
   $RC=_mychmod('664','/etc/resolv.conf',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	my $frole='/cfg/onm.role';
	if (! -f $frole) {
		open (F, ">$frole");
		print F "ROLE = active\n";
		print F "ACTIVE_ADDRESS = \n";
		close F;
      $RC=_mychown("root:$www_user",$frole,\$ROK,\$RNOK);
      $RC=_mychmod('776',$frole,\$ROK,\$RNOK);
   }

   # ---------------------------------------------------------------------------------------
 	# Modificacion de permisos en ficheros de SO
   $RC=_mychmod('755','/etc/cron.fast/cnm-watch',\$ROK,\$RNOK);			#cnm-watch
   $RC=_mychmod('755','/etc/cron.daily/cnm-daily',\$ROK,\$RNOK);			#cnm-backup
   if ( -f '/etc/cron.hourly/ntpdate' ) {
		#Puede no existir porque se crea en chk-host
   	$RC=_mychown("root:$www_user",'/etc/cron.hourly/ntpdate',\$ROK,\$RNOK);
		$RC=_mychmod('775','/etc/cron.hourly/ntpdate',\$ROK,\$RNOK);			#ntpdate
	}

   # ---------------------------------------------------------------------------------------
	# Miscelanea
	# Se crea el usuario cnm para samba
   system ("/opt/crawler/bin/support/add_smb_user.expect");
	# Si existe el fichero /etc/logrotate.d/syslog hay que eliminarlo porque interfiere con el syslog-ng
   if (-f '/etc/logrotate.d/syslog') { move('/etc/logrotate.d/syslog', '/tmp'); }
	# Para que se encuentren las librerias dinamicas
	system ($LDCONFIG);

	# Se garantiza que exista el fichero /update/releases.Necesario para que funcione el interfaz
	# web de actualizacion de software
	$RC=_mytouch('/update/releases',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	# Se garantiza que existe el fichero custom de syslog-ng: syslog-ng-custom.conf
	if (! -f '/etc/syslog-ng/syslog-ng-custom.conf') {
		my $default='filter f_host_list {
   netmask(1.1.1.1/255.255.255.255);
};
';
		open (F,">/etc/syslog-ng/syslog-ng-custom.conf");
		print F $default;
		close F;
	}
   $RC=_mychown("root:$www_user",'/etc/syslog-ng/syslog-ng-custom.conf',\$ROK,\$RNOK);
   $RC=_mychmod('664','/etc/syslog-ng/syslog-ng-custom.conf',\$ROK,\$RNOK);


	my $syslog_var_dir='/var/lib/syslog-ng';
	if (! -d $syslog_var_dir) { $RC=_mymkdir('-p',$syslog_var_dir,\$ROK,\$RNOK); }

   # ---------------------------------------------------------------------------------------
   # Permisos de scripts en init.d
   $RC=_mychmod('755','/etc/init.d/cnmd',\$ROK,\$RNOK);			#cnmd
	if ( $os !~ /deb/) {
	   $RC=_mychmod('755','/etc/init.d/snmptrapd',\$ROK,\$RNOK);	#snmptrapd
   	$RC=_mychmod('755','/etc/init.d/syslog-ng',\$ROK,\$RNOK);	#syslog-ng
	
   	# ---------------------------------------------------------------------------------------
		# Arranque del sistema
  	 	system ('chkconfig --levels 2345 snmptrapd on');		#snmptrapd
	   system ('chkconfig --levels 2345 smb on');				#smb
   	system ('chkconfig --levels 2345 httpd on');				#httpd
   	system ('chkconfig --levels 2345 mysql on');				#mysql
   	system ('chkconfig --add  cnmd');							#cnmd
   	system ('chkconfig --levels 2345 cnmd on');				#cnmd
   	system ('chkconfig --levels 2345 smartd off');			#smartd
   	system ('chkconfig --add  syslog-ng');						#syslog-ng
   	system ('chkconfig --levels 2345 syslog-ng on');		#syslog-ng
	}

   # ---------------------------------------------------------------------------------------
	my $dir_plugins = '/opt/crawler/bin/Crawler/FXM/Plugin';
	if (! -d $dir_plugins) { $RC=_mymkdir('-p',$dir_plugins,\$ROK,\$RNOK); }
   # ---------------------------------------------------------------------------------------
	#cfg
   if (! -f '/cfg/key') { _myecho('0','/cfg/key',\$ROK,\$RNOK); }
   #if (! -f '/cfg/onm.conf') {
   #   print ">>> NO EXISTE /cfg/onm.conf (Se pone uno por defecto /os --> /)\n";
	#	_mycp('-fr --reply=yes', '/os/cfg/onm.conf.base', '/cfg/onm.conf', \$ROK, \$RNOK);
	#	_myecho('0','/cfg/key',\$ROK,\$RNOK);
   #}
   # Permitir modificar parametros de correo
   #$RC=_mychmod('666','/cfg/onm.conf',\$ROK,\$RNOK);


   # ---------------------------------------------------------------------------------------
   # Directorio tmp en la ruta del web
	# Crea el directorio /home/cnm/backup/old_bbdd y cambia sus permisos para poder descargar
	# datos de la BBDD
	$RC=_mymkdir('-p','/home/cnm/backup/old_bbdd/',\$ROK,\$RNOK);
	$RC=_mychmod('666','/home/cnm/backup/old_bbdd/',\$ROK,\$RNOK);
	$RC=_mychown("-R cnm:$www_user",'/home/cnm/backup/old_bbdd',\$ROK,\$RNOK);


   # ---------------------------------------------------------------------------------------
	# Se modifican los permisos de /opt/crawler/bin y el propietario:grupo
   $RC=_mychown("-R root:$www_user",'/opt/crawler/bin',\$ROK,\$RNOK);
	$RC=_mychmod('-R o-r','/opt/crawler/bin/*',\$ROK,\$RNOK);
	$RC=_mychmod('751','/opt/crawler/bin/libexec/*',\$ROK,\$RNOK);


   # ---------------------------------------------------------------------------------------
   # Se revisa que exista el link a expires.load en los modulos habilitados del apache
	if (! -l '/etc/apache2/mods-enabled/expires.load') {
		$RC=_myln('-sf','/etc/apache2/mods-available/expires.load', '/etc/apache2/mods-enabled/expires.load',\$ROK,\$RNOK);
	}       

   # ---------------------------------------------------------------------------------------
   # Se revisa que exista el link a rewrite.load en los modulos habilitados del apache
   if (! -l '/etc/apache2/mods-enabled/rewrite.load') {
      $RC=_myln('-sf','/etc/apache2/mods-available/rewrite.load', '/etc/apache2/mods-enabled/rewrite.load',\$ROK,\$RNOK);
   }     

	$RC=_mychmod('600','/etc/apache2/cnm_default.pem',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	# Opcion cnm-proxy
	_mymkdir('-p','/store/www-user/apache2',\$ROK,\$RNOK);
	$RC=_mytouch('/store/www-user/apache2/cnm-http-proxy',\$ROK,\$RNOK);

   # ---------------------------------------------------------------------------------------
	# Reiniciar servicios
   system("/etc/init.d/smb restart");
   if ($os !~ /deb/) { system("/etc/init.d/snmptrapd restart"); }

	print "[ DONE ] >> post_system_configuration [OK=$ROK NOK=$RNOK] \n";

}

#-------------------------------------------------------------------------------------------
# Instala las actualizaciones
#-------------------------------------------------------------------------------------------
sub do_updates {
my ($rev_base)=@_;

   ($RC,$ROK,$RNOK)=(0,0,0);
	if (! $rev_base) { $rev_base=0; }

   # ---------------------------------------------------------------------------------------
   # Solo soportado para Debia. Se recorre el directorio en orden y se ejecuta
   # el install de cada subdirectorio.
   # Es el install el que debe comprobar si el sw esta instalado o no.
	my $os=check_os();
	my $DIR_UPDATES_BASE="/os/$os/updates";
   opendir (DIR,$DIR_UPDATES_BASE);
   my @updates = sort  grep { /\d+/ } readdir(DIR);
   closedir(DIR);

	my $CWD = getcwd;
	foreach my $subdir (sort @updates) {
		my $newdir="$DIR_UPDATES_BASE/$subdir";
		chdir $newdir;
		my $cmd="$DIR_UPDATES_BASE/$subdir/install";
		#print "CMD=$cmd\n";
		if (-f $cmd) {
			system ($cmd);
		}
		else { print "**NO EXISTE FICHERO** $cmd\n"; }
	}
	chdir $CWD;
}


#-------------------------------------------------------------------------------------------
# Actualiza los paquetes de Debian a la version adecuada del repositorio
#-------------------------------------------------------------------------------------------
sub do_apt_install {

	# El fichero de paquetes se obtiene de la siguiente forma
	# dpkg -l | grep ^ii |cut -d" " -f3 | grep -v -e 'linux-k' -e 'linux-headers' -e 'linux-image' > /os/deb/etc/apt/cnm_packages
	#my $file_pkgs='/os/deb/etc/apt/cnm_packages';
	my $os=check_os();
	my $file_pkgs="/os/$os/etc/apt/cnm_packages";
print "do_apt_install: os=$os file=$file_pkgs\n";

	if (! -f $file_pkgs) {
		print "ERROR: No existe $file_pkgs ($!)\n";
		return;
	}

	print "Instalando paquetes ...\n";
	#my $pkgs=`/bin/cat $file_pkgs | /usr/bin/xargs`;
#	my $pkgs=`/bin/grep -v '#' $file_pkgs | /usr/bin/xargs`;
#	my @res=`/usr/bin/apt-get -y --force-yes install $pkgs`;
#
#	foreach my $l (@res) {
#		chomp($l);
#		if ($l !~ /is already the newest version/) { print "do_apt_install:: $l\n"; }
#	}


	open (F,"<$file_pkgs");
	while (<F>) {
		chomp;

		if ($_=~/^#/) { next; }
		my $pkg=$_;
		# En el fichero puede haber casos como este: libssl0.9.8=0.9.8o-4
		if ($_=~/^(.+)\=.*?$/) { $pkg=$1; }
		# Miro si esta instalado el paquete
		my $cmd="/usr/bin/dpkg --status $pkg 2>&1 | grep Status";
		my $res=`$cmd`;
		if ($res=~/install ok/) { print "[ INSTALLED  ]: $pkg\n"; next; }

		print "[ **UNINST** ]:\t$pkg\n";
		$cmd="export DEBIAN_FRONTEND=noninteractive; /usr/bin/apt-get -y --force-yes install $pkg";
		$res=`$cmd`;
	}
	close F;
}


#-------------------------------------------------------------------------------------------
# Algunos modulos de perl no tienen bien puesto el nombre del modulo en el fichero que
# lo empaqueta. En este hash estan las excepciones
my %PERL_MODULE_NAMES=(

	'TermReadKey' 	=> 'Term::ReadKey',
	'libwww::perl' => 'LWP',
	'NTLM'			=> 'Authen::NTLM',
	'MailTools'		=>	'Mail::Internet',
	'MIME::tools'	=>	'MIME::Tools',
	'Time::modules'=>	'Time::Timezone',
	'Scalar::List::Utils'=>'Scalar::Util',
	'CGI.pm'			=> 'CGI',
	'HTML::Format'	=>	'HTML::FormatText',
	'IO::Compress'	=>	'IO::Compress::Base::Common',
	'perl::ldap'	=>	'Net::LDAP',
	'IO::stringy'	=>	'IO::Stringy',
	#'Crypt::IDEA'	=>	'IDEA',

);

#-------------------------------------------------------------------------------------------
# Revisa si un modulo esta instalado correctamente y con la version acorde al fichero que
# contiene dicho modulo.
# En el caso de no estar instalado, lo instala
#-------------------------------------------------------------------------------------------
sub perl_module_install {
my ($module_name)=@_;

   my $dir_modules=$DIR_PERL_MODULES;
	my $info = get_os_version();
	if ( ($info->{'Distributor ID'} =~ /debian/i) && ($info->{'Release'} =~ /10/) ) {
		$dir_modules=$DIR_PERL_MODULES;
	}


	my $inst=ExtUtils::Installed->new();
	# ej: Time-HiRes-1.42.tar.gz
	my ($mname, $mversion)=('','');
	# Soporte para modulos tar.gz, tgz o zip
	if ($module_name =~/^(\S+?)-*([\d+|\.*|_*]+)\.tar\.gz$/ ) {
		$mname=$1;
		$mversion=$2;
		$mname=~s/-/\:\:/g;
	}
   elsif ($module_name =~/^(\S+?)-*([\d+|\.*|_*]+)\.tgz$/ ) {
      $mname=$1;
      $mversion=$2;
      $mname=~s/-/\:\:/g;
   }
   elsif ($module_name =~/^(\S+?)-*([\d+|\.*|_*]+)\.zip$/ ) {
      $mname=$1;
      $mversion=$2;
      $mname=~s/-/\:\:/g;
   }


	if (exists $PERL_MODULE_NAMES{$mname}) { $mname=$PERL_MODULE_NAMES{$mname}; }	

	my ($version,$found)=('',0);

	eval "require $mname";
	if ($@) { $found=0; print STDERR "MODULO NO INSTALADO $mname >>> $@\n"; } 
	else {

		eval {
			$found=1;
			if ($mname eq 'Crypt::IDEA') { $version=eval '$IDEA::VERSION'; }
			else {$version=eval '$'.$mname.'::VERSION'; }
#print "****FML***** eval de $ $mname ::VERSION >>>>>> V=$version\n";
		};
		if ($@) { 	$version='NO'; }

	}

#print "MNAME=$mname FOUND=$found version=$version\n";

	my $perl_version=`/usr/bin/perl -V:version`;
	chomp $perl_version;
	$perl_version =~ s/version='([\w+|\.+]+)';*/$1/;	

#	#PARCHES GUARROS ------------------------------------------
#	if ($module_name eq 'Net-Ping-2.36.tar.gz') { 
#		system ("$RM -f /usr/lib/perl/$perl_version/Net/Ping.pm"); 
#	}
#	#---------------
#	#OJO: /usr/local/share/perl/5.8.8/Net/Telnet/Cisco.pm esta modificado en /os/perl_modules/extras ...
#	#		Si se cambiara la version de Telnet::Cisco.pm Habria que tocar este fichero en /os
#	# cp /os/perl_modules/extras/Cisco.pm /usr/local/share/perl/5.10.1/Net/Telnet/
#	#---------------
#	elsif ( $module_name eq 'Net-Telnet-Cisco-1.10.tar.gz') {
#		system ("$CP -fr $dir_modules/extras/Cisco.pm /usr/local/share/perl/$perl_version/Net/Telnet/Cisco.pm > /dev/null 2>&1");
#	}
#	#---------------
#	#OJO: /usr/local/share/perl/5.8.8/Mail/POP3Client.pm esta modificado en /os/perl_modules/extras ...
#	#Evita el warning:
#	#Version string '2.18 ' contains invalid data; ignoring: ' ' at /usr/local/share/perl/5.20.2/ExtUtils/MM_Unix.pm line 2784.
#	#---------------
#        elsif ( $module_name eq 'Mail-POP3Client-2.18.tar.gz') {
#                system ("$CP -fr $dir_modules/extras/POP3Client.pm /usr/local/share/perl/$perl_version/Mail/POP3Client.pm > /dev/null 2>&1");
#        }
#	#---------------
#	elsif ($module_name eq 'CPAN-Meta-2.120921.tar.gz') {
#		my $l = `/bin/grep 'our $VERSION' /usr/local/share/perl/$perl_version/CPAN/Meta.pm`;
#		chomp $l;
#		if ($l =~ /\$VERSION \= '([\d+|\.+]+)'/) { $version=$1; $found=1; }
#	}

	#----------------------------------------------------------
	
	if ($found) {
		print "MODULO: [   INSTALLED   ] $version | $mversion\t$mname\t$module_name\n";

		# En algunos casos el formato es x.y.z => No es numerico. 
		# Se eliminan los '.' y asi se transforma en numerico.
		$version =~ s/_|\.//g;
		$mversion =~ s/_|\.//g;
		#2.500
		$mversion =~ s/0+$//g;


		#print "MODULO: [   OK  ] $version | $mversion\t$mname  VERSION INSTALADA | DISPONIBLE >> $version | $mversion\n";
		#if ( ($version ne 'NO') && ($version != $mversion) ) {
		#if ($version != $mversion) { print "**INSTALADA=$version** MODULO=$mversion\n"; }
		if ( ($version ne 'NO') && ($version < $mversion) ) {

			print "**INSTALADA=$version** MODULO=$mversion\n";	
			# En Tie::EncryptedHash no coincide la version interna del modulo (1.8) con la que aparece en el fichero 1.24	
			if ($mname ne 'Tie::EncryptedHash') {
				install_perl_module($module_name);
			}
		}
	}
	else {
		if (! $mname) { $mname=$module_name; }
		print "MODULO: [ NOT INSTALLED ] $version | $mversion\t$mname\t$module_name\n";

		install_perl_module($module_name);
	}

	return 0;
}

#-------------------------------------------------------------------------------------------
# Crea la estructura de directorios adecuada en /store y los links
#-------------------------------------------------------------------------------------------
sub do_init_store  {
	my ($rok,$rnok,$msg,$cmd,$rc) = (0,0,'','','');

   ##############
   ### /store ###
   ##############

	if (-d "/store"){
		# Ya existe /store
		$msg = "Ya existe /store [OK]";
		print("$msg\n");
	}
	else{
	   # Crea el directorio /store 
		$msg = "Creando /store ";
	   _mymkdir('-p','/store',\$rok,\$rnok);
		$msg.=($rok==1)?'[OK]':'[NOOK]';
		print("$msg\n");
	}

   ($rok,$rnok) = (0,0);
	$msg = "Permisos /store ";
	_mychmod('-R 777','/store',\$rok,\$rnok);
   $msg.=($rok==1)?'[OK]':'[NOOK]';
   print("$msg\n");
	

	###################
	### /store/data ###
	###################

	$msg = 'Parando procesos CNM ';
   $cmd = "/etc/init.d/cnmd";
	if (-f $cmd) {
	   if ($DEBUG) { print "$cmd stop\n"; }
   	$rc=system ("$cmd stop");
		$msg.=($rc==0)?'[OK]':'[NOOK]';
		print("$msg\n");
	}

	if (-l '/opt/data'){
		$msg = 'Ya se ha copiado /opt/data [OK]';
	   print("$msg\n");
	}
	else{
	   # Mover el directorio /opt/data a /store/data
		$msg = 'Moviendo el directorio /opt/data a /store/data ';
		$cmd = "mv /opt/data /store/data";
	   if ($DEBUG) { print "$cmd\n"; }
	   $rc=system ($cmd);
		$msg.=($rc==0)?'[OK]':'[NOOK]';
	   print("$msg\n");
	
		# Link de /opt/data a /store/data
		($rok,$rnok) = (0,0);
	   $msg = "Link de /opt/data a /store/data ";
		_myln('-s','/store/data','/opt/data',\$rok,\$rnok);
		$msg.=($rok==1)?'[OK]':'[NOOK]';
   	print("$msg\n");
	}

   ##################
   ### /store/log ###
   ##################

   $msg = 'Parando proceso syslog-ng ';
   $cmd = "/etc/init.d/syslog-ng stop";
   if ($DEBUG) { print "$cmd\n"; }
   $rc=system ($cmd);
   $msg.=($rc==0)?'[OK]':'[NOOK]';
   print("$msg\n");

   if (-l '/var/log'){
      $msg = 'Ya se ha copiado /var/log [OK]';
	   print("$msg\n");
   }else{
	   # Mover el directorio /var/log a /store/log
	   $msg = 'Moviendo el directorio /var/log a /store/log ';
	   $cmd = "mv /var/log /store/log";
	   $rc=system ($cmd);
	   $msg.=($rc==0)?'[OK]':'[NOOK]';
	   print("$msg\n");
	
	   # Link de /var/log a /store/log
	   ($rok,$rnok) = (0,0);
	   $msg = "Link de /var/log a /store/log ";
	   _myln('-s','/store/log','/var/log',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

   $msg = 'Arrancando proceso syslog-ng ';
   $cmd = "/etc/init.d/syslog-ng start";
   if ($DEBUG) { print "$cmd\n"; }
   $rc=system ($cmd);
   $msg.=($rc==0)?'[OK]':'[NOOK]';
   print("$msg\n");


   ####################
   ### /store/mysql ###
   ####################

   $msg = 'Parando base de datos ';
   $cmd = "/etc/init.d/mysql stop";
   if ($DEBUG) { print "$cmd\n"; }
   $rc=system ($cmd);
   $msg.=($rc==0)?'[OK]':'[NOOK]';
   print("$msg\n");

   if (-l '/var/lib/mysql'){
      $msg = 'Ya se ha copiado /var/lib/mysql [OK]';
	   print("$msg\n");
   }else{
   	# Mover el directorio /var/lib/mysql a /store/mysql
	   $msg = 'Moviendo el directorio /var/lib/mysql a /store/mysql ';
	   $cmd = "mv /var/lib/mysql /store/mysql";
	   $rc=system ($cmd);
	   $msg.=($rc==0)?'[OK]':'[NOOK]';
	   print("$msg\n");
	
	   ($rok,$rnok) = (0,0);
	   $msg = "Permisos /store/mysql ";
	   _mychown("-R mysql:mysql",'/store/mysql',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	
	   # Link de /var/lib/mysql a /store/mysql
	   ($rok,$rnok) = (0,0);
	   $msg = "Link de /var/lib/mysql a /store/mysql ";
	   _myln('-s','/store/mysql','/var/lib/mysql',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

   $msg = 'Arrancando base de datos ';
   $cmd = "/etc/init.d/mysql start";
   if ($DEBUG) { print "$cmd\n"; }
   $rc=system ($cmd);
   $msg.=($rc==0)?'[OK]':'[NOOK]';
   print("$msg\n");

   #######################
   ### /store/www-user ###
   #######################

   if (-d "/store/www-user"){
      # Ya existe /store/www-user
      $msg = "Ya existe /store/www-user [OK]";
      print("$msg\n");
   }else{
   	# Crea el directorio /store/www-user
	   ($rok,$rnok) = (0,0);
	   $msg = 'Creando el directorio /store/www-user ';
	   _mymkdir('-p','/store/www-user',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

	if (-d "/store/www-user/background"){
      # Ya existe /store/www-user/background
      $msg = "Ya existe /store/www-user/background [OK]";
      print("$msg\n");
   }else{
	   # Crea el directorio /store/www-user/background
		   ($rok,$rnok) = (0,0);
	   $msg = 'Creando el directorio /store/www-user/background ';
	   _mymkdir('-p','/store/www-user/background',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

	if (-d "/store/www-user/gui_templates"){
      # Ya existe /store/www-user/gui_templates
      $msg = "Ya existe /store/www-user/gui_templates [OK]";
      print("$msg\n");
   }else{
	   # Crea el directorio /store/www-user/gui_templates
	   ($rok,$rnok) = (0,0);
	   $msg = 'Creando el directorio /store/www-user/gui_templates ';
	   _mymkdir('-p','/store/www-user/gui_templates',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

   if (-d "/store/www-user/images"){
      # Ya existe /store/www-user/images
      $msg = "Ya existe /store/www-user/images [OK]";
      print("$msg\n");
   }else{
	   # Crea el directorio /store/www-user/images
	   ($rok,$rnok) = (0,0);
	   $msg = 'Creando el directorio /store/www-user/images ';
	   _mymkdir('-p','/store/www-user/images',\$rok,\$rnok);
	   $msg.=($rok==1)?'[OK]':'[NOOK]';
	   print("$msg\n");
	}

   if (-d "/store/www-user/tmp"){
      # Ya existe /store/www-user/tmp
      $msg = "Ya existe /store/www-user/tmp [OK]";
      print("$msg\n");
   }else{
      # Crea el directorio /store/www-user/tmp
      ($rok,$rnok) = (0,0);
      $msg = 'Creando el directorio /store/www-user/tmp ';
      _mymkdir('-p','/store/www-user/tmp',\$rok,\$rnok);
      $msg.=($rok==1)?'[OK]':'[NOOK]';
      print("$msg\n");
   }

   if (-d "/store/www-user/resources"){
      # Ya existe /store/www-user/resources
      $msg = "Ya existe /store/www-user/resources [OK]";
      print("$msg\n");
   }else{
      # Crea el directorio /store/www-user/resources
      ($rok,$rnok) = (0,0);
      $msg = 'Creando el directorio /store/www-user/resources ';
      _mymkdir('-p','/store/www-user/resources',\$rok,\$rnok);
      $msg.=($rok==1)?'[OK]':'[NOOK]';
      print("$msg\n");
   }

   if (-d "/store/www-user/files"){
      # Ya existe /store/www-user/files
      $msg = "Ya existe /store/www-user/files [OK]";
      print("$msg\n");
   }else{
      # Crea el directorio /store/www-user/resources
      ($rok,$rnok) = (0,0);
      $msg = 'Creando el directorio /store/www-user/files ';
      _mymkdir('-p','/store/www-user/files',\$rok,\$rnok);
      $msg.=($rok==1)?'[OK]':'[NOOK]';
      print("$msg\n");
   }

	# Cambiar permisos de /store/www-user y subdirectorios 
   ($rok,$rnok) = (0,0);
   $msg = "Permisos /store/www-data y subdirectorios ";
   _mychown("-R www-data:www-data",'/store/www-user',\$rok,\$rnok);
   $msg.=($rok==1)?'[OK]':'[NOOK]';
   print("$msg\n");
}

#-------------------------------------------------------------------------------------------
# Revisa si un modulo esta instalado correctamente y con la version acorde al fichero que
# contiene dicho modulo.
# Return:  1 => Hay que instalarlo , 0 => No hay que instalarlo
#-------------------------------------------------------------------------------------------
sub do_perl_module_check_all  {

   my $dir_modules=$DIR_PERL_MODULES;
   my $info = get_os_version();
   if ( ($info->{'Distributor ID'} =~ /debian/i) && ($info->{'Release'} =~ /10/) ) {
      $dir_modules=$DIR_PERL_MODULES;
   }



	# Se eliminan posibles modulos obsoletos que estaban en una ruta distinta
	my %old_modules=(
		'/usr/local/lib/perl/5.10.1/Date/Calc.pm'=>{'module'=>'Date::Calc','path'=>'/usr/local/lib/perl'}, 
		'/usr/local/share/perl/5.10.1/Module/Build.pm'=>{'module'=>'Module::Build','path'=>'/usr/local/share/perl'}, 
		#'/usr/lib/perl/5.10.1/Unicode/Normalize.pm'=>{'module'=>'Unicode::Normalize','path'=>'/usr/lib/perl'}, 
	);

	# Unicode::Normalize hay que eliminarlo a mano ...
	my @manual = qw (/usr/lib/perl/5.10/Unicode/Normalize.pm /usr/lib/perl/5.10/auto/Unicode/Normalize/Normalize.bs /usr/lib/perl/5.10/auto/Unicode/Normalize/Normalize.so );
	foreach my $file (@manual) {
		if (-f $file) { 
			my $rc=unlink $file;
         if ($rc) { print "Eliminado $file\n"; }
         else { print "Eliminando $file --> **ERROR** ($!)\n"; }
		}
	}

	my $installed = ExtUtils::Installed->new;
	foreach my $x (keys %old_modules) {

		if (-f $x) {
			my $module=$old_modules{$x}->{'module'};	
			my $path=$old_modules{$x}->{'path'};
			print "+++++Eliminamos $module ($x)\n";

			my @ifiles=();
			my $packfile;			
			eval {
				@ifiles=$installed->files($module,'all',$path);
				$packfile = $installed->packlist($module)->packlist_file;
			};
			if ($@) { print "**ERROR**($@)\n";}

			#foreach my $file ($installed->files($module,'all',$path)) {
			foreach my $file (@ifiles) {
    			my $rc=unlink $file;
				if ($rc) { print "Eliminado $file\n"; }
				else { print "Eliminando $file --> **ERROR** ($!)\n"; }
			}



#			my $packfile = $installed->packlist($module)->packlist_file;
			if ( (defined $packfile) && (-f $packfile)) {
print "packfile=$packfile---\n";
				my $rc=unlink $packfile;
         	if ($rc) { print "Eliminado $packfile\n"; }
         	else { print "Eliminando $packfile --> **ERROR** ($!)\n"; }
			}
		}
	}

	# ------------------------------------------------------------------
	my $file_modules = $dir_modules.'/perl_modules.txt';
	open (F,"<$file_modules");
	print "MODULO: [INSTALLED|UNINST] INSTALADA | ACTUAL\tNOMBRE DEL MODULO\n";
	while (<F>) {
		chomp;
		if ($_ =~/\#/) { next; }
		if ($_ eq '') { next; }

		perl_module_install($_);

	}		

   # ------------------------------------------------------------------
   my $file_modules_forced = $dir_modules.'/perl_modules_forced.txt';
	if (-f $file_modules_forced) {
	   open (F,"<$file_modules_forced");
   	print "***FORCED***\n";
   	while (<F>) {
      	chomp;
      	if ($_ =~/\#/) { next; }
      	if ($_ eq '') { next; }
			install_perl_module($_);
   	}
	}	
}

#-------------------------------------------------------------------------------------------
# Instala un modulo de perl pasado como parametro
#-------------------------------------------------------------------------------------------
sub install_perl_module  {
my $module_name=shift;

   my $CWD = getcwd;
   my $dir_modules=$DIR_PERL_MODULES;
   my $info = get_os_version();
   if ( ($info->{'Distributor ID'} =~ /debian/i) && ($info->{'Release'} =~ /10/) ) {
      $dir_modules=$DIR_PERL_MODULES;
   }

   chdir $dir_modules;
   my $cmd="./iperl $module_name 2>&1 > /tmp/$module_name.log";
   print "+++Instalando $module_name desde $dir_modules ...\n\t($cmd) \n";
   `$cmd`;
   chdir $CWD;
}


#-------------------------------------------------------------------------------------------
# php_post_config
#-------------------------------------------------------------------------------------------
sub php_post_config {

	($RC,$ROK,$RNOK)=(0,0,0);
	my $os=check_os();
	if ($os =~ /deb/) {
   	if (! -d '/usr/share/pear') { $RC=_myln('-s','/usr/share/php','/usr/share/pear',\$ROK,\$RNOK);  }
	}
	else {
   	# /etc/php.ini -> /usr/local/lib/php.ini
   	if (! -e '/etc/php.ini') { $RC=_myln('-s','/usr/local/lib/php.ini','/etc/php.ini',\$ROK,\$RNOK); }
	}

}


#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# Wrappers de sistema
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
sub _mychmod {
my ($perm,$file,$rok,$rnok)=@_;
my $CHMOD='/bin/chmod';

   my $rc=system ("$CHMOD $perm $file");
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _mychown {
my ($perm,$file,$rok,$rnok)=@_;
my $CHOWN='/bin/chown';

   my $rc=system ("$CHOWN $perm $file");
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _mymkdir {
my ($opt,$dir,$rok,$rnok)=@_;
my $MKDIR='/bin/mkdir';

   my $rc=system ("$MKDIR $opt $dir");
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _myadduser {
my ($user,$rok,$rnok)=@_;
my $USERADD='/usr/sbin/useradd';

   my $pwd=`/usr/bin/mkpasswd cnm123`;
   chomp $pwd;
   my $rc=system ("$USERADD $user -p $pwd -s /bin/bash > /dev/null 2>&1");
   # Si ya existe el usuario da error, pero para nosotros es OK
   # =0 -> OK, !=0 -> NOK
   if (($rc == 0) || ($rc==2304)) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _mycp {
my ($opt,$from,$to,$rok,$rnok)=@_;
my $CP='/bin/cp';

	my $cmd="$CP $opt $from $to";
	if ($DEBUG) { print "$cmd\n"; }
   my $rc=system ($cmd);
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _myln {
my ($opt,$from,$to,$rok,$rnok)=@_;
my $LN='/bin/ln';

   my $cmd="$LN $opt $from $to";
   if ($DEBUG) { print "$cmd\n"; }
   my $rc=system ($cmd);
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _mytouch {
my ($file,$rok,$rnok)=@_;
my $TOUCH='/bin/touch';

   my $cmd="$TOUCH $file";
   if ($DEBUG) { print "$cmd\n"; }
   my $rc=system ($cmd);
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub _myecho {
my ($value,$file,$rok,$rnok)=@_;
my $ECHO='/bin/echo';

   my $cmd="$ECHO $value";
	if ($file) { $cmd="$ECHO $value > $file"; }
   if ($DEBUG) { print "$cmd\n"; }
   my $rc=system ($cmd);
   # =0 -> OK, !=0 -> NOK
   if ($rc == 0) { $$rok +=1; }
   else { $$rnok +=1; }
   return $rc;
}


#--------------------------------------------------------------------------------
sub get_input {
my ($txt,$val,$intro_ok)=@_;

   my $ok=0;
   my $input;
   while (!$ok) {
      print "$txt\n";
      chomp($input = <STDIN>);
		if ($intro_ok) {return 'intro'; }

      if ($val eq 'ip') {$ok=validate_ip($input); }
      else { $ok=1; }
      if (!$ok) { print "Error en dato !!\n"; }
   }

   return $input;
}

#--------------------------------------------------------------------------------
sub validate_ip  {
my $val=shift;

   my $rc=0;
   if ($val=~/\d+\.\d+\.\d+\.\d+/) {$rc=1;}
   return $rc;
}



#-------------------------------------------------------------------------------------------
sub set_key {
my ($key)=@_;

   # Crea el directorio /cfg (por si acaso)
	_mymkdir('-p','/cfg',\$ROK,\$RNOK);

   my $file='/cfg/key';
   if ( open (F,">$file") ) {
      print F "$key";
      close F;
      print "[  OK  ] >> Configurada key (KEY=$key)\n";
   }
   else { print "[ERROR] >> NO Configurada key (KEY=$key)\n"; }
}

#-------------------------------------------------------------------------------------------
# Valida si el NTP esta bien configurado
# rc=0  => OK
# rc!=0 => NOK
sub check_ntp_config {

	my $rc = system("/etc/cron.hourly/ntpdate");
	return $rc;
}



#-------------------------------------------------------------------------------------------
# Valida si el DNS esta bien configurado
# rc=0  => OK
# rc!=0 => NOK
sub check_dns_config {

	my $rc=0;
	my $x=`host www.s30labs.com`;
	if ($x !~ /has address \d+\.\d+\.\d+\.\d+/) { $rc=1; }
   return $rc;
}

#-------------------------------------------------------------------------------------------
sub check_os {
#my ()=@_;

	my $os='unk';
	if (-f '/etc/debian_version') { 
		$os='deb'; 
   	my $version=slurp_file('/etc/debian_version');
   	chomp $version;
   	if ($version eq '6.0') { $os='deb6'; }
   	elsif ($version eq '7.8') { $os='deb6'; }
   	elsif ($version eq '8.0') { $os='deb8'; }
	}
	elsif (-f '/etc/fedora-release') { $os='fc'; }
	elsif (-f '/etc/redhat-release') { $os='fc'; }
	return $os;
}

#--------------------------------------------------------------------------------
# Obtiene la particion de disco que debe corresponder al store
sub get_store_dev {

#cat /proc/partitions
#major minor  #blocks  name
#
#   8        0   83886080 sda
#   8        1     123904 sda1
#   8        2    3906560 sda2
#   8        3   14648320 sda3
#   8        4   65205248 sda4

  	my $big_part_size=0;
  	my $big_part_name='';
  	my $file='/proc/partitions';
  	open (F,"<$file");
  	while (<F>) {
     	chomp;
     	s/^\s+//;
     	my @d=split(/\s+/,$_);
     	if (scalar(@d)<4) { next; }
     	if ($d[3] !~ /\d+$/) {next;}
     	if ($d[2] > $big_part_size) {
        	$big_part_size=$d[2];
        	$big_part_name='/dev/'.$d[3];
     	}
  	}
	return $big_part_name;
}


#----------------------------------------------------------------------------
sub slurp_file {
my ($file)=@_;

        local($/) = undef;  # slurp
        open (F,"<$file");
        my $content = <F>;
        close F;
        return $content;
}

#----------------------------------------------------------------------------
sub my_if {

   my $if='eth0';
   my $file_if='/cfg/onm.if';

   if (-f $file_if) {
      open (F,"<$file_if");
      $if=<F>;
      chomp $if;
      close F;
   }
   return $if;
}

#----------------------------------------------------------------------------
sub get_os_version {

	my %os_info=();
	my @out=`lsb_release -ir`;
	foreach my $l (@out) {
   	chomp $l;
   	my ($k,$v)=split(/\:\s+/,$l);
   	$os_info{$k}=$v;
	}

	return \%os_info;

}

1;
__END__

