<?php
abstract class Link{

   public function r($id,$file,$xml,$isGlobalAdmin=false){
		//if(! in_array($tab_meta['id'],$xml)AND($this->isGlobalAdmin==false)){
      //   return;
      //}	
		if(is_file("/var/www/html/onm/custom/".$file.".php")){
			return "custom/".$file;
		}
		else{
			return $file;
		}
   }
}
?>
