<?php
class Option{

	private $xmlAll;
	private $xmlData;
   function __construct($structure){
		$a_ini = array('"');
		$a_end = array('\"');
		foreach($structure as $line){
			$this->xmlData.='<option';
			// $meta = $line[0];
			// $name = $line[1];
			$meta = str_replace($a_ini,$a_end,$line[0]);
			$name = str_replace($a_ini,$a_end,$line[1]);
			// foreach ($meta as $key => $value){$this->xmlData.=' '.$key.'="'.$value.'"';}
			foreach ($meta as $key => $value){
            // SSV 2012-07-09
            $value=str_replace("'","&apos;",$value);
            $value=str_replace("<","&lt;",$value);
            $value=str_replace(">","&gt;",$value);
				$this->xmlData.=" $key='$value'";
			}
			$this->xmlData.="><![CDATA[$name]]></option>";
		}
   }
	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<complete>";
		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</complete>";
		echo $this->xmlAll;
	}
	function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<complete>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</complete>";
      return $this->xmlAll;
   }
}
?>
