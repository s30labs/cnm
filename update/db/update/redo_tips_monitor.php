#!/usr/bin/php
<?php
// Programa que actualiza la documentación de los monitores en los sitios en los que por el motivo que sea la documentación de los monitores
// sale vacia.


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

function redo_tips_monitor(){
	global $enlace;

	$date = time();
	$a_monitor = array();

   $sql="SELECT a.id_alert_type,a.cause,a.monitor,a.expr,a.params,a.severity,a.mname,a.type,a.subtype,a.wsize,a.class,a.apptype FROM alert_type a";
   $result = $enlace->query($sql);
   while ($result->fetchInto($r)){
		$monitor = array();
		$monitor['monitor']        = $r['monitor'];		
		$monitor['id_alert_type']  = $r['id_alert_type'];		
		$monitor['type']           = $r['type']; //latency, snmp, xagent
		$monitor['cause']          = $r['cause'];
		$monitor['ventana']        = $r['wsize'];
		$monitor['a_def'][0] = array('sev'=>1,'expr'=>'');	
		$monitor['a_def'][1] = array('sev'=>2,'expr'=>'');	
		$monitor['a_def'][2] = array('sev'=>3,'expr'=>'');	
		$a_expr = explode(':',$r['expr']);
		if(count($a_expr)>1){
			$aux_cont = 0;
			foreach($a_expr as $aux_expr){
				$monitor['a_def'][$aux_cont]['sev']  = $aux_cont+1;
				$monitor['a_def'][$aux_cont]['expr'] = $aux_expr;
				$aux_cont++;
			}
		}else{
			$monitor['a_def'][$r['severity']-1]['expr'] = $r['expr'];
		}	

		$sql2="(SELECT a.cause,a.expr,a.severity,a.type,b.description,b.info,b.items,b.id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor b WHERE a.id_alert_type={$monitor['id_alert_type']} AND b.monitor=a.mname) UNION (SELECT a.cause,a.expr,a.severity,a.type,b.descr as description,b.oid_info as info,b.items,b.id_cfg_monitor_snmp as id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor_snmp b WHERE a.id_alert_type={$monitor['id_alert_type']} AND b.subtype=a.mname) UNION (SELECT a.cause,a.expr,a.severity,a.type,b.description,b.info,b.items,b.id_cfg_monitor_agent as id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor_agent b WHERE a.id_alert_type={$monitor['id_alert_type']} AND b.subtype=a.mname)";
		$result2 = $enlace->query($sql2);	
		while ($result2->fetchInto($r2)){
			$monitor['items']          = $r2['items'];		
			$monitor['metrica_descr']  = $r2['description'];		
			$monitor['id_cfg_monitor'] = $r2['id_cfg_monitor'];
		}
		$monitor['funcion']  = '';
		$monitor['vigencia'] = '';
	
		$a_monitor[]=$monitor;
	}

/*
   $funcion        = $params['funcion'];
   $ventana        = $params['ventana'];
   $vigencia       = $params['vigencia'];
*/
	

	foreach($a_monitor as $mon){
	   $expr           = '';
	   $severity       = 3;
	   $n_expr = 0;
	   foreach ($mon['a_def'] as $def) if($def['expr']!='')$n_expr++;

	   if($n_expr>1){
	      if($mon['funcion'] != ''){
   	      $sep = '';
      	   foreach ($mon['a_def'] as $def){
	            $expr.="$sep{$mon['funcion']};{$def['expr']};{$mon['ventana']};{$mon['vigencia']}";
	            if ($def['expr']!=''){
	               $severity=($severity<$def['sev'])?$severity:$def['sev'];
            	}
            	$sep = ':';
         	}
      	}else{
         	$sep = '';
         	foreach ($mon['a_def'] as $def){
            	$def['expr']=htmlspecialchars_decode($def['expr']);
            	$expr.="$sep{$def['expr']}";
            	if ($def['expr']!=''){
               	$severity=($severity<$def['sev'])?$severity:$def['sev'];
            	}
            	$sep = ':';
         	}
      	}
   	}else{
      	if($mon['funcion'] != ''){
         	foreach ($mon['a_def'] as $def){
            	if ($def['expr']=='') continue;
            	$def['expr']=htmlspecialchars_decode($def['expr']);
            	$expr.="{$mon['funcion']};{$def['expr']};{$mon['ventana']};{$mon['vigencia']}";
            	if ($def['expr']!=''){
               	$severity=($severity<$def['sev'])?$severity:$def['sev'];
            	}
         	}
      	}else{
         	foreach ($mon['a_def'] as $def){
            	if ($def['expr']=='') continue;
            	$def['expr']=htmlspecialchars_decode($def['expr']);
            	$expr.="{$def['expr']}";
            	if ($def['expr']!=''){
               	$severity=($severity<$def['sev'])?$severity:$def['sev'];
            	}
         	}
      	}
   	}

	   // Genero documentacion
	   $vector_patterns=array('/(V|v)1/', '/(V|v)2/', '/(V|v)3/', '/(V|v)4/', '/(V|v)5/', '/(V|v)6/', '/(V|v)7/', '/(V|v)8/');
	   $vector_items = explode('|',$mon['items']);
	   $expr_formated = preg_replace($vector_patterns, $vector_items, $expr);
	   $vector_severity = array ('1'=>'ROJA', '2'=>'NARANJA', '3'=>'AMARILLA');
	
	   // Se aplica la función htmlspecialchars a la expresión porque puede darse el caso de una expresión del tipo V1<1 que haga que 
	   // el código html generado falle y se vea mal o se pierdan datos al mostrar la documentación.
	   if($n_expr>1){
	      $tip_descr="Monitor para la metrica \"{$mon['metrica_descr']}\" que genera una alerta con las siguientes severidades:\n";
	      foreach ($mon['a_def'] as $def){
	         if ($def['expr']=='') continue;
	         $tip_descr.="<br>- {$vector_severity[$def['sev']]} cuando se cumple la expresión ".htmlspecialchars($def['expr'])." que equivale a <strong>".preg_replace($vector_patterns, $vector_items, htmlspecialchars($def['expr']))."</strong>";
	      }
	   }else{
	      $tip_descr="Monitor para la metrica \"{$mon['metrica_descr']}\" que genera una alerta de severidad {$vector_severity[$severity]} cuando se cumple la siguiente expresión (".htmlspecialchars($expr).") que equivale a:<br><strong>".htmlspecialchars($expr_formated)."</strong>";
	   }
	
	   $data_tip=array(  '__ID_REF__' => $mon['monitor'], '__TIP_TYPE__'=>'id_alert_type', '__NAME__'=>'CNM-Info','__TIP_CLASS__'=>'1', '__DESCR__'=>$tip_descr, '__DATE__'=>time());
		$sql_tip_create_update = "INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class) VALUES ('$tip_descr','{$mon['monitor']}','id_alert_type',$date,'CNM-Info','1_') ON DUPLICATE KEY UPDATE descr='$tip_descr', date=$date, tip_class='1', id_ref='{$mon['monitor']}', tip_type='id_alert_type', name='CNM-Info'";
		$result_sql_tip_create_update = $enlace->query($sql_tip_create_update);
	   if (@PEAR::isError($result_sql_tip_create_update)) {
	      print"ERROR: ".$result_sql_tip_create_update->getMessage()."\n";
   	}
	}
}

// PROGRAMA PRINCIPAL
global $enlace;
$db_params=array(
   'phptype'  => 'mysql',
   'username' => 'onm',
   'hostspec' => 'localhost',
   'database' => 'onm',
);
$db_params['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
if (connectDB($db_params)==1){ exit;}
redo_tips_monitor();
?>
