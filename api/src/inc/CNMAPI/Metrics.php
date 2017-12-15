<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Metrics.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_metrics
// ------------------------------------------------------------------------------
// IN: 	id (Id de la metrica. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener todos las metricas:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/info/metrics.json"
// Para obtener una metrica concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/info/metrics/2332.json"
// ------------------------------------------------------------------------------
function api_get_metrics($id=0) {

   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

   // Filtros que ha puesto el usuario
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type') continue;
      $params[$key]=$val;
   }
   if ($id>0) { $params['id'] = "=$id"; }
/*
Campos:
	// - id              => id de la metrica
	// - name            => nombre de la métrica
	// - type            => tipo de la métrica
	// - items           => items de la métrica
	// - deviceid        => id del dispositivo
	// - deviceip        => ip del dispositivo
	// - devicename      => nombre del dispositivo
	// - devicedomain    => dominio del dispositivo
	// - devicestatus    => estado del dispositivo
	// - devicetype      => tipo del dispositivo
	// - monitorid       => id del monitor
	// - monitorname     => nombre del monitor
	// - severityred     => condición del monitor para que la métrica produzca una alerta roja
	// - severityorange  => condición del monitor para que la métrica produzca una alerta naranja
	// - severityyellow  => condición del monitor para que la métrica produzca una alerta amarilla

Comando: curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "http://localhost/onm/api/1.0/info/metrics.json?monitorname=SERVICIO"
*/

   $table  = common_metrics_get_table(3,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}


// ------------------------------------------------------------------------------
// api_get_metric_rrd
// ------------------------------------------------------------------------------
// IN:   id_metric (Id de la metrica)
//			Por GET: lapse (periodo del que se quiere obtener valores)
// OUT:  Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener valores de una metrica:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/metrics/2332/week.json"
// Lapses validos:
// - year
// - month
// - week
// - today
// - hour
// - minute
// - day_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n días (y 24 horas)
// - hour_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n horas (y 60 minutos)
// - minute_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n minutos (y 60 segundos)
// ------------------------------------------------------------------------------
// curl -ki -H "Authorization: 008de81a28fbf801120c99a1abfb271d" "https://localhost/onm/api/1.0/metrics/12/today.json"
// ------------------------------------------------------------------------------
function api_get_metric_rrd($id_metric){
	$lapse = 'all';
	if(array_key_exists('lapse',$_GET)) $lapse = $_GET['lapse'];
	$params = array('graph_type'=>'metric','lapse'=>$lapse,'id'=>$id_metric);
	$return = myflot($params);
	return $return;
}


