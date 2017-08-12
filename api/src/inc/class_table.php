<?php
class Table{

	private $xmlAll;
	private $xmlData;
	private $xmlHead;
	private $xmlAttachHead = array();
	private $xmlBeforeInit;
	private $xmlAfterInit;
	private $xmlAttachFooter;
	private $setColumnMinWidth = array();
	private $enableResizing = array();
	private $numRows=0;
	private $limit_word = true;
	private $enableSearch = true;
	private $width_mode = 'px';
	private $userHidden = false;
	private $a_user_params = array();

   function __construct(){
   }
   function addRow(){
      list($row_meta,$row_data,$row_user)=func_get_args();

		// Datos no visibles del grid
      $this->xmlData.="<row";
		foreach($row_meta as $key => $value){
         $value=$this->clearStr($value,'all');
         $this->xmlData.=" $key='$value'";
		}
      $this->xmlData.=">";

		// Datos visibles del grid	
      foreach($row_data as $value){
			$value=$this->clearStr($value,'zero');
			$value=$this->limitarPalabras($value,1000);
			$this->xmlData.="<cell><![CDATA[$value]]></cell>";
		}

		// Datos de usuario del grid
      foreach($row_user as $key => $value){
			$value=$this->clearStr($value,'zero');
			$this->xmlData.="<userdata name='$key'><![CDATA[$value]]></userdata>";
		}

      $this->xmlData.='</row>';
      $this->numRows++;
   }

   function addRow2(){
      list($row_meta,$row_data,$row_user)=func_get_args();

		// Datos no visibles del grid
      $this->xmlData.="<row";
      foreach($row_meta as $key => $value){
			$value=$this->clearStr($value,'all');
			$this->xmlData.=" $key='$value'";
		}
      $this->xmlData.=">";

		// Datos visibles del grid
      foreach($row_data as $cell){
			$this->xmlData.="<cell ";
			foreach ($cell as $key => $value){
				$value=$this->clearStr($value,'all');
				if ($key!='value') $this->xmlData.=" $key='$value'";
			}	
			$value = $this->clearStr($cell['value'],'zero');
			$this->xmlData.="><![CDATA[$value]]></cell>";
		}

		// Datos de usuario del grid
      foreach($row_user as $key => $value){
			$value=$this->clearStr($value,'zero');
			$this->xmlData.="<userdata name='$key'><![CDATA[$value]]></userdata>";
		}

      $this->xmlData.='</row>';
      $this->numRows++;
   }

