#---------------------------------------------------------------------------
package GConf;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

use Data::Dumper;

@EXPORT_OK = qw(generate_sql_remote_alerts);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#---------------------------------------------------------------------------
use Digest::MD5 qw(md5_hex);

#---------------------------------------------------------------------------
$GConf::SCRATCH_DIR='/tmp/GCONF_OUT';
$GConf::DB_INIT_DIR='/update/db/Init';
$GConf::INIT_TIPS_REMOTE_FILE=$GConf::SCRATCH_DIR.'/__MODULE__-Init-tips-remote.php';
$GConf::INIT_REMOTEA_FILE=$GConf::SCRATCH_DIR.'/__MODULE__-Init-remote_alerts.php';

#---------------------------------------------------------------------------
system ("mkdir -p $GConf::SCRATCH_DIR");
my ($OID_COLS, $COL_FILTERS, $TUNE, $COL_WIDTHS, $COL_SORTING, $OID_LAST, $NAME, $DESCR, $XML_FILE, $PARAMS, $RANGE, $ENTERPRISE, $CMD, $IPPARAM, $SUBTYPE, $ANAME, $ITEMS, $ITIL_TYPE, $APPTYPE,$USE_ENUMS) = ( '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', 2,'',1);


#---------------------------------------------------------------------------
# __SUBTYPE__ => UCD-SNMP-MIB::ucdavis.991.17
# __DESCR_REMOTE__ => ALERTA TEST TRAP V2
# __MONITOR__ => ''
# __VDATA__ => '',
# __SEVERITY__ => 1,2 o 3
# __ACTION__ => SET o CLR
# __SCRIPT__ => ''
# __ITIL_TYPE__ =>''
my $SQLREMOTEA = <<"SQLREMOTEA";

   \$CFG_REMOTE_ALERTS[]=array(
      'type' => '__TYPE__',     'subtype' => '__SUBTYPE__',      'hiid' => '__HIID__',
      'descr' => '__DESCR_REMOTE__',    'mode'=>'__MODE__',    'expr'=>'__EXPR__',
		'vardata' =>'__VARDATA__',
      'monitor' => '__MONITOR__',     'vdata' => '__VDATA__', 'severity' => '__SEVERITY__',   'action' => '__ACTION__',   'script' => '__SCRIPT__', 'enterprise' => '__ENTERPRISE__',
      'apptype' => '__APPTYPE__', 'itil_type' => '__ITIL_TYPE__', 'class'=>'__CLASS__', 'include'=>'__INCLUDE__',
		__SET_ALERT_COLUMNS__
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				__REMOTE2EXPR__
      )
   );

SQLREMOTEA

#---------------------------------------------------------------------------
my $SQLREMOTETIP = <<"SQLREMOTETIP";
      \$TIPS[]=array(
         'id_ref' => '__ID_REF__',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '__DESCR_TIP__',
      );

SQLREMOTETIP

#      array(
#         'id_remote_alert' => '12',    'type' => 'snmp',    'subtype' => '2.0',
#         'descr' => 'INTERFAZ CAIDO (Link Down)',
#         'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '',
#         'apptype' => 'net.generic', 'itil_type' => '1',
#      ),
#      array(
#         'id_remote_alert' => '13',    'type' => 'snmp',    'subtype' => '3.0',
#         'descr' => 'INTERFAZ ACTIVO (Link Up)',
#         'monitor' => '',     'vdata' => 'id=12',  'severity' => '1',   'action' => 'CLR',   'script' => '',
#         'apptype' => 'net.generic', 'itil_type' => '1',
#      ),

