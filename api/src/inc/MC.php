<?php
class MC_Base {
	private $lang           = '';
	private $messages       = array();
	private $a_lang         = array();
	private $_dir_file      = '/var/www/html/onm/lang/';
	private $_dir_mem       = '/store/data/mdata/lang/';
	private $a_lang_defined = array(
		'es_ES'=>'es.lang',
		'en_US'=>'en.lang',
		'ch_CH'=>'ch.lang',
	);
 
	public function __construct($lang='es_ES') {
      if(! array_key_exists($lang,$this->a_lang_defined)){
         echo "El idioma {$lang} no está definido";
         exit;
      }
		$this->lang = $lang;
	}
   function msg($key=''){
		if(count($this->messages)==0){
			$this->read_lang();
		}
		
		if(!$key){
			return $this->messages;
		}
		elseif(isset($this->messages[$key])){
			return $this->messages[$key];
		}else{
			return substr($key,1);
			// return "??? {$this->lang} $key";
		}
   }
   function save_lang(){
      $file        = $this->a_lang_defined[$this->lang];
      $orig_path   = $this->_dir_file.$file;
		$dest_path   = $this->_dir_mem.$file;
      if (!file_exists($orig_path)) die("ERROR:No existe el fichero de idiomas $orig_path\n");
      $FD = fopen($orig_path,"r");
      $cont = 0;
      while ($linea = fgets($FD,4096)){
         if($cont==0){
            $cont++;
            continue;
         }
         @list($clave,$valor)=explode('||',$linea);
         if($clave!='') $messages[$clave]=rtrim($valor);
      }
      fclose($FD);
		$fp = fopen($dest_path,'w');
		fwrite($fp, json_encode($messages));
		fclose($fp);	
   }
	function read_lang(){
      $file           = $this->a_lang_defined[$this->lang];
      $orig_path      = $this->_dir_mem.$file;
		// En caso de no existir el fichero de idioma intenta crearlo
		if (!file_exists($orig_path)) $this->save_lang();
		if (!file_exists($orig_path)) die("ERROR:No existe el fichero json de idiomas $orig_path\n");
		$json           = file_get_contents($orig_path);
		$this->messages = json_decode($json,true);
	}
}
function i18($id_in,$php=''){
   $id=($php=='')?$id_in:"$php-$id_in";
	if(substr($id,0,1)!='_') $id='_'.$id;
	$msg= (is_object($GLOBALS['mc']))?$GLOBALS['mc']->msg($id):'';
   return $msg;
}

	
abstract class HIDX_Base{
	static public function save($dbc){
		$a_hidx = array();

   	$query  = "SELECT hidx,host_ip,cid,host_descr FROM cfg_cnms";
	   $result = QueryNoGlobal($dbc,$query);
      foreach ($result['obj'] as $r) $a_hidx[$r['hidx']]=array('ip'=>$r['host_ip'],'name'=>$r['cid'],'descr'=>$r['host_descr'],'cid'=>$r['cid']);
		$orig_path = '/opt/data/mdata/cache/hidx.json';
      $fp = fopen($orig_path,'w');
      fwrite($fp, json_encode($a_hidx));
      fclose($fp);
	}

	static public function info($hidx){
      $orig_path = '/opt/data/mdata/cache/hidx.json';
		$a_rc      = array();

      if (!file_exists($orig_path)) die("ERROR:No existe el fichero json de cache de hidx $orig_path\n");
      $json   = file_get_contents($orig_path);
      $a_hidx = json_decode($json,true);
		if(array_key_exists($hidx,$a_hidx)) $a_rc = $a_hidx[$hidx];
		return $a_rc;
	}

	static public function ip($hidx){
		$ip = 'NULL';

		$a_hidx = HIDX_Base::info($hidx);
		if( $a_hidx['ip']!='') $ip = $a_hidx['ip'];
		return $ip;
	}

}
?>
