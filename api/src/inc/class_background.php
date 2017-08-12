<?php
class Background{
	private $a_item;
   function __construct(){
   }
   function add($a_item){
		$this->a_item[]=$a_item;
   }
	private function createXML(){
		$xml = "<?xml version='1.0' ?>";
      $xml.="<data>";
      foreach($this->a_item as $item){
         $xml.="<item id='{$item['id']}' name='{$item['name']}' type='{$item['type']}'>";
         $xml.="<filesize>{$item['filesize']}</filesize>";
         $xml.="<modifdate>{$item['modifdate']}</modifdate>";
         $xml.="</item>";
      }
      $xml.="</data>";
		return $xml;	
	}
	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		echo $this->createXML();
	}
   function xml(){
		return $this->createXML();
   }
}
?>