#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# generate_sql_remote_alerts
#---------------------------------------------------------------------------
sub generate_sql_remote_alerts {
my ($fab,$items,$tip_descr)=@_;


	$GConf::INIT_REMOTEA_FILE=~s/__MODULE__/$fab/;
	$GConf::INIT_TIPS_REMOTE_FILE=~s/__MODULE__/$fab/;

	print "***** generate_sql_remote_alerts  (cp $GConf::INIT_REMOTEA_FILE /update/db/Init/cfg_remote_alerts) *****\n";

   if (scalar(@$items)==0) { return; }

   open (F,">$GConf::INIT_REMOTEA_FILE");
   print F "<?\n";
   close F;

   open (F,">$GConf::INIT_TIPS_REMOTE_FILE");
   print F "<?\n";
   close F;

	my $cnt=1;
   foreach my $item (@$items) {

      print "REMOTE_ALERT $cnt ....\n";

      my $tpl=$SQLREMOTEA;

		my @VDATA=();
		my @VDATA_DESCR=();
		my @VDATA_SYNTAX=();
		my $mib_descr='';
		my $syntax='';
		my $TYPE = $item->{'type'};
		my $SUBTYPE = $item->{'subtype'};
		my $DESCR = $item->{'descr'};
		my $VARDATA = $item->{'vardata'};
		my	$SEVERITY= $item->{'severity'};
		my $MODE = $item->{'mode'};
		my $EXPR = $item->{'expr'};
		my $MONITOR = $item->{'monitor'};
		my $VDATA = $item->{'vdata'};
		my $ACTION = $item->{'action'};
		my $SCRIPT = $item->{'script'};
		my $APPTYPE = $item->{'apptype'};
		my $CLASS = $item->{'class'};
		my $ITIL_TYPE = $item->{'itil_type'};
		my $ENTERPRISE = (exists $item->{'enterprise'}) ? $item->{'enterprise'} : '0';
		my $INCLUDE = (exists $item->{'include'}) ? $item->{'include'} : '1';

		my $SET_TYPE = (exists $item->{'set_type'}) ? $item->{'set_type'} : '';
		my $SET_SUBTYPE = (exists $item->{'set_subtype'} ) ? $item->{'set_subtype'} : '';
		my $SET_HIID = (exists $item->{'set_hiid'}) ? $item->{'set_hiid'} : '';

print "+++++++++++++++++++++++ SUBTYPE=$SUBTYPE SET_TYPE=$SET_TYPE SET_SUBTYPE=$SET_SUBTYPE SET_HIID=$SET_HIID INCLUDE=$INCLUDE\n";


		my ($MIB,$VAR)=split('::',$SUBTYPE);

		my $seed='';
		my @REMOTE2EXPR=();
		foreach my $x (@{$item->{'remote2expr'}}) {
			my $v=$x->{'v'};
			my $descr=$x->{'descr'};
			my $fx=$x->{'fx'};
			my $expr=$x->{'expr'};
			$seed.=$v.$fx.$expr;
			push @REMOTE2EXPR, "array(\'v\'=>\'$v\', \'descr\'=>'$descr', \'fx\'=>\'$fx\',  \'expr\'=>\'$expr\')";
		}
		my $hiidl=md5_hex($seed);
		my $HIID=substr $hiidl,0,10;
		my $REMOTE2EXPR_LINES=join(",\n",@REMOTE2EXPR);

		# fml. Revisar que aporta SET_ALERT_COLUMNS ¿?
		# Esto parece mas obvio.
		if ($SET_HIID ne '') { $HIID = $SET_HIID; }
		
      $tpl=~s/__TYPE__/$TYPE/g;
      $tpl=~s/__SUBTYPE__/$SUBTYPE/g;
      $tpl=~s/__HIID__/$HIID/g;
      $tpl=~s/__DESCR_REMOTE__/$DESCR/g;
      $tpl=~s/__MODE__/$MODE/g;
      $tpl=~s/__EXPR__/$EXPR/g;
      $tpl=~s/__VARDATA__/$VARDATA/g;
      $tpl=~s/__MONITOR__/$MONITOR/g;
      $tpl=~s/__VDATA__/$VDATA/g;
      $tpl=~s/__ENTERPRISE__/$ENTERPRISE/g;
      $tpl=~s/__INCLUDE__/$INCLUDE/g;
      $tpl=~s/__SEVERITY__/$SEVERITY/g;
      $tpl=~s/__ACTION__/$ACTION/g;
      $tpl=~s/__SCRIPT__/$SCRIPT/g;
      $tpl=~s/__APPTYPE__/$APPTYPE/g;
      $tpl=~s/__ITIL_TYPE__/$ITIL_TYPE/g;
      $tpl=~s/__CLASS__/$CLASS/g;
      $tpl=~s/__REMOTE2EXPR__/$REMOTE2EXPR_LINES/g;

		my $set_cols='';
		#if ( ($SET_TYPE ne '') || ($SET_SUBTYPE ne '') || ($SET_HIID ne '') ) {
	#		my $set_cols='';
			if ($SET_TYPE ne '')  { $set_cols .= "\'set_type\' => \'$SET_TYPE\', "; }
			if ($SET_SUBTYPE ne '')  { $set_cols .= "\'set_subtype\' => \'$SET_SUBTYPE\', "; }
			if ($SET_HIID ne '')  { $set_cols .= "\'set_hiid\' => \'$SET_HIID\', "; }
	#	}
		$tpl=~s/__SET_ALERT_COLUMNS__/$set_cols/;

#print "+++++++++++++++++++++++++++++++++++set_cols=$set_cols+++++++++++++++++++++++++++++++\n";

#      print $tpl;
#      print "\n";

      open (F,">>$GConf::INIT_REMOTEA_FILE");
      print F "$tpl\n";
      close F;

		#-------------------------------------------------------------------------------------
      $tpl=$SQLREMOTETIP;
      $tpl=~s/__ID_REF__/$SUBTYPE/g;

      if ($tip_descr eq '') { $tip_descr=$mib_descr; }

print "+++ tip_descr=$tip_descr\n";
print "+++ mib_descr=$mib_descr\n";

		my $j=0;
		my $N=scalar(@VDATA);
		for my $j (0..$N-1) {
			my $c=$j+1;
			my $item=$VDATA[$j];
			my $descr=$VDATA_DESCR[$j];
			my $syntax=$VDATA_SYNTAX[$j];
			$tip_descr .= 'v'.$c.': <strong>'.$item.'</strong><br>'.$descr.'<br>'.$syntax.'<br>';
		}

      $tpl=~s/__DESCR_TIP__/$tip_descr/g;
#      print $tpl;


      open (F,">>$GConf::INIT_TIPS_REMOTE_FILE");
      print F "$tpl\n";
      close F;


		$cnt +=1;
   }

   open (F,">>$GConf::INIT_REMOTEA_FILE");
   print F "?>\n";
   close F;

   open (F,">>$GConf::INIT_TIPS_REMOTE_FILE");
   print F "?>\n";
   close F;

	system ("/bin/mkdir -p $GConf::DB_INIT_DIR/cfg_remote_alerts");
   my $cmd="cp $GConf::INIT_REMOTEA_FILE $GConf::DB_INIT_DIR/cfg_remote_alerts/";
	system($cmd);
   print "++++++CMD=$cmd\n";
	system ("/bin/mkdir -p $GConf::DB_INIT_DIR/tips");
   $cmd="cp $GConf::INIT_TIPS_REMOTE_FILE $GConf::DB_INIT_DIR/tips/";
	system($cmd);
   print "++++++CMD=$cmd\n";

}


#--------------------------------------------------------------------------------
sub usage {

   my @fpth = split ('/',$0,10);
   my @fname = split ('\.',$fpth[$#fpth],10);
   my $USAGE = <<USAGE;
Compilador de MIB descriptors 
hf:c:d:

$fpth[$#fpth] -d  : Fija el nivel de depuracion
$fpth[$#fpth] -h  : Ayuda
$fpth[$#fpth] -m  : Nombre de modulo p.ej: ENT_00000_MIB_II 
$fpth[$#fpth] -c  : Fichero de CACHE
$fpth[$#fpth] -i  : Init Dir -> Directorio donde se almacenan los php para provision de BBDD
$fpth[$#fpth] -l  : Lib Dir (por defecto es /opt/custom_pro/conf/pkgs)

USAGE

}

