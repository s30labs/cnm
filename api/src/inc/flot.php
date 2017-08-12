<?php

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------

   class template{
      public $href;
      public $a_tpl;
      public $tpl;
      public function __construct($href,$a_tpl,$a_block=null){
         $this->href=$href;
         $this->a_tpl=$a_tpl;
         $this->tpl = new TemplatePower($this->href=$href);
         $this->tpl->prepare();
         $this->tpl->assign($this->a_tpl);

         //print_r($a_block);
         if(!is_null($a_block)){
            foreach($a_block as $id_block=>$a_value_block){
               // print "$id_block<br>";
               foreach($a_value_block as $value_block){
                  // print "$value_block<br>";
                  $this->tpl->newBlock($id_block);
                  $this->tpl->assign($value_block);
               }
            }
         }
         $this->tpl->printToScreen();
      }
   }


function flot($input){
   $graph_type     = $input['graph_type']; // metric|subview
   $id             = $input['id'];
   $lapse          = $input['lapse'];
   $lapse_rrd      = 300;
   $null           = '';

   $sec_offset = date('Z');

	$foo = calc_lapse($lapse,$lapse_rrd);
	$start = $foo['start'];
	$end   = $foo['end'];
	$res   = $foo['res'];


	$a_id_values = array();
	// En caso de pedir los valores de todas las métricas
	if($id == 'all'){
		$dataq = array();
		$result = doQuery('get_all_metrics_api',$dataq);
		foreach($result['obj'] as $r) $a_id_values[]=$r['id_metric'];
	}
	else{
		$a_id_values[]=$id;
	}

	$data = array();
	$cont = 1;
	foreach($a_id_values as $id_value){
	   if($graph_type=='metric'){
	      $id_metric = $id_value;
	      $dataq     = array('__ID_METRIC__'=>$id_metric);
	      $result    = doQuery('metric_alert',$dataq);
	      $subtype   = $result['obj'][0]['subtype'];
	      $file      = $result['obj'][0]['file'];
	      $lapse_rrd = $result['obj'][0]['lapse'];
	      $mtype     = $result['obj'][0]['mtype'];
	      $items     = explode('|',$result['obj'][0]['items']);
	      $c_items   = explode('|',$result['obj'][0]['c_items']);
	      $dir_rrd   = '/opt/data/rrd/elements';
	   }
		elseif($graph_type=='subview'){
	      $id_cfg_subview = $id_value;
	      $subtype        = 'subview';
	      $file           = str_pad($id_cfg_subview, 6, "0", STR_PAD_LEFT).'.rrd';
	      $items          = array('Rojas','Naranjas','Amarillas');
	      $dir_rrd        = '/opt/data/rrd/views';
	   }
	   $num_fields = count($items);
		
		/////////////////////////
		// ITEMS DE LA MÉTRICA //
		/////////////////////////
	   for ($i=0;$i<$num_fields;$i++){
	      $data[$id_value]['label'][$i]=(isset($c_items[$i]) and $c_items[$i]!='')?$c_items[$i]:$items[$i];
	   }
	
	   $cf = (strpos($file,'STDMM')!==false)?'MAX':'AVERAGE';
	
		if (strpos($lapse,'year')===0 or strpos($lapse,'month')===0 or strpos($lapse,'week')===0){
//	   if ($lapse == 'year' or $lapse == 'month' or $lapse == 'week'){
			$cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -r $res -s $start -e $end";
		}
	   else{
			$cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -s $start -e $end";
		}
	
		// CNMUtils::info_log(__FILE__, __LINE__, "**flot** START=$start END=$end CONT=$cont CMD=$cmd");
	
	   if (file_exists("$dir_rrd/$file")){
			// EN CASO DE HABER SELECCIONADO UN LAPSE == 'all' SE EMPIEZAN A MOSTRAR VALORES A PARTIR 
			// DEL PRIMER VALOR DIFERENTE A -nan
			$flag_value = 0;
			$aux_data = array();
	      $fp = popen($cmd, "r");
	      while( !feof( $fp )){
	         $c = preg_split ("/\s+/",chop(fgets($fp)));
	         if ($c[0] == 'timestamp' or $c[0]=='') continue;
	         else {
	            $timestamp = str_replace(':','',$c[0]);
					// Hay que contemplar esto para el tema del desfase horario
	            // $timestamp_js = ($timestamp+$sec_offset);
	            $timestamp_js = $timestamp;
	
	            $a_value = array();
					for ($i=0;$i<$num_fields;$i++){
						if($c[$i+1]!='-nan') $flag_value = 1;
						$a_value[]=$c[$i+1];
					}
	         }
	         if($flag_value==1 or $lapse!='all')$data[$id_value]['data'][]=array('t'=>$timestamp_js,'v'=>$a_value);
	      }
			pclose($fp);
	   }
		
		$cont++;
	}
   return($data);
}


