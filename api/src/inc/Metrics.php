<?php
require_once('/usr/share/pear/DB.php');

//--------------------------------------------------------------------------
// Function: days_in_metric
// Descripcion: Funcion auxiliar. Parsea un string y elimina aquellos caracteres
// que pueden hacer que al incluir el string dentro de un array de javascript 
// se produzca un error.
//--------------------------------------------------------------------------
function days_in_metric ($type,&$LAPSES,&$period2date, &$hoy, &$ayer, &$day_2, &$day_3, &$day_4, &$day_5, &$day_6, &$day_7)  {
   $now=time();
   $values=array();
   list ($c,$g) = explode( "_", $type, 2 );
//	print("c => ".$c."<br>");

   //-----------------------------------------------------------------------
   if ( ($c == 'STD') || ($c == 'STDMM') ){

      fill_lapses(86400,$LAPSES);

      $period2date['today'] = $hoy;
      $period2date['day_1'] = $ayer;
      $period2date['day_2'] = $day_2;
      $period2date['day_3'] = $day_3;
      $period2date['day_4'] = $day_4;
      $period2date['day_5'] = $day_5;
      $period2date['day_6'] = $day_6;
      $period2date['day_7'] = $day_7;
      $period2date['week'] =  'Semanal';
      $period2date['month'] = 'Mensual';
      $period2date['year'] = 'Anual';


      for ($i=7;$i>0;$i--) {
         $ts=$now-($i*86400);
         $values[$ts]=$i;
      }
   }

   //-----------------------------------------------------------------------
   elseif ($c == 'H0'){
      //$def=array('1_24h','1_18h','1_12h','1_6h','24h','18h','12h','6h');
      //for ($i=0;$i<=7;$i++) {

      //$def=array('6h','12h','18h','24h','1_6h','1_12h','1_18h','1_24h');
      for ($i=7;$i>0;$i--) {

         $ts=$now-($i*21600);
         //$values[$ts]=$def[$i];
         $values[$ts]=$i;
      }

      fill_lapses(21600,$LAPSES);

   }
   return $values;
}


//--------------------------------------------------------------------------
// Function: fill_lapses
// Descripcion: Rellena el array $LAPSES.
// Parametros:
// IN : $lapse
// OUT : $LAPSES
//--------------------------------------------------------------------------
function fill_lapses  ($lapse,&$LAPSES)
{

   $tnow=mktime();
   $dnow = date("d/m/Y",$tnow);
   $dmy = explode( "/", $dnow,3);
   $tnow0h= mktime(0,0,0,$dmy[1],$dmy[0],$dmy[2]);

   $LAPSES = array();
   array_push ($LAPSES,'today');
   $t2=-($tnow-$tnow0h);
   $t1=$t2-$lapse;
   array_push ($LAPSES,"$t1,$t2");

   for ($i = 0; $i < 6; $i++) {
      $t2=$t1;
      $t1=$t2-$lapse;
      array_push ($LAPSES,"$t1,$t2");
   }
}



