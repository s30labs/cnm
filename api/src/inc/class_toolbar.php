<?php
class Toolbar{

	private $xmlAll;
	private $xmlData;
	private $structure;
   function __construct($structure='',$xml='',$isGlobalAdmin=false){
      if($structure=='')return;

		$this->structure=$structure;
		$this->xml=$xml;
		$this->isGlobalAdmin=$isGlobalAdmin;
		$this->_rec($this->structure);
   }

	function composer($a_input){
		/*
      $a_input = array(
         'html_id'       => 'devices_upper_toolbar',
         'xml'           => $xml,
         'isGlobalAdmin' => $isGlobalAdmin,
         'parent'        => '',
      );
		*/
		$a_data = array(
			'html_id'=>$a_input['html_id'],
			'parent'=>'',
		);
		$a_disabled = (array_key_exists('disabled',$a_input))?$a_input['disabled']:array();
		$a_deleted  = (array_key_exists('deleted',$a_input))?$a_input['deleted']:array();
		$a_kids = (array_key_exists('kids',$a_input))?$a_input['kids']:array();
		$structure = $this->aux_composer($a_data,$a_disabled,$a_kids,$a_deleted);
      $this->structure=$structure;
      $this->xml=$a_input['xml'];
      $this->isGlobalAdmin=$a_input['isGlobalAdmin'];
      $this->_rec($this->structure);
	}

	private function aux_composer($a_input,$a_disabled=array(),$a_kids=array(),$a_deleted=array()){
      require_once('inc/Store.php');
      require_once('inc/MC.php');
		
		$aux_data = array();
      $data = array('__HTML_ID__'=>$a_input['html_id'],'__HTML_TYPE__'=>'toolbar','__PARENT__'=>$a_input['parent']);
      // SELECT label,icon,size,target,position,plugin_id,parent,item_id,item_type FROM plugin_base WHERE html_id='__HTML_ID__' AND html_type='__HTML_TYPE__' AND PARENT='__PARENT__' ORDER BY position;
      $result = doQuery('get_all_plugin_name_by_id_type_parent_1',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_2',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_3',$data);
		foreach ($result['obj'] as $r){
			if($r['item_type']=='buttonSelect'){
				$a_data = array('html_id'=>$a_input['html_id'],'parent'=>$r['item_id']);
				$kids = $this->aux_composer($a_data,$a_disabled,$a_kids);
				if(array_key_exists($r['item_id'],$a_kids)){
					foreach($a_kids[$r['item_id']] as $kk) $kids[]=$kk;
				}
				// http://forum.dhtmlx.com/viewtopic.php?f=4&t=20939&p=66679
				$aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type'],'text'=>i18($r['label']),'img'=>$r['icon'],'kids'=>$kids,'renderSelect'=>'false');
			}
			else{
				if($r['item_type']=='separator')	   $aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type']);	
				elseif($r['item_type']=='slider')	$aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type'],'length'=>'70','valueMin'=>'0','valueMax'=>'15','valueNow'=>'5','textMin'=>i18('_refresco0min'),'textMax'=>i18('_15min'),'toolTip'=>i18('_refrescarcadavminutos'));	
				elseif($r['icon']=='')              $aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type'],'text'=>i18($r['label']));
				else{
					// No aparece el elemento
					if(in_array($r['item_id'],$a_deleted)){
						continue;
					}
					// Icono deshabilitado
					elseif(in_array($r['item_id'],$a_disabled)){
						$aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type'],'text'=>i18($r['label']),'img'=>$r['icon'],'imgdis'=>$r['icon'],'enabled'=>'false');
					}
					else{
						$aux_data[]=array('id'=>$r['item_id'],'type'=>$r['item_type'],'text'=>i18($r['label']),'img'=>$r['icon'],'imgdis'=>$r['icon']);
					}
				}
			}
		}
		return $aux_data;
	}

	/*
	*	Function: _rec
	*	Input:
	*		$input
	*		$input_sep: 0 => No pone separadores
	*						1 => Pone separadores (por defecto);
	*	Output: 
	*/
	private function _rec($input,$input_sep=1){
      $cont = 1;

      foreach ($input as $value){
			// 2015-01-06 SSV: Acabo de comentar esto, debería mirar si tiene algún efecto secundario aparte de poder meter elementos de tipo 
			// separator en plugin_base.
			// if($value['type'] == 'separator') continue;

			if( (! isset($value['cnm_visible'])) OR ($value['cnm_visible']!=true) ){
		      if(! in_array($value['id'],$this->xml)AND($this->isGlobalAdmin==false)) continue;
			}

			if ($cont>1 AND $input_sep==1) $this->xmlData.=" <item id='sep{$cont}' type='separator' /> ";
         $cont++;

         $this->xmlData.="<item";
         $this->xmlData.=$this->_params($value);
         $this->xmlData.=">";
			if(array_key_exists('userdata',$value)){
				foreach($value['userdata'] as $k => $v) $this->xmlData.="<userdata name='$k'>$v</userdata>";
			}
         $this->xmlData.=$this->_kids($value);
         $this->xmlData.="</item>";
		}
	}

