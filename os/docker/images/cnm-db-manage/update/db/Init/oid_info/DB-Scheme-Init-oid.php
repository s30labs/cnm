<?php

	$OID_INFO = array(

      // WINDOWS -----------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1',    'device' => 'HOST WINDOWS XP/NT WORKSTATION'    ),
      array(
         'oid' => '.1.3.6.1.4.1.311.1.1.3.1.2',    'device' => 'HOST WINDOWS W2K/NT SERVER'     ),
      array(
         'oid' => '.1.3.6.1.4.1.311.1.1.3.1.3',    'device' => 'HOST WINDOWS W2K/NT DC'      ),
      array(
         'oid' => '.1.3.6.1.4.1.311.1.1.3.2',      'device' => 'HOST WINDOWS 9x'    ),
      // NET-SNMP ----------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.8072.3.2.3',       'device' => 'HOST SUN NET-SNMP'     ),
      array(
         'oid' => '.1.3.6.1.4.1.8072.3.2.10',      'device' => 'HOST LINUX NET-SNMP'      ),
      // SUN  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.42.2.1.1',         'device' => 'HOST SUN ULTRA'     ),
      // OPEN VMS  ---------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.22.1',     'device' => 'HOST OPEN VMS '     ),
      // NOKIA  ------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.8',    'device' => 'FIREWALL NOKIA'     ),
      // REDLINE - ---------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.6213',             'device' => 'SHAPER REDLINE'     ),
      // 3COM  -------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.2', 'device' => 'SWITCH 3COM SUPERSTACKII'    ),
      // LEXMARK -- ---------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.641.1',            'device' => 'IMPRESORA LEXMARK T634'      ),
      // FLUKE  -------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.1226.1.3.2',       'device' => 'ANALIZADOR FLUKE OptiView'      ),
      // RICOH  -------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.367.1.1',          'device' => 'IMPRESORA RICOH Aficio 2022'    ),
      // AXIS  ---------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.368.1.2',          'device' => 'AXIS StorPoint CD E100 CD-ROM Server'    ),

      // AGERE  ---------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.11898.2.4.9',      'device' => 'TSUNAMI MP.11 5054'    ),

      // FORTINET  ---------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.12356.1688',      	'device' => 'FORTINET FORTIMAIL-100'    ),
      array(
         'oid' => '.1.3.6.1.4.1.12356.603',      	'device' => 'FORTINET FORTIGATE-60B'    ),
      array(
         'oid' => '.1.3.6.1.4.1.12356.3001',      	'device' => 'FORTINET FORTIGATE-300A'    ),
      array(
         'oid' => '.1.3.6.1.4.1.12356.8000',      	'device' => 'FORTINET FORTIGATE-800'    ),

      // LINKSYS  ---------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.3955.1.1',      	'device' => 'LINKSYS VPN ROUTER'    ),
      array(
         'oid' => '.1.3.6.1.4.1.3955.6.11.82.1', 	'device' => 'LINKSYS VPN ROUTER'    ),

		// CISCO  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.9.1.950',     		'device' => 'CISCO CAT2960'     ),
      array(
         'oid' => '.1.3.6.1.4.1.9.12.3.1.3.587',     'device' => 'CISCO SAN M9100'     ),
      array(
         'oid' => '.1.3.6.1.4.1.9.1.896',     'device' => 'CISCO CAT5xx VIRTUAL SWITCH'     ),

      // NEC  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.119.1.68.1',     	'device' => 'NEC iSTORAGE 2000'     ),

      // ALTEON  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.1872.1.13.1.3',    'device' => 'ALTEON APPLICATION SWITCH 2224'     ),

      // DRAGON WAVE  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.7262.2.2',     	'device' => 'DRAGON WAVE hc56_385_256qam Omni'     ),

      // INFOBLOX  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.7779.550.4.1.5.0',     	'device' => 'INFOBLOX'     ),

      // RADWARE  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.89.1.1.62.16',     	'device' => 'RADWARE DEFENSE PRO'     ),

      // SOCOMEC  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.4555.1.1.1',     	'device' => 'SOCOMEC NET VISION SAI'     ),

      // PACKETEER  --------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.17',       'device' => 'PACKETEER PACKET SHAPER'     ),

      // IRONPORT (CISCO) --------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.15497.1.1.1',       'device' => 'IRONPORT C150'     ),

      // AIRSPACE (CISCO) --------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.14179.1.1.4.3',       'device' => 'AIRSPACE CISCO WIRELESS LAN CONTROLLER'     ),

      // BLUE COAT ---------------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.3417.1.3.3',       'device' => 'AV810 SERIES PROXYAV'     ),
      array(
         'oid' => '.1.3.6.1.4.1.3417.1.1.28',       'device' => 'SG8100 SERIES'     ),



		// NETWORKING ----------------------------------------------------------------------------
      array(
         'oid' => '.1.3.6.1.4.1.9.1.507',     'device' => 'CISCO 1100 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.474',     'device' => 'CISCO 1200/1220 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.525',     'device' => 'CISCO 1210/1230 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.685',     'device' => 'CISCO 1240 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.758',     'device' => 'CISCO 1250 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.565',     'device' => 'CISCO 1300 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.533',     'device' => 'CISCO 1400 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.35',     'device' => 'ENTERASYS 1G582-09'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.60',     'device' => 'ENTERASYS 1G587-09'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.36',     'device' => 'ENTERASYS 1G694-13'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.59',     'device' => 'ENTERASYS 1H582-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.34',     'device' => 'ENTERASYS 1H582-51'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.82',     'device' => 'ENTERASYS 2E253-49R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.76',     'device' => 'ENTERASYS 2H22-08R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.80',     'device' => 'ENTERASYS 2H252-25R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.84',     'device' => 'ENTERASYS 2H253-25R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.83',     'device' => 'ENTERASYS 2H258-17R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.75',     'device' => 'ENTERASYS 2H28-08R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.379',     'device' => 'CISCO 340 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.522.2.1.76',     'device' => 'TELESYSTEMS SLW INC. 340 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.380',     'device' => 'CISCO 350 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.552',     'device' => 'CISCO 350 AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.8.20',     'device' => '3COM 3COM LINKBUILDERFMS100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.260.1.100',     'device' => 'STAR-TEK, INC. 3COM SS2 TR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.10',     'device' => '3COM 3COM4000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.4',     'device' => '3COM 3COM4400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.5',     'device' => '3COM 3COM4900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.24',     'device' => 'ENTERASYS 5-SSRM-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.21',     'device' => 'ENTERASYS 5G102-6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.20',     'device' => 'ENTERASYS 5G106-06'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.18',     'device' => 'ENTERASYS 5H102-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.19',     'device' => 'ENTERASYS 5H103-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.28',     'device' => 'ENTERASYS 5H152-50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.29',     'device' => 'ENTERASYS 5H153-50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.33.4.1',     'device' => 'ENTERASYS 6-SSRM-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.2',     'device' => 'ENTERASYS 6E122-26'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.7',     'device' => 'ENTERASYS 6E123-26'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.5',     'device' => 'ENTERASYS 6E123-50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.12',     'device' => 'ENTERASYS 6E128-26'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.14',     'device' => 'ENTERASYS 6E129-26'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.3',     'device' => 'ENTERASYS 6E132-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.8',     'device' => 'ENTERASYS 6E133-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.6',     'device' => 'ENTERASYS 6E133-49'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.13',     'device' => 'ENTERASYS 6E138-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.15',     'device' => 'ENTERASYS 6E139-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.23',     'device' => 'ENTERASYS 6E233-49'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.7',     'device' => 'ENTERASYS 6E308-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.14',     'device' => 'ENTERASYS 6E308-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.35',     'device' => 'ENTERASYS 6G306-06'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.2',     'device' => 'ENTERASYS 6G306-06'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.4',     'device' => 'ENTERASYS 6H122-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.18',     'device' => 'ENTERASYS 6H122-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.10',     'device' => 'ENTERASYS 6H123-50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.16',     'device' => 'ENTERASYS 6H128-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.17',     'device' => 'ENTERASYS 6H129-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.19',     'device' => 'ENTERASYS 6H133-37'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.20',     'device' => 'ENTERASYS 6H202-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.29',     'device' => 'ENTERASYS 6H202-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.15',     'device' => 'ENTERASYS 6H202-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.25',     'device' => 'ENTERASYS 6H203-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.21',     'device' => 'ENTERASYS 6H252-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.26',     'device' => 'ENTERASYS 6H253-13'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.24',     'device' => 'ENTERASYS 6H258-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.27',     'device' => 'ENTERASYS 6H259-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.28',     'device' => 'ENTERASYS 6H262-18'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.33',     'device' => 'ENTERASYS 6H302-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.3',     'device' => 'ENTERASYS 6H302-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.32',     'device' => 'ENTERASYS 6H303-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.4',     'device' => 'ENTERASYS 6H303-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.6',     'device' => 'ENTERASYS 6H308-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.13',     'device' => 'ENTERASYS 6H308-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.34',     'device' => 'ENTERASYS 6H352-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.5',     'device' => 'ENTERASYS 6H352-25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.2.11',     'device' => 'ENTERASYS 6M146-04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.12.1.1',     'device' => 'ENTERASYS 7C03'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.12.1.2',     'device' => 'ENTERASYS 7C04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.12.1.4',     'device' => 'ENTERASYS 7C04R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.3.4.56',     'device' => 'ENTERASYS 8H02-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.10',     'device' => 'ENTERASYS 9A128-01'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.20',     'device' => 'ENTERASYS 9A426-01'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.5',     'device' => 'ENTERASYS 9A426-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.11.6',     'device' => 'ENTERASYS 9A656-04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.11.8',     'device' => 'ENTERASYS 9A686-04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.11',     'device' => 'ENTERASYS 9E106-06'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.8',     'device' => 'ENTERASYS 9E132-15'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.1',     'device' => 'ENTERASYS 9E133-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.12',     'device' => 'ENTERASYS 9E138-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.3',     'device' => 'ENTERASYS 9E138-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.1',     'device' => 'ENTERASYS 9E312-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.8',     'device' => 'ENTERASYS 9E423-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.16',     'device' => 'ENTERASYS 9E423-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.10',     'device' => 'ENTERASYS 9E428-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.11',     'device' => 'ENTERASYS 9E428-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.12',     'device' => 'ENTERASYS 9E429-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.13',     'device' => 'ENTERASYS 9E429-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.14',     'device' => 'ENTERASYS 9E531-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.16',     'device' => 'ENTERASYS 9E531-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.4',     'device' => 'ENTERASYS 9F116-01'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.6.2',     'device' => 'ENTERASYS 9F120-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.6.1',     'device' => 'ENTERASYS 9F122-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.6.3',     'device' => 'ENTERASYS 9F125-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.6.4',     'device' => 'ENTERASYS 9F241-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.4',     'device' => 'ENTERASYS 9F310-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.7',     'device' => 'ENTERASYS 9F426-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.14',     'device' => 'ENTERASYS 9F426-03'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.24',     'device' => 'ENTERASYS 9G421-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.21',     'device' => 'ENTERASYS 9G426-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.27',     'device' => 'ENTERASYS 9G429-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.7',     'device' => 'ENTERASYS 9G536-04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.15',     'device' => 'ENTERASYS 9H421-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.9',     'device' => 'ENTERASYS 9H422-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.23',     'device' => 'ENTERASYS 9H423-26'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.22',     'device' => 'ENTERASYS 9H423-28'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.17',     'device' => 'ENTERASYS 9H429-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.5',     'device' => 'ENTERASYS 9H531-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.2',     'device' => 'ENTERASYS 9H531-18'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.9',     'device' => 'ENTERASYS 9H531-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.4',     'device' => 'ENTERASYS 9H532-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.1',     'device' => 'ENTERASYS 9H532-18'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.8',     'device' => 'ENTERASYS 9H532-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.12',     'device' => 'ENTERASYS 9H533-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.13',     'device' => 'ENTERASYS 9H533-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.6',     'device' => 'ENTERASYS 9H539-17'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.3',     'device' => 'ENTERASYS 9H539-18'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.10',     'device' => 'ENTERASYS 9H539-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.25',     'device' => 'ENTERASYS 9M426-02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.13.11',     'device' => 'ENTERASYS 9M546-04'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.9',     'device' => 'ENTERASYS 9T122-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.7',     'device' => 'ENTERASYS 9T122-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.17',     'device' => 'ENTERASYS 9T125-08'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.5.18',     'device' => 'ENTERASYS 9T125-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.18',     'device' => 'ENTERASYS 9T425-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.29',     'device' => 'ENTERASYS 9T427-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.32.9.28',     'device' => 'ENTERASYS 9T428-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.26',     'device' => 'JUNIPER A40'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.20',     'device' => 'NORTEL ACCELAR 740'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.21',     'device' => 'NORTEL ACCELAR 750'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.22',     'device' => 'NORTEL ACCELAR 790'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.9',     'device' => 'NORTEL ACCELAR1050'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.2',     'device' => 'NORTEL ACCELAR1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.7',     'device' => 'NORTEL ACCELAR1150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.8',     'device' => 'NORTEL ACCELAR1200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.6',     'device' => 'NORTEL ACCELAR1250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.23',     'device' => 'NORTEL ACCELAR750S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1872.1.4',     'device' => 'NORTEL ACEDIRECTOR2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1872.1.6',     'device' => 'NORTEL ACEDIRECTOR3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1872.1.10',     'device' => 'NORTEL ACEDIRECTOR4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6486.800.1.1.2.1.3.1.1',     'device' => 'ALCATEL 6624STACKSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6486.800.1.1.2.1.3.1.2',     'device' => 'ALCATEL 6648STACKSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.637.69.2.1.1.63',     'device' => 'ALCATEL 7670'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6486.800.1.1.2.1.1.1.1',     'device' => 'ALCATEL 7700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.637.61.1',     'device' => 'ALCATEL ASAM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6486.800.1.1.2.1.5.1.1',     'device' => 'ALCATEL OMNISW6300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.26',     'device' => 'EXTREME NETWORKS ALPINE 3802'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.20',     'device' => 'EXTREME NETWORKS ALPINE 3804'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.17',     'device' => 'EXTREME NETWORKS ALPINE 3808'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.618',     'device' => 'CISCO AP 1130'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.9',     'device' => 'PACKETEER APVNTG ASM30'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.7',     'device' => 'PACKETEER APVNTG ASM50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.8',     'device' => 'PACKETEER APVNTG ASM70'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.10',     'device' => 'PACKETEER APVNTG ASM90'     ),

      array(
         'oid' => '.1.3.6.1.4.1.14823.1.1.2',     'device' => 'ARUBA NETWORKS ARUBA 2400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.14823.1.1.1',     'device' => 'ARUBA NETWORKS ARUBA 5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.14823.1.1.3',     'device' => 'ARUBA NETWORKS ARUBA 800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.14823.1.2.4',     'device' => 'ARUBA NETWORKS ARUBA AP61'     ),

      array(
         'oid' => '.1.3.6.1.4.1.529.1.3.9',     'device' => 'LUCENT TECHNOLOGIES ASCEND PIPELINE220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.219',     'device' => 'ADTRAN ATLAS 550'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.143',     'device' => 'ADTRAN ATLAS 800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.155',     'device' => 'ADTRAN ATLAS 800PLUS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.5.1',     'device' => 'PARADYNE ATM-9580'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.9.8.4',     'device' => 'PARADYNE ATT DSLAM8810'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.9.8.1',     'device' => 'PARADYNE ATT MC-M'     ),

      array(
         'oid' => '.ATT Paradyne3161',     'device' => '"AT&AMP T"'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.10.3',     'device' => 'LUCENT TECHNOLOGIES AVAYA INTUITYPBX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.11',     'device' => 'F5 NETWORKS BALANCEADOR F5'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3493.4.1.3.1.24',     'device' => 'BROADBAND ACCESS SYSTEMS, INC. BAS CLUSTER MANAGER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3493.4.1.3.1.27',     'device' => 'BROADBAND ACCESS SYSTEMS, INC. BAS CLUSTER MANAGER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.26.1',     'device' => 'NORTEL BAYSTACK NMM AGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.45.1',     'device' => 'NORTEL BAYSTACK380-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.43.1',     'device' => 'NORTEL BAYSTACK420'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.57.2',     'device' => 'NORTEL BAYSTACK425-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.35.1',     'device' => 'NORTEL BAYSTACK450-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.49.1',     'device' => 'NORTEL BAYSTACK460-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.54.1',     'device' => 'NORTEL BAYSTACK470-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.46.1',     'device' => 'NORTEL BAYSTACK470-48T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.52.1',     'device' => 'NORTEL BAYSTACK5510-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.53.1',     'device' => 'NORTEL BAYSTACK5510-48T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.59.1',     'device' => 'NORTEL BAYSTACK5520-24T-PWR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.59.2',     'device' => 'NORTEL BAYSTACK5520-48T-PWR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1456.3.2',     'device' => 'TERAYON BE2800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.3',     'device' => 'F5 NETWORKS BIGIP 1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.4',     'device' => 'F5 NETWORKS BIGIP 1500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.5',     'device' => 'F5 NETWORKS BIGIP 2400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.6',     'device' => 'F5 NETWORKS BIGIP 3400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.7',     'device' => 'F5 NETWORKS BIGIP 4100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.8',     'device' => 'F5 NETWORKS BIGIP 5100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.9',     'device' => 'F5 NETWORKS BIGIP 5110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.1',     'device' => 'F5 NETWORKS BIGIP 520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.2',     'device' => 'F5 NETWORKS BIGIP 540'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.10',     'device' => 'F5 NETWORKS BIGIP 6400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.12',     'device' => 'F5 NETWORKS BIGIP 8400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1.3.4.13',     'device' => 'F5 NETWORKS BIGIP 8800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.2.1',     'device' => 'F5 NETWORKS BIGIP LOAD BALANCER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.32.2',     'device' => 'FOUNDRY NETWORKS BIGIRONMG8RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.32.1',     'device' => 'FOUNDRY NETWORKS BIGIRONMG8SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.1.2',     'device' => 'FOUNDRY NETWORKS BIGIRONRX16RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.1.1',     'device' => 'FOUNDRY NETWORKS BIGIRONRX16SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.3.2',     'device' => 'FOUNDRY NETWORKS BIGIRONRX4RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.3.1',     'device' => 'FOUNDRY NETWORKS BIGIRONRX4SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.2.2',     'device' => 'FOUNDRY NETWORKS BIGIRONRX8RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.40.2.1',     'device' => 'FOUNDRY NETWORKS BIGIRONRX8SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.37.1.3',     'device' => 'FOUNDRY NETWORKS BIGIRONSXL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.37.1.2',     'device' => 'FOUNDRY NETWORKS BIGIRONSXRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.37.1.1',     'device' => 'FOUNDRY NETWORKS BIGIRONSXSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.14.2',     'device' => 'FOUNDRY NETWORKS BIRON15000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.14.3',     'device' => 'FOUNDRY NETWORKS BIRON15000SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.14.1',     'device' => 'FOUNDRY NETWORKS BIRON15000SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.6.2',     'device' => 'FOUNDRY NETWORKS BIRON4000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.6.3',     'device' => 'FOUNDRY NETWORKS BIRON4000SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.6.1',     'device' => 'FOUNDRY NETWORKS BIRON4000SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.7.2',     'device' => 'FOUNDRY NETWORKS BIRON8000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.7.3',     'device' => 'FOUNDRY NETWORKS BIRON8000SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.7.1',     'device' => 'FOUNDRY NETWORKS BIRON8000SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.56',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 10808'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.77',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 12804'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.8',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 6800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.11',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 6808'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.24',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 6816'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.62',     'device' => 'EXTREME NETWORKS BLACKDIAMOND 8810'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9967',     'device' => 'BLUESOCKET BLUESOCKET WG'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.2.1',     'device' => 'PARADYNE BONAIRE-1SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.2.2',     'device' => 'PARADYNE BONAIRE-2SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.2.4',     'device' => 'PARADYNE BONAIRE-NAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.2.3',     'device' => 'PARADYNE BONAIRE-NAF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4981.4.1.1',     'device' => 'MOTOROLA BSR64000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1456.3.1',     'device' => 'TERAYON BW3500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.2.2',     'device' => 'FORCE10 NETWORKS, INC. C150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.2.1',     'device' => 'FORCE10 NETWORKS, INC. C300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1872.1.7',     'device' => 'NORTEL CACHEDIRECTOR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3417.1.1.7',     'device' => 'CACHEFLOW, INC. CACHEFLOW 3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3417.1.1.8',     'device' => 'CACHEFLOW, INC. CACHEFLOW 500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3417.1.1.5',     'device' => 'CACHEFLOW, INC. CACHEFLOW 5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3417.1.1.13',     'device' => 'CACHEFLOW, INC. CACHEFLOW 600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.2.0.1',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.3.0.0',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.3.0.3',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.3.1.1',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.3.1.2',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4998.2.1.3.2.0',     'device' => 'ARRIS CADANTC4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.17',     'device' => 'AVAYA CAJUN P330'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.45.1',     'device' => 'LUCENT TECHNOLOGIES CAJUN P550 GIGABIT SWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.45.2',     'device' => 'LUCENT TECHNOLOGIES CAJUN P550 ROUTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.45.8',     'device' => 'LUCENT TECHNOLOGIES CAJUN P880'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.791',     'device' => 'CISCO CAT 3750E48PD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.554',     'device' => 'CISCO CAT 6500SSLSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.706',     'device' => 'CISCO CAT 6KMSFC2A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.152',     'device' => 'CISCO CAT1116'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.151',     'device' => 'CISCO CAT116C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.150',     'device' => 'CISCO CAT116T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.175',     'device' => 'CISCO CAT1912C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.170',     'device' => 'CISCO CAT2908XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.370',     'device' => 'CISCO CAT2912LREXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.221',     'device' => 'CISCO CAT2912MFXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.219',     'device' => 'CISCO CAT2912XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.171',     'device' => 'CISCO CAT2916MXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.184',     'device' => 'CISCO CAT2924CXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.218',     'device' => 'CISCO CAT2924CXLV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.369',     'device' => 'CISCO CAT2924LREXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.220',     'device' => 'CISCO CAT2924MXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.183',     'device' => 'CISCO CAT2924XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.217',     'device' => 'CISCO CAT2924XLV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.35',     'device' => 'CISCO CAT2926'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.542',     'device' => 'CISCO CAT29408TF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.540',     'device' => 'CISCO CAT29408TT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.62',     'device' => 'CISCO CAT2948GGETX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.275',     'device' => 'CISCO CAT2948GL3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.386',     'device' => 'CISCO CAT2948GL3DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.323',     'device' => 'CISCO CAT295012'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.427',     'device' => 'CISCO CAT295012G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.324',     'device' => 'CISCO CAT295024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.325',     'device' => 'CISCO CAT295024C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.428',     'device' => 'CISCO CAT295024G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.472',     'device' => 'CISCO CAT295024GDC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.484',     'device' => 'CISCO CAT295024LREG'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.482',     'device' => 'CISCO CAT295024LREST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.430',     'device' => 'CISCO CAT295024S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.480',     'device' => 'CISCO CAT295024SX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.429',     'device' => 'CISCO CAT295048G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.560',     'device' => 'CISCO CAT295048SX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.559',     'device' => 'CISCO CAT295048T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.483',     'device' => 'CISCO CAT29508LREST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.551',     'device' => 'CISCO CAT2950ST24LRE997'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.359',     'device' => 'CISCO CAT2950T24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.489',     'device' => 'CISCO CAT2955C12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.508',     'device' => 'CISCO CAT2955S12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.488',     'device' => 'CISCO CAT2955T12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.694',     'device' => 'CISCO CAT2960-24TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.716',     'device' => 'CISCO CAT2960-24TT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.695',     'device' => 'CISCO CAT2960-48TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.717',     'device' => 'CISCO CAT2960-48TT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.798',     'device' => 'CISCO CAT29608TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.696',     'device' => 'CISCO CAT2960G-24TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.697',     'device' => 'CISCO CAT2960G-48TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.799',     'device' => 'CISCO CAT2960G8TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.527',     'device' => 'CISCO CAT297024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.561',     'device' => 'CISCO CAT297024TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.51',     'device' => 'CISCO CAT2980GA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.431',     'device' => 'CISCO CAT355012G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.368',     'device' => 'CISCO CAT355012T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.366',     'device' => 'CISCO CAT355024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.452',     'device' => 'CISCO CAT355024DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.453',     'device' => 'CISCO CAT355024MMF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.485',     'device' => 'CISCO CAT355024PWR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.367',     'device' => 'CISCO CAT355048'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.633',     'device' => 'CISCO CAT3560-24TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.634',     'device' => 'CISCO CAT3560-48TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.797',     'device' => 'CISCO CAT35608PC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.563',     'device' => 'CISCO CAT3560_24PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.564',     'device' => 'CISCO CAT3560_48PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.795',     'device' => 'CISCO CAT3560E24PD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.793',     'device' => 'CISCO CAT3560E24TD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.796',     'device' => 'CISCO CAT3560E48PD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.794',     'device' => 'CISCO CAT3560E48TD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.614',     'device' => 'CISCO CAT3560G-24PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.615',     'device' => 'CISCO CAT3560G-24TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.616',     'device' => 'CISCO CAT3560G-48PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.617',     'device' => 'CISCO CAT3560G-48TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.603',     'device' => 'CISCO CAT370G48PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.511',     'device' => 'CISCO CAT375024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.656',     'device' => 'CISCO CAT375024FS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.536',     'device' => 'CISCO CAT375024PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.514',     'device' => 'CISCO CAT375024T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.513',     'device' => 'CISCO CAT375024TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.512',     'device' => 'CISCO CAT375048'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.535',     'device' => 'CISCO CAT375048PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.574',     'device' => 'CISCO CAT3750_24ME'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.792',     'device' => 'CISCO CAT3750E24PD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.789',     'device' => 'CISCO CAT3750E24TD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.790',     'device' => 'CISCO CAT3750E48TD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.591',     'device' => 'CISCO CAT3750G16TD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.602',     'device' => 'CISCO CAT3750G24PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.624',     'device' => 'CISCO CAT3750G24TS1U'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.778',     'device' => 'CISCO CAT3750G24WS25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.779',     'device' => 'CISCO CAT3750G24WS50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.604',     'device' => 'CISCO CAT3750G48TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.530',     'device' => 'CISCO CAT3750GE12SFP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.688',     'device' => 'CISCO CAT3750GE12SFPDC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.516',     'device' => 'CISCO CAT37XXSTACK'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.575',     'device' => 'CISCO CAT4000NAM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.448',     'device' => 'CISCO CAT4006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.300',     'device' => 'CISCO CAT4232L3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.503',     'device' => 'CISCO CAT4503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.58',     'device' => 'CISCO CAT4503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.502',     'device' => 'CISCO CAT4506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.501',     'device' => 'CISCO CAT4507'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.537',     'device' => 'CISCO CAT4510'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.312',     'device' => 'CISCO CAT4840GL3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.298',     'device' => 'CISCO CAT4908GL3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.387',     'device' => 'CISCO CAT4908GL3DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.41',     'device' => 'CISCO CAT4912'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.626',     'device' => 'CISCO CAT4948'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.659',     'device' => 'CISCO CAT494810GE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.318',     'device' => 'CISCO CAT4KGATEWAY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.257',     'device' => 'CISCO CAT5KRSFC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.241',     'device' => 'CISCO CAT6000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.280',     'device' => 'CISCO CAT6006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.281',     'device' => 'CISCO CAT6009'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.522',     'device' => 'CISCO CAT6500FIREWALLSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.449',     'device' => 'CISCO CAT6503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.56',     'device' => 'CISCO CAT6503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.282',     'device' => 'CISCO CAT6506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.283',     'device' => 'CISCO CAT6509'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.61',     'device' => 'CISCO CAT6509NEBA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.310',     'device' => 'CISCO CAT6509SP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.400',     'device' => 'CISCO CAT6513'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.573',     'device' => 'CISCO CAT6KGATEWAY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.258',     'device' => 'CISCO CAT6KMSFC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.301',     'device' => 'CISCO CAT6KMSFC2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.48',     'device' => 'CISCO CAT6KNAM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.557',     'device' => 'CISCO CAT6KSUP720'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.53',     'device' => 'CISCO CAT7603'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.63',     'device' => 'CISCO CAT7604'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.54',     'device' => 'CISCO CAT7606'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.55',     'device' => 'CISCO CAT7609'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.60',     'device' => 'CISCO CAT7613'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.190',     'device' => 'CISCO CAT8510_CSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.230',     'device' => 'CISCO CAT8510_MSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.196',     'device' => 'CISCO CAT8515_CSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.231',     'device' => 'CISCO CAT8515_MSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.203',     'device' => 'CISCO CAT8540_CSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.202',     'device' => 'CISCO CAT8540_MSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.197',     'device' => 'CISCO CAT9006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.198',     'device' => 'CISCO CAT9009'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.18',     'device' => 'CISCO CAT_1900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.28',     'device' => 'CISCO CAT_1900C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.31',     'device' => 'CISCO CAT_1900I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.175',     'device' => 'CISCO CAT_1900LITEFX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.42',     'device' => 'CISCO CAT_2948G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.49',     'device' => 'CISCO CAT_2980GSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.10',     'device' => 'CISCO CAT_3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.26',     'device' => 'CISCO CAT_3001'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.23',     'device' => 'CISCO CAT_3100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.15',     'device' => 'CISCO CAT_3200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.111',     'device' => 'CISCO CAT_3500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.246',     'device' => 'CISCO CAT_3508GXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.247',     'device' => 'CISCO CAT_3512XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.287',     'device' => 'CISCO CAT_3524TXLEN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.248',     'device' => 'CISCO CAT_3524XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.278',     'device' => 'CISCO CAT_3548XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.40',     'device' => 'CISCO CAT_4003'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.46',     'device' => 'CISCO CAT_4006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.59',     'device' => 'CISCO CAT_4506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.727',     'device' => 'CISCO CATEXPRESS500-12TC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.725',     'device' => 'CISCO CATEXPRESS500-24LC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.726',     'device' => 'CISCO CATEXPRESS500-24PC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.724',     'device' => 'CISCO CATEXPRESS500-24TT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.784',     'device' => 'CISCO CATWSCBS3040FSC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.16.1.1.1.1',     'device' => '3COM CBLDR-3500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.16.1.2.1.1',     'device' => '3COM CBLDR-9400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.930.1.1',     'device' => 'CENTILLION NETWORKS, INC. CENT_100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.930.1.4',     'device' => 'CENTILLION NETWORKS, INC. CENT_5000BH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.16943.2.2',     'device' => 'CETERUS NETWORKS CETERUSUTS1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.16943.2.1',     'device' => 'CETERUS NETWORKS CETERUSUTS1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.16943.2.3',     'device' => 'CETERUS NETWORKS CETERUSUTS900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.1',     'device' => '3COM CHAS17SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.2',     'device' => '3COM CHAS7SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.4',     'device' => 'CISCO CISCCSS11050'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.4',     'device' => 'CISCO CISCCSS11050'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.3',     'device' => 'CISCO CISCCSS11150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.3',     'device' => 'CISCO CISCCSS11150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.7',     'device' => 'CISCO CISCCSS11501'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.7',     'device' => 'CISCO CISCCSS11501'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.5',     'device' => 'CISCO CISCCSS11503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.5',     'device' => 'CISCO CISCCSS11503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.6',     'device' => 'CISCO CISCCSS11506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.6',     'device' => 'CISCO CISCCSS11506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.9.368.4.2',     'device' => 'CISCO CISCCSS11800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2467.4.2',     'device' => 'CISCO CISCCSS11800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.478',     'device' => 'CISCO  12810'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.477',     'device' => 'CISCO  12816'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.21',     'device' => 'CISCO  1420 ETHERSWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.24',     'device' => 'CISCO  1420 ETHERSWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.8',     'device' => 'CISCO  1600 ROUTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.783',     'device' => 'CISCO  1801M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.981',     'device' => 'CISCO  1805'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.904',     'device' => 'CISCO  1861SRST2BK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.905',     'device' => 'CISCO  1861SRST4FK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.939',     'device' => 'CISCO  1861SRSTCUE2BK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.940',     'device' => 'CISCO  1861SRSTCUE4FK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.902',     'device' => 'CISCO  1861UC2BK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.903',     'device' => 'CISCO  1861UC4FK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.872',     'device' => 'CISCO  1900AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.734',     'device' => 'CISCO  240024TSA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.735',     'device' => 'CISCO  240024TSD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.545',     'device' => 'CISCO  2430IAD24FXS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.547',     'device' => 'CISCO  2431IAD16FXS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.548',     'device' => 'CISCO  2431IAD1T1E1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.546',     'device' => 'CISCO  2431IAD8FXS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.549',     'device' => 'CISCO  2432IAD24FXS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.804',     'device' => 'CISCO  3200WIRELESSMIC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.736',     'device' => 'CISCO  340024TSA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.737',     'device' => 'CISCO  340024TSD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.926',     'device' => 'CISCO  520 WIRELESSCONTROLLER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.820',     'device' => 'CISCO  5720'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.833',     'device' => 'CISCO  5740'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.731',     'device' => 'CISCO  5750'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.329',     'device' => 'CISCO  626'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.330',     'device' => 'CISCO  627'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.331',     'device' => 'CISCO  633'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.332',     'device' => 'CISCO  673'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.364',     'device' => 'CISCO  674'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.333',     'device' => 'CISCO  675'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.334',     'device' => 'CISCO  675E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.335',     'device' => 'CISCO  676'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.336',     'device' => 'CISCO  677'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.337',     'device' => 'CISCO  678'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.821',     'device' => 'CISCO  7201'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.862',     'device' => 'CISCO  7603S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.863',     'device' => 'CISCO  7606S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.864',     'device' => 'CISCO  7609S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.314',     'device' => 'CISCO  7750'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.302',     'device' => 'CISCO  7750MRP200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.456',     'device' => 'CISCO  7750MRP300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.303',     'device' => 'CISCO  7750SSP80'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.349',     'device' => 'CISCO  8110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.566',     'device' => 'CISCO  851'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.567',     'device' => 'CISCO  857'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.869',     'device' => 'CISCO  860AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.568',     'device' => 'CISCO  876'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.782',     'device' => 'CISCO  877M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.870',     'device' => 'CISCO  880AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.871',     'device' => 'CISCO  890AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.730',     'device' => 'CISCO  ACE10K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.2',     'device' => 'CISCO  ADAPTER CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.867',     'device' => 'CISCO  AIM2CUE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.623',     'device' => 'CISCO  AIMCUE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.828',     'device' => 'CISCO  AIRWLC2106K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.745',     'device' => 'CISCO  ASA5505'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.669',     'device' => 'CISCO  ASA5510'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.773',     'device' => 'CISCO  ASA5510SC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.774',     'device' => 'CISCO  ASA5510SY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.670',     'device' => 'CISCO  ASA5520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.671',     'device' => 'CISCO  ASA5520SC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.764',     'device' => 'CISCO  ASA5520SY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.672',     'device' => 'CISCO  ASA5540'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.673',     'device' => 'CISCO  ASA5540SC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.765',     'device' => 'CISCO  ASA5540SY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.753',     'device' => 'CISCO  ASA5550'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.763',     'device' => 'CISCO  ASA5550SC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.766',     'device' => 'CISCO  ASA5550SY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.607',     'device' => 'CISCO  BMGX8830PXM1E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.606',     'device' => 'CISCO  BMGX8830PXM45'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.609',     'device' => 'CISCO  BMGX8850PXM1E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.608',     'device' => 'CISCO  BMGX8850PXM45'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5296.1',     'device' => 'CISCO  BTS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.593',     'device' => 'CISCO  CCM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.486',     'device' => 'CISCO  CDM4630'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.487',     'device' => 'CISCO  CDM4650'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.936',     'device' => 'CISCO  CDSCDE100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.937',     'device' => 'CISCO  CDSCDE200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.938',     'device' => 'CISCO  CDSCDE300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.454',     'device' => 'CISCO  CE2636'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.612',     'device' => 'CISCO  CE501K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.409',     'device' => 'CISCO  CE507'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.432',     'device' => 'CISCO  CE507AV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.490',     'device' => 'CISCO  CE508'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.505',     'device' => 'CISCO  CE510'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.595',     'device' => 'CISCO  CE511K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.759',     'device' => 'CISCO  CE512K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.410',     'device' => 'CISCO  CE560'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.433',     'device' => 'CISCO  CE560AV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.491',     'device' => 'CISCO  CE565'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.596',     'device' => 'CISCO  CE566K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.411',     'device' => 'CISCO  CE590'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.708',     'device' => 'CISCO  CE611K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.761',     'device' => 'CISCO  CE612K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.504',     'device' => 'CISCO  CE7305'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.600',     'device' => 'CISCO  CE7306K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.412',     'device' => 'CISCO  CE7320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.492',     'device' => 'CISCO  CE7325'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.601',     'device' => 'CISCO  CE7326K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.361',     'device' => 'CISCO  CONTENTENGINE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.531',     'device' => 'CISCO  CR4430'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.532',     'device' => 'CISCO  CR4450'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.822',     'device' => 'CISCO  CRS14S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.524',     'device' => 'CISCO  CSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.306',     'device' => 'CISCO  CVA122'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.371',     'device' => 'CISCO  CVA122E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.307',     'device' => 'CISCO  CVA124'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.372',     'device' => 'CISCO  CVA124E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.381',     'device' => 'CISCO  DPA7610'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.365',     'device' => 'CISCO  DPA7630'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.686',     'device' => 'CISCO  DSC9210CLK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.455',     'device' => 'CISCO  DWCE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.556',     'device' => 'CISCO  ESSE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.14',     'device' => 'CISCO  ESSTACK'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.19',     'device' => 'CISCO  ETHERSWITCH 1220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.27',     'device' => 'CISCO  ETHERSWITCH 1220C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.226',     'device' => 'CISCO  FASTHUB100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.740',     'device' => 'CISCO  FE2636'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.681',     'device' => 'CISCO  FE511K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.760',     'device' => 'CISCO  FE512K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.687',     'device' => 'CISCO  FE611K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.661',     'device' => 'CISCO  FE6326K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.680',     'device' => 'CISCO  FE73325K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.517',     'device' => 'CISCO  GSS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.405',     'device' => 'CISCO  HSE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.632',     'device' => 'CISCO  HSE1140'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.362',     'device' => 'CISCO  IAD2420'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.693',     'device' => 'CISCO  ICM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.645',     'device' => 'CISCO  IDS4210'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.646',     'device' => 'CISCO  IDS4215'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.807',     'device' => 'CISCO  IDS4215VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.741',     'device' => 'CISCO  IDS4220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.742',     'device' => 'CISCO  IDS4230'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.647',     'device' => 'CISCO  IDS4235'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.808',     'device' => 'CISCO  IDS4235VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.812',     'device' => 'CISCO  IDS4240VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.649',     'device' => 'CISCO  IDS4250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.650',     'device' => 'CISCO  IDS4250SX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.810',     'device' => 'CISCO  IDS4250SXVIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.809',     'device' => 'CISCO  IDS4250VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.651',     'device' => 'CISCO  IDS4250XL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.811',     'device' => 'CISCO  IDS4250XLVIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.813',     'device' => 'CISCO  IDS4255VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.814',     'device' => 'CISCO  IDS4260VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.653',     'device' => 'CISCO  IDSIDSM2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.815',     'device' => 'CISCO  IDSIDSM2VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.654',     'device' => 'CISCO  IDSNMCIDS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.434',     'device' => 'CISCO  IE2105'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.648',     'device' => 'CISCO  IPS4240'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.652',     'device' => 'CISCO  IPS4255'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.830',     'device' => 'CISCO  IPS4270'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.831',     'device' => 'CISCO  IPS4270VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.662',     'device' => 'CISCO  IPSSSM10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.817',     'device' => 'CISCO  IPSSSM10VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.655',     'device' => 'CISCO  IPSSSM20'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.816',     'device' => 'CISCO  IPSSSM20VIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.806',     'device' => 'CISCO  IPSVIRTUAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.805',     'device' => 'CISCO  ISRWIRELESS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.157',     'device' => 'CISCO  MC3810'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.286',     'device' => 'CISCO  MC3810'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.582',     'device' => 'CISCO  MCS7815I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.900',     'device' => 'CISCO  MCS7816H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.898',     'device' => 'CISCO  MCS7816I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.583',     'device' => 'CISCO  MCS7825H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.746',     'device' => 'CISCO  MCS7825I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.901',     'device' => 'CISCO  MCS7828H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.899',     'device' => 'CISCO  MCS7828I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.584',     'device' => 'CISCO  MCS7835H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.585',     'device' => 'CISCO  MCS7835I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.586',     'device' => 'CISCO  MCS7845H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.587',     'device' => 'CISCO  MCS7845I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.588',     'device' => 'CISCO  MCS7855I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.589',     'device' => 'CISCO  MCS7865I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.780',     'device' => 'CISCO  ME3400G12CSA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.781',     'device' => 'CISCO  ME3400G12CSD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.825',     'device' => 'CISCO  ME3400G2CSA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.788',     'device' => 'CISCO  ME492410GE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.719',     'device' => 'CISCO  MEC6524GS8S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.720',     'device' => 'CISCO  MEC6524GT8S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.285',     'device' => 'CISCO  MGMTENGINE1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.710',     'device' => 'CISCO  MPX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.954',     'device' => 'CISCO  N5KC5020PBA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.955',     'device' => 'CISCO  N5KC5020PBD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.611',     'device' => 'CISCO  NETWORKREGISTRAR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.756',     'device' => 'CISCO  NMAONAPS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.754',     'device' => 'CISCO  NMAONK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.755',     'device' => 'CISCO  NMAONWS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.622',     'device' => 'CISCO  NMCUE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.711',     'device' => 'CISCO  NMCUEEC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.663',     'device' => 'CISCO  NME16ES1GE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.906',     'device' => 'CISCO  NMEAPA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.866',     'device' => 'CISCO  NMECUE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.826',     'device' => 'CISCO  NMENAM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.664',     'device' => 'CISCO  NMEX24ES1GE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.665',     'device' => 'CISCO  NMEXD24ES2ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.666',     'device' => 'CISCO  NMEXD48ES2GE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.562',     'device' => 'CISCO  NMNAM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.823',     'device' => 'CISCO  NMWAE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.818',     'device' => 'CISCO  NMWLCE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.785',     'device' => 'CISCO  OE511K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.776',     'device' => 'CISCO  OE512K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.786',     'device' => 'CISCO  OE611K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.777',     'device' => 'CISCO  OE612K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.957',     'device' => 'CISCO  OE674'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.787',     'device' => 'CISCO  OE7326K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.907',     'device' => 'CISCO  OE7330K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.908',     'device' => 'CISCO  OE7350K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.494',     'device' => 'CISCO  ONS15327'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.493',     'device' => 'CISCO  ONS15454'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.460',     'device' => 'CISCO  ONS15530'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.462',     'device' => 'CISCO  ONS15530ETSI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.461',     'device' => 'CISCO  ONS1553ONEBS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.481',     'device' => 'CISCO  ONS15540ESPX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.406',     'device' => 'CISCO  ONS1554OESP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.518',     'device' => 'CISCO  PRIMARYGSSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.683',     'device' => 'CISCO  SCE1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.684',     'device' => 'CISCO  SCE2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.682',     'device' => 'CISCO  SCEDISPATCHER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.980',     'device' => 'CISCO  SCS1000K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.555',     'device' => 'CISCO  SIMSE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.750',     'device' => 'CISCO  SPAOC48POSSFP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.519',     'device' => 'CISCO  STANDBYGSSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.800',     'device' => 'CISCO  TSPRI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.801',     'device' => 'CISCO  TSSEC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.868',     'device' => 'CISCO  UC500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.970',     'device' => 'CISCO  UC520M24U4BRIK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.971',     'device' => 'CISCO  UC520M24U8FXOK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.888',     'device' => 'CISCO  UC520M32U4BRIK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.889',     'device' => 'CISCO  UC520M32U4BRIWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.886',     'device' => 'CISCO  UC520M32U8FXOK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.887',     'device' => 'CISCO  UC520M32U8FXOWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.890',     'device' => 'CISCO  UC520M48U12FXOK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.891',     'device' => 'CISCO  UC520M48U12FXOWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.895',     'device' => 'CISCO  UC520M48U1T1E1BK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.894',     'device' => 'CISCO  UC520M48U1T1E1FK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.892',     'device' => 'CISCO  UC520M48U6BRIK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.893',     'device' => 'CISCO  UC520M48U6BRIWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.884',     'device' => 'CISCO  UC520S16U2BRIK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.885',     'device' => 'CISCO  UC520S16U2BRIWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.972',     'device' => 'CISCO  UC520S16U2BRIWK9J'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.882',     'device' => 'CISCO  UC520S16U4FXOK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.883',     'device' => 'CISCO  UC520S16U4FXOWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.880',     'device' => 'CISCO  UC520S8U2BRIK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.881',     'device' => 'CISCO  UC520S8U2BRIWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.973',     'device' => 'CISCO  UC520S8U2BRIWK9J'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.878',     'device' => 'CISCO  UC520S8U4FXOK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.879',     'device' => 'CISCO  UC520S8U4FXOWK9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.803',     'device' => 'CISCO  UWIPPHONE7920'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.941',     'device' => 'CISCO  VFRAMEDATACENTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.279',     'device' => 'CISCO  VG200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.558',     'device' => 'CISCO  VG224'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.404',     'device' => 'CISCO  VG248'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.945',     'device' => 'CISCO  VGD1T3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.360',     'device' => 'CISCO  VPS1110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.942',     'device' => 'CISCO  VQE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.969',     'device' => 'CISCO  VQETOOLS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.977',     'device' => 'CISCO  VSDECODER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.979',     'device' => 'CISCO  VSENCODER1P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.978',     'device' => 'CISCO  VSENCODER4P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.976',     'device' => 'CISCO  VSHYDECODER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.974',     'device' => 'CISCO  VSINTSP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.975',     'device' => 'CISCO  VSSP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.757',     'device' => 'CISCO  WAE612K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.459',     'device' => 'CISCO  WLSE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.631',     'device' => 'CISCO  WLSE1030'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.630',     'device' => 'CISCO  WLSE1130'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.712',     'device' => 'CISCO  WLSE1132'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.752',     'device' => 'CISCO  WLSE1133'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.709',     'device' => 'CISCO  WLSES20'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.3',     'device' => 'CISCO  WSC1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.4',     'device' => 'CISCO  WSC1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.832',     'device' => 'CISCO  WSC6509VE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.621',     'device' => 'CISCO  WSSVCMWAM1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.599',     'device' => 'CISCO  WSSVCWLAN1K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.40',     'device' => 'CISCO 1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.437',     'device' => 'CISCO 10005'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.438',     'device' => 'CISCO 10008'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.41',     'device' => 'CISCO 1003'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.44',     'device' => 'CISCO 1004'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.49',     'device' => 'CISCO 1005'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.43',     'device' => 'CISCO 1020'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.272',     'device' => 'CISCO 10400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.397',     'device' => 'CISCO 10720'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.181',     'device' => 'CISCO 12004'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.590',     'device' => 'CISCO 12006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.182',     'device' => 'CISCO 12008'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.348',     'device' => 'CISCO 12010'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.173',     'device' => 'CISCO 12012'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.273',     'device' => 'CISCO 12016'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.423',     'device' => 'CISCO 12404'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.388',     'device' => 'CISCO 12406'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.394',     'device' => 'CISCO 12410'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.385',     'device' => 'CISCO 12416'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.206',     'device' => 'CISCO 1401'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.249',     'device' => 'CISCO 1407'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.250',     'device' => 'CISCO 1417'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.161',     'device' => 'CISCO 1502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.160',     'device' => 'CISCO 1503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.224',     'device' => 'CISCO 1538M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.225',     'device' => 'CISCO 1548M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.113',     'device' => 'CISCO 1601'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.114',     'device' => 'CISCO 1602'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.115',     'device' => 'CISCO 1603'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.116',     'device' => 'CISCO 1604'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.172',     'device' => 'CISCO 1605'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.550',     'device' => 'CISCO 1701ADSLBRI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.200',     'device' => 'CISCO 1710'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.538',     'device' => 'CISCO 1711'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.539',     'device' => 'CISCO 1712'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.201',     'device' => 'CISCO 1720'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.444',     'device' => 'CISCO 1721'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.216',     'device' => 'CISCO 1750'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.326',     'device' => 'CISCO 1751'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.416',     'device' => 'CISCO 1760'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.638',     'device' => 'CISCO 1801'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.639',     'device' => 'CISCO 1802'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.640',     'device' => 'CISCO 1803'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.641',     'device' => 'CISCO 1811'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.642',     'device' => 'CISCO 1812'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.620',     'device' => 'CISCO 1841'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.10',     'device' => 'CISCO 2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.15',     'device' => 'CISCO 2102'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.16',     'device' => 'CISCO 2202'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.13',     'device' => 'CISCO 2500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.17',     'device' => 'CISCO 2501'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.165',     'device' => 'CISCO 2501FRADFX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.166',     'device' => 'CISCO 2501LANFRADFX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.18',     'device' => 'CISCO 2502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.167',     'device' => 'CISCO 2502LANFRADFX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.19',     'device' => 'CISCO 2503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.20',     'device' => 'CISCO 2504'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.21',     'device' => 'CISCO 2505'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.22',     'device' => 'CISCO 2506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.23',     'device' => 'CISCO 2507'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.24',     'device' => 'CISCO 2508'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.25',     'device' => 'CISCO 2509'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.26',     'device' => 'CISCO 2510'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.27',     'device' => 'CISCO 2511'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.28',     'device' => 'CISCO 2512'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.29',     'device' => 'CISCO 2513'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.30',     'device' => 'CISCO 2514'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.31',     'device' => 'CISCO 2515'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.42',     'device' => 'CISCO 2516'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.67',     'device' => 'CISCO 2517'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.68',     'device' => 'CISCO 2518'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.69',     'device' => 'CISCO 2519'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.70',     'device' => 'CISCO 2520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.71',     'device' => 'CISCO 2521'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.72',     'device' => 'CISCO 2522'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.73',     'device' => 'CISCO 2523'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.74',     'device' => 'CISCO 2524'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.75',     'device' => 'CISCO 2525'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.185',     'device' => 'CISCO 2610'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.418',     'device' => 'CISCO 2610M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.466',     'device' => 'CISCO 2610XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.186',     'device' => 'CISCO 2611'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.419',     'device' => 'CISCO 2611M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.467',     'device' => 'CISCO 2611XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.187',     'device' => 'CISCO 2612'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.195',     'device' => 'CISCO 2613'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.208',     'device' => 'CISCO 2620'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.468',     'device' => 'CISCO 2620XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.209',     'device' => 'CISCO 2621'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.469',     'device' => 'CISCO 2621XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.319',     'device' => 'CISCO 2650'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.470',     'device' => 'CISCO 2650XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.320',     'device' => 'CISCO 2651'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.471',     'device' => 'CISCO 2651XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.413',     'device' => 'CISCO 2691'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.619',     'device' => 'CISCO 2801'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.576',     'device' => 'CISCO 2811'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.577',     'device' => 'CISCO 2821'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.578',     'device' => 'CISCO 2851'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.6',     'device' => 'CISCO 3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.32',     'device' => 'CISCO 3101'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.33',     'device' => 'CISCO 3102'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.34',     'device' => 'CISCO 3103'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.35',     'device' => 'CISCO 3104'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.36',     'device' => 'CISCO 3202'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.37',     'device' => 'CISCO 3204'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.553',     'device' => 'CISCO 3220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.479',     'device' => 'CISCO 3250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.122',     'device' => 'CISCO 3620'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.425',     'device' => 'CISCO 3631CO'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.110',     'device' => 'CISCO 3640'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.205',     'device' => 'CISCO 3660'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.338',     'device' => 'CISCO 3661AC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.339',     'device' => 'CISCO 3661DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.340',     'device' => 'CISCO 3662AC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.342',     'device' => 'CISCO 3662ACCO'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.341',     'device' => 'CISCO 3662DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.343',     'device' => 'CISCO 3662DCCO'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.625',     'device' => 'CISCO 371098-HP001'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.33.3.1.1',     'device' => 'HEWLETT PACKARD CISCO371098-HP001'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.414',     'device' => 'CISCO 3725'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.436',     'device' => 'CISCO 3745'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.543',     'device' => 'CISCO 3825'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.544',     'device' => 'CISCO 3845'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.7',     'device' => 'CISCO 4000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.399',     'device' => 'CISCO 4224'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.14',     'device' => 'CISCO 4500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.50',     'device' => 'CISCO 4700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.299',     'device' => 'CISCO 6015'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.251',     'device' => 'CISCO 6100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.252',     'device' => 'CISCO 6130'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.297',     'device' => 'CISCO 6160'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.192',     'device' => 'CISCO 6200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.253',     'device' => 'CISCO 6260'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.180',     'device' => 'CISCO 6400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.211',     'device' => 'CISCO 6400NRP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.464',     'device' => 'CISCO 6400UAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.363',     'device' => 'CISCO 677I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.8',     'device' => 'CISCO 7000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.12',     'device' => 'CISCO 7010'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.263',     'device' => 'CISCO 7120AE3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.262',     'device' => 'CISCO 7120AT3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.261',     'device' => 'CISCO 7120E3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.259',     'device' => 'CISCO 7120QUADT1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.264',     'device' => 'CISCO 7120SMI3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.260',     'device' => 'CISCO 7120T3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.268',     'device' => 'CISCO 7140DUALAE3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.267',     'device' => 'CISCO 7140DUALAT3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.266',     'device' => 'CISCO 7140DUALE3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.277',     'device' => 'CISCO 7140DUALFE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.269',     'device' => 'CISCO 7140DUALMM3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.265',     'device' => 'CISCO 7140DUALT3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.276',     'device' => 'CISCO 7140OCTT1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.355',     'device' => 'CISCO 7150DUALFE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.357',     'device' => 'CISCO 7150DUALT3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.356',     'device' => 'CISCO 7150OCTT1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.194',     'device' => 'CISCO 7202'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.125',     'device' => 'CISCO 7204'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.223',     'device' => 'CISCO 7204VXR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.108',     'device' => 'CISCO 7206'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.222',     'device' => 'CISCO 7206VXR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.476',     'device' => 'CISCO 7301'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.439',     'device' => 'CISCO 7304'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.403',     'device' => 'CISCO 7401ASR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.376',     'device' => 'CISCO 7401VXR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.94',     'device' => 'CISCO 741'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.95',     'device' => 'CISCO 742'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.96',     'device' => 'CISCO 743'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.97',     'device' => 'CISCO 744'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.48',     'device' => 'CISCO 7505'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.47',     'device' => 'CISCO 7506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.45',     'device' => 'CISCO 7507'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.290',     'device' => 'CISCO 7507MX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.288',     'device' => 'CISCO 7507Z'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.81',     'device' => 'CISCO 751'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.46',     'device' => 'CISCO 7513'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.291',     'device' => 'CISCO 7513MX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.289',     'device' => 'CISCO 7513Z'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.82',     'device' => 'CISCO 752'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.83',     'device' => 'CISCO 753'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.204',     'device' => 'CISCO 7576'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.401',     'device' => 'CISCO 7603'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.658',     'device' => 'CISCO 7604'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.402',     'device' => 'CISCO 7606'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.509',     'device' => 'CISCO 7609'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.98',     'device' => 'CISCO 761'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.528',     'device' => 'CISCO 7613'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.99',     'device' => 'CISCO 762'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.102',     'device' => 'CISCO 765'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.103',     'device' => 'CISCO 766'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.126',     'device' => 'CISCO 771'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.127',     'device' => 'CISCO 772'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.128',     'device' => 'CISCO 775'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.129',     'device' => 'CISCO 776'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.212',     'device' => 'CISCO 801'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.213',     'device' => 'CISCO 802'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.295',     'device' => 'CISCO 802J'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.214',     'device' => 'CISCO 803'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.215',     'device' => 'CISCO 804'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.296',     'device' => 'CISCO 804J'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.245',     'device' => 'CISCO 805'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.384',     'device' => 'CISCO 806'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.395',     'device' => 'CISCO 811'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.396',     'device' => 'CISCO 813'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.322',     'device' => 'CISCO 826'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.321',     'device' => 'CISCO 826QUADV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.284',     'device' => 'CISCO 827'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.446',     'device' => 'CISCO 827H'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.270',     'device' => 'CISCO 827QUADV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.382',     'device' => 'CISCO 828'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.497',     'device' => 'CISCO 831'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.499',     'device' => 'CISCO 836'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.495',     'device' => 'CISCO 837'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.571',     'device' => 'CISCO 871'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.569',     'device' => 'CISCO 877'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.570',     'device' => 'CISCO 878'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.424',     'device' => 'CISCO 9004'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.11',     'device' => 'CISCO AGS+'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.39',     'device' => 'CISCO APEC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.38',     'device' => 'CISCO APRC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.153',     'device' => 'CISCO AS2509RJ'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.154',     'device' => 'CISCO AS2511RJ'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.109',     'device' => 'CISCO AS5200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.162',     'device' => 'CISCO AS5300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.313',     'device' => 'CISCO AS5350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.679',     'device' => 'CISCO AS5350XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.274',     'device' => 'CISCO AS5400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.668',     'device' => 'CISCO AS5400XM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.188',     'device' => 'CISCO AS5800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.308',     'device' => 'CISCO AS5850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.237',     'device' => 'CISCO BPX8620'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.238',     'device' => 'CISCO BPX8650'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.239',     'device' => 'CISCO BPX8680'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.242',     'device' => 'CISCO BPXSES'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.240',     'device' => 'CISCO CACHEENGINE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.613',     'device' => 'CISCO CRS16S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.738',     'device' => 'CISCO CRS18LINECARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.739',     'device' => 'CISCO CRS1FABRIC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.643',     'device' => 'CISCO CRS8S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.9',     'device' => 'CISCO CS500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.521',     'device' => 'CISCO DSC9216K9'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.169',     'device' => 'CISCO FASTHUB216T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.178',     'device' => 'CISCO FASTHUBBMMFX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.177',     'device' => 'CISCO FASTHUBBMMTX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.1',     'device' => 'CISCO GS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.592',     'device' => 'CISCO IGESM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.5',     'device' => 'CISCO IGS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.232',     'device' => 'CISCO IGX8410'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.233',     'device' => 'CISCO IGX8420'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.234',     'device' => 'CISCO IGX8430'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.235',     'device' => 'CISCO IGX8450'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.243',     'device' => 'CISCO IGXSES'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.244',     'device' => 'CISCO LOCALDIRECTOR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.713',     'device' => 'CISCO ME6340ACA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.714',     'device' => 'CISCO ME6340DCA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.715',     'device' => 'CISCO ME6340DCB'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.176',     'device' => 'CISCO MICROWEBSERVER2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.398',     'device' => 'CISCO MWR1900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.520',     'device' => 'CISCO MWR1941DC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.358',     'device' => 'CISCO OLYMPUS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.254',     'device' => 'CISCO OPTICALREGENERATOR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.51',     'device' => 'CISCO PRO1003'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.52',     'device' => 'CISCO PRO1004'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.53',     'device' => 'CISCO PRO1005'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.54',     'device' => 'CISCO PRO1020'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.117',     'device' => 'CISCO PRO1601'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.118',     'device' => 'CISCO PRO1602'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.119',     'device' => 'CISCO PRO1603'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.120',     'device' => 'CISCO PRO1604'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.55',     'device' => 'CISCO PRO2500PCE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.56',     'device' => 'CISCO PRO2501'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.130',     'device' => 'CISCO PRO2502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.57',     'device' => 'CISCO PRO2503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.131',     'device' => 'CISCO PRO2504'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.58',     'device' => 'CISCO PRO2505'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.132',     'device' => 'CISCO PRO2506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.59',     'device' => 'CISCO PRO2507'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.133',     'device' => 'CISCO PRO2508'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.60',     'device' => 'CISCO PRO2509'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.134',     'device' => 'CISCO PRO2510'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.61',     'device' => 'CISCO PRO2511'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.135',     'device' => 'CISCO PRO2512'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.136',     'device' => 'CISCO PRO2513'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.62',     'device' => 'CISCO PRO2514'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.137',     'device' => 'CISCO PRO2515'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.63',     'device' => 'CISCO PRO2516'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.138',     'device' => 'CISCO PRO2517'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.139',     'device' => 'CISCO PRO2518'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.64',     'device' => 'CISCO PRO2519'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.104',     'device' => 'CISCO PRO2520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.65',     'device' => 'CISCO PRO2521'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.105',     'device' => 'CISCO PRO2522'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.140',     'device' => 'CISCO PRO2523'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.106',     'device' => 'CISCO PRO2524'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.141',     'device' => 'CISCO PRO2525'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.149',     'device' => 'CISCO PRO3116'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.148',     'device' => 'CISCO PRO316C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.147',     'device' => 'CISCO PRO316T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.123',     'device' => 'CISCO PRO3620'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.124',     'device' => 'CISCO PRO3640'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.66',     'device' => 'CISCO PRO4500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.142',     'device' => 'CISCO PRO4700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.84',     'device' => 'CISCO PRO741'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.85',     'device' => 'CISCO PRO742'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.86',     'device' => 'CISCO PRO743'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.87',     'device' => 'CISCO PRO744'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.76',     'device' => 'CISCO PRO751'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.77',     'device' => 'CISCO PRO752'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.78',     'device' => 'CISCO PRO753'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.88',     'device' => 'CISCO PRO761'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.89',     'device' => 'CISCO PRO762'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.92',     'device' => 'CISCO PRO765'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.93',     'device' => 'CISCO PRO766'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.4',     'device' => 'CISCO PROTOCOLTRANSLATOR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.199',     'device' => 'CISCO RPM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.457',     'device' => 'CISCO RPMPR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.440',     'device' => 'CISCO RPMXF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.189',     'device' => 'CISCO SC3640'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.407',     'device' => 'CISCO SN5420'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.475',     'device' => 'CISCO SN5428'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.354',     'device' => 'CISCO SOHO76'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.353',     'device' => 'CISCO SOHO77'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.498',     'device' => 'CISCO SOHO91'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.500',     'device' => 'CISCO SOHO96'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.496',     'device' => 'CISCO SOHO97'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.3',     'device' => 'CISCO TROUTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.2',     'device' => 'CISCO TS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.373',     'device' => 'CISCO URM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.374',     'device' => 'CISCO URM2FE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.375',     'device' => 'CISCO URM2FE2V'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.748',     'device' => 'CISCO WS3020HPQ'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.749',     'device' => 'CISCO WS3030DEL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.747',     'device' => 'CISCO WSC3750G-24PS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.657',     'device' => 'CISCO WSC6504E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.64',     'device' => 'CISCO WSC6504E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.534',     'device' => 'CISCO WSC6509NEBA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.112',     'device' => 'CISCO WSX3011'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.168',     'device' => 'CISCO WSX5302'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.256',     'device' => 'CISCO WSX6302MSM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.789.2.3',     'device' => 'NETWORK APPLIANCE CORPORATION CLUSTEREDFILER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.7737.5.2.2.6',     'device' => 'CIENA CN 4200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1424.1.1',     'device' => 'PERFORMANCE TECHNOLOGY, INC. CONTIVITY100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.3',     'device' => 'NORTEL CONTIVITY1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1010',     'device' => 'NORTEL CONTIVITY1010'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1050',     'device' => 'NORTEL CONTIVITY1050'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1100',     'device' => 'NORTEL CONTIVITY1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.5',     'device' => 'NORTEL CONTIVITY15XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.7',     'device' => 'NORTEL CONTIVITY1600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1700',     'device' => 'NORTEL CONTIVITY1700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1740',     'device' => 'NORTEL CONTIVITY17XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.12',     'device' => 'NORTEL CONTIVITY1XXX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.2',     'device' => 'NORTEL CONTIVITY2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.6',     'device' => 'NORTEL CONTIVITY2500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.8',     'device' => 'NORTEL CONTIVITY2600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.2700',     'device' => 'NORTEL CONTIVITY2700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.1',     'device' => 'NORTEL CONTIVITY4000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.4',     'device' => 'NORTEL CONTIVITY4500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.9',     'device' => 'NORTEL CONTIVITY4600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.5000',     'device' => 'NORTEL CONTIVITY5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.10',     'device' => 'NORTEL CONTIVITY600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.600',     'device' => 'NORTEL CONTIVITY600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2505.13',     'device' => 'NORTEL CONTIVITYX700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.232.134.1.3',     'device' => 'COMPAQ CPQ-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.232.134.1.1',     'device' => 'COMPAQ CPQ-8000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.232.134.1.2',     'device' => 'COMPAQ CPQ-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.25',     'device' => 'CISCO CPW1601'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.16',     'device' => 'CISCO CPW1900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.1',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-4100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.2',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-4200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.3',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-4250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.4',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-8200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.5',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-8400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.2.6',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM APM-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.2',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.6',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.4',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.7',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.1',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C30'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.3',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C30I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.3.1.5',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.2.1.2',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM C80 CHASSIS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.1.1',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM CPM-4100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.1.2',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM CPM-8100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.1.3',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM CPM-8400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.1.4',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM CPM-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.3.1',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM NPM-4100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.3.2',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM NPM-4110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.3.3',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM NPM-8200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.3.4',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM NPM-8210'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.1.2.3.5',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM NPM-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6848.1.2.1.1',     'device' => 'CROSSBEAM SYSTEMS, INC. CROSSBEAM X45 CHASSIS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.562.3.21',     'device' => 'NORTEL CS 1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3493.4.1.3.0.1',     'device' => 'BROADBAND ACCESS SYSTEMS, INC. CUDA 12000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.30.3',     'device' => 'ENTERASYS DEC-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.30.1',     'device' => 'ENTERASYS DEC-8000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.30.2',     'device' => 'ENTERASYS DEC-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.33',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS DELL BLADE CENTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.7',     'device' => 'ENTERASYS DLE02'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.2',     'device' => 'ENTERASYS DLE22'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.5',     'device' => 'ENTERASYS DLE32'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.10',     'device' => 'ENTERASYS DLE49'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.8',     'device' => 'ENTERASYS DLE52'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.28.9',     'device' => 'ENTERASYS DLEHF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.71',     'device' => 'ENTERASYS DRAGON IDS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.141',     'device' => 'ADTRAN DSU IQ'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.125',     'device' => 'ADTRAN DSU IV ESP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6213',     'device' => 'JUNIPER NETWORKS DX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.6.2',     'device' => 'JUNIPER E120'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.1.1',     'device' => 'FORCE10 NETWORKS, INC. E1200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.1.3',     'device' => 'FORCE10 NETWORKS, INC. E300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.6.1',     'device' => 'JUNIPER E320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.1.2',     'device' => 'FORCE10 NETWORKS, INC. E600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.1.4',     'device' => 'FORCE10 NETWORKS, INC. E610'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.5851.0',     'device' => 'FLOWPOINT CORPORATION EF5851DSLRTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.5861.0',     'device' => 'FLOWPOINT CORPORATION EF5861DSLRTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.5865.0',     'device' => 'FLOWPOINT CORPORATION EF5865DSLRTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.5871.0',     'device' => 'FLOWPOINT CORPORATION EF5871DSLRTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.5950.0',     'device' => 'FLOWPOINT CORPORATION EF5950DSLRTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.97.5.9',     'device' => 'NORTEL ELS10-27TX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.1.10.7',     'device' => 'ENTERASYS ELS100-24TX2M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.289',     'device' => 'MCDATA CORPORATION EMC CONNECTRIXSWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.23',     'device' => 'EXTREME NETWORKS ENETSWITCH24PORT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.23',     'device' => 'ENTERASYS ER16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.1.1',     'device' => 'JUNIPER ERX1400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.1.3',     'device' => 'JUNIPER ERX1440'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.1.5',     'device' => 'JUNIPER ERX310'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.1.2',     'device' => 'JUNIPER ERX700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4874.1.1.1.1.4',     'device' => 'JUNIPER ERX705'     ),

      array(
         'oid' => '.1.3.6.1.4.1.7393.1.2',     'device' => 'OASYS TELECOM, INC. EXCHANGEMUXII'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3375.1.1',     'device' => 'F5 NETWORKS F5LOADBLNCR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.8.2',     'device' => 'FOUNDRY NETWORKS FASTIRON2RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.8.1',     'device' => 'FOUNDRY NETWORKS FASTIRON2SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.16.2',     'device' => 'FOUNDRY NETWORKS FASTIRON3RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.16.1',     'device' => 'FOUNDRY NETWORKS FASTIRON3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.1.2',     'device' => 'FOUNDRY NETWORKS FASTIRONBBSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.1.1',     'device' => 'FOUNDRY NETWORKS FASTIRONWGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.28.2',     'device' => 'FOUNDRY NETWORKS FES12GCFRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.28.1',     'device' => 'FOUNDRY NETWORKS FES12GCFSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.29.2',     'device' => 'FOUNDRY NETWORKS FES2402POERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.29.1',     'device' => 'FOUNDRY NETWORKS FES2402POESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.25.2',     'device' => 'FOUNDRY NETWORKS FES2402RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.25.1',     'device' => 'FOUNDRY NETWORKS FES2402SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.30.2',     'device' => 'FOUNDRY NETWORKS FES4802POERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.30.1',     'device' => 'FOUNDRY NETWORKS FES4802POESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.26.2',     'device' => 'FOUNDRY NETWORKS FES4802RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.26.1',     'device' => 'FOUNDRY NETWORKS FES4802SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.27.2',     'device' => 'FOUNDRY NETWORKS FES9604RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.27.1',     'device' => 'FOUNDRY NETWORKS FES9604SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.2.2.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP1XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.2.2.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP1XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.2.1.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.2.1.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.3.2.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP2XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.3.2.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP2XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.3.1.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.3.1.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERP2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.1.2.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.1.2.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.1.1.2',     'device' => 'FOUNDRY NETWORKS FESX424FIBERRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.3.1.1.1',     'device' => 'FOUNDRY NETWORKS FESX424FIBERSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.2.2.2',     'device' => 'FOUNDRY NETWORKS FESX424P1XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.2.2.1',     'device' => 'FOUNDRY NETWORKS FESX424P1XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.2.1.2',     'device' => 'FOUNDRY NETWORKS FESX424P1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.2.1.1',     'device' => 'FOUNDRY NETWORKS FESX424P1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.3.2.2',     'device' => 'FOUNDRY NETWORKS FESX424P2XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.3.2.1',     'device' => 'FOUNDRY NETWORKS FESX424P2XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.3.1.2',     'device' => 'FOUNDRY NETWORKS FESX424P2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.3.1.1',     'device' => 'FOUNDRY NETWORKS FESX424P2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.2.2.2',     'device' => 'FOUNDRY NETWORKS FESX424POEP1XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.2.2.1',     'device' => 'FOUNDRY NETWORKS FESX424POEP1XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.2.1.2',     'device' => 'FOUNDRY NETWORKS FESX424POEP1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.2.1.1',     'device' => 'FOUNDRY NETWORKS FESX424POEP1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.3.2.2',     'device' => 'FOUNDRY NETWORKS FESX424POEP2XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.3.2.1',     'device' => 'FOUNDRY NETWORKS FESX424POEP2XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.3.1.2',     'device' => 'FOUNDRY NETWORKS FESX424POEP2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.3.1.1',     'device' => 'FOUNDRY NETWORKS FESX424POEP2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.1.2.2',     'device' => 'FOUNDRY NETWORKS FESX424POEPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.1.2.1',     'device' => 'FOUNDRY NETWORKS FESX424POEPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.1.1.2',     'device' => 'FOUNDRY NETWORKS FESX424POERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.5.1.1.1',     'device' => 'FOUNDRY NETWORKS FESX424POESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.1.2.2',     'device' => 'FOUNDRY NETWORKS FESX424PREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.1.2.1',     'device' => 'FOUNDRY NETWORKS FESX424PREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.1.1.2',     'device' => 'FOUNDRY NETWORKS FESX424RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.1.1.1.1',     'device' => 'FOUNDRY NETWORKS FESX424SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.2.2.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP1XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.2.2.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP1XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.2.1.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.2.1.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.3.2.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP2XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.3.2.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP2XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.3.1.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.3.1.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERP2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.1.2.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.1.2.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.1.1.2',     'device' => 'FOUNDRY NETWORKS FESX448FIBERRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.4.1.1.1',     'device' => 'FOUNDRY NETWORKS FESX448FIBERSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.2.2.2',     'device' => 'FOUNDRY NETWORKS FESX448P1XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.2.2.1',     'device' => 'FOUNDRY NETWORKS FESX448P1XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.2.1.2',     'device' => 'FOUNDRY NETWORKS FESX448P1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.2.1.1',     'device' => 'FOUNDRY NETWORKS FESX448P1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.3.2.2',     'device' => 'FOUNDRY NETWORKS FESX448P2XGPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.3.2.1',     'device' => 'FOUNDRY NETWORKS FESX448P2XGPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.3.1.2',     'device' => 'FOUNDRY NETWORKS FESX448P2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.3.1.1',     'device' => 'FOUNDRY NETWORKS FESX448P2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.1.2.2',     'device' => 'FOUNDRY NETWORKS FESX448PREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.1.2.1',     'device' => 'FOUNDRY NETWORKS FESX448PREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.1.1.2',     'device' => 'FOUNDRY NETWORKS FESX448RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.34.2.1.1.1',     'device' => 'FOUNDRY NETWORKS FESX448SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.3.1.2',     'device' => 'FOUNDRY NETWORKS FGS624PPOERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.3.1.1',     'device' => 'FOUNDRY NETWORKS FGS624PPOESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.1.1.2',     'device' => 'FOUNDRY NETWORKS FGS624PRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.1.1.1',     'device' => 'FOUNDRY NETWORKS FGS624PSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.4.1.2',     'device' => 'FOUNDRY NETWORKS FGS624XGPPOERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.4.1.1',     'device' => 'FOUNDRY NETWORKS FGS624XGPPOESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.2.1.2',     'device' => 'FOUNDRY NETWORKS FGS624XGPRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.1.2.1.1',     'device' => 'FOUNDRY NETWORKS FGS624XGPSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.2.2.1.2',     'device' => 'FOUNDRY NETWORKS FGS648PPOERT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.2.2.1.1',     'device' => 'FOUNDRY NETWORKS FGS648PPOESW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.2.1.1.2',     'device' => 'FOUNDRY NETWORKS FGS648PRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.45.2.1.1.1',     'device' => 'FOUNDRY NETWORKS FGS648PSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.13.2',     'device' => 'FOUNDRY NETWORKS FI2PLUSGCRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.13.1',     'device' => 'FOUNDRY NETWORKS FI2PLUSGCSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.789.2.1',     'device' => 'NETWORK APPLIANCE CORPORATION FILER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.24.2',     'device' => 'FOUNDRY NETWORKS FIRON1500RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.24.1',     'device' => 'FOUNDRY NETWORKS FIRON1500SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.12.2',     'device' => 'FOUNDRY NETWORKS FIRON2GCRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.12.1',     'device' => 'FOUNDRY NETWORKS FIRON2GCSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.9.2',     'device' => 'FOUNDRY NETWORKS FIRON2PLUSRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.9.1',     'device' => 'FOUNDRY NETWORKS FIRON2PLUSSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.17.2',     'device' => 'FOUNDRY NETWORKS FIRON3GCRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.17.1',     'device' => 'FOUNDRY NETWORKS FIRON3GCSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.22.2',     'device' => 'FOUNDRY NETWORKS FIRON400RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.22.1',     'device' => 'FOUNDRY NETWORKS FIRON400SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.21.2',     'device' => 'FOUNDRY NETWORKS FIRON4802RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.21.3',     'device' => 'FOUNDRY NETWORKS FIRON4802SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.21.1',     'device' => 'FOUNDRY NETWORKS FIRON4802SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.23.2',     'device' => 'FOUNDRY NETWORKS FIRON800RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.23.1',     'device' => 'FOUNDRY NETWORKS FIRON800SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.5.3',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600BASEL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.6.3',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600PREMBASEL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.6.2',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600PREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.6.1',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600PREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.5.2',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.5.1',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX1600SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.3.3',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800BASEL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.4.3',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800PREMBASEL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.4.2',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800PREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.4.1',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800PREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.3.2',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.3.1',     'device' => 'FOUNDRY NETWORKS FIRONSUPERX800SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.1.3',     'device' => 'FOUNDRY NETWORKS FIRONSXL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.2.3',     'device' => 'FOUNDRY NETWORKS FIRONSXPREML3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.2.2',     'device' => 'FOUNDRY NETWORKS FIRONSXPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.2.1',     'device' => 'FOUNDRY NETWORKS FIRONSXPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.1.2',     'device' => 'FOUNDRY NETWORKS FIRONSXRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.36.1.1',     'device' => 'FOUNDRY NETWORKS FIRONSXSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.46.1.1.1.2',     'device' => 'FOUNDRY NETWORKS FLS624RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.46.1.1.1.1',     'device' => 'FOUNDRY NETWORKS FLS624SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.46.2.1.1.2',     'device' => 'FOUNDRY NETWORKS FLS648RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.46.2.1.1.1',     'device' => 'FOUNDRY NETWORKS FLS648SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.110.0',     'device' => 'FLOWPOINT CORPORATION FP128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.112.0',     'device' => 'FLOWPOINT CORPORATION FP128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.114.0',     'device' => 'FLOWPOINT CORPORATION FP128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.121.0',     'device' => 'FLOWPOINT CORPORATION FP128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.123.0',     'device' => 'FLOWPOINT CORPORATION FP128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.134.0',     'device' => 'FLOWPOINT CORPORATION FP144'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2025.0',     'device' => 'FLOWPOINT CORPORATION FP2025'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2000.0',     'device' => 'FLOWPOINT CORPORATION FP2100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2201.0',     'device' => 'FLOWPOINT CORPORATION FP2200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2202.0',     'device' => 'FLOWPOINT CORPORATION FP2200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2210.0',     'device' => 'FLOWPOINT CORPORATION FP2200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.2250.0',     'device' => 'FLOWPOINT CORPORATION FP2200V'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.2',     'device' => 'PARADYNE FR-2SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.1',     'device' => 'PARADYNE FR-9620'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.7',     'device' => 'PARADYNE FR-9623'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.5',     'device' => 'PARADYNE FR-9624'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.8',     'device' => 'PARADYNE FR-9624-OS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.6',     'device' => 'PARADYNE FR-9626'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.4',     'device' => 'PARADYNE FR-NAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.1.3',     'device' => 'PARADYNE FR-NAF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.2.1.2',     'device' => 'FOUNDRY NETWORKS FWSX424P1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.2.1.1',     'device' => 'FOUNDRY NETWORKS FWSX424P1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.3.1.2',     'device' => 'FOUNDRY NETWORKS FWSX424P2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.3.1.1',     'device' => 'FOUNDRY NETWORKS FWSX424P2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.1.1.2',     'device' => 'FOUNDRY NETWORKS FWSX424RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.1.1.1.1',     'device' => 'FOUNDRY NETWORKS FWSX424SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.2.1.2',     'device' => 'FOUNDRY NETWORKS FWSX448P1XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.2.1.1',     'device' => 'FOUNDRY NETWORKS FWSX448P1XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.3.1.2',     'device' => 'FOUNDRY NETWORKS FWSX448P2XGRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.3.1.1',     'device' => 'FOUNDRY NETWORKS FWSX448P2XGSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.1.1.2',     'device' => 'FOUNDRY NETWORKS FWSX448RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.35.2.1.1.1',     'device' => 'FOUNDRY NETWORKS FWSX448SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2879.1.1.1',     'device' => 'SONUS NETWORKS GSX9000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2879.1.1.2',     'device' => 'SONUS NETWORKS GSX9000HD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.290.7.1.1.1.1',     'device' => 'HARRIS HARRIS SCM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.32',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS HP 4100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.29',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS HP BLADE CENTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.6.9.1.1',     'device' => 'HEWLETT PACKARD HP FASTELANPROBE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.11',     'device' => 'HEWLETT PACKARD HP PROCURVE2424M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.18',     'device' => 'HEWLETT PACKARD HP PROCURVE2512'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.19',     'device' => 'HEWLETT PACKARD HP PROCURVE2524'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.29',     'device' => 'HEWLETT PACKARD HP PROCURVE2650A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.44',     'device' => 'HEWLETT PACKARD HP PROCURVE2650B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.31',     'device' => 'HEWLETT PACKARD HP PROCURVE2824'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.32',     'device' => 'HEWLETT PACKARD HP PROCURVE2848'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.27',     'device' => 'HEWLETT PACKARD HP PROCURVE4104GL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.11.2.3.7.11.23',     'device' => 'HEWLETT PACKARD HP PROCURVE4108GL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.17',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS HP STORAGEWORKS 2/16-EL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.18',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS HP STORAGEWORKS 2/8'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.64',     'device' => 'HUAWEI HUAWEI AR18-10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.11812',     'device' => 'HUAWEI HUAWEI AR18-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.11813',     'device' => 'HUAWEI HUAWEI AR18-13'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.50',     'device' => 'HUAWEI HUAWEI AR18-13V'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.11815',     'device' => 'HUAWEI HUAWEI AR18-15'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.11816',     'device' => 'HUAWEI HUAWEI AR18-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.55',     'device' => 'HUAWEI HUAWEI AR18-18'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.51',     'device' => 'HUAWEI HUAWEI AR18-18V'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.56',     'device' => 'HUAWEI HUAWEI AR18-20'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.53',     'device' => 'HUAWEI HUAWEI AR18-20S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.65',     'device' => 'HUAWEI HUAWEI AR18-21'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.66',     'device' => 'HUAWEI HUAWEI AR18-21A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.67',     'device' => 'HUAWEI HUAWEI AR18-21B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.68',     'device' => 'HUAWEI HUAWEI AR18-21C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.69',     'device' => 'HUAWEI HUAWEI AR18-22'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.71',     'device' => 'HUAWEI HUAWEI AR18-22-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.70',     'device' => 'HUAWEI HUAWEI AR18-22-8'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.91',     'device' => 'HUAWEI HUAWEI AR18-22S-8'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.72',     'device' => 'HUAWEI HUAWEI AR18-23-1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.92',     'device' => 'HUAWEI HUAWEI AR18-23S-1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.57',     'device' => 'HUAWEI HUAWEI AR18-30'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.73',     'device' => 'HUAWEI HUAWEI AR18-30E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.58',     'device' => 'HUAWEI HUAWEI AR18-31'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.74',     'device' => 'HUAWEI HUAWEI AR18-31E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.59',     'device' => 'HUAWEI HUAWEI AR18-32'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.75',     'device' => 'HUAWEI HUAWEI AR18-32E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.60',     'device' => 'HUAWEI HUAWEI AR18-33'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.20',     'device' => 'HUAWEI HUAWEI AR18-33E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.61',     'device' => 'HUAWEI HUAWEI AR18-34'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.21',     'device' => 'HUAWEI HUAWEI AR18-34E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.6',     'device' => 'HUAWEI HUAWEI AR18-35'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.76',     'device' => 'HUAWEI HUAWEI AR18-35E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.77',     'device' => 'HUAWEI HUAWEI AR18-36E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.78',     'device' => 'HUAWEI HUAWEI AR18-37E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.19',     'device' => 'HUAWEI HUAWEI AR18-50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.79',     'device' => 'HUAWEI HUAWEI AR18-52'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.138',     'device' => 'HUAWEI HUAWEI AR19-61'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.139',     'device' => 'HUAWEI HUAWEI AR19-62'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12809',     'device' => 'HUAWEI HUAWEI AR28-09'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.1761',     'device' => 'HUAWEI HUAWEI AR28-09B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12810',     'device' => 'HUAWEI HUAWEI AR28-10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12811',     'device' => 'HUAWEI HUAWEI AR28-11'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.61',     'device' => 'HUAWEI HUAWEI AR28-12'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.112',     'device' => 'HUAWEI HUAWEI AR28-12B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.62',     'device' => 'HUAWEI HUAWEI AR28-13'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.63',     'device' => 'HUAWEI HUAWEI AR28-14'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12830',     'device' => 'HUAWEI HUAWEI AR28-30'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12831',     'device' => 'HUAWEI HUAWEI AR28-31'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12840',     'device' => 'HUAWEI HUAWEI AR28-40'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.1.1.1.12880',     'device' => 'HUAWEI HUAWEI AR28-80'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.140',     'device' => 'HUAWEI HUAWEI AR29-01'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.141',     'device' => 'HUAWEI HUAWEI AR29-21'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.142',     'device' => 'HUAWEI HUAWEI AR29-41'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.143',     'device' => 'HUAWEI HUAWEI AR29-61'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.44',     'device' => 'HUAWEI HUAWEI AR46-20'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.88',     'device' => 'HUAWEI HUAWEI AR46-20E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.45',     'device' => 'HUAWEI HUAWEI AR46-40'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.89',     'device' => 'HUAWEI HUAWEI AR46-40E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.46',     'device' => 'HUAWEI HUAWEI AR46-80'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.90',     'device' => 'HUAWEI HUAWEI AR46-80E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.144',     'device' => 'HUAWEI HUAWEI AR49-45'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.145',     'device' => 'HUAWEI HUAWEI AR49-65'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.51',     'device' => 'HUAWEI HUAWEI E1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.88.2',     'device' => 'HUAWEI HUAWEI NE20E-8'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.62.2.5',     'device' => 'HUAWEI HUAWEI NE40E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.62.2.3',     'device' => 'HUAWEI HUAWEI NE5000E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.62.2.2',     'device' => 'HUAWEI HUAWEI NE80E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.109',     'device' => 'HUAWEI HUAWEI S3108C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.106',     'device' => 'HUAWEI HUAWEI S3108T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.110',     'device' => 'HUAWEI HUAWEI S3116C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.107',     'device' => 'HUAWEI HUAWEI S3116T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.111',     'device' => 'HUAWEI HUAWEI S3126C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.108',     'device' => 'HUAWEI HUAWEI S3126T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.158',     'device' => 'HUAWEI HUAWEI S3126TP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.101',     'device' => 'HUAWEI HUAWEI S3224P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.102',     'device' => 'HUAWEI HUAWEI S3226T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.105',     'device' => 'HUAWEI HUAWEI S3250P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.104',     'device' => 'HUAWEI HUAWEI S3250T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.41',     'device' => 'HUAWEI HUAWEI S3526C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.45',     'device' => 'HUAWEI HUAWEI S3526C-24-12FM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.44',     'device' => 'HUAWEI HUAWEI S3526C-24-12FS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.21',     'device' => 'HUAWEI HUAWEI S3526E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.27',     'device' => 'HUAWEI HUAWEI S3526E-FM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.28',     'device' => 'HUAWEI HUAWEI S3526E-FS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.39',     'device' => 'HUAWEI HUAWEI S3528G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.40',     'device' => 'HUAWEI HUAWEI S3528P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.68',     'device' => 'HUAWEI HUAWEI S3552F-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.7',     'device' => 'HUAWEI HUAWEI S3552F-HI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.67',     'device' => 'HUAWEI HUAWEI S3552F-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.37',     'device' => 'HUAWEI HUAWEI S3552G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.38',     'device' => 'HUAWEI HUAWEI S3552P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.9',     'device' => 'HUAWEI HUAWEI S3924-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.17',     'device' => 'HUAWEI HUAWEI S3928F-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.119',     'device' => 'HUAWEI HUAWEI S3928F-V6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.13',     'device' => 'HUAWEI HUAWEI S3928P-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.15',     'device' => 'HUAWEI HUAWEI S3928P-PWR-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.161',     'device' => 'HUAWEI HUAWEI S3928P-PWR-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.10',     'device' => 'HUAWEI HUAWEI S3928P-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.117',     'device' => 'HUAWEI HUAWEI S3928P-V6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.12',     'device' => 'HUAWEI HUAWEI S3928TP-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.116',     'device' => 'HUAWEI HUAWEI S3928TP-V6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.14',     'device' => 'HUAWEI HUAWEI S3952P-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.16',     'device' => 'HUAWEI HUAWEI S3952P-PWR-EI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.11',     'device' => 'HUAWEI HUAWEI S3952P-SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.118',     'device' => 'HUAWEI HUAWEI S3952P-V6'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.18',     'device' => 'HUAWEI HUAWEI S5600M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.100',     'device' => 'HUAWEI HUAWEI S5624F'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.43',     'device' => 'HUAWEI HUAWEI S5624P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.44',     'device' => 'HUAWEI HUAWEI S5624P-PWR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.45',     'device' => 'HUAWEI HUAWEI S5648P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.46',     'device' => 'HUAWEI HUAWEI S5648P-PWR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.80',     'device' => 'HUAWEI HUAWEI S6502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.174',     'device' => 'HUAWEI HUAWEI S6502ME'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.30',     'device' => 'HUAWEI HUAWEI S6503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.19',     'device' => 'HUAWEI HUAWEI S6506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.33',     'device' => 'HUAWEI HUAWEI S6506R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.25506.1.52',     'device' => 'HUAWEI 3COM HUAWEI S7502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.25506.1.176',     'device' => 'HUAWEI 3COM HUAWEI S7502M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.25506.1.53',     'device' => 'HUAWEI 3COM HUAWEI S7503'     ),

      array(
         'oid' => '.1.3.6.1.4.1.25506.1.54',     'device' => 'HUAWEI 3COM HUAWEI S7506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.25506.1.55',     'device' => 'HUAWEI 3COM HUAWEI S7506R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.163',     'device' => 'HUAWEI HUAWEI S8502'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.32',     'device' => 'HUAWEI HUAWEI S8505'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.22',     'device' => 'HUAWEI HUAWEI S8508'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.10.1.156',     'device' => 'HUAWEI HUAWEI S8508V'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2011.2.23.31',     'device' => 'HUAWEI HUAWEI S8512'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.1',     'device' => '3COM HUB3COMLS1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.2',     'device' => '3COM HUB3COMLS3300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.10.27.4.1.2.3',     'device' => '3COM HUB3COMLS3400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.260.1.99',     'device' => 'STAR-TEK, INC. HUB3COMSSTR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.32.1',     'device' => 'NORTEL HUBBAYST300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.30',     'device' => 'NORTEL HUBBAYST350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.33.2.8',     'device' => 'ENTERASYS IA-1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.22',     'device' => 'RIVERSTONE NETWORKS IA-1100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.23',     'device' => 'RIVERSTONE NETWORKS IA-1200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.27',     'device' => 'RIVERSTONE NETWORKS IA-1500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.33.2.9',     'device' => 'ENTERASYS IA-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.1',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.2',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.3',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.4',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.5',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.6',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.7',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.8',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.9',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.10',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.11',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.12',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.13',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.14',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.15',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.16',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.17',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.18',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.19',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.20',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.21',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.22',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.23',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.24',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.25',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.26',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.27',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.28',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.29',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.30',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.31',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.32',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.33',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.34',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.35',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.99.1.1.3.36',     'device' => 'SRI IAGENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.22',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS IBM BLADECENTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.7.1',     'device' => 'PARADYNE INT-9820'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.7.4',     'device' => 'PARADYNE INT-9820-45M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.7.3',     'device' => 'PARADYNE INT-9820-8M'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.7.2',     'device' => 'PARADYNE INT-9820-C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.40',     'device' => 'NORTEL INTRWANPE100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.143',     'device' => 'NOKIA IPSO IP2255'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.144',     'device' => 'NOKIA IPSO IP390'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.145',     'device' => 'NOKIA IPSO IP560'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.150',     'device' => 'NOKIA IPSO SC6600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.10',     'device' => 'NOKIA IPSOIP110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.139',     'device' => 'NOKIA IPSOIP1220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.140',     'device' => 'NOKIA IPSOIP1260'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.141',     'device' => 'NOKIA IPSOIP260'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.142',     'device' => 'NOKIA IPSOIP265'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.13',     'device' => 'NOKIA IPSOIP3400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.138',     'device' => 'NOKIA IPSOIP350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.137',     'device' => 'NOKIA IPSOIP380'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.9',     'device' => 'NOKIA IPSOIP3XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.3',     'device' => 'NOKIA IPSOIP400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.4',     'device' => 'NOKIA IPSOIP410'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.5',     'device' => 'NOKIA IPSOIP440'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.2',     'device' => 'NOKIA IPSOIP4XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.11',     'device' => 'NOKIA IPSOIP530'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.7',     'device' => 'NOKIA IPSOIP600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.8',     'device' => 'NOKIA IPSOIP650'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.6',     'device' => 'NOKIA IPSOIP6XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.15',     'device' => 'NOKIA IPSOIP710'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.12',     'device' => 'NOKIA IPSOIP740'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.1',     'device' => 'NOKIA IPSOIPUNKWN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.133',     'device' => 'NOKIA IPSOVPN210'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.134',     'device' => 'NOKIA IPSOVPN220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.135',     'device' => 'NOKIA IPSOVPN230'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.136',     'device' => 'NOKIA IPSOVPN240'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.130',     'device' => 'NOKIA IPSOVPNRL250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.129',     'device' => 'NOKIA IPSOVPNRL50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.131',     'device' => 'NOKIA IPSOVPNRL500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.132',     'device' => 'NOKIA IPSOVPNRLU'     ),

      array(
         'oid' => '.1.3.6.1.4.1.94.1.21.2.1.128',     'device' => 'NOKIA IPSOVPNUNKWN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.176',     'device' => 'ADTRAN IQ PROBE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.16',     'device' => 'JUNIPER IRM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.10.1',     'device' => 'PARADYNE ISDN-9664'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.13',     'device' => 'JUNIPER J2300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.23',     'device' => 'JUNIPER J2320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.24',     'device' => 'JUNIPER J2350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.14',     'device' => 'JUNIPER J4300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.22',     'device' => 'JUNIPER J4320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.19',     'device' => 'JUNIPER J4350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.15',     'device' => 'JUNIPER J6300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.20',     'device' => 'JUNIPER J6350'     ),

      array(
         'oid' => '.1.3.6.1.4.1.197.2.4',     'device' => 'CISCO KALPANA ESWCISCOPRO'     ),

      array(
         'oid' => '.1.3.6.1.4.1.607.1.5.1.0',     'device' => 'LACHMAN TECHNOLOGY, INC. LACHMANTECH STEAMWARERAS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.607.1.4.1',     'device' => 'LACHMAN TECHNOLOGY, INC. LACHMANTECH UNIXSYSTEMV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2745.1.4.2.1.1',     'device' => 'LANCAST, INC. LANCAST 7500 12HS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.2.1612',     'device' => 'LANCOM SYSTEMS LANCOM 1611+'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.2.1711',     'device' => 'LANCOM SYSTEMS LANCOM 1711'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.4.1720',     'device' => 'LANCOM SYSTEMS LANCOM 1721'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.7.1722',     'device' => 'LANCOM SYSTEMS LANCOM 1722'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.7.1723',     'device' => 'LANCOM SYSTEMS LANCOM 1723'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.7.1724',     'device' => 'LANCOM SYSTEMS LANCOM 1724'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.3.1811',     'device' => 'LANCOM SYSTEMS LANCOM 1811'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.4.18201',     'device' => 'LANCOM SYSTEMS LANCOM 1821+'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.7.1823',     'device' => 'LANCOM SYSTEMS LANCOM 1823'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2356.500.4.823',     'device' => 'LANCOM SYSTEMS LANCOM 821+'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3052.1.1.1',     'device' => 'OMNITRONIX, INC. LANTRONIX DATALINK'     ),

      array(
         'oid' => '.1.3.6.1.4.1.244.25',     'device' => 'LANTRONIX LANTRONIX ETS32PR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.244.40',     'device' => 'LANTRONIX LANTRONIX MPS1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.244.24',     'device' => 'LANTRONIX LANTRONIX PEPS1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.476.1.2.1.1',     'device' => 'EMERSON COMPUTER POWER LIEBERT PS3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.18.1',     'device' => 'LUCENT TECHNOLOGIES LUCENT AC60'     ),

      array(
         'oid' => '.1.3.6.1.4.1.838.5.1.450.2.0',     'device' => 'LUCENT TECHNOLOGIES LUCENT AP450'     ),

      array(
         'oid' => '.1.3.6.1.4.1.838.5.1.450.2.1',     'device' => 'LUCENT TECHNOLOGIES LUCENT AP450'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.2.12.1',     'device' => 'LUCENT TECHNOLOGIES LUCENT ATMMUX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.30',     'device' => 'LUCENT TECHNOLOGIES LUCENT CONNGW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1080.1.4.1',     'device' => 'NETSTAR, INC. LUCENT IPSWGRF400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.2.6',     'device' => 'AVAYA LUCENT LSF100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.7',     'device' => 'AVAYA LUCENT M410S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.10',     'device' => 'AVAYA LUCENT M420S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.3',     'device' => 'AVAYA LUCENT M440S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.4',     'device' => 'AVAYA LUCENT M440S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.16',     'device' => 'AVAYA LUCENT M770ATM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.15',     'device' => 'AVAYA LUCENT M770S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.2.8',     'device' => 'AVAYA LUCENT M770SWMLS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.12',     'device' => 'AVAYA LUCENT P110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.1.11',     'device' => 'AVAYA LUCENT P120'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.45.4',     'device' => 'LUCENT TECHNOLOGIES LUCENT P220FE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.45.3',     'device' => 'LUCENT TECHNOLOGIES LUCENT P220G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.81.17.2.13',     'device' => 'AVAYA LUCENT P330R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.18.2',     'device' => 'LUCENT TECHNOLOGIES LUCENT PSAX1250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.18.7',     'device' => 'LUCENT TECHNOLOGIES LUCENT PSAX1250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1677.1.1.6',     'device' => 'SAHARA NETWORKS, INC. LUCENT PSAX600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.838.5.1.1.0',     'device' => 'LUCENT TECHNOLOGIES LUCENT SRVRTR1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.529.1.2.11',     'device' => 'LUCENT TECHNOLOGIES LUCENT TERMINATOR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.4.2',     'device' => 'LUCENT TECHNOLOGIES LUCENT WAVEPTII'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1751.1.8.1.40',     'device' => 'LUCENT TECHNOLOGIES LUCENTPROXY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.4',     'device' => 'JUNIPER M10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.11',     'device' => 'JUNIPER M10I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.18',     'device' => 'JUNIPER M120'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.3',     'device' => 'JUNIPER M160'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.2',     'device' => 'JUNIPER M20'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.9',     'device' => 'JUNIPER M320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.1',     'device' => 'JUNIPER M40'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.8',     'device' => 'JUNIPER M40E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.5',     'device' => 'JUNIPER M5'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.10',     'device' => 'JUNIPER M7I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.4.1',     'device' => 'AMERICAN POWER CONVERSION MASTERSWITCHV1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.65',     'device' => 'ENTERASYS MATRIX E7 GOLD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.51',     'device' => 'ENTERASYS MATRIX N'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.70',     'device' => 'ENTERASYS MATRIX N ROUTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.77',     'device' => 'ENTERASYS MATRIX N STANDALONE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.83',     'device' => 'ENTERASYS MATRIX N1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.84',     'device' => 'ENTERASYS MATRIX N1 GOLD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.122',     'device' => 'ENTERASYS MATRIX N1 NAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.53',     'device' => 'ENTERASYS MATRIX N3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.67',     'device' => 'ENTERASYS MATRIX N3 GOLD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.79',     'device' => 'ENTERASYS MATRIX N5'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.78',     'device' => 'ENTERASYS MATRIX N5 POE GOLD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.52',     'device' => 'ENTERASYS MATRIX N7'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.66',     'device' => 'ENTERASYS MATRIX N7 GOLD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.3.1',     'device' => 'AMERICAN POWER CONVERSION MATRIXUPS3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.3.2',     'device' => 'AMERICAN POWER CONVERSION MATRIXUPS5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.705.1.2',     'device' => 'MERLIN GERIN MGE UPS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.351.110',     'device' => 'CISCO MGX 8220'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.304',     'device' => 'CISCO MGX 8230'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.311',     'device' => 'CISCO MGX 8240'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.305',     'device' => 'CISCO MGX 8250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.229',     'device' => 'CISCO MGX 8830'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.458',     'device' => 'CISCO MGX 8830PXM1E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.228',     'device' => 'CISCO MGX 8850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.435',     'device' => 'CISCO MGX 8850PXM1E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.598',     'device' => 'CISCO MGX 8880'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.315',     'device' => 'CISCO MGX 8950'     ),

      array(
         'oid' => '.1.3.6.1.4.1.351.130',     'device' => 'CISCO MGX_8850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.6',     'device' => '3COM MODEMPOOL16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.7',     'device' => '3COM MODEMPOOL8'     ),

      array(
         'oid' => '.1.3.6.1.4.1.161.7.10.1',     'device' => 'MOTOROLA MOTOROLA CDLP CABLE ROUTER REL. 4.1.7'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.6.1',     'device' => 'PARADYNE MSA-9192'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.6.2',     'device' => 'PARADYNE MSA-9195'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.6.3',     'device' => 'PARADYNE MSA-9292'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.6.4',     'device' => 'PARADYNE MSA-9295'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.9.1',     'device' => 'PARADYNE MSDSL-9724'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.25',     'device' => 'JUNIPER MX480'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.21',     'device' => 'JUNIPER MX960'     ),

      array(
         'oid' => '.1.3.6.1.4.1.789.2.2',     'device' => 'NETWORK APPLIANCE CORPORATION NETCACHE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.10.1',     'device' => 'FOUNDRY NETWORKS NETIRON400RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.33.1',     'device' => 'FOUNDRY NETWORKS NETIRON40GRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.11.1',     'device' => 'FOUNDRY NETWORKS NETIRON800RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.39.1.2',     'device' => 'FOUNDRY NETWORKS NETIRONIMRRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.44.1.2',     'device' => 'FOUNDRY NETWORKS NETIRONMLX16RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.44.3.2',     'device' => 'FOUNDRY NETWORKS NETIRONMLX4RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.44.2.2',     'device' => 'FOUNDRY NETWORKS NETIRONMLX8RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.2.1',     'device' => 'FOUNDRY NETWORKS NETIRONRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.41.1.2',     'device' => 'FOUNDRY NETWORKS NETIRONXMR16000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.41.3.2',     'device' => 'FOUNDRY NETWORKS NETIRONXMR4000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.41.2.2',     'device' => 'FOUNDRY NETWORKS NETIRONXMR8000RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.141.1.1.7303',     'device' => 'FRONTIER SOFTWARE DEVELOPMENT NETSCOUT 7303'     ),

      array(
         'oid' => '.1.3.6.1.4.1.141.1.1.8150',     'device' => 'FRONTIER SOFTWARE DEVELOPMENT NETSCOUT 8150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.863',     'device' => 'ADTRAN NETVANTA 1024 PWR MIDSPAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.525',     'device' => 'ADTRAN NETVANTA 1224'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.745',     'device' => 'ADTRAN NETVANTA 1224'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.582',     'device' => 'ADTRAN NETVANTA 1224R'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.807',     'device' => 'ADTRAN NETVANTA 1224R DC CHASSIS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.526',     'device' => 'ADTRAN NETVANTA 1224ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.583',     'device' => 'ADTRAN NETVANTA 1224STR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.808',     'device' => 'ADTRAN NETVANTA 1224STR DC CHASSIS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.932',     'device' => 'ADTRAN NETVANTA 1335'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.934',     'device' => 'ADTRAN NETVANTA 1335 POE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.935',     'device' => 'ADTRAN NETVANTA 1335 POE W/AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.933',     'device' => 'ADTRAN NETVANTA 1335 W/AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.864',     'device' => 'ADTRAN NETVANTA 1355'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.950',     'device' => 'ADTRAN NETVANTA 1355'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.949',     'device' => 'ADTRAN NETVANTA 150 W/AP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.760',     'device' => 'ADTRAN NETVANTA 1524ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.501',     'device' => 'ADTRAN NETVANTA 2050'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.502',     'device' => 'ADTRAN NETVANTA 2054'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.503',     'device' => 'ADTRAN NETVANTA 2100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.504',     'device' => 'ADTRAN NETVANTA 2104'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.505',     'device' => 'ADTRAN NETVANTA 2300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.506',     'device' => 'ADTRAN NETVANTA 2400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.878',     'device' => 'ADTRAN NETVANTA 3120'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.879',     'device' => 'ADTRAN NETVANTA 3130 ANNEX A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.383',     'device' => 'ADTRAN NETVANTA 3200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.466',     'device' => 'ADTRAN NETVANTA 3205'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.467',     'device' => 'ADTRAN NETVANTA 3305'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.746',     'device' => 'ADTRAN NETVANTA 340 CHASSIS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.876',     'device' => 'ADTRAN NETVANTA 3430'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.764',     'device' => 'ADTRAN NETVANTA 344'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.811',     'device' => 'ADTRAN NETVANTA 344 ANNEX A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.812',     'device' => 'ADTRAN NETVANTA 344 ANNEX B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.877',     'device' => 'ADTRAN NETVANTA 3448'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.943',     'device' => 'ADTRAN NETVANTA 3448 POE DAUGHTER CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.869',     'device' => 'ADTRAN NETVANTA 347'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.468',     'device' => 'ADTRAN NETVANTA 3XXX DDS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.803',     'device' => 'ADTRAN NETVANTA 3XXX DUALBRIST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.804',     'device' => 'ADTRAN NETVANTA 3XXX DUALBRIU'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.771',     'device' => 'ADTRAN NETVANTA 3XXX DUALT1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.472',     'device' => 'ADTRAN NETVANTA 3XXX ISDN DBU'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.473',     'device' => 'ADTRAN NETVANTA 3XXX SERIAL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.474',     'device' => 'ADTRAN NETVANTA 3XXX SHDSL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.469',     'device' => 'ADTRAN NETVANTA 3XXX T1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.470',     'device' => 'ADTRAN NETVANTA 3XXX T1/DSX-1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.471',     'device' => 'ADTRAN NETVANTA 3XXX V.90 DBU'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.586',     'device' => 'ADTRAN NETVANTA 4305'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.578',     'device' => 'ADTRAN NETVANTA 5305'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.637',     'device' => 'ADTRAN NETVANTA 5305 T3 NIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.841',     'device' => 'ADTRAN NETVANTA 7100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.638',     'device' => 'ADTRAN NETVANTA 950 SYSTEM CONTROLLER UNIT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.641',     'device' => 'ADTRAN NETVANTA 950.970 OCTAL FXS MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.640',     'device' => 'ADTRAN NETVANTA 950/970 OCTAL ETHERNET SWITCH MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.642',     'device' => 'ADTRAN NETVANTA 950/970 OCTAL FXO MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.643',     'device' => 'ADTRAN NETVANTA 970 OCTAL DSS MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.639',     'device' => 'ADTRAN NETVANTA 970 SYSTEM CONTROLLER UNIT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.585',     'device' => 'ADTRAN NETVANTA E1 & G.703 NIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.584',     'device' => 'ADTRAN NETVANTA E1 NIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.581',     'device' => 'ADTRAN NETVANTA ISDN S/T DIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.742',     'device' => 'ADTRAN NETVANTA NV1224 POE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.744',     'device' => 'ADTRAN NETVANTA NV1224R POE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.743',     'device' => 'ADTRAN NETVANTA NV1224ST POE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.644',     'device' => 'ADTRAN NETVANTA T1/V35 EXPANSION MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.819',     'device' => 'ADTRAN NETVANTA XXXX DUAL E1 CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.851',     'device' => 'ADTRAN NETVANTA XXXX DUAL FXO VIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.850',     'device' => 'ADTRAN NETVANTA XXXX DUAL FXS/FXO VIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.818',     'device' => 'ADTRAN NETVANTA XXXX IPSEC CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.866',     'device' => 'ADTRAN NETVANTA XXXX ISDN BRI ST MODULE '     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.865',     'device' => 'ADTRAN NETVANTA XXXX ISDN BRI U MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.817',     'device' => 'ADTRAN NETVANTA XXXX ISDN DBU S/T CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.849',     'device' => 'ADTRAN NETVANTA XXXX QUAD FXO VIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.848',     'device' => 'ADTRAN NETVANTA XXXX QUAD FXS VIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.810',     'device' => 'ADTRAN NETVANTA XXXX SERIAL DBU CARD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.852',     'device' => 'ADTRAN NETVANTA XXXX T1/PRI VIM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.861',     'device' => 'ADTRAN NETVANTA XXXX VPN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.15.1',     'device' => 'FOUNDRY NETWORKS NIRON1500RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.31.2',     'device' => 'FOUNDRY NETWORKS NIRON4802RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.31.1',     'device' => 'FOUNDRY NETWORKS NIRON4802SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.8.1',     'device' => 'PARADYNE NNI-9110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.15.1.3.1',     'device' => 'NORTEL NORTEL ANNEX3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.65',     'device' => 'NORTEL NORTEL ERS 5530-24TFD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.13.6',     'device' => 'NORTEL NORTEL NMM5616A SA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.1',     'device' => 'JUNIPER NSCREEN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.3',     'device' => 'JUNIPER NSCREEN10'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.4',     'device' => 'JUNIPER NSCREEN100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.5',     'device' => 'JUNIPER NSCREEN1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.9',     'device' => 'JUNIPER NSCREEN204'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.10',     'device' => 'JUNIPER NSCREEN208'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.8',     'device' => 'JUNIPER NSCREEN25'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.2',     'device' => 'JUNIPER NSCREEN5'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.7',     'device' => 'JUNIPER NSCREEN50'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.6',     'device' => 'JUNIPER NSCREEN500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.13',     'device' => 'JUNIPER NSCREEN5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.14',     'device' => 'JUNIPER NSCREEN5GT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.17',     'device' => 'JUNIPER NSCREEN5GT-ADSL-A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.23',     'device' => 'JUNIPER NSCREEN5GT-ADSL-A-WLAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.19',     'device' => 'JUNIPER NSCREEN5GT-ADSL-B'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.25',     'device' => 'JUNIPER NSCREEN5GT-ADSL-B-WLAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.21',     'device' => 'JUNIPER NSCREEN5GT-WLAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.12',     'device' => 'JUNIPER NSCREEN5XP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.11',     'device' => 'JUNIPER NSCREEN5XT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.15',     'device' => 'JUNIPER NSCREENCLIENT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.28',     'device' => 'JUNIPER NSCREENISG1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.16',     'device' => 'JUNIPER NSCREENISG2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.50',     'device' => 'JUNIPER NSCREENSSG520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3224.1.51',     'device' => 'JUNIPER NSCREENSSG550'     ),

      array(
         'oid' => '.1.3.6.1.4.1.791.2.9.4.5',     'device' => 'CA NSM SYSTEM HOST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.791.2.10.2.43',     'device' => 'CA NSM SYSTEM HOST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.791.2.10.2.74',     'device' => 'CA NSM SYSTEM HOST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.791.2.10.2.90',     'device' => 'CA NSM SYSTEM HOST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.285.9.27',     'device' => 'OLICOM AS OLI-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.285.9.25',     'device' => 'OLICOM AS OLI-8000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.285.9.26',     'device' => 'OLICOM AS OLI-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3003.2.2.2.1',     'device' => 'ALCATEL OMNICORE 5200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.800.3.1.1.3',     'device' => 'ALCATEL OMNISTACK'     ),

      array(
         'oid' => '.1.3.6.1.4.1.800.3.1.1.17',     'device' => 'ALCATEL OMNISTACK 4024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.800.3.1.1.16',     'device' => 'ALCATEL OMNISTACK 5024'     ),

      array(
         'oid' => '.1.3.6.1.4.1.800.3.1.1.2',     'device' => 'ALCATEL OMNISWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3607.1.20.10.10',     'device' => 'CISCO ONS15454'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2865.1',     'device' => 'NORTEL OPTERA5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1550.2.17',     'device' => 'NUERA COMMUNICATION INC. ORCARDT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6889.1.45.2',     'device' => 'AVAYA P580 MULTISERVICE SWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6889.1.45.10',     'device' => 'AVAYA P882 MULTISERVICE SWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6889.1.8.1.51',     'device' => 'AVAYA S8700 SERVER FOR IP CONNECT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6889.1.8.1.49',     'device' => 'AVAYA S8700 SERVER FOR MULTICONNECT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.42',     'device' => 'NORTEL PASSPORT1424T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.44',     'device' => 'NORTEL PASSPORT1612'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.45',     'device' => 'NORTEL PASSPORT1624'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.43',     'device' => 'NORTEL PASSPORT1648'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.280887558',     'device' => 'NORTEL PASSPORT8006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.280887562',     'device' => 'NORTEL PASSPORT8010'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.33',     'device' => 'NORTEL PASSPORT8106'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.32',     'device' => 'NORTEL PASSPORT8110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.31',     'device' => 'NORTEL PASSPORT8606'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.30',     'device' => 'NORTEL PASSPORT8610'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2272.37',     'device' => 'NORTEL PASSPORT8610'     ),

      array(
         'oid' => '.1.3.6.1.4.1.562.36.1.4',     'device' => 'NORTEL PASSPT 15000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.562.36.1.1',     'device' => 'NORTEL PASSPT 7440'     ),

      array(
         'oid' => '.1.3.6.1.4.1.562.36.1.2',     'device' => 'NORTEL PASSPT 7480'     ),

      array(
         'oid' => '.1.3.6.1.4.1.562.36.1.3',     'device' => 'NORTEL PASSPT VR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.417',     'device' => 'CISCO PIX 501 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.389',     'device' => 'CISCO PIX 506 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.450',     'device' => 'CISCO PIX 506E FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.390',     'device' => 'CISCO PIX 515 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.451',     'device' => 'CISCO PIX 515E FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.677',     'device' => 'CISCO PIX 515ESC FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.769',     'device' => 'CISCO PIX 515ESY FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.678',     'device' => 'CISCO PIX 515SC FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.768',     'device' => 'CISCO PIX 515SY FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.391',     'device' => 'CISCO PIX 520 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.392',     'device' => 'CISCO PIX 525 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.676',     'device' => 'CISCO PIX 525SC FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.770',     'device' => 'CISCO PIX 525SY FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.393',     'device' => 'CISCO PIX 535 FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.675',     'device' => 'CISCO PIX 535SC FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.771',     'device' => 'CISCO PIX 535SY FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.227',     'device' => 'CISCO PIX FIREWALL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.674',     'device' => 'CISCO PIX FIREWALL SECURITY MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.767',     'device' => 'CISCO PIX FIREWALL SYSTEM MODULE'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.3',     'device' => 'PACKETEER PACKET SHAPER 1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.6',     'device' => 'PACKETEER PACKET SHAPER 1500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.1',     'device' => 'PACKETEER PACKET SHAPER 2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.4',     'device' => 'PACKETEER PACKET SHAPER 2500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.2',     'device' => 'PACKETEER PACKET SHAPER 4000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.5',     'device' => 'PACKETEER PACKET SHAPER 4500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.11',     'device' => 'PACKETEER PACKET SHAPER 6500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2334.1.1.20',     'device' => 'PACKETEER PACKET SHAPER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2352.1.1',     'device' => 'REDBACK NETWORKS REDBKSMS1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2352.1.4',     'device' => 'REDBACK NETWORKS REDBKSMS10000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2352.1.3',     'device' => 'REDBACK NETWORKS REDBKSMS1800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2352.1.2',     'device' => 'REDBACK NETWORKS REDBKSMS500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.64',     'device' => 'ENTERASYS ROAMABOUT AP 3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.92',     'device' => 'ENTERASYS ROAMABOUT AP 4102'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.4.15.1.3.1.1',     'device' => 'ENTERASYS ROAMABOUT SW 8100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.4.15.1.3.1.4',     'device' => 'ENTERASYS ROAMABOUT SW 8110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.4.15.1.3.1.2',     'device' => 'ENTERASYS ROAMABOUT SW 8200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.4.15.1.3.1.3',     'device' => 'ENTERASYS ROAMABOUT SW 8400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.14525.3.1.4',     'device' => 'TRAPEZE NETWORKS ROAMABOUT SW MXR2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.36.2.15.3.9.1',     'device' => 'ENTERASYS ROAMABOUTAP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.30',     'device' => 'ENTERASYS ROAMABOUTR2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.8',     'device' => 'RIVERSTONE NETWORKS RS-1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.3',     'device' => 'RIVERSTONE NETWORKS RS-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.4',     'device' => 'RIVERSTONE NETWORKS RS-2100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.5',     'device' => 'RIVERSTONE NETWORKS RS-3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.6',     'device' => 'RIVERSTONE NETWORKS RS-32000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.9',     'device' => 'RIVERSTONE NETWORKS RS-38000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.1',     'device' => 'RIVERSTONE NETWORKS RS-8000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5567.1.1.2',     'device' => 'RIVERSTONE NETWORKS RS-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.4981.1.1.1.0',     'device' => 'MOTOROLA RVRDELTABSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.12867.2.2.1',     'device' => 'CEDAR POINT COMMUNICATIONS SAFARIC3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1663.1.1.1.1.17',     'device' => 'QLOGIC SANBOX 5200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1663.1.1.1.1.30',     'device' => 'QLOGIC SANBOX 5202'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1663.1.1.1.1.23',     'device' => 'QLOGIC SANBOX 5600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1663.1.1.1.1.24',     'device' => 'QLOGIC SANBOX 5602'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1663.1.1.1.1.33',     'device' => 'QLOGIC SANBOX 9000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1166.1.200.1.4.6.19',     'device' => 'MOTOROLA SB3500'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1166.1.200.0.1.5.3.2',     'device' => 'MOTOROLA SBV4200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1573.2.1',     'device' => 'SECURE COMPUTING SCC SIDEWINDER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.87',     'device' => 'ENTERASYS SECURESTACK A2H124-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.91',     'device' => 'ENTERASYS SECURESTACK A2H124-24FX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.88',     'device' => 'ENTERASYS SECURESTACK A2H124-24P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.89',     'device' => 'ENTERASYS SECURESTACK A2H124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.90',     'device' => 'ENTERASYS SECURESTACK A2H124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.95',     'device' => 'ENTERASYS SECURESTACK A2H254-16'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.314',     'device' => 'ENTERASYS SECURESTACK B2G124-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.315',     'device' => 'ENTERASYS SECURESTACK B2G124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.316',     'device' => 'ENTERASYS SECURESTACK B2G124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.317',     'device' => 'ENTERASYS SECURESTACK B2H124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.318',     'device' => 'ENTERASYS SECURESTACK B2H124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.100',     'device' => 'ENTERASYS SECURESTACK B3G124-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.101',     'device' => 'ENTERASYS SECURESTACK B3G124-24P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.102',     'device' => 'ENTERASYS SECURESTACK B3G124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.103',     'device' => 'ENTERASYS SECURESTACK B3G124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.283',     'device' => 'ENTERASYS SECURESTACK C2G124-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.284',     'device' => 'ENTERASYS SECURESTACK C2G124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.287',     'device' => 'ENTERASYS SECURESTACK C2G124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.350',     'device' => 'ENTERASYS SECURESTACK C2G134-24P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.360',     'device' => 'ENTERASYS SECURESTACK C2G170-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.220',     'device' => 'ENTERASYS SECURESTACK C2H124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.286',     'device' => 'ENTERASYS SECURESTACK C2H124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.2.285',     'device' => 'ENTERASYS SECURESTACK C2K122-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.96',     'device' => 'ENTERASYS SECURESTACK C3G124-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.97',     'device' => 'ENTERASYS SECURESTACK C3G124-24P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.98',     'device' => 'ENTERASYS SECURESTACK C3G124-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.99',     'device' => 'ENTERASYS SECURESTACK C3G124-48P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.3.1',     'device' => 'FOUNDRY NETWORKS SERVERIRON'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.3.2',     'device' => 'FOUNDRY NETWORKS SERVERIRONXL'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6027.1.3.1',     'device' => 'FORCE10 NETWORKS, INC. SFTOS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.10',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 12000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.4',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 20X0'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.5',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 22X0'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.3',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 2400/2100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.21',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 24000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.2',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 2800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.6',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 2800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.16',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 3200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.26',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 3250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.9',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 3800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.27',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 3850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.12',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 3900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.42',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM 48000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.38',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM AP7420'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.7',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM SPIDER 2800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1588.2.1.1.1',     'device' => 'BROCADE COMMUNICATIONS SYSTEMS SILKWORM SWITCH'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.20.2',     'device' => 'FOUNDRY NETWORKS SIRON1500RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.20.1',     'device' => 'FOUNDRY NETWORKS SIRON1500SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.18.2',     'device' => 'FOUNDRY NETWORKS SIRON400RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.18.1',     'device' => 'FOUNDRY NETWORKS SIRON400SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.19.2',     'device' => 'FOUNDRY NETWORKS SIRON800RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.19.1',     'device' => 'FOUNDRY NETWORKS SIRON800SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.9.1.2',     'device' => 'FOUNDRY NETWORKS SIRONLS100RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.9.1.1',     'device' => 'FOUNDRY NETWORKS SIRONLS100SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.9.2.2',     'device' => 'FOUNDRY NETWORKS SIRONLS300RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.9.2.1',     'device' => 'FOUNDRY NETWORKS SIRONLS300SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.10.1.1',     'device' => 'FOUNDRY NETWORKS SIRONTM100SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.10.1.2',     'device' => 'FOUNDRY NETWORKS SIRONTM100SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.10.2.1',     'device' => 'FOUNDRY NETWORKS SIRONTM300SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.42.10.2.2',     'device' => 'FOUNDRY NETWORKS SIRONTM300SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.3.3',     'device' => 'FOUNDRY NETWORKS SIRONXLTCS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.34',     'device' => 'ADTRAN SMART16 SHELF CONTROLLER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.9',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.5',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS1250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.10',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS1400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.6',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.11',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS2200'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.1',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.12',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS3000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.2',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.7',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS450'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.3',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.8',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS700'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.2.4',     'device' => 'AMERICAN POWER CONVERSION SMARTUPS900'     ),

      array(
         'oid' => '.1.3.6.1.4.1.3199.10.1',     'device' => 'NORTEL SSG5000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.33.1.1',     'device' => 'ENTERASYS SSR-2000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.33.1.3',     'device' => 'ENTERASYS SSR-2100'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.10.2',     'device' => 'ENTERASYS SSR-32000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.1.3',     'device' => 'ENTERASYS SSR-8000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.9.20.1.4',     'device' => 'ENTERASYS SSR-8600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.101.0',     'device' => 'FLOWPOINT CORPORATION SSR110'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.115.0',     'device' => 'FLOWPOINT CORPORATION SSR115'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.103.0',     'device' => 'FLOWPOINT CORPORATION SSR130'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.130.0',     'device' => 'FLOWPOINT CORPORATION SSR130'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.104.0',     'device' => 'FLOWPOINT CORPORATION SSR140'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.140.0',     'device' => 'FLOWPOINT CORPORATION SSR140'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.105.0',     'device' => 'FLOWPOINT CORPORATION SSR150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.150.0',     'device' => 'FLOWPOINT CORPORATION SSR150'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.175.0',     'device' => 'FLOWPOINT CORPORATION SSR175'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.245.0',     'device' => 'FLOWPOINT CORPORATION SSR245'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.250.0',     'device' => 'FLOWPOINT CORPORATION SSR250'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.255.0',     'device' => 'FLOWPOINT CORPORATION SSR255'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1548.265.0',     'device' => 'FLOWPOINT CORPORATION SSR265'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.16.2.2.2.1',     'device' => '3COM STK-9300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.16.2.2.1.1',     'device' => '3COM STK3900-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.43.1.16.2.2.1.2',     'device' => '3COM STK3900-36'     ),

      array(
         'oid' => '.1.3.6.1.4.1.351.100',     'device' => 'CISCO STRATACOMBPX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.63',     'device' => 'EXTREME NETWORKS SUMMIT 400-24T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.93',     'device' => 'EXTREME NETWORKS SUMMIT X250E-24T (3-STACK)'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.88',     'device' => 'EXTREME NETWORKS SUMMIT X250E-24T (SINGLE)'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.65',     'device' => 'EXTREME NETWORKS SUMMIT X450-24X'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.84',     'device' => 'EXTREME NETWORKS SUMMIT X450A-24X'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.1',     'device' => 'EXTREME NETWORKS SUMMIT1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.19',     'device' => 'EXTREME NETWORKS SUMMIT1ISX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.14',     'device' => 'EXTREME NETWORKS SUMMIT1ITX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.2',     'device' => 'EXTREME NETWORKS SUMMIT2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.53',     'device' => 'EXTREME NETWORKS SUMMIT200-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.54',     'device' => 'EXTREME NETWORKS SUMMIT200-48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.7',     'device' => 'EXTREME NETWORKS SUMMIT24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.41',     'device' => 'EXTREME NETWORKS SUMMIT24E2SX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.40',     'device' => 'EXTREME NETWORKS SUMMIT24E2TX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.25',     'device' => 'EXTREME NETWORKS SUMMIT24E3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.3',     'device' => 'EXTREME NETWORKS SUMMIT3'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.4',     'device' => 'EXTREME NETWORKS SUMMIT4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.58',     'device' => 'EXTREME NETWORKS SUMMIT400-24'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.59',     'device' => 'EXTREME NETWORKS SUMMIT400-48T'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.6',     'device' => 'EXTREME NETWORKS SUMMIT48'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.16',     'device' => 'EXTREME NETWORKS SUMMIT48I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.28',     'device' => 'EXTREME NETWORKS SUMMIT48I1U'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.5',     'device' => 'EXTREME NETWORKS SUMMIT4FX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.15',     'device' => 'EXTREME NETWORKS SUMMIT5I'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.21',     'device' => 'EXTREME NETWORKS SUMMIT5ILX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.22',     'device' => 'EXTREME NETWORKS SUMMIT5ITX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.12',     'device' => 'EXTREME NETWORKS SUMMIT7ISX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.13',     'device' => 'EXTREME NETWORKS SUMMIT7ITX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1916.2.30',     'device' => 'EXTREME NETWORKS SUMMITPX1'     ),

      array(
         'oid' => '.1.3.6.1.4.1.42.2.24.1',     'device' => 'SUN MICROSYSTEMS SUNFIREB1600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.20',     'device' => 'CISCO SWCAT2820'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.5.3',     'device' => 'AMERICAN POWER CONVERSION SYMMETRAUPS12KVA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.5.4',     'device' => 'AMERICAN POWER CONVERSION SYMMETRAUPS16KVA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.5.1',     'device' => 'AMERICAN POWER CONVERSION SYMMETRAUPS4KVA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318.1.3.5.2',     'device' => 'AMERICAN POWER CONVERSION SYMMETRAUPS8KVA'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1139',     'device' => 'EMC CORP SYMMETRIX SNAS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3',     'device' => 'NORTEL SYNOP 27XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.45.3.15.1',     'device' => 'NORTEL SYNOP 281XX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.33.8.1.2.3',     'device' => 'XYPLEX SYNOPTICS 3395A'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.1',     'device' => 'PARADYNE T1-1SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.7',     'device' => 'PARADYNE T1-9161'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.2',     'device' => 'PARADYNE T1-9162'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.3',     'device' => 'PARADYNE T1-9165'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.8',     'device' => 'PARADYNE T1-9261'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.5',     'device' => 'PARADYNE T1-9262'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.6',     'device' => 'PARADYNE T1-9265'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.3.4',     'device' => 'PARADYNE T1-NAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.27',     'device' => 'JUNIPER T1600'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.2',     'device' => 'PARADYNE T1FR-2SLOT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.1',     'device' => 'PARADYNE T1FR-9121'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.11',     'device' => 'PARADYNE T1FR-9123'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.11.2',     'device' => 'PARADYNE T1FR-9123-SLV'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.5',     'device' => 'PARADYNE T1FR-9124'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.9',     'device' => 'PARADYNE T1FR-9124-II'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.10',     'device' => 'PARADYNE T1FR-9124-L'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.6',     'device' => 'PARADYNE T1FR-9124-NNI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.12',     'device' => 'PARADYNE T1FR-9124-OS'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.7',     'device' => 'PARADYNE T1FR-9126'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.8',     'device' => 'PARADYNE T1FR-9128'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.4',     'device' => 'PARADYNE T1FR-NAC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1795.1.14.2.4.4.3',     'device' => 'PARADYNE T1FR-NAF'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.7',     'device' => 'JUNIPER T320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.6',     'device' => 'JUNIPER T640'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.8',     'device' => '3COM TC-1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.429.2.9',     'device' => '3COM TC-1000'     ),

      array(
         'oid' => '.1.3.6.1.4.1.128.2.1.4.1.3.2',     'device' => 'TEKTRONIX, INC. TEKTRONIX PHASER 740P'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6141.1.37',     'device' => 'WORLD WIDE PACKETS TELLABS 8813 EAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6141.1.70',     'device' => 'WORLD WIDE PACKETS TELLABS 8813 EAN'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6141.1.1',     'device' => 'WORLD WIDE PACKETS TELLABS 8820 MSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.6141.1.3',     'device' => 'WORLD WIDE PACKETS TELLABS 8840 MSR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1456.3.3',     'device' => 'TERAYON TERAYON ROUTER'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.5.4',     'device' => 'FOUNDRY NETWORKS TIRON8SIXLG'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1456.1',     'device' => 'TERAYON TL1000MC'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1456.2',     'device' => 'TERAYON TLGWAY'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.253',     'device' => 'ADTRAN TOTAL ACCESS 850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.2.180',     'device' => 'ENTERASYS TRMM-2'     ),

      array(
         'oid' => '.1.3.6.1.4.1.52.3.2.183',     'device' => 'ENTERASYS TRMM-4'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.130',     'device' => 'ADTRAN TSU 120E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.129',     'device' => 'ADTRAN TSU 600E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.127',     'device' => 'ADTRAN TSU ESP'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.147',     'device' => 'ADTRAN TSU IQ'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.217',     'device' => 'ADTRAN TSU IQ SMART16 RACKMOUNT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.664.1.186',     'device' => 'ADTRAN TSU IQ+'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.5.2',     'device' => 'FOUNDRY NETWORKS TURBOIRON8RT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.5.3',     'device' => 'FOUNDRY NETWORKS TURBOIRON8SI'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.5.1',     'device' => 'FOUNDRY NETWORKS TURBOIRON8SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.4.2',     'device' => 'FOUNDRY NETWORKS TURBOIRONRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.4.1',     'device' => 'FOUNDRY NETWORKS TURBOIRONSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.1.3',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXL3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.2.3',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXPREML3SW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.2.2',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXPREMRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.2.1',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXPREMSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.1.2',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXRT'     ),

      array(
         'oid' => '.1.3.6.1.4.1.1991.1.3.38.1.1',     'device' => 'FOUNDRY NETWORKS TURBOIRONSXSW'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2636.1.1.1.2.17',     'device' => 'JUNIPER TX'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.317',     'device' => 'CISCO UBR_10012'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.344',     'device' => 'CISCO UBR_7111'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.345',     'device' => 'CISCO UBR_7111E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.346',     'device' => 'CISCO UBR_7114'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.347',     'device' => 'CISCO UBR_7114E'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.210',     'device' => 'CISCO UBR_7223'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.179',     'device' => 'CISCO UBR_7246'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.271',     'device' => 'CISCO UBR_7246VXR'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.191',     'device' => 'CISCO UBR_904'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.351',     'device' => 'CISCO UBR_905'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.292',     'device' => 'CISCO UBR_912C'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.293',     'device' => 'CISCO UBR_912S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.294',     'device' => 'CISCO UBR_914'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.255',     'device' => 'CISCO UBR_924'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.1.316',     'device' => 'CISCO UBR_925'     ),

      array(
         'oid' => '.1.3.6.1.4.1.2021.250.255',     'device' => 'UCDAVIS UCDAVIS UCDFREEBSD'     ),

      array(
         'oid' => '.1.3.6.1.4.1.318',     'device' => 'AMERICAN POWER CONVERSION UPS APC 9605'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.300',     'device' => 'CODEX VANGUARD 300'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.320',     'device' => 'CODEX VANGUARD 320'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.6435',     'device' => 'CODEX VANGUARD6435'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.6455',     'device' => 'CODEX VANGUARD6455'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.6520',     'device' => 'CODEX VANGUARD6520'     ),

      array(
         'oid' => '.1.3.6.1.4.1.449.2.1.6560',     'device' => 'CODEX VANGUARD6560'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.11',     'device' => 'ENTERASYS VH-2402S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.46',     'device' => 'ENTERASYS VH-2402S'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.10',     'device' => 'ENTERASYS VH-4802'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.9',     'device' => 'ENTERASYS VH-8G'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.25',     'device' => 'ENTERASYS VH-8TX1UM'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.38',     'device' => 'CISCO WS-C6006'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.39',     'device' => 'CISCO WS-C6009'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.45',     'device' => 'CISCO WS-C6506'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.44',     'device' => 'CISCO WS-C6509'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.47',     'device' => 'CISCO WS-C6509NEB'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.50',     'device' => 'CISCO WS-C6513'     ),

      array(
         'oid' => '.1.3.6.1.4.1.9.5.37',     'device' => 'CISCO WSC 3920'     ),

      array(
         'oid' => '.1.3.6.1.4.1.253.8.62.1.1.6.1.1',     'device' => 'XEROX 230ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.253.8.62.1.1.3.1.2',     'device' => 'XEROX 250ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.253.8.62.1.1.3.1.3',     'device' => 'XEROX 255ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.253.8.62.1.1.4.1.2',     'device' => 'XEROX 265ST'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.42',     'device' => 'ENTERASYS XP-2400'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1',     'device' => 'ENTERASYS XSR-1800'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.32',     'device' => 'ENTERASYS XSR-1805'     ),

      array(
         'oid' => '.1.3.6.1.4.1.5624.2.1.45',     'device' => 'ENTERASYS XSR-1850'     ),

      array(
         'oid' => '.1.3.6.1.4.1.33.8.7.1.6',     'device' => 'XYPLEX RTRTERMSERVER'     ),


);


?>
