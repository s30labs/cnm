<?php

// Función que convierte un grid almacenado en fichero csv
// INPUT:
//    $file_xml => path del fichero que representa el grid (que contiene xml)
// OUTPUT:
//    string en formato csv que se puede manejar en excel
function file_grid2csv($file_xml){
   $xml = implode('',file($file_xml));
   grid2csv($xml);
}

// Función que convierte un grid en formato xml en csv
// INPUT:
//    $xml => string con el xml que representa el grid
//    $mode => 0:utiliza todas las filas||1:la segunda fila se desecha
// OUTPUT:
//    string en formato csv que se puede manejar en excel
function grid2csv($xml,$mode=0){
	$regexp_entities = array(
		array('/<\/*strong>/',''),
		array('/<br>/',''),
		array('/<\/*b>/',''),
		array('/&nbsp;/',' '),
		array('/\t/','   '),
      array('/"/','""'),
	);

	// Eliminamos los caracteres de control
	$xml = ereg_replace('[[:cntrl:]]', '', $xml);

   $o_xml = (array) simplexml_load_string($xml, 'SimpleXMLElement', LIBXML_NOCDATA);

	$a_csv = array();
	$a_title = array();
   /////////////
   // Titulos //
   /////////////
   $head = (array) $o_xml['head'];
   foreach ($head['column'] as $title){
      foreach ($regexp_entities as $entitie) $title = preg_replace($entitie[0],$entitie[1],$title);
		$a_title[]=$title;
   }
	$a_csv[]=implode("\t",$a_title);

   ////////////////////
   // Cuerpo del grid //
   ////////////////////
	$a_row = (array)$o_xml['row'];

	// Grid con una linea
	if(is_array($a_row['cell'])){
		$row = $a_row;
		$a_cell = array();
      foreach ($row['cell'] as $cell){
         foreach ($regexp_entities as $entitie) $cell = preg_replace($entitie[0],$entitie[1],$cell);
			// En caso de que el primer caracter sea un - o un + se pone una comilla delante para ponerlo como comentario y no como formula
			$a_cell[]=(0===strpos($cell,'-') or 0===strpos($cell,'+'))?"'".(str_replace("\n",'',$cell)):'"'.$cell.'"';
      }
		$a_csv[]=implode("\t",$a_cell);
	}
	// Grid con más de una linea
	else{
	   foreach ($a_row as $row){
      $csv_out  .= $sep_fila;
	      $row = (array) $row;
			$a_cell = array();
	      foreach ($row['cell'] as $cell){
	         foreach ($regexp_entities as $entitie) $cell = preg_replace($entitie[0],$entitie[1],$cell);
			// En caso de que el primer caracter sea un - o un + se pone una comilla delante para ponerlo como comentario y no como formula
				$a_cell[]=(0===strpos($cell,'-') or 0===strpos($cell,'+'))?"'".(str_replace("\n",'',$cell)):'"'.$cell.'"';
				// $a_cell[]='\'"'.$cell.'"';
	      }
			$a_csv[]=implode("\t",$a_cell);
	   }
	}

	$csv_out = implode("\n",$a_csv);

   header("Content-type: application/octet-stream;charset=UTF-16");
   header('Content-Disposition: attachment; filename="my-data.csv"');
   // BOM DE UTF-16LE
   print (chr(255).chr(254));
   print(mb_convert_encoding($csv_out,"UTF-16LE" ,"UTF-8"));
}

// Función que convierte un grid en formato xml en array
// INPUT:
//    $xml => string con el xml que representa el grid
//    $mode => 0:utiliza todas las filas||1:la segunda fila se desecha
// OUTPUT:
//    array 
function grid2array($xml,$mode=0){
	$a_return = array();
	$regexp_entities = array(
		array('/<\/*strong>/',''),
		array('/<br>/',''),
		array('/<\/*b>/',''),
		array('/&nbsp;/',' '),
		array('/\t/','   '),
	);
   $o_xml = (array) simplexml_load_string($xml, 'SimpleXMLElement', LIBXML_NOCDATA);

   /////////////
   // Titulos //
   /////////////
	$a_title = array();
   $head = (array) $o_xml['head'];
   foreach ($head['column'] as $title){
      foreach ($regexp_entities as $entitie) $title = preg_replace($entitie[0],$entitie[1],$title);
		$a_title[]=$title;
   }

   /////////////////////
   // Cuerpo del grid //
   /////////////////////
	$a_row = (array)$o_xml['row'];

	// Grid con una linea
	if(is_array($a_row['cell'])){
		$row = $a_row;
		$a_cell = array();
		$c_cell = 0;
      foreach ($row['cell'] as $cell){
         foreach ($regexp_entities as $entitie) $cell = preg_replace($entitie[0],$entitie[1],$cell);
			$a_cell[$a_title[$c_cell]]=$cell;
			$c_cell++;
      }
		$a_return[]=$a_cell;
	}
	// Grid con más de una linea
	else{
	   foreach ($a_row as $row){
	      $row = (array) $row;
			$a_cell = array();
			$c_cell = 0;
	      foreach ($row['cell'] as $cell){
	         foreach ($regexp_entities as $entitie) $cell = preg_replace($entitie[0],$entitie[1],$cell);
				$a_cell[$a_title[$c_cell]]=$cell;
				$c_cell++;
	      }
			$a_return[]=$a_cell;
	   }
	}
	return $a_return;
}
?>
