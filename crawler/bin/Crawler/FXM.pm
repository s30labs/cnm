#----------------------------------------------------------------------------
# Crawler::FXM
# Modulo que contiene la clase FXM encargada de implementar las funciones 
# especiales que se aplican sobre los resultados de una metrica
#----------------------------------------------------------------------------
use Crawler;
package Crawler::FXM;
@ISA=qw(Crawler);
$VERSION='1.00';

#----------------------------------------------------------------------------
use strict;
use Data::Dumper;

# Hash para almacenar resulatdos temporales
%Crawler::FXM::Intermediate=();

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::FXM
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_subtype} = $arg{subtype} || 0;
   $self->{_snmp} = $arg{snmp} || 0;
   $self->{_xagent} = $arg{xagent} || 0;

   return $self;
}

#----------------------------------------------------------------------------
# subtype
#----------------------------------------------------------------------------
sub subtype {
my ($self,$subtype) = @_;
   if (defined $subtype) {
      $self->{_subtype}=$subtype;
   }
   else { return $self->{_subtype}; }
}

#----------------------------------------------------------------------------
# snmp
#----------------------------------------------------------------------------
sub snmp {
my ($self,$snmp) = @_;
   if (defined $snmp) {
      $self->{_snmp}=$snmp;
   }
   else { return $self->{_snmp}; }
}

#----------------------------------------------------------------------------
# xagent
#----------------------------------------------------------------------------
sub xagent {
my ($self,$xagent) = @_;
   if (defined $xagent) {
      $self->{_xagent}=$xagent;
   }
   else { return $self->{_xagent}; }
}


