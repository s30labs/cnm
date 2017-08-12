<?php
class Menu{

	private $xmlAll;
	private $xmlData;
	private $structure;
   function __construct($structure){
		$this->structure=$structure;
		$this->_rec($this->structure);
   }
	private function _rec($input){
		// print_r($input);
		foreach ($input as $key => $value){
			$this->xmlData.="<item";
	      $this->xmlData.=$this->_params($value);
	      $this->xmlData.=">";
			$this->xmlData.=$this->_kids($value);	
			$this->xmlData.=$this->_userdata($value);	
			$this->xmlData.="</item>";
		}
	}

   private function _params($input){
      $xml = '';
      foreach ($input as $key=>$value){
         if (!is_array($value)) $xml.=" $key='$value'";
      }
      return $xml;
   }

   private function _kids($input){
      $xml = '';
      // En caso de ser dispositivos o vistas, se permite que tenga hojas
      if (isset($input['kids']) and is_array($input['kids'])){
         $xml.=$this->_rec($input['kids']);
      }
      return $xml;
   }

   private function _userdata($input){
      $xml = '';
      if (isset($input['userdata']) and is_array($input['userdata'])){
			foreach($input['userdata'] as $key => $value) $xml.="<userdata name='$key'>$value</userdata>";
      }
      return $xml;
   }

	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<menu>";
		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</menu>";
		echo $this->xmlAll;
	}
   function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<menu>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</menu>";
      return $this->xmlAll;
   }
}
?>
