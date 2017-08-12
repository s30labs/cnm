<?php
class Tree{

	private $xmlAll;
	private $xmlData;
	private $structure;
	private $xml;
   function __construct($structure='',$xml='',$isGlobalAdmin=false,$sublevel=0){
		// En caso de utilizar el constructor vacio, no hacer nada
		if($structure=='')return;

		$this->structure=$structure;
		$this->xml=$xml;
		$this->isGlobalAdmin=$isGlobalAdmin;
		$this->_rec($this->structure,$sublevel);
   }

	function composer($a_input){
/*
      $a_input = array(
         'html_id'       => 'global_tree',
         'do'            => $do,
         'xml'           => $xml,
         'isGlobalAdmin' => $isGlobalAdmin,
         'sublevel'      => 0,
			'parent'        => '',
			'hidx'          => $hidx,
			'mode'          => full|onelevel # full => árbol completo | onelevel => el nivel que corresponda del árbol
      );

*/
		require_once('inc/Store.php');
		require_once('inc/MC.php');

		$this->xml=$a_input['xml'];
		$this->isGlobalAdmin=$a_input['isGlobalAdmin'];	

		// Árbol completo
		if($a_input['mode']=='full'){
			$sublevel = 0;
	      $a_data = array(
	         'html_id' => $a_input['html_id'],
				'do'      => $a_input['do'],
	         'parent'  => '',
	      );
	      $structure = $this->aux_composer_full($a_data);
	      $this->structure=$structure;
		}
		// Un nivel del árbol	
		else{

			// sublevel == 1 es cuando son hojas dinámicas (tipos de dispositivos, de vistas) de una rama y que deben ser vistos siempre
			// sublevel == 0 es cuando son hojas estáticas (configuración) de una rama y deben ser vistos dependiendo del perfil o cuando son ramas
			$sublevel = 1;
			if($a_input['parent']=='' OR $a_input['parent']=='configuracion') $sublevel = 0;

			$data = array('__HTML_ID__'=>$a_input['html_id'],'__HTML_TYPE__'=>'tree','__PARENT__'=>$a_input['parent']);
			// SELECT label,icon,size,target,position,plugin_id,parent,item_id,item_type FROM plugin_base WHERE html_id='__HTML_ID__' AND html_type='__HTML_TYPE__' AND PARENT='__PARENT__' ORDER BY position;
			$result = doQuery('get_all_plugin_name_by_id_type_parent_1',$data);
			$result = doQuery('get_all_plugin_name_by_id_type_parent_2',$data);
			$result = doQuery('get_all_plugin_name_by_id_type_parent_3',$data);
			foreach($result['obj'] as $r){
/*
				// En caso de que sea la rama de assets en el árbol global: Elementos dinámicos
				if($r['item_id']=='__assets'){
					$a_count_subtype=array();
	      		$data2 = array();
			      $result2 = doQuery('asset_subtypes_group_count',$data2);
					foreach($result2['obj'] as $r2) $a_count_subtype[$r2['hash_asset_type']] = $r2['cuantos'];

	      		$data2 = array();
			      $result2 = doQuery('all_asset_types_count',$data2);
			      foreach($result2['obj'] as $r2){
						// Mostramos el tipo de asset
		            $structure = array('id'=>'__assets_'.$r2['hash_asset_type'].'-'.$a_input['hidx'].'-all','text'=>($r2['manage']==0)?'Inventario: '.$r2['descr']:$r2['descr'],'style'=>($r2['manage']==0)?"background-color: #DAFAF8":'',
		               'im0'=>$r2['icon'],'im1'=>$r2['icon'],'im2'=>$r2['icon'],'imheight'=>$r['size'],'imwidth'=>$r['size'],
		               'userdata' => array(
                     	array('name' => 'href' ,   'value' => $a_input['do'].'mod_asset_layout&type='.$r2['hash_asset_type'].'&subtype=all'),
	                     array('name' => 'hidx' ,   'value' => $a_input['hidx']),
	                     array('name' => 'enable' , 'value' => 0),
	                     array('name' => 'target' , 'value' => 'mod_asset_layout&type='.$r2['hash_asset_type'].'&subtype=all'),
		               ),
		            );
						if(array_key_exists($r2['hash_asset_type'],$a_count_subtype) AND $a_count_subtype[$r2['hash_asset_type']]>0){
							$structure['child'] = 1;
						};
		      		$this->structure[]=$structure;
					}
				}
				// Elementos estáticos que vienen de plugin_base
				else{
*/
					$structure = array('id'=>$r['item_id'].'_'.$a_input['hidx'],'text'=>i18($r['label']),
	   	         'im0'=>$r['icon'],'im1'=>$r['icon'],'im2'=>$r['icon'],'imheight'=>$r['size'],'imwidth'=>$r['size'],
		            'userdata' => array(
		               array('name' => 'href' ,   'value' => $a_input['do'].$r['target']),
	   	            array('name' => 'hidx' ,   'value' => $a_input['hidx']),
		               array('name' => 'enable' , 'value' => 0),
							array('name' => 'target' , 'value' => $r['target']),
		            ),
		         );
	
	   	      if($r['item_id']=='__dispositivos'){
		            $data2=array();
		            $result2 = doQuery('get_num_device_types',$data2);
		            if($result2['obj'][0]['cuantos']>0) $structure['child'] = 1;
		         }
		         elseif($r['item_id']=='__vistas'){
		            $data2=array();
		            $result2 = doQuery('get_num_view_types',$data2);
		            if($result2['obj'][0]['cuantos']>0) $structure['child'] = 1;
		         }
					// Elementos TI gestionables
	            elseif($r['item_id']=='__elementosti'){
	               $data2=array('__MANAGE__'=>1);
	               $result2 = doQuery('get_num_assets_types_by_manage',$data2);
	               if($result2['obj'][0]['cuantos']>0) $structure['child'] = 1;
	            }
					// Activos
               elseif($r['item_id']=='__assets'){
                  $data2=array('__MANAGE__'=>0);
                  $result2 = doQuery('get_num_assets_types_by_manage',$data2);
                  if($result2['obj'][0]['cuantos']>0) $structure['child'] = 1;
               }
		         elseif($r['item_id']=='configuracion'){
						$structure['child'] = 1;
					}
		      	$this->structure[]=$structure;
				//}	
			}
		}
		$this->_rec($this->structure,$sublevel);
	}

