########################################################
# Funciones de apoyo para acceso SQL
# $Id: libSQL.pm,v 1.3 2004/10/04 10:38:21 fml Exp $
########################################################
package libSQL;

use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use DBI;
use Logger;
use strict;

@EXPORT_OK = qw( sqlConnect sqlDropDatabase sqlInsert sqlInsert_fast sqlCmd_fast sqlCmd sqlCmdRows sqlSelectCount sqlSelectHashref sqlSelectAll sqlSelectAllCmd sqlUpdate sqlInsertUpdate sqlInsertUpdate4x sqlDelete sqlDrop sqlCreate sqlCreateView sqlTableExists sqlShowVars sqlSetCS sqlShowColumns sqlLastInsertId errstr err cmd sqlCreateTS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

$libSQL::errstr='';
$libSQL::err='';
$libSQL::cmd='';

########################################################
# my $dsn = "DBI:mysql:database=$$db{DATABASE};mysql_socket=/dir/mysql/tmp/mysql.sock";
sub sqlConnect
{
#fml
my $db=shift;
my $dsn='';
my $dbh=undef;


	if ($$db{DRIVERNAME} eq 'Sybase'){
		$dsn="DBI:$$db{DRIVERNAME}:database=$$db{DATABASE};server=$$db{SERVER};port=$$db{PORT};";
	}
	elsif ($$db{DRIVERNAME} eq 'Pg'){
		$dsn = "DBI:Pg:dbname=$$db{DATABASE};host=$$db{SERVER};port=$$db{PORT};";
	}
   elsif ($$db{DRIVERNAME} eq 'SQLite'){
      $dsn = "DBI:SQLite:dbname=$$db{DATABASE}";
   }
	else {
		$dsn = "DBI:mysql:database=$$db{DATABASE};host=$$db{SERVER};port=$$db{PORT};mysql_connect_timeout=5";
	}

	#($$db{DEBUG}) ?
	#	$dbh = DBI->connect($dsn,$$db{USER},$$db{PASSWORD},{PrintError => 1,RaiseError => 1,AutoCommit => 0}) :
	#	$dbh = DBI->connect($dsn,$$db{USER},$$db{PASSWORD},{PrintError => 0,RaiseError => 0,AutoCommit => 0});

	#die "No se puede conectar a la BD: $DBI:errstr\n" unless $dbh;
	#$dbh||=DBI->connect($dsn,$dbuser,$dbpass) or die DBI::errstr;
	#kill 9, $$ unless $dbh;  # The Suicide Die


	eval {
		if ($$db{DRIVERNAME} eq 'SQLite'){
			$dbh = DBI->connect($dsn,"","");
		}
	   elsif ($$db{DRIVERNAME} eq 'Pg'){
			$dbh = DBI->connect($dsn,$$db{USER},$$db{PASSWORD},{PrintError => 1,RaiseError => 1}) ;
		}
		else {
			$dbh = DBI->connect($dsn,$$db{USER},$$db{PASSWORD},{PrintError => 1,RaiseError => 1,AutoCommit => 1}) ;
			$dbh->{'mysql_enable_utf8'} = 1;
			$dbh->do("set character set utf8");
		}
	   $libSQL::errstr=$DBI::errstr;
   	$libSQL::err=$DBI::err;

#print "***$libSQL::errstr\t($libSQL::err)\n";

	};
	if ($@) {
		$libSQL::errstr=$DBI::errstr;
      $libSQL::err=$DBI::err;
	}
   # Opcional
   #$dbh->trace(2,'/tmp/trace_db');

   return $dbh;
}



########################################################
sub sqlDropDatabase
{
#fml
my($dbh,$database)=@_;
my $rc=undef;

eval {

   my $sql="DROP DATABASE IF EXISTS $database\n";
   $libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;

}





########################################################
sub sqlCreate
{
#fml
my($dbh,$table,$fields,$temporal)=@_;
my($names,$values);
my $rc=1;

eval {
	
	my $sql="CREATE TABLE IF NOT EXISTS $table ($fields)\n";
	if ($temporal) { $sql="CREATE TEMPORARY TABLE $table ($fields)\n"; }
   $libSQL::cmd=$sql;
	$rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

	return $rc;
}

########################################################
sub sqlCreateTS
{
#fml
my($dbh,$table,$fields,$temporal)=@_;
my($names,$values);
my $rc=1;

eval {

	$rc = sqlCreate($dbh,$table,$fields,$temporal);

	if ($rc) { return $rc; }

	my $time_field='time';
	if ($fields=~/^(\S+) /) { $time_field=$1; }

   my $sql="SELECT create_hypertable('$table', '$time_field')";
   $libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;
}


########################################################
sub sqlCreateView
{
#fml
my($dbh,$vtable,$select)=@_;
my $rc;

eval {

# CREATE VIEW vlogp_333333001004_api_sc_catalog_prod_from_elk AS SELECT id_log,hash,ts,line,'api_sc_catalog_prod_from_elk' as logfile,21 as id_device2log,'app-api-sc-catalog' as name FROM logp_333333001004_api_sc_catalog_prod_from_elk;

   my $sql="CREATE VIEW $vtable AS $select\n";
   $libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;
}



########################################################
sub sqlDrop
{
#fml
my($dbh,$table)=@_;
my $rc=undef;

eval {

	my $sql="DROP TABLE IF EXISTS $table \n";
   $libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;

}


########################################################
sub sqlInsert
{
#fml
my($dbh,$table,$data,$noerr)=@_;
my($names,$values);
my $rc=undef;
my $ignore='';

eval {

	foreach (keys %$data) {
  	if (/^-/) {$values.="  ".$$data{$_}.","; s/^-//;}
   	else { $values.="  ".$dbh->quote($$data{$_}).","; }
      $names.="$_,";
   }

   chop($names);
   chop($values);

   if ($noerr) {$ignore='IGNORE'; }
   my $sql="INSERT $ignore INTO $table ($names) VALUES ($values)\n";
	$libSQL::cmd=$sql;

#print "SQL=$sql\n";

	$rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}
   return $rc;
}


########################################################
# sqlInsert_fast
# Valor de retorno: -1 => OK ; undef => ERROR
#
sub sqlInsert_fast
{
my($dbh,$table,$rfields,$rvalues)=@_;
my $rc=1;


eval {

	my $names=join(",", @$rfields);

	my $sql = sprintf "INSERT INTO %s (%s) values (%s)", $table, join(",", @$rfields), join(",", ("?")x@$rfields);
	$libSQL::cmd=$sql;

   my $sth = $dbh->prepare($sql);

	foreach my $v (@$rvalues) {
		my @l=();
		foreach (@$v) {push @l,$_;}
		my $rv=$sth->execute(@l);
		if (!defined $rv) {
			log_debug("sqlInsert_fast::[ERROR] en execute [@l] ($DBI::errstr)");
			$rc=undef;
			}
	}

	#fml Sobra si AutoCommit=1
	#$dbh->commit;

};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

	return $rc;
}


#-----------------------------------------------------------------------------------
# sqlCmd_fast
# DESCRIPCION: Ejecuta un comando SQL como vector (usando placeholders)
# IN:
#     $dbh (db handler),
#     $rvalues (ref. a un vector de vectores con los valores a sustituir en las ?)
#     $sql (comando sql => UPDATE metrics SET crawler_idx = ? WHERE id_metric = ?)
#-----------------------------------------------------------------------------------
sub sqlCmd_fast
{
my($dbh,$rvalues,$sql)=@_;
my $rc=1;

	$libSQL::cmd=$sql;

eval {

   my $sth = $dbh->prepare($sql);
   foreach my $v (@$rvalues) {
      my $rc=$sth->execute(@$v);
      if (!defined $rc) { last; }
   }

	#fml Sobra si AutoCommit=1
   #$dbh->commit;

};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;
}



#-----------------------------------------------------------------------------------
# sqlCmd
# DESCRIPCION: Ejecuta un comando SQL
# IN:
#     $dbh (db handler),
#     $sql comando sql => CALL sp()
#-----------------------------------------------------------------------------------
sub sqlCmd
{
my($dbh,$sql)=@_;
my $rc=1;

eval {

   #my $sth = $dbh->prepare($sql);
   my $sth = $dbh->prepare(qq{$sql});
   my $rc=$sth->execute();

	#fml Sobra si AutoCommit=1
   #$dbh->commit;

	$libSQL::cmd=$sql;
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;
}


#-----------------------------------------------------------------------------------
# sqlCmdRows
# DESCRIPCION: Ejecuta un comando SQL que devuelve filas
# IN:
#     $dbh (db handler),
#     $sql comando sql => CHECK TABLE xxxx
#-----------------------------------------------------------------------------------
sub sqlCmdRows
{
my($dbh,$sql)=@_;
my $rc=1;
my @rows=();

eval {

   #my $sth = $dbh->prepare($sql);
   my $sth = $dbh->prepare(qq{$sql});
   my $rc=$sth->execute();

	@rows=$sth->fetchrow_array();
	$libSQL::cmd=$sql;

};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return \@rows;
}

#-----------------------------------------------------------------------------------
sub sqlLastInsertId
{
my($dbh,$table,$field)=@_;
my $rc=0;

eval {

	$rc = $dbh->last_insert_id(undef, undef, $table, $field);

};
if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
	$rc=undef;
}

	return $rc;
}


#-----------------------------------------------------------------------------------
# sqlInsertUpdate4x
# DESCRIPCION: Inserta o Actualiza tabla. Aprovecha la funcion insert on duplicate key
#					oportada por MySQL 4x.
# IN:
#		$dbh (db handler),
#		$table (tabla),
#		$datai (ref. hash con los datos de la tabla para insertar)
#		$datau (ref. hash con los datos de la tabla)
# $where (condicion para update y select posterior)
# $what (campos a devolver en el select final)
#-----------------------------------------------------------------------------------
sub sqlInsertUpdate4x
{
#fml
my($dbh,$table,$datai,$datau,$noerr)=@_;
my($names,$values);
my $rc=undef;
my $set='';
my $ignore='';

eval {

	#$datai ==> $names,$values
   foreach (keys %$datai) {
  	if (/^-/) {$values.="\n  ".$$datai{$_}.","; s/^-//;}
     	else { $values.="\n  ".$dbh->quote($$datai{$_}).","; }
     	$names.="$_,";
  	}

  	chop($names);
  	chop($values);

	if (ref($datau) eq "HASH") {
	   foreach (keys %$datau) {
   	   if (/^-/) {
      	   s/^-//;
         	$set.="\n  $_ = $$datau{-$_},";
	      }
   	   else {
      	   # my $d=$dbh->quote($$data{$_}) || "''";
         	$set.="\n $_ = ".$dbh->quote($$datau{$_}).",";
	      }
   	}
	}
	else { $set=$datau; }
	chop($set);

	if ($noerr) {$ignore='IGNORE'; }

   my $sql="INSERT $ignore INTO $table ($names) VALUES ($values) ON DUPLICATE KEY UPDATE $set\n";

   $libSQL::cmd=$sql;
	$rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}
   return $rc;
}




########################################################
sub sqlUpdate
{
#fml
my($dbh,$table,$data,$where,$noerr)=@_;
my $rc=undef;
my $ignore='';

eval {

	if ($noerr) {$ignore='IGNORE'; }
	my $sql="UPDATE $ignore $table SET";
   foreach (keys %$data) {
		if (/^-/) {
			s/^-//;
			$sql.="  $_ = $$data{-$_},";
   	}
		else {
			# my $d=$dbh->quote($$data{$_}) || "''";
			$sql.=" $_ = ".$dbh->quote($$data{$_}).",";
		}
   }

   chop($sql);
   $sql.=" WHERE $where";
	$libSQL::cmd=$sql;

#print "SQL=$sql\n";
#log_debug ($sql);

   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;
}

#-----------------------------------------------------------------------------------
# sqlInsertUpdate
# DESCRIPCION: Inserta o Actualiza tabla. Si OK hace un select de los valores para
#					devolver algun valor interesante ($what). Posiblemente el id generado
# IN: $dbh (db handler), $table (tabla), $data (ref. hash con los datos de la tabla)
# $where (condicion para update y select posterior)
# $what (campos a devolver en el select final)
#-----------------------------------------------------------------------------------
sub sqlInsertUpdate
{
my($dbh,$table,$data,$where,$what)=@_;

	#Ejecuto el insert con noerr=1
   my $rv=sqlInsert($dbh,$table,$data,1);
	my $sql=$libSQL::cmd;
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,$what,$table,$where);
		$libSQL::cmd=$sql;
      return $rres;
   }

   $rv=sqlUpdate($dbh,$table,$data,$where);
	$sql=$libSQL::cmd;
   if ( (defined $rv) && ($what) ) {
      my $rres=sqlSelectAll($dbh,$what,$table,$where);
		$libSQL::cmd=$sql;
      return $rres;
   }

	return undef;
}



########################################################
sub sqlSelectMany
{
	my($dbh,$select,$from,$where,$other)=@_;

	my $sql="SELECT $select ";
	$sql.="   FROM $from " if $from;
	$sql.="  WHERE $where " if $where;
	$sql.="        $other" if $other;

	sqlConnect();
	my $c=$dbh->prepare_cached($sql);
	if($c->execute()) {
		return $c;
	} else {
		$c->finish();
		return undef;
	}
}

########################################################
sub sqlSelect
{
	my ($dbh,$select, $from, $where, $other)=@_;
	my $sql="SELECT $select ";
	$sql.="FROM $from " if $from;
	$sql.="WHERE $where " if $where;
	$sql.="$other" if $other;
	
#	sqlConnect();
	my $c=$dbh->prepare_cached($sql);

   if (!$c ) {
      $libSQL::errstr=$DBI::errstr;
      $libSQL::err=$DBI::err;
      return undef;
   }
   if(not $c->execute()) {
      $libSQL::errstr=$DBI::errstr;
      $libSQL::err=$DBI::err;
      return undef;
   }

	my @r=$c->fetchrow();
	$c->finish();
	return @r;
}

########################################################
sub sqlSelectHash
{
	my $H=sqlSelectHashref(@_);
	return map { $_ => $$H{$_} } keys %$H;
}

##########################################################
sub sqlSelectCount
{
#fml
my ($dbh,$table, $where)=@_;
my $count=undef;

eval {

	my $sql= "SELECT count(*) FROM $table WHERE $where";
	$libSQL::cmd=$sql;
	my $c=$dbh->selectall_arrayref($sql);
	$count = $c->[0][0];
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

	return $count;
}

########################################################
sub sqlSelectHashref
{
	my ($dbh,$select, $from, $where)=@_;

	my $sql="SELECT $select ";
	$sql.="FROM $from " if $from;
	$sql.="WHERE $where " if $where;

	my $c=$dbh->prepare_cached($sql);
	$c->execute() or return undef;
	
	my $H=$c->fetchrow_hashref();
	$c->finish();
	return $H;
}

########################################################
# sqlSelectAll - this function returns the entire
# array ref of all records selected. Use this in the case
# where you want all the records and have to do a time consuming
# process that would tie up the db handle for too long.
#
# inputs:
# select - columns selected
# from - tables
# where - where clause
# other - limit, asc ...
#
# returns:
# array ref of all records
sub sqlSelectAll
{
my ($dbh,$select, $from, $where, $other)=@_;
my $H=undef;

eval {

	my $sql="SELECT $select ";
	$sql.="FROM $from " if $from;
	$sql.="WHERE $where " if $where;
	$sql.="$other" if $other;
	$libSQL::cmd=$sql;

	$H=$dbh->selectall_arrayref($sql);

};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

	return $H;
}


#---------------------------------------------------------
sub sqlSelectAllCmd
{
my ($dbh, $sql, $key_val)=@_;
my $H=undef;

eval {
   $libSQL::cmd=$sql;
   $H=$dbh->selectall_arrayref($sql);
   if ($key_val ne '') {
      $H=$dbh->selectall_hashref($sql, $key_val);
   }
   else {
      $H=$dbh->selectall_arrayref($sql);
   }

};

if ($@) {
   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $H;
}


#---------------------------------------------------------
sub sqlTableExists
{
my ($dbh,$table) = @_;

	return unless $table;

my $H;

eval {
   $libSQL::cmd="SHOW TABLES LIKE \"$table\"";
	$H=$dbh->selectall_arrayref("SHOW TABLES LIKE \"$table\"");
};

	if ($@) {
   	$libSQL::errstr=$DBI::errstr;
   	$libSQL::err=$DBI::err;
	}
	else {
   	$libSQL::errstr='';
   	$libSQL::err=0;
	}

   return $H;

}



#---------------------------------------------------------
sub sqlShowVars
{
my ($dbh,$var) = @_;

   return unless $var;

my $H;

eval {
   $libSQL::cmd="SHOW VARIABLES LIKE '%".$var."%'";
   $H=$dbh->selectall_arrayref($libSQL::cmd);
};

   if ($@) {
      $libSQL::errstr=$DBI::errstr;
      $libSQL::err=$DBI::err;
   }
   else {
      $libSQL::errstr='';
      $libSQL::err=0;
   }

   return $H;

}


#---------------------------------------------------------
sub sqlShowColumns
{
my ($dbh,$table) = @_;

   return unless $table;

my $H;

eval {
	$libSQL::cmd="SHOW COLUMNS FROM $table";

   $H=$dbh->selectall_arrayref($libSQL::cmd);
};

   if ($@) {
      $libSQL::errstr=$DBI::errstr;
      $libSQL::err=$DBI::err;
   }
   else {
      $libSQL::errstr='';
      $libSQL::err=0;
   }

   return $H;

}


########################################################
sub sqlReplace
{
        my($dbh,$table,$data,$delay)=@_;
        my($names,$values);

        foreach (keys %$data) {
   		if (/^-/) {$values.="\n  ".$$data{$_}.","; s/^-//;}
                else { $values.="\n  ".$dbh->quote($$data{$_}).","; }
                $names.="$_,";
        }

        chop($names);
        chop($values);

	#my $p="DELAYED" if $delay;
	my $p;
        my $sql="REPLACE $p INTO $table ($names) VALUES($values)\n";
	sqlConnect();
        return $dbh->do($sql) || apacheLog($sql);
}


########################################################
sub sqlSelectColumns
{
my ($dbh,$table) = @_;

	return unless $table;

   my $c=$dbh->prepare_cached("SHOW COLUMNS FROM $table");
   $c->execute();
   my @ret;
   while(my @d=$c->fetchrow() ) {
  		push @ret, $d[0];
   }
	$c->finish();

   return @ret;
}


########################################################
sub sqlDelete
{
#fml
my($dbh,$table,$where)=@_;
my $rc=undef;

eval {

	my $sql="DELETE FROM $table ";
	if ($where) { $sql .= " WHERE $where"; }
	$sql .= "\n";
	
	$libSQL::cmd=$sql;

   $rc=$dbh->do($sql);
	if ($rc eq '0E0') { $rc=0; }
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

	return $rc;
}

########################################################
sub sqlDeleteAll
{
#fml
my($dbh,$table)=@_;
my $rc=undef;

eval {

	my $sql="DELETE FROM $table\n";
	$libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;

}


########################################################
sub sqlSetCS
{
#fml
my ($dbh,$cs)=@_;
my $rc=undef;

eval {

   my $sql="SET CHARACTER SET \'$cs\'\n";
   $libSQL::cmd=$sql;
   $rc=$dbh->do($sql);
};

if ($@) {

   $libSQL::errstr=$DBI::errstr;
   $libSQL::err=$DBI::err;
}
else {
   $libSQL::errstr='';
   $libSQL::err=0;
}

   return $rc;

}



1;

__END__