	function addCol(){
		list($col_meta,$col_search,$title)=func_get_args();

		$this->xmlHead.="<column";
		$id = '';
      foreach($col_meta as $key => $value){

			if($value=='')$value='&nbsp;';

			if($key=='option')next;
         elseif($key=='width'){
            if(strpos($value,',')){
               list($width,$minwidth,$resizable)=explode(',',$value);

					if($id!='' AND array_key_exists($id,$this->a_user_params) AND array_key_exists('width',$this->a_user_params[$id]) AND $this->a_user_params[$id]['width']!='' and $width!='*'){
						$width = $this->a_user_params[$id]['width'];
      			}

               $this->xmlHead.=" $key='$width'";
               $this->setColumnMinWidth[]=$minwidth;
               $this->enableResizing[]=$resizable;
            }else{
					$value = $this->clearStr($value,'zero');
					if($id!='' AND array_key_exists($id,$this->a_user_params) AND array_key_exists('width',$this->a_user_params[$id]) AND $this->a_user_params[$id]['width']!=''){
						$width = $this->a_user_params[$id]['width'];
      			}
               $this->xmlHead.=" $key='$value'";
            }
			}elseif($key=='hidden'){
				continue;	
			}else{
				if($key=='id') $id = $value;
	         $value=$this->clearStr($value,'zero');
				$this->xmlHead.=" $key='$value'";
			}
		}
		if($id!='' AND array_key_exists($id,$this->a_user_params) AND array_key_exists('visible',$this->a_user_params[$id]) AND $this->a_user_params[$id]['visible']==0){
			$this->xmlHead.=" hidden='true'";
		}
		$title=$this->clearStr($title,'zero');
	   $this->xmlHead.="><![CDATA[$title]]>";

		if(isset($col_meta['option']) and $col_meta['option']!=''){
			foreach($col_meta['option'] as $v) $this->addOption($v);
		}
		$this->xmlHead.="</column>";
		
		// Parte de busqueda del titulo
		if ($col_search!='' and $this->enableSearch==true) $this->xmlAttachHead[]=$col_search;
	}
	function addOption(){
		$option=func_get_args();
		$text=$this->clearStr($option[0]['text'],'zero');
		$value=$this->clearStr($option[0]['value'],'all');
		$this->xmlHead.="<option value='$value'><![CDATA[$text]]></option>";
	}
	function footer(){
		list($footer)=func_get_args();
		$this->xmlAttachFooter=$footer;
	}
	// $tabla->beforeInit('enableMultiLine','true');
	function beforeInit(){
		list($command,$param)=func_get_args();
		$command=$this->clearStr($command,'all');
		$param=$this->clearStr($param,'zero');
		$this->xmlBeforeInit.="<call command='$command'><param><![CDATA[$param]]></param></call>";
	}
	function afterInit(){
      list($command,$param,$param2)=func_get_args();
		$command=$this->clearStr($command,'all');
		$param=$this->clearStr($param,'zero');
		if(isset($param2)){
	      $this->xmlAfterInit.="<call command='$command'><param><![CDATA[$param]]></param><param><![CDATA[$param2]]></param></call>";
		}else{
	      $this->xmlAfterInit.="<call command='$command'><param><![CDATA[$param]]></param></call>";
		}
	}
   function enableAlterCss(){
      list($param1,$param2)=func_get_args();
		$param1=$this->clearStr($param1,'zero');
		$param2=$this->clearStr($param2,'zero');
      $this->xmlAfterInit.="<call command='enableAlterCss'><param><![CDATA[$param1]]></param><param><![CDATA[$param2]]></param></call>";
   }
	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<rows>";
		$this->xmlAll.="<head>";
		$this->xmlAll.=$this->xmlHead;
		if($this->width_mode == 'px'){
	      $this->xmlAll.='<settings><colwidth><![CDATA[px]]></colwidth></settings>';
		}else{
	      $this->xmlAll.='<settings><colwidth><![CDATA[%]]></colwidth></settings>';
		}
      $this->xmlAll.='<beforeInit>';
      // $this->xmlAll.='<call command="enableMultiline"><param>true</param></call>';
		$this->xmlAll.=$this->xmlBeforeInit;
      // $this->xmlAll.='<call command="setSkin"><param>light</param></call>';
      $this->xmlAll.="<call command='setSkin'><param><![CDATA[dhx_skyblue]]></param></call>";
      $this->xmlAll.='</beforeInit>';

		$this->xmlAll.='<afterInit>';
		if (count($this->xmlAttachHead)>0){
			$this->xmlAll.="<call command='attachHeader'>";
			$this->xmlAll.='<param><![CDATA['.implode(',',$this->xmlAttachHead).']]></param>';
			$this->xmlAll.='</call>';
		}
		if ($this->xmlAttachFooter!=''){
		   $this->xmlAll.="<call command='attachFooter'>";
         $this->xmlAll.='<param><![CDATA['.$this->xmlAttachFooter.']]></param>';
         $this->xmlAll.='</call>';
			$this->xmlAll.="<call command='paging_init'/>";
		}
		if (count($this->setColumnMinWidth)>0){
			$this->xmlAll.="<call command='setColumnMinWidth'>";
         $this->xmlAll.='<param><![CDATA['.implode(',',$this->setColumnMinWidth).']]></param>';
         $this->xmlAll.='</call>';
		}
      if (count($this->enableResizing)>0){
         $this->xmlAll.="<call command='enableResizing'>";
         $this->xmlAll.='<param><![CDATA['.implode(',',$this->enableResizing).']]></param>';
         $this->xmlAll.='</call>';
      }
      $this->xmlAll.=$this->xmlAfterInit;
		$this->xmlAll.='</afterInit>';

