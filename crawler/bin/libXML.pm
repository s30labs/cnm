#######################################################################################################
# Fichero:libXML.pm  $Id$
# Fecha:
########################################################################################################
package libXML;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use Data::Dumper;
use strict;

@EXPORT_OK = qw( libXML_init libXML_addAlert libXML_createDatagrid libXML_addColumn libXML_do_header libXML_do_node test libXML_addData);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


# printf '<%*s>', $c, "a"; 
# printf ' %*s', $c, "<a";

#------------------------------------------------------------------------------------
sub libXML_do_node{
 my ($ref,$name,$c)=@_;
 #print "@@@ Nodo $name\n";
 my $c2 = $c + 2 ;

 my $r=ref($ref);
 # CASO HASH
 my $has_childs = 1;
 if (ref($ref) eq 'HASH') {
  printf ' %*s', $c , "" ;
  print "<$name";
  if (! defined ($ref->{'_attrs'})){ print ">\n";} 

  foreach my $k (sort keys %$ref){
   if ($k eq "_attrs"){
     my $r=$ref->{$k};
     foreach my $attr (keys %$r){
        my $val=$r->{$attr};
        print " $attr=\"$val\"";
       }
     my $num_k=scalar(keys(%$ref));
     if ($num_k == 1 ){print " />\n";}
     else {print ">\n";}
    }
   else{
     $has_childs =0;
     my $r=ref($ref->{$k});
     if ( ($r eq 'HASH') || ($r eq 'ARRAY') ){
       my $r2=$ref->{$k};
       &libXML_do_node($r2,$k,$c2);
     }else{
      my $val=$ref->{$k};
      printf ' %*s', $c2 , "" ;
      print "<$k>$val</$k>\n";
     }
    }
  }
  if ($has_childs != 1 ){
   printf ' %*s', $c , "" ;
   print "</$name>\n";
  }
 }

 if (ref($ref) eq 'ARRAY') {
   foreach my $linea (@$ref){
      my $r=ref($linea);
   #  print "'''PARSING ($name)ARRAY_ITEM($r)'''\n";
     if (ref($linea) eq 'HASH') {
       &libXML_do_node($linea,$name,$c);
     }else{
      printf ' %*s', $c , "" ;
      print "<$name>$linea</$name>\n";
     }

   }
 }

 # if ( defined ($ref->{'_attr'}) ) {print " />\n"; }

}


#------------------------------------------------------------------------------------
sub libXML_do_header{
 my $encoding=shift;
 if ($encoding) { print '<?xml version="1.0" encoding="'.$encoding.'"?>'."\n"; }
 else { print '<?xml version="1.0" encoding="UTF-8"?>'."\n"; }
}

#------------------------------------------------------------------------------------
sub libXML_init{
 my %vars;
 return (\%vars);
}


#------------------------------------------------------------------------------------
sub libXML_addAlert {
 my ($vars,$params)=@_;
 my $func='libXML_addAlert';
 my @list = ('rc','rc_str','logs','title');
 foreach my $p (@list){
   if ( ! defined ($params->{$p}) ) {
      my %out = ('rc'=>1,'rc_str'=>"($func)->ERROR: Falta el parametro $p") ;
      return \%out; 
    }
  }
 if (!$vars->{'alert'} ) {my %a; $vars->{'alert'}=\%a;}
 my %attributes =( 'rc'=>$params->{'rc'}, 'rc_str'=>$params->{'rc_str'});
 if ($params->{'title'}) { $attributes{'title'}=$params->{'title'}; }
 $vars->{'alert'}->{'_attrs'}=\%attributes;


 $vars->{'alert'}->{'log'}=$params->{'logs'};
 my %out = ('rc'=>0,'rc_str'=>"($func)-> Alerta inicializada correctamente") ;
 return \%out;
}

#------------------------------------------------------------------------------------
sub libXML_createDatagrid{
 my ($vars,$params)=@_;
 my $func='libXML_createDatagrid';
 my @list = ('rc','columnNames');
 foreach my $p (@list){
   if ( ! defined ($params->{$p}) ) {
      my %out = ('rc'=>1,'rc_str'=>"($func)->ERROR: Falta el parametro $p") ;
      return \%out;
    }
  }
 if (!$vars->{'datagrid'} ) {my @a; $vars->{'datagrid'}=\@a;}
 my $ref=$vars->{'datagrid'};
 my $id=scalar(@$ref) ;
 $id++;
 my %datagrid;
 push (@$ref,\%datagrid);
 
 my %attributes=(id=>$id, rc=>$params->{'rc'}, columnNames=>$params->{'columnNames'} );
 $datagrid{'_attrs'}=\%attributes;
 
 my @columnas;
 my %h_col=(columna=>\@columnas);
 my $c=$params->{'columnNames'};
 $h_col{'_attrs'} = {columnNames=>$c} ;

 $datagrid{'columnas'}=\%h_col;

 my @data;
 my %h_data=(item=>\@data);
 $datagrid{'data'}=\%h_data;

 my %out = ('rc'=>0,'rc_str'=>"($func)-> Datagrid id=$id inicializado") ;
 return \%out;

}