   private function _params($input){
      $xml = '';
      foreach ($input as $key=>$value){
         if($key == 'cnm_visible') continue;
			if($key == 'userdata') continue;
         if (!is_array($value)) $xml.=" $key='$value'";
         // if (!is_array($value)) $xml.=' '.$key.'="'.$value.'"';
      }
      return $xml;
   }
	private function _kids($input){
      $xml = '';
      // En caso de ser dispositivos o vistas, se permite que tenga hojas
      if (isset($input['kids']) and is_array($input['kids'])){
         $xml.=$this->_rec($input['kids'],0);
      }
      return $xml;
	}

	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.="<toolbar>";
		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</toolbar>";
		echo $this->xmlAll;
	}
   function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<toolbar>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</toolbar>";
      return $this->xmlAll;
   }

}

/*
      $array_toolbar = array(
                        array('id'=>'acciones','type'=>'buttonSelect','text'=>'Acciones',
                              'kids'=>array(
                                       array('id'=>'crear_dispositivo','type'=>'button','text'=>'Crear'),
                                       array('id'=>'borrar_dispositivo','type'=>'button','text'=>'Borrar'),
                                      ),
                             ),
                        array('id'=>'estado','type'=>'buttonSelect','text'=>'Estado',
                              'kids'=>array(
                                       array('id'=>'activar_dispositivo','type'=>'button','text'=>'Activar','img'=>'ico_activ_tr_20.gif'),
                                       array('id'=>'mantenimiento_dispositivo','type'=>'button','text'=>'Mantenimiento','img'=>'ico_mant_tr_20.gif'),
                                       array('id'=>'baja_dispositivo','type'=>'button','text'=>'Dar de baja','img'=>'ico_desact_tr_20.gif'),
                                      ),
                             ),
                       );
      $toolbar = new Toolbar($array_toolbar);
      $toolbar->show();
*/
/*

<?xml version="1.0"?>	
<toolbar> 	a top xml tag
 <item id="new" type="button" img="new.gif" imgdis="new_dis.gif"/> 	a button item with images for enabled/disabled states only
 <item id="save" type="button" text="Save" img="save.gif" imgdis="save_dis.gif"/> 	a button item with text, images for enabled/disabled states
 <item id="open" type="button" text="Open"/> 	a button item with text only
 <item id="sep01" type="separator"/> 	a separator item
 <item id="undo" type="button" img="undo.gif" imgdis="undo_dis.gif" title="Undo"/> 	a button item with tooltip
 <item id="redo" type="button" img="redo.gif" imgdis="redo_dis.gif" title="Redo"/>	
 <item id="cut" type="button" img="cut.gif" imgdis="cut_dis.gif" title="Cut" enabled="false"/> 	a disabled button
 <item id="copy" type="button" img="copy.gif" imgdis="copy_dis.gif" title="Copy"/>	
 <item id="paste" type="button" img="paste.gif" imgdis="paste_dis.gif" title="Paste"/>	
 <item id="sep02" type="separator"/>	
 <item id="form" type="buttonTwoState" img="form.gif" imgdis="form_dis.gif" title="Form"/> 	a two-state button with images for enabled/disabled states, tooltip
 <item id="filter" type="buttonTwoState" img="filter.gif" imgdis="filter_dis.gif" text="Filter" title="Filter"/> 	a two-state button with images for enabled/disabled states, text, tooltip
 <item id="any_word" type="buttonTwoState" text="Any Word" selected="true"/> 	a pressed two-state button with text only
 <item id="txt_1" type="buttonInput"/> 	an input button
 <item id="txt_2" type="buttonInput" value="Filter Text" width="60" title="type the text here"/> 	an input button with predifined initial value, width, and tooltip
 <item id="sep1" type="separator"/>	
 <item id="history" type="buttonSelect" text="History"> 	a select button with text only
  <item type="button" id="8_1" text="Today"/> 	a listed option with text only
  <item type="button" id="8_2" text="Yesturday" selected="true"/> 	a preselected listed option
  <item type="button" id="8_3" text="Last Week"/>	
  <item type="button" id="8_4" text="Last Month"/>	
  <item id="8_sep0" type="separator"/> 	a listed option - separator
  <item type="button" id="8_5" img="icon_more.gif" text="More..."/> 	a listed option with image for the enabled state, text
 </item>	
 <item id="sep2" type="separator"/>	
 <item id="page_setup" type="buttonSelect" img="page_setup.gif" imgdis="page_setup_dis.gif" text="Page"> 	a select button with text, images for enabled/disabled states
  <item type="button" id="9_11" text="Layout"/>	
  <item type="button" id="9_12" text="Management"/>	
 </item>	
 <item id="print" type="buttonSelect" img="print.gif" imgdis="print_dis.gif" title="Print"> 	a select button with images for enabled/disabled states, tooltip
  <item type="button" id="9_1" text="Page"/>	
  <item type="button" id="9_2" text="Selection"/>	
  <item id="9_sep0" type="separator"/>	
  <item type="button" id="9_3" text="Custom..."/> 	
 </item>	
 <item id="sep3" type="separator"/>	
 <item id="slider" type="slider" length="70" valueMin="10" valueMax="100" valueNow="70" textMin="10 MBit" textMax="100 MBit" toolTip="%v MBit"/> 	a slider item
 <item id="sep4" type="separator"/>	
 <item id="text" type="text" text="dhtmlxToolbar Demo"/> 	a text item
</toolbar>	


*/
?>
