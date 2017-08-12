<?php
class Tabbar{

	private $xmlAll;
	private $xmlData;
   function __construct($isGlobalAdmin=false){
		$this->isGlobalAdmin=$isGlobalAdmin;
   }

   function composer($a_input){
/*
   $html_id = 'views_tab';
   $a_param = array(
      'html_id'       => $html_id,
      'do'            => $do,
      'xml'           => $xml,
      'isGlobalAdmin' => $isGlobalAdmin,
      'hidx'          => _hidx,
		'tab'           => $tab,
   );
   $tabbar = new Tabbar();
   $tabbar->composer($a_param);
   $tabbar->show();
*/
      require_once('inc/Store.php');
      require_once('inc/MC.php');

      $this->isGlobalAdmin=$a_input['isGlobalAdmin'];

      $data = array('__HTML_ID__'=>$a_input['html_id'],'__HTML_TYPE__'=>'tab','__PARENT__'=>'');
      // SELECT label,icon,icon_size,target,position,custom,parent FROM plugin_base WHERE html_id='__HTML_ID__' AND html_type='__HTML_TYPE__' AND PARENT='__PARENT__' ORDER BY position;
      $result = doQuery('get_all_plugin_name_by_id_type_parent_1',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_2',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_3',$data);

		$selected = 0;
      foreach($result['obj'] as $r){

			// START: SE HACE ESTO PARA MOSTRAR LA PRIMERA SOLAPA EN CASO DE NO EXISTIR LA SOLAPA QUE DEBE MOSTRARSE 
			if(! in_array($r['item_id'],$a_input['xml'])AND($this->isGlobalAdmin==false)){
         	continue;
      	}
			// END

			if($a_input['tab'] == $r['item_id']) $selected = 1;
      }
		$cont = 0;
		foreach($result['obj'] as $r){
			if( ($selected==0 and $cont==0) or ($a_input['tab'] == $r['item_id']) ){
				$tab = array('id'=>$r['item_id'],'width'=>$r['size'],'href'=>$a_input['do'].$r['target'],'selected'=>1);
			}
			else{
				$tab = array('id'=>$r['item_id'],'width'=>$r['size'],'href'=>$a_input['do'].$r['target']);
			}
			$selected++;
			$this->addTab($tab,i18($r['label']),$a_input['xml']);
      }
	}

	function addRow(){
		$this->xmlData.="</row>";
		$this->xmlData.="<row>";
	}
   function addTab(){
      list($tab_meta,$label,$xml)=func_get_args();
		if(! in_array($tab_meta['id'],$xml)AND($this->isGlobalAdmin==false)){
			return;
      }

      $this->xmlData.="<tab";
		foreach($tab_meta as $key => $value){
			if($key=='content')continue;
			$this->xmlData.=" $key='".str_replace('&','&amp;',$value)."'";
		}
      $this->xmlData.=">";

		if (isset($tab_meta['content']) and $tab_meta['content']!=''){
			$this->xmlData.="<content><![CDATA[{$tab_meta['content']}]]></content>";
		}

      $this->xmlData.="<![CDATA[$label]]>";
      $this->xmlData.='</tab>';
   }
	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<tabbar>";
		$this->xmlAll.="<row>";
		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</row>";
		$this->xmlAll.="</tabbar>";
		echo $this->xmlAll;
	}
	function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<tabbar>";
      $this->xmlAll.="<row>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</row>";
      $this->xmlAll.="</tabbar>";
		return $this->xmlAll;
	}
}
?>