	private function aux_composer_full($a_input){
      require_once('inc/Store.php');
      require_once('inc/MC.php');

      $aux_data = array();
      $data = array('__HTML_ID__'=>$a_input['html_id'],'__HTML_TYPE__'=>'tree','__PARENT__'=>$a_input['parent']);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_1',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_2',$data);
      $result = doQuery('get_all_plugin_name_by_id_type_parent_3',$data);
      foreach ($result['obj'] as $r){
			// En caso de que sea la rama de support pack en configuracion
			if($r['item_id']=='conf_tab_custom_supportpack'){
				$a_kids = array();
				$data2 = array();
				$result2 = doQuery('support_pack_list_all',$data2);
				foreach($result2['obj'] as $r2){
					$a_kids[]=array('id'=>$r2['subtype'],'text'=>$r2['name'],
                  'im0'=>'mod_sp_16x16.png','im1'=>'mod_sp_16x16.png','im2'=>'mod_sp_16x16.png','imheight'=>'18px','imwidth'=>'18px',
                  'userdata' => array(
                     array('name' => 'href' ,   'value' => $a_input['do']."mod_conf_misc_global_supportpack&supportpack={$r2['subtype']}"),
							array('name' => 'target' , 'value' => "mod_conf_misc_global_supportpack"),
                  ),
               );
				}

				$aux_data[]=array('id'=>$r['item_id'],'text'=>i18($r['label']),'child'=>'1',
               'im0'=>$r['icon'],'im1'=>$r['icon'],'im2'=>$r['icon'],'imheight'=>$r['size'],'imwidth'=>$r['size'],
               'subtree'=>$a_kids,
               'userdata' => array(
                  array('name' => 'href' ,   'value' => $a_input['do'].$r['target']),
						array('name' => 'target' , 'value' => $r['target']),
               ),
            );
			}
			else{
				$a_data = array('html_id'=>$a_input['html_id'],'parent'=>$r['item_id'],'do'=>$a_input['do']);
         	$a_kids = $this->aux_composer_full($a_data);
				if(count($a_kids)>0){
	         	$aux_data[]=array('id'=>$r['item_id'],'text'=>i18($r['label']),'child'=>'1',
						'im0'=>$r['icon'],'im1'=>$r['icon'],'im2'=>$r['icon'],'imheight'=>$r['size'],'imwidth'=>$r['size'],
						'subtree'=>$a_kids,
						'userdata' => array(
	                  array('name' => 'href' ,   'value' => $a_input['do'].$r['target']),
	                  array('name' => 'target' , 'value' => $r['target']),
	            	),
					);
				}
				else{
	         	$aux_data[]=array('id'=>$r['item_id'],'text'=>i18($r['label']),
						'im0'=>$r['icon'],'im1'=>$r['icon'],'im2'=>$r['icon'],'imheight'=>$r['size'],'imwidth'=>$r['size'],
						'userdata' => array(
	                  array('name' => 'href' ,   'value' => $a_input['do'].$r['target']),
	                  array('name' => 'target' , 'value' => $r['target']),
	               ),
					);
				}
			}
      }
      return $aux_data;
	}

	private function _rec($input,$sublevel){

// print_r($input);
// print_r($this->xml);
//exit;

		foreach ($input as $key => $value){

			$id = $value['id'];
	
			// Los id que sean hidx_[numero] siempre se muestran
			if(! in_array_like($id,$this->xml) AND ($sublevel==0) AND ($this->isGlobalAdmin==false) AND (!preg_match('/^hidx_\d+$/',$id)) ){
				continue;
			}
/*
         if((! array_key_exists($value['id'],$this->xml))AND($sublevel==0)AND($this->isGlobalAdmin==false)){
         	continue;
         }
*/
         $this->xmlData.="<item";
         $this->xmlData.=$this->_params($value);
         $this->xmlData.=">";
         $this->xmlData.=$this->_userdata($value);
         $this->xmlData.=$this->_subtree($value,$id);
         $this->xmlData.="</item>";
		}
	}
	private function _subtree($input,$id){
      $xml = '';
		// En caso de ser dispositivos o vistas, se permite que tenga hojas porque el id empieza por __
		if ( (isset($input['subtree'])) AND  (is_array($input['subtree']))AND(substr($id,0,2)=='__')){
         $xml.=$this->_rec($input['subtree'],1);
      }
		elseif((isset($input['subtree'])) AND (is_array($input['subtree'])) ){
         $xml.=$this->_rec($input['subtree'],0);
		}
      return $xml;
	}
	private function _params($input){
		$xml = '';
		foreach ($input as $key=>$value){
			if (!is_array($value)){
				// SSV 2012-07-09
				$value=str_replace("'","&apos;",$value);
				$value=str_replace("<","&lt;",$value);
				$value=str_replace(">","&gt;",$value);
				$xml.=" $key='$value'";
			}
		}
		return $xml;
	}
	private function _userdata($input){
		$xml = '';
		if (is_array($input['userdata'])){
	      foreach ($input['userdata'] as $userdata){
	         $xml.="<userdata name='{$userdata['name']}'><![CDATA[{$userdata['value']}]]></userdata>";
	      }
		}
		return $xml;
	}

	function show(){
		header("Content-Type:application/xhtml+xml;charset=UTF-8");
		$this->xmlAll="<?xml version='1.0' ?>";
		$this->xmlAll.='<tree id="0">';
		$this->xmlAll.=$this->xmlData;
		$this->xmlAll.="</tree>";
		echo $this->xmlAll;
	}

	function refresh_subtree($parent_id){
      header("Content-Type:application/xhtml+xml;charset=UTF-8");
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<tree id='$parent_id'>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</tree>";
      echo $this->xmlAll;
	}

   function xml(){
      $this->xmlAll="<?xml version='1.0' ?>";
      $this->xmlAll.="<tree id='0'>";
      $this->xmlAll.=$this->xmlData;
      $this->xmlAll.="</tree>";
      return $this->xmlAll;
   }
}
?>