function calc_lapse($lapse,$lapse_rrd=''){
	$res   = 0;
	$start = 0;
	$end   = 0;
	if ($lapse=='all'){
		// En caso de ser todos los valores, hay que recoger desde el 1 de Enero de 1980 a las 00:01 horas y eso es 
		// sumarle al timestamp de 1970 315360001 segundos (10 años). Con rrdfetch sólo se pueden obtener valores 
		// desde el 1 de Enero de 1980 a las 00:01 horas.
		$start = '315360001';
		$end   = 'now';	
	}
	elseif ($lapse=='today' or $lapse=='day_0'){
      $end   = time();
      $start = $end-86400;
   }
	elseif ($lapse=='hour' or $lapse=='hour_0'){
      $end   = time();
      $start = $end-3600;
   }
	elseif ($lapse=='minute' or $lapse=='minute_0'){
      $end   = time();
      $start = $end-60;
   }
	elseif ($lapse=='year' or $lapse=='year_0'){
      $res = 86400; // 60*60*24
      $end = (floor(mktime()/$res)*$res);
      $start = $end-(365*86400);
   }
	elseif ($lapse=='month' or $lapse=='month_0'){
		$res = ($lapse_rrd == 300)?7200:3600;
      $end = (floor(mktime()/$res)*$res);
      $start = $end-(30*86400);
   }
	elseif ($lapse=='week' or $lapse=='week_0'){
		$res = ($lapse_rrd == 300)?1800:900;
      $end = (floor(mktime()/$res)*$res);
      $start = $end-(7*86400);
   }
	elseif(strpos($lapse,'day_')!==false){
      $n = str_replace('day_','',$lapse);
      //$aux = lapse_flot(86400*$n);
      //$start = $aux[0];
      //$end   = $aux[1];
		$n = str_replace('day_','',$lapse);
      $end   = time()-($n*86400);
      $start = $end-86400;
   }
	elseif(strpos($lapse,'hour_')!==false){
      $n = str_replace('hour_','',$lapse);
      $end   = time()-($n*3600);
      $start = $end-3600;
   }
	elseif(strpos($lapse,'minute_')!==false){
      $n = str_replace('minute_','',$lapse);
      $end   = time()-($n*60);
      $start = $end-60;
   }
   elseif(strpos($lapse,'week_')!==false){
		$res = ($lapse_rrd == 300)?1800:900;
      $n = str_replace('week_','',$lapse);
      $end   = time()-($n*7*86400);
      $start = $end-(7*86400);
   }
	elseif(strpos($lapse,'year_')!==false){
      $res = 86400; // 60*60*24
      $n = str_replace('year_','',$lapse);
      $end   = time()-($n*365*86400);
      $start = $end-(365*86400);
   }
   elseif(strpos($lapse,'month_')!==false){
		$res = ($lapse_rrd == 300)?7200:3600;
      $n = str_replace('month_','',$lapse);
      $end   = time()-($n*30*86400);
      $start = $end-(30*86400);
   }

	return array('start'=>$start,'end'=>$end,'res'=>$res);
}

function lapse_flot($input){
   $tnow    = mktime();
   $dnow    = date("d/m/Y",$tnow);
   $dmy     = explode( "/", $dnow,3);
   $tnow0h  = mktime(0,0,0,$dmy[1],$dmy[0],$dmy[2]);
   $tday0h  = $tnow0h-$input;
   $tday24h = $tday0h+86400;
   return array($tday0h,$tday24h);
}

?>