		$this->xmlAll.="</head>";

		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</rows>";
		echo $this->xmlAll;
	}
   function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<rows>";
      $this->xmlAll.="<head>";
      $this->xmlAll.=$this->xmlHead;
      if($this->width_mode == 'px'){
         $this->xmlAll.='<settings><colwidth><![CDATA[px]]></colwidth></settings>';
      }else{
         $this->xmlAll.='<settings><colwidth><![CDATA[%]]></colwidth></settings>';
      }
      $this->xmlAll.='<beforeInit>';
      // $this->xmlAll.='<call command="enableMultiline"><param>true</param></call>';
      $this->xmlAll.=$this->xmlBeforeInit;
      // $this->xmlAll.='<call command="setSkin"><param>light</param></call>';
      $this->xmlAll.="<call command='setSkin'><param><![CDATA[dhx_skyblue]]></param></call>";
      $this->xmlAll.='</beforeInit>';

      $this->xmlAll.='<afterInit>';
      if (count($this->xmlAttachHead)>0){
         $this->xmlAll.="<call command='attachHeader'>";
         $this->xmlAll.='<param><![CDATA['.implode(',',$this->xmlAttachHead).']]></param>';
         $this->xmlAll.='</call>';
      }
      if ($this->xmlAttachFooter!=''){
         $this->xmlAll.="<call command='attachFooter'>";
         $this->xmlAll.='<param><![CDATA['.$this->xmlAttachFooter.']]></param>';
         $this->xmlAll.='</call>';
         $this->xmlAll.="<call command='paging_init'/>";
      }
      if (count($this->setColumnMinWidth)>0){
         $this->xmlAll.="<call command='setColumnMinWidth'>";
         $this->xmlAll.='<param><![CDATA['.implode(',',$this->setColumnMinWidth).']]></param>';
         $this->xmlAll.='</call>';
      }
      if (count($this->enableResizing)>0){
         $this->xmlAll.="<call command='enableResizing'>";
         $this->xmlAll.='<param><![CDATA['.implode(',',$this->enableResizing).']]></param>';
         $this->xmlAll.='</call>';
      }
      $this->xmlAll.=$this->xmlAfterInit;
      $this->xmlAll.='</afterInit>';

      $this->xmlAll.="</head>";

      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</rows>";
      return $this->xmlAll;
   }
   function showData($cuantos='',$posStart=''){
      header("Content-Type:application/xhtml+xml;charset=UTF-8");
      $this->xmlAll="<?xml version='1.0' ?>";
		if($cuantos!=''){
	      $this->xmlAll.="<rows total_count='$cuantos' pos='$posStart'>";
		}else{
	      $this->xmlAll.="<rows>";
		}
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</rows>";
      echo $this->xmlAll;
   }
	// Funcion que se utiliza cuando mostramos los hijos en un treegrid
	function showKids($parent){
      header("Content-Type:application/xhtml+xml;charset=UTF-8");
      $this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<rows parent ='$parent'>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</rows>";
      echo $this->xmlAll;
	}
	function limitarPalabras($cadena, $longitud, $elipsis = "..."){
		if($this->limit_word == false){
			$str = $cadena;
		}else{
			$str = (strlen($cadena) > $longitud)?(substr($cadena,0, $longitud)).$elipsis:$cadena;
		}
		return $str;
	}
	// Función que modifica el parámetro privado limit_word
	function no_limit_words(){
		$this->limit_word = false;
	}
	// Función que modifica el parámetro privado enableSearch
	function no_search(){
		$this->enableSearch = false;
	}
	function set_width_mode($mode){
		if($mode=='%') $this->width_mode = '%';
		else $this->width_mode = 'px';
	}
	function clearStr($s_input,$mode){
		$str = $s_input;
		if($mode=='all'){
			$str = str_replace(chr(0),"",$str);
			// MIRAR EN : http://php.net/manual/en/function.htmlentities.php en la entrada de 08-Apr-2010 03:34
			//	$str = htmlentities($str,ENT_QUOTES,'UTF-8');
			$str = str_replace('&',"&amp;",$str);
			$str = str_replace('<',"&lt;",$str);
			$str = str_replace('>',"&gt;",$str);
			$str = str_replace('"',"&quot;",$str);
			$str = str_replace("'","&apos;",$str);
		}elseif($mode=='zero'){
			$str = str_replace(chr(0),"",$str);
			// SSV,2012-03-15: La sustitución de abajo no está muy probada, en caso de dar problemas quitarla directamente 
			// $str = str_replace('"','\"',$str);
		}
		$str = str_replace("\n"," ",$str);
		$str = str_replace("\r"," ",$str);
//		$str = str_replace("&middot;","&#183;",$str);
		return $str;
	}
	function setUserHidden($a_user_params){
		$this->userHidden=true;
		if(!is_array($a_user_params)) $a_user_params = array();
		$this->a_user_params = $a_user_params;
	}
}
?>