function myflot($input){
   $graph_type     = $input['graph_type']; // metric|subview
   $id             = $input['id'];
   $lapse          = $input['lapse'];
   $lapse_start    = isset($input['lapse_start'])?$input['lapse_start']:'';
   $lapse_end      = isset($input['lapse_end'])?$input['lapse_end']:'';
   $last_timestamp = $input['last_timestamp'];
   $lapse_rrd      = 300;
   $null           = '';

#print "***PARCHE****\n";

   $sec_offset = date('Z');
   // Array con los valores máximos definidos en la métrica/vista
   $a_top_value = array();

   if($graph_type=='metric'){
      $id_metric = $id;
      $dataq     = array('__ID_METRIC__'=>$id_metric);
      $result    = doQuery('metric_alert',$dataq);
      // SSV: En caos de no existir la métrica se sale
      if($result['cont'] == 0) {
         metric_error($id_metric);
         return;
      }
      $subtype   = $result['obj'][0]['subtype'];
      $file      = $result['obj'][0]['file'];
      $lapse_rrd = $result['obj'][0]['lapse'];
      $mtype     = $result['obj'][0]['mtype'];
      $items     = explode('|',$result['obj'][0]['items']);
      $c_items   = explode('|',$result['obj'][0]['c_items']);
      $top_value = ($result['obj'][0]['top_value']=='')?'':$result['obj'][0]['top_value'];

      // Valores máximos
      if($top_value!=''){
         $aux_top_cont=1;
         $aux_top_value = explode('|',$top_value);
         foreach ($aux_top_value as $_){
            if($_=='') continue;
            //$a_top_value[$aux_top_tag] = $_;
            $a_top_value[] = $_;

            $aux_top_tag = "LEVEL".$aux_top_cont;
            if($result['obj'][0]['c_items']!='')$c_items[] = $aux_top_tag;
            $items[]   = $aux_top_tag;

            $aux_top_cont++;
         }
      }
      $dir_rrd   = '/opt/data/rrd/elements';
   }
   elseif($graph_type=='subview'){
      $id_cfg_subview = $id;
      $subtype        = 'subview';
      $file           = str_pad($id_cfg_subview, 6, "0", STR_PAD_LEFT).'.rrd';
      $items          = array('Rojas','Naranjas','Amarillas');
      $dir_rrd        = '/opt/data/rrd/views';
   }
   $data = array();
   $num_fields = count($items);

   // ///////////////////////////////////////////////// //
   // START: Manejo del tipo de linea (rellena o hueca) //
   // ///////////////////////////////////////////////// //

   // ITEMS NORMALES
   for ($i=0;$i<$num_fields-count($a_top_value);$i++){
      $data['flot']['label'][$i]=(isset($c_items[$i]) and $c_items[$i]!='')?$c_items[$i]:$items[$i];
      $data['flot']['checked'][$i] = 'true';
      $data['flot']['type'][$i] = 'normal';
      // SSV: Aquí se indica si debe estar rellena la gráfica o no
      if (preg_match('/SOLID/',$mtype)) {
         $data['flot']['lines'][$i]=array('show'=>true,'fill'=>true);
      }
      elseif ($num_fields-count($a_top_value)>=4) {
         $data['flot']['lines'][$i]=array('show'=>true);
      }
      else{
         $data['flot']['lines'][$i]=array('show'=>true,'fill'=>true);
      }
   }

   // ITEMS LEVEL o TOP
   for ($j=0;$j<count($a_top_value);$j++){
      $data['flot']['label'][]=(isset($c_items[$num_fields-count($a_top_value)+$j]) and $c_items[$num_fields-count($a_top_value)+$j]!='')?$c_items[$num_fields-count($a_top_value)+$j]:$items[$num_fields-count($a_top_value)+$j];
      $data['flot']['checked'][] = 'false';
      $data['flot']['type'][] = 'top';
      $data['flot']['lines'][] = array('show'=>true);
   }

   // /////////////////////////////////////////////// //
   // END: Manejo del tipo de linea (rellena o hueca) //
   // /////////////////////////////////////////////// //


   if($lapse=='custom'){
      $start = $lapse_start;
      $end   = $lapse_end;
   }
   // Último día
   elseif ($lapse=='today'){
/*
      $aux = lapse_flot(0);
      $start = ($last_timestamp==0)?time()-86400:$last_timestamp;
      $end   = 'now';
*/
      $start = ($last_timestamp==0)?strtotime(date("Y-m-d H:i:s",strtotime("-1 days"))):$last_timestamp;
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
   // Último año
   elseif ($lapse=='year'){
      $res = 86400; // 60*60*24
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(365*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 years")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
   // Último mes
   elseif ($lapse=='month'){
      $res = ($lapse_rrd == 300)?7200:3600;
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(30*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 months")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
   // Última semana
   elseif ($lapse=='week'){
      $res = ($lapse_rrd == 300)?1800:900;
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(7*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 weeks")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
   // Hace X días, el día completo
   elseif(strpos($lapse,'day_')!==false){
      $n = str_replace('day_','',$lapse);
      $start = strtotime(date('Y-m-d', strtotime("-$n days")). '00:00:00');
      $end   = strtotime(date('Y-m-d', strtotime("-$n days")). '23:59:59');
/*
      $n = str_replace('day_','',$lapse);
      $aux = lapse_flot(86400*$n);
      $start = $aux[0];
      $end   = $aux[1];
*/
   }
   // Hace X meses, el mes completo
   elseif(strpos($lapse,'month_')!==false){
      $n = str_replace('month_','',$lapse);
      $start = strtotime(date('Y-m-01', strtotime("-$n months")). '00:00:00');
      $end   = strtotime(date('Y-m-t',  strtotime("-$n months")). '23:59:59');
   }
/*
   // Hace X semanas, la semana completa
   elseif(strpos($lapse,'week_')!==false){
      $n = str_replace('week_','',$lapse);
      $start = strtotime(date('Y-m-d', strtotime("-$n weeks")). '00:00:00');
      $end   = strtotime(date('Y-m-d', strtotime("-$n weeks")). '23:59:59');

   //$fstSunday = date("d-F-Y", strtotime("first Sunday of ".date('M')." ".date('Y')."")); $weekArray = getfstlastdayOfWeekofmonth($fstSunday);
   }
*/
   elseif($lapse=='other'){
      $start = $input['start'];
      $end   = $input['end'];
   }
   else return;

   CNMUtils::info_log(__FILE__, __LINE__, "**flot** START=$start END=$end");
   $cf = (strpos($file,'STDMM')!==false)?'MAX':'AVERAGE';
   $a_last_timestamp = array();

   if ($lapse == 'year' or $lapse == 'month' or $lapse == 'week') $cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -r $res -s $start -e $end";
   else $cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -s $start -e $end";

   // print_r($cmd);
   CNMUtils::info_log(__FILE__, __LINE__, "**flot** CMD=$cmd");

   $flag = 0;
   if (file_exists("$dir_rrd/$file")){
      $fp = popen($cmd, "r");
      while( !feof( $fp )){
         // $c = preg_split ("[[:space:]]+",chop(fgets($fp)));
         $c = preg_split ("/\s+/",chop(fgets($fp)));
         $campos=array();
         if ($c[0] == 'timestamp' or $c[0]=='') continue;
         else {

            $timestamp = str_replace(':','',$c[0]);
            $a_last_timestamp[]=$timestamp;
            $timestamp_js = ($timestamp+$sec_offset);

            $a_value = array();
            // DISPONIBILIDAD O ESTADO DE INTERFACES
            if ($subtype=='disp_icmp' or $subtype=='status_mibii_if'){
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  $value=$c[$i+1];
                  if ($value == '0') $value = 'nan';
                  elseif ($value == '1') $value=(int)$value;
                  $value=(strpos($value,'nan')!==false)?$null:$value;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
            }
            // TRÁFICO DE INTERFAZ
            elseif($subtype=='traffic_mibii_if'){
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  // En el fichero rrd la unidad es B/s y nosotros lo pasamos a b/s
                  $value=$c[$i+1];
                  if ($value == '0' or $value == '1') $value=(int)$value;
                  $value=(strpos($value,'nan')!==false)?$null:$value*8;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
            }
            //
            elseif($mtype=='STD_SOLID'){
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  $value=$c[$i+1];
                  if ($value == '0') $value = 'nan';
                  elseif ($value == '1') $value=(int)$value;
                  $value=(strpos($value,'nan')!==false)?$null:$value;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
            }
            // RESTO DE MÉTRICAS
            else{
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  $value=$c[$i+1];
                  if ($value == '0' or $value == '1') $value=(int)$value;
                  $value=(strpos($value,'nan')!==false)?$null:$value;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
            }

         }
         // Parche para que, en caso de que solo haya un valor en el fichero rrd aparezca algo en la gráfica porque hacen falta dos valores para que pinte flot
         // if($flag==0)$data['flot']['data'][]=array('t'=>($timestamp_js-10)/10,'v'=>$a_value);
         if($flag==0)$data['flot']['data'][]=array('t'=>($timestamp_js-1),'v'=>$a_value);
         $flag = 1;

         // $data['flot']['data'][]=array('t'=>$timestamp_js/10,'v'=>$a_value);
         $data['flot']['data'][]=array('t'=>$timestamp_js,'v'=>$a_value);
      }
   }else{
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
   }


   array_pop($a_last_timestamp);
   array_pop($a_last_timestamp);
   if(count($a_last_timestamp)!=0) $data['meta']['last_timestamp']=end($a_last_timestamp);
   else $data['meta']['last_timestamp']=$last_timestamp;

   $data['meta']['num_items']=$num_fields;





   array_pop($data['flot']['data']);
   array_pop($data['flot']['data']);
/*
 print_r($data);
 print("<br>");
*/

   return($data);
}






?>