#----------------------------------------------------------------------------
# parse_fx
#		Aplica una funcion fx sobre un vector de datos y devuelve el resultado
# IN:
#		$subtype:	subtype de la metrica (para depuracion)
#		$esp_fx:		Contiene la funcion fx calcular que permite calcular cada valor
#						del resultado.
#		$values:		Vector con los datos de la metrica sobre los cuales se aplica esp_fx
#						(VECTOR O)
# OUT:
#		\@newvals:	Vector con los resultados (VECTOR V)
#----------------------------------------------------------------------------
sub parse_fx  {
my ($self,$esp_fx,$values,$desc)=@_;

   my @newvals=();
   my @esp=split(/\|/,$esp_fx);
   my $nitems=scalar(@esp);
	my $subtype=$self->subtype();
	my $mode=$desc->{'mode'};

	if (!defined $values) {
		$self->log('debug',"parse_fx:: ****ERROR***** subtype=$subtype  NO DEFINIDO values");
		return \@newvals;
	}

   if (ref($values) ne 'ARRAY') {
      $self->log('debug',"parse_fx:: ****ERROR***** subtype=$subtype  values NO ES ARRAY");
      return \@newvals;
   }

$self->log('debug',"parse_fx:: *****START**** subtype=$subtype mode=$mode values=@$values esp=@esp");

	# ---------------------------------------------------
   # Si todos los datos son U, se responde U
   my $nv=scalar(@$values);
   my $u=0;
   foreach my $v (@$values) {
      if ($v eq 'U') { $u+=1; }
   }
   if ($u==$nv) {
      for my $i (0..$nitems-1) { push @newvals, 'U'; }
      return \@newvals;
   }
	# ---------------------------------------------------



	eval {

		# ---------------------------------------------------
		# Se itera sobre el VECTOR V
		# ---------------------------------------------------
      for my $i (0..$nitems-1) {
         if ($esp[$i] eq '') {
            push @newvals, $values->[$i];
            next;
         }

         $self->log('debug',"parse_fx:: START v$i subtype=$subtype $esp[$i]");

         # ------------------------------------------------
         # Evaluamos $esp[$i]
         # ------------------------------------------------
         my $esp_base=$esp[$i];
         $esp_base =~ s/map\(/MAP\(/g;
         $esp_base =~ s/maps\(/MAPS\(/g;
         $esp_base =~ s/bit\(/BIT\(/g;
         $esp_base =~ s/table\(/TABLE\(/g;
         $esp_base =~ s/int\(/INT\(/g;
         $esp_base =~ s/csv\(/CSV\(/g;
         $esp_base =~ s/if\(/IF\(/g;

         # ------------------------------------------------
         # 1. FUNCIONES UNICAS
			# Solo se procesa esta funcion y se termina
         # ------------------------------------------------
         # MAP()()
         if ($esp_base =~ /^MAP\(.*\)\(.*\)$/) {
				my $nv = $self->fx_MAP(\@esp,$values);
				@newvals=@$nv;
				last;
         }
         # MAPS()()
         if ($esp_base =~ /^MAPS\(.*\)\(.*\)$/) {
            my $nv = $self->fx_MAPS(\@esp,$values);
            @newvals=@$nv;
            last;
         }

         # ------------------------------------------------
         # TABLE(MATCH)()
         # TABLE(SUM)()
         if ($esp_base =~ /^TABLE\((.*)\)\(.*\)$/) {
				my $tfx=$1;
				if ((uc $tfx) eq 'MATCH') {
	            my $nv = $self->fx_tab_MATCH(\@esp,$values,$desc);
   	         @newvals=@$nv;
      	      last;
				}
            elsif ((uc $tfx) eq 'SUM') {
               my $nv = $self->fx_tab_SUM(\@esp,$values,$desc);
               @newvals=@$nv;
               last;
            }

         }

         # ------------------------------------------------
         # PLUGIN()()
         if (($esp_base =~ /^PLUGIN\(.*\)\(.*\)$/) || ($esp_base =~ /^PLUGIN\(.*\)$/) ){

            my $nv = $self->fx_PLUGIN(\@esp,$values,$desc);
            @newvals=@$nv;
            last;
         }

         # ------------------------------------------------


         # ------------------------------------------------
         # 2. FUNCIONES ATOMICAS
			# Pueden estar incluidas en otras funciones o expresiones
         # ------------------------------------------------
			# INT(ox)
         if ($esp_base =~ /INT\(o\d+\)/) {  $esp_base = $self->fx_INT($esp_base,$values);  }
         # ------------------------------------------------
         # CSV(ox,separator,position)
         if ($esp_base =~ /(CSV\(.*?\))/) { $esp_base = $self->fx_CSV($esp_base,$values);  }
         # ------------------------------------------------
         # IF(cond,vok,vnok)
         # ------------------------------------------------
         if ($esp_base =~ /IF\((.*?),(.*?),(.*?)\)/) { $esp_base = $self->fx_IF($esp_base,$values);  }



         # BIT()()
         if ($esp_base =~ /^BIT\(.*\)\(.*\)$/) { $esp_base = $self->fx_BIT($esp_base,$values);  }



         # ------------------------------------------------
         # 3. SE SUSTITUYEN LOS VALORES NUMERICOS (ox) y SE HACEN
			# LAS OPERACIONES ARITMETICAS FINALES
         # ------------------------------------------------
			$esp_base = $self->o2val($esp_base,$values);


         # ------------------------------------------------
         if ($esp_base =~ /^[-|\d+|\.]+$/) {
	
				if ($mode eq 'COUNTER') { $esp_base = int $esp_base; }
            $self->log('debug',"parse_fx:: END v$i OK subtype=$subtype $esp[$i] RES=$esp_base");
            push @newvals, $esp_base;
         }
         elsif ($esp[$i] =~ /^o\d+$/) {
            $self->log('debug',"parse_fx:: END v$i OK **PERO NO INT** subtype=$subtype $esp[$i] RES=$esp_base");
            push @newvals, $esp_base;
         }
         else {
            $self->log('debug',"parse_fx:: END v$i **NOK** subtype=$subtype $esp[$i] RES=$esp_base");
            push @newvals, 'U';
         }
      }
   };

   if ($@) {
      $self->log('warning',"parse_fx:: **ERROR EN EVAL** ($@)");
   }

   return \@newvals;
}


#----------------------------------------------------------------------------
# o2val		>>		$snmp->o2val($esp_base,$values);
#
# IN: $esp_base:	Contiene el valor para procesar
# 		$values:		Vector con los datos de entrada (VECTOR O)
# OUT:
# 		$esp_baes:	Se deviuelve el valor de entrada ya procesado.
#----------------------------------------------------------------------------
sub o2val   {
my ($self,$esp_base,$values)=@_;

	my $subtype=$self->subtype();
	$self->log('debug',"parse_fx:: [o2val] IN subtype=$subtype esp_base=$esp_base values=@$values");
	for my $i (1..24) {
      my $j=$i-1;
      if ($esp_base =~ /o$i/i) {
        	$esp_base =~ s/o$i/$values->[$j]/ig;
			#Para el caso de metricas con instancias donde values puede ser del tipo:
			#values=67.67.71.82.70.65.83.83.73.80.48.49:@:1 67.67.71.82.70.65.83.83.73.80.48.50:@:1
			$esp_base =~ s/^.+?\:\@\:(\d+)/$1/g;	
			$self->log('debug',"parse_fx:: [o2val] subtype=$subtype esp_base=$esp_base SUBST o$i");
      }
   }
	$self->log('debug',"parse_fx:: [o2val] subtype=$subtype OUT esp_base=$esp_base ");

#     #----------------------------------------------------
#     #Sustituyo = por ==
#     while ($esp_base =~ s/([^=]+)=([^=|^~]+)/$1==$2/g) {}
#     #Sustituyo <> por !=
#     while ($esp_base =~ s/<>/!=/g) {}
#     #Sustituyo (0/0) por (0)
#     while ($esp_base =~ s/\(0\/0\)/\(0\)/g) {}
#     #Sustituyo (0/0) por (0)
#     $esp_base =~ s/^(.*?)(\s*[=|!]+~.*)$/'$1'$2/;

   # ------------------------------------------------
   # Operaciones aritmeticas +,-,*,/,%

	$esp_base=~s/\+\+/\+/g;
	$esp_base=~s/\-\-/\+/g;
	$esp_base=~s/\+\-/\-/g;
	$esp_base=~s/\-\+/\-/g;

	$esp_base=~s/ABS/abs/g;

   # Para hacer el eval 'untainted'
   if ($esp_base =~ /(.+)/) { $esp_base = eval $1; }
	if (! defined $esp_base) { $esp_base=0;}

	# Ademas de redondear, evita la notacion cientifica del float
	my $esp_base_rounded = $esp_base;
	if ($esp_base_rounded=~/\./) { $esp_base_rounded = sprintf("%.9f", $esp_base); }
	#my $esp_base_rounded = sprintf("%.9f", $esp_base);

	$self->log('debug',"parse_fx:: [o2val] OUT subtype=$subtype esp_base=$esp_base_rounded");
	return $esp_base_rounded;

}


#----------------------------------------------------------------------------
# fx_INT
# INT(o1)   >>    $snmp->fx_INT($esp_base,$values);
# No es la funcion int de perl. Lo que hace es quedarse con la parte numerica del 
# resultado. Quita unidades y signos, pero no convierte a entero
# Si se quiere usar la funcion int de perl lo que hay que hacer es ponerla con 
# minusculas en la expresion de la metrica.
# "3 mv"		-->	3
# "3.5 mv"  -->   3.5
#
# IN: $esp_base:  Contiene el valor para procesar
#     $values:    Vector con los datos de entrada (VECTOR O)
# OUT:
#     $esp_base:  Se deviuelve el valor de entrada ya procesado.
#
#----------------------------------------------------------------------------
sub fx_INT   {
my ($self,$esp_base,$values)=@_;

	%Crawler::FXM::Intermediate=();
	my $subtype=$self->subtype();

	$self->log('debug',"parse_fx:: [fx_INT] IN subtype=$subtype esp_base=$esp_base values=@$values");
	while ($esp_base =~ /INT\(o(\d+)\)/g) {
		my $aux=$1;
      my $v=$values->[$aux-1];
      $v=~ s/,/\./g;

   	my $newvalue=$v;
	   if ($v=~/^\s*.*?([-|\d+|\.+|\,+]+).*?$/) {
   	   $newvalue=$1;
      	#if( $newvalue =~/\.$/) {$newvalue.='0'; }
   	}
		else { $newvalue.='0'; }

	 	$Crawler::FXM::Intermediate{"INT\\(o$aux\\)"} = $newvalue;
	}

   foreach my $expr (keys %Crawler::FXM::Intermediate) {
		my $result=$Crawler::FXM::Intermediate{$expr};
      #$self->log('debug',"parse_fx:: [fx_INT] subtype=$subtype PROCESADO $esp_base >> / $expr / $result /");

      $esp_base =~ s/$expr/$result/;
	}

	$self->log('debug',"parse_fx:: [fx_INT] OUT subtype=$subtype esp_base=$esp_base ");
	return $esp_base;
}

#----------------------------------------------------------------------------
# fx_CSV
# CSV(o1,',',3)   >> $snmp->fx_CSV($esp_base,$values);
# "1,2,3"			-->	3
# 
# IN: $esp_base:  Contiene el valor para procesar
#     $values:    Vector con los datos de entrada (VECTOR O)
# OUT:
#     $esp_base:  Se deviuelve el valor de entrada ya procesado.
#----------------------------------------------------------------------------
sub fx_CSV   {
my ($self,$esp_base,$values)=@_;

	%Crawler::FXM::Intermediate=();
	my $subtype=$self->subtype();
	$self->log('debug',"parse_fx:: [fx_CSV] IN subtype=$subtype esp_base=$esp_base values=@$values");

	my ($aux,$separator,$position,$intermediate)=('','',1,'');	
   while ($esp_base =~ /(CSV\(.*?\))/g) {
   	my $fx=$1;
      if ($fx=~ /CSV\(o(\d+)\,\"+([\,|\;|\s+])\"+\,(\d+)\)/) { 
			($aux,$separator,$position)=($1,$2,$3);
			$intermediate="CSV\\(o$aux,\"$separator\",$position\\)";
		}
		elsif ($fx=~ /CSV\(o(\d+)\,\'+([\,|\;|\s+])\'+\,(\d+)\)/) { 
			($aux,$separator,$position)=($1,$2,$3);
			$intermediate="CSV\\(o$aux,\'$separator\',$position\\)";
		}
		else { next; }

      my $value=$values->[$aux-1];

	   if ($position<1) { $position=1; }
   	if ($separator eq '') { $separator='\s+'; }
	   $value=~s/"//g;
   	$value=~s/'//g;
   	my @d=split(/$separator/,$value);

		$Crawler::FXM::Intermediate{$intermediate} = $d[$position-1];
	}

   foreach my $expr (keys %Crawler::FXM::Intermediate) {
      my $result=$Crawler::FXM::Intermediate{$expr};
     # $self->log('debug',"parse_fx:: [fx_CSV]  subtype=$subtype PROCESADO $esp_base >> / $expr / $result /");

      $esp_base =~ s/$expr/$result/;
   }

	$self->log('debug',"parse_fx:: [fx_CSV] OUT subtype=$subtype esp_base=$esp_base");
   return $esp_base;

}


#----------------------------------------------------------------------------
# fx_IF
# IF(cond,vok,vnok)	>> 	$snmp->fx_IF($esp_base,$values);
# IF(o1>2,o1,o2)    	-->	o1 
#
# IN: $esp_base:  Contiene el valor para procesar
#     $values:    Vector con los datos de entrada (VECTOR O)
# OUT:
#     $esp_base:  Se deviuelve el valor de entrada ya procesado.
#
#----------------------------------------------------------------------------
sub fx_IF   {
my ($self,$esp_base,$values)=@_;

	%Crawler::FXM::Intermediate=();
	my $subtype=$self->subtype();

   $self->log('debug',"parse_fx:: [fx_IF] IN subtype=$subtype esp_base=$esp_base values=@$values");
	while ($esp_base =~ /IF\((.*?),(.*?),(.*?)\)/g) {
		
      my ($condition,$vok,$vnok)=($1,$2,$3);

		my $condition_parsed=quotemeta($condition);
		my $vok_parsed=quotemeta($vok);
		my $vnok_parsed=quotemeta($vnok);
		#$condition_parsed =~ s/\+/\\\+/g;
		my $expr="IF\\($condition_parsed,$vok_parsed,$vnok_parsed\\)";

		$condition = $self->o2val($condition,$values);

	   #my $r = eval $condition;
		my $r = ($condition) ? $vok : $vnok;
		$Crawler::FXM::Intermediate{$expr} = $self->o2val($r,$values);

#      $self->log('debug',"parse_fx:: [fx_IF] subtype=$subtype **FML123** expr=$expr condition=$condition vok=$vok vnok=$vnok r=$r");
   }

   foreach my $expr (keys %Crawler::FXM::Intermediate) {
      my $result=$Crawler::FXM::Intermediate{$expr};
#      $self->log('debug',"parse_fx:: [fx_IF] subtype=$subtype PROCESADO $esp_base >> / $expr / $result /");

      $esp_base =~ s/$expr/$result/;
   }

   $self->log('debug',"parse_fx:: [fx_IF] OUT subtype=$subtype esp_base=$esp_base");
   return $esp_base;
}


#----------------------------------------------------------------------------
sub fx_BIT   {
my ($self,$esp_base,$values)=@_;

   %Crawler::FXM::Intermediate=();
   my $subtype=$self->subtype();

   $self->log('debug',"parse_fx:: [fx_BIT] IN subtype=$subtype esp_base$esp_base values=@$values");
   # ej. BIT(2)(o1)
   while ($esp_base =~ /BIT\((\d+)\)\(o(\d+)\)/g) {
      my ($desp,$aux)=($1,$2);
      my $v=$values->[$aux-1];

      my $newvalue=($v>>$desp) & 1;

      $Crawler::FXM::Intermediate{"BIT\\($desp\\)\\(o$aux\\)"} = $newvalue;
   }

   foreach my $expr (keys %Crawler::FXM::Intermediate) {
      my $result=$Crawler::FXM::Intermediate{$expr};

      #$self->log('debug',"parse_fx:: [fx_BIT] subtype=$subtype PROCESADO $esp_base >> / $expr / $result /");

      $esp_base =~ s/$expr/$result/;
   }

   $self->log('debug',"parse_fx:: [fx_BIT] OUT subtype=$subtype esp_base=$esp_base");
   return $esp_base;
}



#----------------------------------------------------------------------------
# fx_MAP
# MAP(0,1)(0,1,0,0)   >> $snmp->fx_MAP($esp_base,$values);
#
# Mapea de N a M valores
# o1 o2  => r1 r2 r3 r4
# 0  0      0  0  0  1
# 0  1      0  0  1  0
# 1  0      0  1  0  0
# 1  1      1  0  0  0
#
# if ((v1==0) && (v2==0)) { [0 0 0 1] }   MAP(0,0)(0,0,0,1)
#
# IN: $esp:  		Vector con las funciones fx para generar los elementos de salida.
#     $values:    Vector con los datos de entrada (VECTOR O)
# OUT:
#     $newals:  	Vectorcon los vvalores de salida.
#
#----------------------------------------------------------------------------
sub fx_MAP   {
my ($self,$esp,$values)=@_;

	my $newvals = $self->fx_MAP_base('int',$esp,$values);
	return $newvals;

}

#----------------------------------------------------------------------------
sub fx_MAPS   {
my ($self,$esp,$values)=@_;

   my $newvals = $self->fx_MAP_base('ascii',$esp,$values);
   return $newvals;

}

#----------------------------------------------------------------------------
sub fx_MAP_base   {
my ($self,$mode,$esp,$values)=@_;

	my @newvals=();
   my $nitems=scalar(@$esp);
	my ($a,$b)=('','');
	my $subtype=$self->subtype();

   eval {

      # ---------------------------------------------------
      # Se itera sobre el VECTOR V (OUT)
      # ---------------------------------------------------
      for my $i (0..$nitems-1) {

         if ($esp->[$i] eq '') { push @newvals, $values->[$i]; next;  }

			#my $mode='int';
			# Caso numerico
			if ($mode eq 'int') {
	         if ($esp->[$i] =~ /MAP\(([-|\d+|\,]+)\)\(([-|\d+|\,|\.]+)\)/) { ($a,$b)=($1,$2); }
				else { push @newvals, 'U'; next; }
			}
			elsif ($mode eq 'ascii') {
			## Caso texto
         	if ($esp->[$i] =~ /MAPS\((.+)\)\(([-|\d+|\,]+)\)/) { ($a,$b)=($1,$2); }
				else { push @newvals, 'U'; next; }
			}
			else { push @newvals, 'U'; next; }

		   my @vx=split(',',$a);
		   my @rx=split(',',$b);
	   	my $nv=scalar(@vx);
		   # Se inicializa a algun valor @newvals para el caso en el que
		   # no cumplaninguna condicion
	   	my $nr=scalar(@rx);

			$self->log('debug',"parse_fx:: [fx_MAP] mode=$mode a=$a b=$b nv=$nv nr=$nr vx=@vx rx=@rx values=@$values");
  			#for my $i (0..$nr-1) { push @newvals,0; }
			push @newvals,0;

	      # ---------------------------------------------------
  		   # Se itera sobre el VECTOR O (IN)
  			# Miramos si los valores de $values cumplen la condicion ...
		   my $ok=0;
  			for my $i (0..$nv-1) {

				# Si hay unstancias los valores no son los numeros, son del tipo:
         	#values=67.67.71.82.70.65.83.83.73.80.48.49:@:1 67.67.71.82.70.65.83.83.73.80.48.50:@:1
         	$values->[$i] =~ s/^.+?\:\@\:(\d+)/$1/g;


				if ($mode eq 'int') {
	  				if (($vx[$i]==$values->[$i]) || ($vx[$i] eq '*') ) { $ok+=1; }
				}
				elsif ($mode eq 'ascii') {
					if (($vx[$i]  =~ /$values->[$i]/) || ($vx[$i] eq '*') ) { $ok+=1; }
				}
#$self->log('debug',"parse_fx:: [fx_MAP] **COMPARO** $vx[$i] CON $values->[$i] >> ok=$ok---");

  			}
         if ($ok == $nv) {
  		     	@newvals=@rx;
				$self->log('debug',"parse_fx:: [fx_MAP] subtype=$subtype ENCONTRADO VALOR $esp->[$i] >> @newvals");
        	   last;
        	}
      
		}

	};

	$self->log('debug',"parse_fx:: [fx_MAP] OUT subtype=$subtype nitems=$nitems values=@$values newvals=@newvals");
	return \@newvals;
}




#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# FUNCIONES TIPO TABLA
# Se aplican sobre el conjunto de valores de un campo de la tabla.
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# fx_tab_MATCH
#
#  Sobre los valores devueltos por el walk de una tabla subre un campo.
#  Hace una comprobacion de patrones y devuelve el numero de veces que la
#  comprobacion es correcta.
#  P.ej: Contar el numero de procesos llamados xxx ($param).

#----------------------------------------------------------------------------
sub fx_tab_MATCH {
my ($self,$esp,$values,$desc)=@_;

   my @newvals=();
  	my ($a,$b)=('','');
  	my $subtype=$self->subtype();

   eval {
	   my $nitems=scalar(@$esp);

	my $kk;
	$kk=Dumper($esp);
	$kk =~ s/\n/ /g;
	$self->log('debug',"parse_fx:: [fx_tab_MATCH] subtype=$subtype esp=$kk nitems=$nitems");
	$kk=Dumper($values);
	$kk =~ s/\n/ /g;
	$self->log('debug',"parse_fx:: [fx_tab_MATCH] subtype=$subtype values=$kk ");
	$kk=Dumper($desc);
	$kk =~ s/\n/ /g;
	$self->log('debug',"parse_fx:: [fx_tab_MATCH] subtype=$subtype desc=$kk");


#values=$VAR1 = [           '1248:@:"notRunning"',           '1376:@:"notRunning"',           '1216:@:"notRunning"',           '1296:@:"notRunning"',           '1392:@:"running"',           '1184:@:"notRunning"',           '1264:@:"notRunning"',           '1360:@:"notRunning"',           '1200:@:"notRunning"',           '1440:@:"notRunning"',           '1424:@:"notRunning"',           '1232:@:"notRunning"',           '1280:@:"notRunning"',           '1312:@:"notRunning"',           '1328:@:"notRunning"',           '1456:@:"notRunning"'         ];  

#esp=$VAR1 = [           'TABLE(MATCH)("running")',           'TABLE(MATCH)("notRunning")'         ];  nitems=2 

#desc=$VAR1 = {           'esp' => 'TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")',           'version' => 2,           'oid' => 'vmGuestState',           'name' => 'vmware_vm_glob_status',           'ext_function' => '',           'cfg' => 2,           'subtype' => 'vmware_vm_glob_status',           'community' => 'public',           'ext_params' => '',           'host_ip' => '192.168.113.79',           'get_iid' => 'vmDisplayName',           'module' => 'mod_snmp_walk',           'oidn' => 'vmGuestState.IID'         };

		# Se compone el vector de patrones y de resultados
		my %patterns=();
		my @items=();
		foreach my $p (@$esp) {
			#$p vale algo asi como: 'TABLE(MATCH)("running")
			if ($p=~/TABLE\(MATCH\)\("*(.*?)"*\)/) { 
				$patterns{$1}=0; 
				push @items, $1;
			}
		}

		#1376:@:"notRunning
		# El patron esta en el index=1. Debe ser parametro ??????
		my $vindex=1;
	

      # ---------------------------------------------------
		# Se procesan los elementos de la tabla
      # ---------------------------------------------------
	   foreach my $l (@$values) {
   	   ## OJO El primer valor es el iid !!

	      if ($l eq 'U') {next; }
      	my @P=split(':@:',$l);

	      # Se quitan las comillas al valor obtenido.
   	   $P[$vindex] =~ s/^"(.+)"$/$1/g;
      	$P[$vindex] =~ s/^'(.+)'$/$1/g;
			
			$self->log('debug',"parse_fx:: [fx_tab_MATCH] subtype=$subtype chequeo $P[$vindex]");

			# Se pueden especificar patrones para los diferentes OIDs separados por |
			foreach my $pattern (keys %patterns) {
				my @px = split (',', $pattern);
				my $i=0;
				my $matched=0;
				foreach my $pat_param (@px) {

					my @pats=();
					# Se permite especificar un grupo de patrones para un item concreto p.ej. [1;2;3;4]
					# La funcion seria: TABLE(MATCH)([1;2;3;4])
					if ($pat_param=~/\[(.+)\]/) { @pats = split (';', $1);}
					else { push @pats, $pat_param;  }

					foreach my $pat (@pats) {
						if ($P[$vindex+$i] =~ /^\d+$/) {
							if (($P[$vindex+$i] == $pat) || ($pat eq '.*')) { $matched += 1; }
						}
						else {
							if ((uc $P[$vindex+$i] eq uc $pat) || ($pat eq '.*')) { $matched += 1; }
						}

						$self->log('debug',"parse_fx:: [fx_tab_MATCH] subtype=$subtype ($l) chequeo --$P[$vindex+$i]-- con --$pat-- matched=$matched pat=$pat pat_param=$pat_param");
					}

					$i+=1;
				}
				if ($matched==scalar(@px)) { $patterns{$pattern} += 1; }
      	}
   	}

      # ---------------------------------------------------
      # Se compone el vector de resultados
      # ---------------------------------------------------
      foreach my $item (@items) {

			if (exists $patterns{$item}) { push @newvals,$patterns{$item}; }
         else { push @newvals, 'U'; }
      }

   };

	$self->log('info',"parse_fx:: [fx_tab_MATCH] subtype=$subtype ***********newvals=@newvals");

	return \@newvals;
}



#----------------------------------------------------------------------------
# fx_tab_SUM
#
#  Sobre los valores devueltos por el walk de una tabla subre un campo.
#  Hace una comprobacion de patrones y devuelve el numero de veces que la
#  comprobacion es correcta.
#  P.ej: Contar el numero de procesos llamados xxx ($param).
#  TABLE(SUM)("running")
#----------------------------------------------------------------------------
sub fx_tab_SUM {
my ($self,$esp,$values,$desc)=@_;

   my @newvals=();
   my ($a,$b)=('','');
   my $subtype=$self->subtype();

   eval {
      my $nitems=scalar(@$esp);

	my $kk;
   $kk=Dumper($esp);
   $kk =~ s/\n/ /g;
   $self->log('debug',"parse_fx:: [fx_tab_SUM] subtype=$subtype esp=$kk nitems=$nitems");
   $kk=Dumper($values);
   $kk =~ s/\n/ /g;
   $self->log('debug',"parse_fx:: [fx_tab_SUM] subtype=$subtype values=$kk ");
   $kk=Dumper($desc);
   $kk =~ s/\n/ /g;
   $self->log('debug',"parse_fx:: [fx_tab_SUM] subtype=$subtype desc=$kk");


#values=$VAR1 = [           '1248:@:"notRunning"',           '1376:@:"notRunning"',           '1216:@:"notRunning"',           '1296:@:"notRunning"',           '1392:@:"running"',           '1184:@:"notRunning"',           '1264:@:"notRunning"',           '1360:@:"notRunning"',           '1200:@:"notRunning"',           '1440:@:"notRunning"',           '1424:@:"notRunning"',           '1232:@:"notRunning"',           '1280:@:"notRunning"',           '1312:@:"notRunning"',           '1328:@:"notRunning"',           '1456:@:"notRunning"'         ];

#esp=$VAR1 = [           'TABLE(MATCH)("running")',           'TABLE(MATCH)("notRunning")'         ];  nitems=2

#desc=$VAR1 = {           'esp' => 'TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")',           'version' => 2,           'oid' => 'vmGuestState',           'name' => 'vmware_vm_glob_status',           'ext_function' => '',           'cfg' => 2,           'subtype' => 'vmware_vm_glob_status',           'community' => 'public',           'ext_params' => '',           'host_ip' => '192.168.113.79',           'get_iid' => 'vmDisplayName',           'module' => 'mod_snmp_walk',           'oidn' => 'vmGuestState.IID'         };

      # Se compone el vector de patrones y de resultados
      my %patterns=();
      my @items=();
      foreach my $p (@$esp) {
         #$p vale algo asi como: 'TABLE(MATCH)("running")
         if ($p=~/TABLE\(SUM\)\("*(.*?)"*\)/) {
            $patterns{$1}=0;
            push @items, $1;
         }
      }

      #1376:@:"notRunning
      # El patron esta en el index=1. Debe ser parametro ??????
      # El campo numerico esta en el index2. Debe ser parametro ??????
      my $vindex=1;
		my $sum_index=2;

      # ---------------------------------------------------
      # Se procesan los elementos de la tabla
      # ---------------------------------------------------
      foreach my $l (@$values) {
         ## OJO El primer valor es el iid !!

         if ($l eq 'U') {next; }
         my @P=split(':@:',$l);

         # Se quitan las comillas al valor obtenido.
         $P[$vindex] =~ s/^"(.+)"$/$1/g;
         $P[$vindex] =~ s/^'(.+)'$/$1/g;

   $self->log('info',"parse_fx:: [fx_tab_SUM] subtype=$subtype chequeo $P[$vindex]");

         foreach my $pattern (keys %patterns) {

   $self->log('info',"parse_fx:: [fx_tab_SUM] subtype=$subtype chequeo --$P[$vindex]-- con --$pattern-- ");
            #if ($P[$vindex]=~ /$pattern/i) { $patterns{$pattern} += 1; }
            if ((uc $P[$vindex] eq uc $pattern) || ($pattern eq '.*')) { $patterns{$pattern} += $P[$sum_index]; }

         }
      }

      # ---------------------------------------------------
      # Se compone el vector de resultados
      # ---------------------------------------------------
      foreach my $item (@items) {

         if (exists $patterns{$item}) { push @newvals,$patterns{$item}; }
         else { push @newvals, 'U'; }
      }

   };

   $self->log('info',"parse_fx:: [fx_tab_SUM] subtype=$subtype ***********newvals=@newvals");

   return \@newvals;

}


#----------------------------------------------------------------------------
# fx_PLUGIN
# IN: $esp:       Vector con las funciones fx para generar los elementos de salida.
#     $values:    Vector con los datos de entrada (VECTOR O)
#     $desc:      Vector con los datos de la metrica (host_ip, mode, community ...)
# OUT:
#     $newals:    Vectorcon los vvalores de salida.
#
#----------------------------------------------------------------------------
#sub fx_PLUGIN   {
#my ($self,$esp,$values,$desc)=@_;
#
#   my ($custom_module,$data) = ('','');
#   if ($esp->[0] =~ /^PLUGIN\((.*)\)$/) { ($custom_module,$data) = ($1,''); }
#   elsif ($esp->[0] =~ /^PLUGIN\((.*)\)\((.*)\)$/) { ($custom_module,$data) = ($1,$2); }
#
#   if ($custom_module eq '') {
#      $self->log('info',"parse_fx:: [fx_PLUGIN] **WARN** fx NO DEFINIDA esp=@$esp values=@$values");
#      return $values;
#   }
#
#	# Hay que crear un objeto de la clase $custom_module
#	# En dicha clase tiene que haber un constructor y una funcion fx que implemente el plugin
#	# Los parametros especificados sepasan a dicha funcion
#	my $cx = 'Crawler::FXM::Plugin::'.$custom_module;
#	my $plugin = new $cx(log_level=>$log_level, 'snmp'=>$self);
#	#my $plugin=Crawler::FXM::Plugin::$custom_module->new(log_level=>$log_level, 'snmp'=>$self);
#	my $nv = $plugin->fx($esp,$values,$desc);
#
#   elsif ($custom_module eq 'STARIX') {
#      my $nv = $self->fx_STARIX($esp,$values,$desc);
#      return $nv;
#   }
#   else {
#      $self->log('info',"parse_fx:: [fx_PLUGIN] **WARN** fx NO CODIFICADA esp=@$esp values=@$values");
#      return $values;
#   }
#
#}


1;
