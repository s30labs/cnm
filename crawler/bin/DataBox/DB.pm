use DataBox;
package DataBox::DB;
@ISA=qw(DataBox);

#------------------------------------------------------------------------
use strict;
use Data::Dumper;
use libSQL;
#------------------------------------------------------------------------


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo DataBox::DB
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_dsn} = $arg{dsn} || {DRIVERNAME => "mysql", SERVER => "localhost", PORT => 3306, DATABASE => "onm", USER => "onm", PASSWORD => "onm1234"};
   $self->{_dbh} = $arg{dbh} || undef;

   return $self;
}

#----------------------------------------------------------------------------
# dsn
#----------------------------------------------------------------------------
sub dsn {
my ($self,$dsn) = @_;
   if (defined $dsn) {
      $self->{_dsn}=$dsn;
   }
   else { return $self->{_dsn}; }
}

#----------------------------------------------------------------------------
# dbh
#----------------------------------------------------------------------------
sub dbh {
my ($self,$dbh) = @_;
   if (defined $dbh) {
      $self->{_dbh}=$dbh;
   }
   else { return $self->{_dbh}; }
}


#-----------------------------------------------------------------------
# store_capacity_data 
#-----------------------------------------------------------------------
# Almacena los datos de las metricas en BBDD (report_xxxx)
# IN. Array con lineas del tipo:
# join(',', $h->{'date'}, $h->{'full_name'}, $h->{'deviceip'}, $h->{'metricname'}, $h->{'v'})."\n";
#-----------------------------------------------------------------------
sub store_capacity_data {
my ($self,$data)=@_;

   my $dsn = $self->dsn();
   my $DBH=sqlConnect($dsn);

	my $table = 'capacity_data';
	foreach my $x (@$data) {

#		my %x=();
#		$x{'date'}=$h->{'date'};
#      $x{'name'}=$h->{'metricname'};
#      $x{'ip'}=$h->{'deviceip'};
#      $x{'full_name'}=$h->{'full_name'};
#      $x{'subtype'}=$h->{'subtype'};
#      $x{'label'}=$h->{'label'};
#      $x{'idm'}=$h->{'metricid'};
#      $x{'v'}=$h->{'v'};
#print Dumper(\%x);

		sqlInsertUpdate4x($DBH,$table,$x,$x,1);

print "SQL >> $libSQL::cmd\n";
   }

   $DBH->disconnect();
}



 
#-----------------------------------------------------------------------
# put_metric_report
#-----------------------------------------------------------------------
# Almacena los datos de las metricas en BBDD (report_xxxx)
# IN. Fichero csv con los datos de los RRDs.
#-----------------------------------------------------------------------
sub put_metric_report {
my ($self,$filename,$table)=@_;

	#my $filename = '/home/cnm/reports/cnm-report-data.csv';
	my $dsn = $self->dsn();
	my $DBH=sqlConnect($dsn);

	open (F,"<$filename");

	while (<F>) {
   	chomp;

#Fecha_Hora,Nombre,Dominio,IP,Tipo,Metrica,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16
#2017/05/22 20:00:00,portfilsip01,adsi.intranet.local,10.230.1.3,Servidor Virtual,USO DE DISCO C:\ Label:SYS (portfilsip01.adsi.intranet.local),3.2201936896e+10,1.2417552084e+10

   	if ($_=~/Fecha_Hora/) { next; }
   	my @parts=split(',',$_);

      my %x=();
      $x{'hdate'}=$parts[0];
      $x{'name'}=$parts[1];
      $x{'domain'}=$parts[2];
      $x{'ip'}=$parts[3];
      $x{'type'}=$parts[4];
      $x{'metric'}=$parts[5];
      #$x{'EmpresaMantenimiento'}=$parts[6];
      #$x{'Fabricante'}=$parts[7];
      #$x{'GrupoResponsable'}=$parts[8];
      #$x{'Modelo'}=$parts[9];
      #$x{'Servicio'}=$parts[10];
      #$x{'SistemaOperativo'}=$parts[11];
      #$x{'Soporte'}=$parts[12];
      #$x{'Ubicacion'}=$parts[13];
      $x{'v1'}=$parts[6];
      $x{'v2'}=$parts[7];

#print Dumper(\%x);
      sqlInsertUpdate4x($DBH,$table,\%x,\%x,1);
	}

	close F;
	$DBH->disconnect();
}


#-----------------------------------------------------------------------
# get_metric_report
#-----------------------------------------------------------------------
# Obtiene los datos almacenados en la tabla report_xxx
# IN. BBDD
# OUT. Array de hashes
#-----------------------------------------------------------------------
sub get_metric_report {
my ($self,$sql)=@_;

   my $dsn = $self->dsn();
   my $DBH=sqlConnect($dsn);


#	my $CMD = "SELECT hdate,name,domain,ip,type,metric,v1,v2 FROM $table";
#   my $CMD = "SELECT distinct month(hdate) as M, monthname(hdate),metric, ROUND((sum(v2)/sum(v1))*100,2) AS 'USADO(%)', ROUND(avg(v2)/1000000,2) AS 'USADO (MB)',ROUND(avg(v1)/1000000,2) AS 'TOTAL (MB)' FROM report_disk_mibhost GROUP BY metric,M";

	my $data = sqlSelectAllCmd($DBH, $sql, '');


	$DBH->disconnect();

	return $data;


}


1;