//--------------------------------------------------------------------------
// Function: get_alert_monitor
// Descripcion: Determina si la metrica en cuestion esta en situacion de alerta.
//    Se utiliza al presentar las graficas en vistas y dispositivos.
//
// OUT : $alert_type + $color_ico y $expr (params)
//       Si $alert_type > 0 ==> Se pinta el fondo rojo.
//--------------------------------------------------------------------------
function get_alert_monitor ($alerts_key,$id_dev,$r,$mname,&$color_ico,&$expr,&$monitor_desc=''){
global $dbc;

	/*
	print "ALERTS_KEY\n";
	print_r($alerts_key);
	print("\n");
	print "ID_DEV\n";
	print_r($id_dev);
	print("\n");
	print "R\n";
	print_r($r);
	print("\n");
	print "MNAME\n";
	print_r($mname);
	print("\n");
	*/
   // OBTENGO EL TIPO DE ALERTA ----------------------------------------------------
	// Tipo de alerta ==> 0: NO HAY ALERTA, 1: INCOMUNICADO,  2: SIN RESP SNMP, 3: SIN RESP: XAGENT, 4: MONITOR, 5: METRICA, 6: SIN RESP. WBEM
   $alert_type=0;
   //caso general
   //mname en alerts es el name de la metrica en cuestion
   if (isset($alerts_key[$id_dev][$mname])) {

		// Metrica alarmada porque se cumple un monitor
		if ($alerts_key[$id_dev][$mname] > 0) { 
			$alert_type=4; 
		}
		// Metrica alarmada porque no responde la metrica
		else{	
			$alert_type=5; 
		}
	}

   // sin respuesta snmp
   // mname en alerts es mon_snmp y el type de la metrica es snmp
   elseif ( (isset($alerts_key[$id_dev]['mon_snmp'])) && ($r['type']=='snmp') ) { $alert_type=2; }

   //sin respuesta xagent
   //mname en alerts es mon_xagent y el type de la metrica es xagent
   elseif ( (isset($alerts_key[$id_dev]['mon_xagent'])) && ($r['type']=='xagent') ) { $alert_type=3; }

   //sin respuesta wbem
   //mname en alerts es mon_wbem y el type de la metrica es wbem
   elseif ( (isset($alerts_key[$id_dev]['mon_wbem'])) && ($r['type']=='wbem') ) { $alert_type=6; }

   //incomunicado por disp_icmp siendo mname mon_icmp
   //mname en alerts es mon_icmp y el name de la metrica es disp_icmp
   elseif ( (isset($alerts_key[$id_dev]['mon_icmp'])) && ($mname=='disp_icmp') ) {  $alert_type=1;  }
   //--------------------------------------------------------------------------------

	// Miro si hay monitor asociado ==> Calculo $color_ico y $expr
   // Tipo de alerta ==> (0: no hay alerta, 1:sin resp. snmp, 2: icmp, 3:snmp, 4: latency, 5:xagent, 6: sin resp. xagent)
   $expr=0;
	$monitor_desc='';
   $color_ico='transp';

	// Obtenemos información del monitor que causa la alerta
   if ($alert_type == 4) {
      $sql="SELECT expr,cause,severity FROM alert_type WHERE monitor='{$r['watch']}'";
		$result = $dbc->query($sql);
		if (@PEAR::isError($result)){
   		$errmsg = $result->getUserInfo();
   		$errno = $result->getCode();
			CNMUtils::info_log(__FILE__, __LINE__, "get_alert_monitor (4) QUERY [ERROR]: $errmsg CODE=$errno");
		}
		//Solo espero un resultado
		$result->fetchInto($r1);
		
      $expr=$r1['expr'];
		$monitor_desc=$r1['cause'];
      if($r1['severity']==2){$color_ico='naranja';}
      elseif($r1['severity']==3){$color_ico='amarillo';}
		else{$color_ico='rojo';}
   }
	// La metrica no esta alarmada
	elseif ($alert_type == 0) {
		$color_ico=($r['watch'])?'verde':'transp';
      $sql="SELECT expr,cause FROM alert_type WHERE monitor='{$r['watch']}'";
      $result = $dbc->query($sql);
      if (@PEAR::isError($result)){
         $errmsg = $result->getUserInfo();
         $errno = $result->getCode();
         CNMUtils::info_log(__FILE__, __LINE__, "get_alert_monitor (0) QUERY [ERROR]: $errmsg CODE=$errno");
      }
      //Solo espero un resultado
      $result->fetchInto($r1);

      $expr=$r1['expr'];
		$monitor_desc=$r1['cause'];
	}
	// En otro caso
	else{
      $color_ico=($r['watch'])?'gris':'transp';
      $sql="SELECT expr,cause FROM alert_type WHERE monitor='{$r['watch']}'";
      $result = $dbc->query($sql);
      if (@PEAR::isError($result)){
         $errmsg = $result->getUserInfo();
         $errno = $result->getCode();
         CNMUtils::info_log(__FILE__, __LINE__, "get_alert_monitor QUERY [ERROR]: $errmsg CODE=$errno");
      }
      //Solo espero un resultado
      $result->fetchInto($r1);

      $expr=$r1['expr'];
      $monitor_desc=$r1['cause'];
	}
	return $alert_type;
}


?>