#------------------------------------------------------------------------------------
sub libXML_addColumn {
 my ($vars,$params)=@_;
 my $func='libXML_addColumn';
 my @list = ('dbfield','head');
 foreach my $p (@list){
   if ( ! defined ($params->{$p}) ) {
      my %out = ('rc'=>1,'rc_str'=>"($func)->ERROR: Falta el parametro $p") ;
      return \%out;
    }
  }
 my $ref=$vars->{'datagrid'};
 my $index=scalar(@$ref);
 $index --;
 my $datagrid=@$ref[$index];
 my $cols=$datagrid->{'columnas'}->{'columna'};
 push (@$cols,{'_attrs' =>$params});
 #push (@$cols,$params);
}


#------------------------------------------------------------------------------------
sub libXML_addData {
 my ($vars,$params)=@_;
 my $func='libXML_addData';
 my $ref=$vars->{'datagrid'};
 my $index=scalar(@$ref);
 $index --;
 my $datagrid=@$ref[$index];
 my $data=$datagrid->{'data'}->{'item'};
 push (@$data,$params);
}

#------------------------------------------------------------------------------------
sub libXML_createList{
 my ($vars,$params)=@_;
 my $func='libXML_createList';
 if (!$vars->{'list'} ) {my @a; $vars->{'list'}=\@a;}
 my $ref=$vars->{'list'};
 my $id=scalar(@$ref) ;
 $id++;
 my %list;
 push (@$ref,\%list);

 my %attributes=(id=>$id);
 $list{'_attrs'}=\%attributes;

 my @data;
 $list{'item'}=\@data;

 my %out = ('rc'=>0,'rc_str'=>"($func)-> List id=$id inicializado") ;
 return \%out;

}
 
#------------------------------------------------------------------------------------
sub libXML_addToList{
 my ($vars,$params)=@_;
 my $func='libXML_addToList';
 my @list = ('label','data');
 foreach my $p (@list){
   if ( ! defined ($params->{$p}) ) {
      my %out = ('rc'=>1,'rc_str'=>"($func)->ERROR: Falta el parametro $p") ;
      return \%out;
    }
  }
 my $ref=$vars->{'list'};
 my $index=scalar(@$ref);
 $index --;
 my $data=@$ref[$index]->{'item'};
 push (@$data,$params);
}


#------------------------------------------------------------------------------------
sub test {
 my $vars=&libXML_init();
 my $res;
 
 my @logs=("Una linea","Dos lineas","Tres lineas");
 my %params=(rc=>'0',rc_str=>"Melapela",logs=>\@logs);
 $res=&libXML_addAlert($vars,\%params);

 my %datagrid=(id=>1,rc=>0,columnNames=>"c,titulo,d1,d2,d3");
 $res=&libXML_createDatagrid($vars,\%datagrid);

 &libXML_addColumn($vars,{dbfield=>"c",head=>'C'});
 &libXML_addColumn($vars,{dbfield=>"titulo",head=>'Titulo de la Metrica'});
 &libXML_addColumn($vars,{dbfield=>"d1",head=>'Dato 1'});
 &libXML_addColumn($vars,{dbfield=>"d2",head=>'Dato 2'});
 &libXML_addColumn($vars,{dbfield=>"d3",head=>'Dato 3'});

 &libXML_addData($vars,{c=>"red_state",titulo=>'Estado Red',d1=>"Un dato",d2=>"Otro Dato",d3=>"2222"});
 &libXML_addData($vars,{c=>"gren_state",titulo=>'Estado cajero',d1=>"Un dato",d2=>"Otro Dato",d3=>"2222"});
 &libXML_addData($vars,{c=>"Yellow_state",titulo=>'Estado Servidor',d1=>"Un dato",d2=>"Otro Dato",d3=>"2222"});
 &libXML_addData($vars,{c=>"Blue_state",titulo=>'Estado Router',d1=>"Un dato",d2=>"Otro Dato",d3=>"2222"});

 &libXML_createList($vars,{});
 &libXML_addToList($vars,{label=>'Lunes',data=>1});
 &libXML_addToList($vars,{label=>'Martes',data=>2});
 &libXML_addToList($vars,{label=>'Miercoles',data=>3});
 &libXML_addToList($vars,{label=>'Jueves',data=>4});
 
 #print Dumper($vars);
 &libXML_do_node ($vars,"xml",0);
}


#&test();












