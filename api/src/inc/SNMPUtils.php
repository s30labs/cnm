<?php

include_once('inc/CNMUtils.php');

class SNMPUtils {

   // -----------------------------------------------------------------------------------
   // parse_mib_info
   // Parsea la info proporcionada por la salida del comando snmptranslate -On -Td de un
   // determinado OID.
   // Extrae la informacion necesaria para generar la documentacion correspondiente.
   // -----------------------------------------------------------------------------------
   public static function parse_mib_info($cmd_out){
/*
 * Para un objeto tipo GET:
CTRON-SSR-CAPACITY-MIB::capCPUCurrentUtilization.1
capCPUCurrentUtilization OBJECT-TYPE
  -- FROM       CTRON-SSR-CAPACITY-MIB
  SYNTAX        INTEGER (0..100)
  MAX-ACCESS    read-only
  STATUS        current
  DESCRIPTION   "The CPU utilization expressed as an integer percentage.
                This is calculated over the last 5 seconds at a 0.1 second
                interval as a simple average."
                ::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) cabletron(52) ssr(2501) ssrMibs(1) capacityMIB(270) cpu(2) capCPUTable(1) capCPUEntry(1) capCPUCurrentUtilization(2) 1 }

 * Para un objeto tipo TRAP:
NOTIFICATION-TEST-MIB::demo-notif
demo-notif NOTIFICATION-TYPE
  -- FROM       NOTIFICATION-TEST-MIB
    OBJECTS       { sysLocation }
  DESCRIPTION   "Just a test notification"
  ::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) ucdavis(2021) demonotifs(991) 17 }

*/
   // -----------------------------------------------------------------------------------

      $indesc=0;
      $oid_translate=array_shift($cmd_out);

      foreach ($cmd_out as $line){

			$line = utf8_encode($line);

         if (preg_match("/FROM\s+(\S+)/",$line,$match)) { $mib=$match[1]; }
         elseif (preg_match("/SYNTAX\s+(\S+)/",$line,$match)) { $type=$match[1]; }
         elseif (preg_match("/DESCRIPTION\s+(.*)/",$line,$match)) { $desc=$match[1]; $indesc=1; continue;}

         if (preg_match("/\:\:= \{/",$line)) {
           $indesc=0;
           CNMUtils::debug_log(__FILE__, __LINE__, "cmd_out=$line----");

            if (preg_match("/\s+(\S+Table)\(/",$line,$match)) { $range=$mib.'::'.$match[1]; }
            else { $range=''; }
				
				if (preg_match("/enterprises\(1\)\s+(\S+)\(\d+\)/",$line,$match)) { $enterprise=strtoupper($match[1]); }
         }
         if ($indesc) { $desc .= ' '.trim($line); }
      }

      //OJO: Elimino la comilla simple de desc. Puede tener impacto al insertar en BBDD
      $desc_parsed=preg_replace("/'/","", $desc);

CNMUtils::debug_log(__FILE__, __LINE__, "oid_trans=$oid_translate");
CNMUtils::debug_log(__FILE__, __LINE__, "MIB=$mib");
CNMUtils::debug_log(__FILE__, __LINE__, "TYPE=$type");
CNMUtils::debug_log(__FILE__, __LINE__, "DESC=$desc_parsed");
CNMUtils::debug_log(__FILE__, __LINE__, "RANGE=$range");
CNMUtils::debug_log(__FILE__, __LINE__, "ENTERPRISE=$enterprise");
/*
      array(
         'id_ref' => 'squid_cache_memory',   'tip_type' =>'cfg' , 'url' => '',
         'date' => '',     'tip_class' => 1,  'name' => 'Descripcion',
         'descr' => 'Mide el uso de memoria por la cache de un proxy SQUID: <strong></strong> a partir de los siguientes atributos de la MIB SQUID-MIB:<br><br><strong>SQUID-MIB::cacheMemUsage (Integer32)</strong> Amount of system memory allocated by the cache.',
      ),

Mide el: <strong></strong> a partir de los siguientes atributos de la MIB $mib:<br>
<br><strong>$oid_translate ($type)</strong>$desc

*/
      return array($oid_translate,$mib,$type,$desc_parsed,$range,$enterprise);
   }



}

?>
