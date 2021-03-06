<?php
$iface = 'eth0';
$file = '/cfg/onm.if';
if(file_exists($file) and false!=file_get_contents($file)) $iface = chop(file_get_contents($file));
if (getenv("CNM_LOCAL_IP") !== false) { $ip = getenv("CNM_LOCAL_IP"); }
else {
//	$ip = chop(`/sbin/ifconfig $iface | grep 'inet addr' | cut -d ":" -f2|cut -d " " -f1`);
   $ip = chop(`/sbin/ifconfig $iface | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`);
   if ($ip == "") {
      //Debian 10
      $ip = chop(`/sbin/ifconfig $iface | grep 'inet ' | cut -d: -f2 | awk '{print $2}'`);
   }

print "***********FML*******************INIT CNMS ip=$ip\n";
}
$name = chop(`/bin/hostname`);
if (getenv("CNM_DB_SERVER") !== false) { $name = getenv("CNM_DB_SERVER"); }

if (getenv("CNM_DB_PASSWORD") !== false) { $pwd = getenv("CNM_DB_PASSWORD"); }
else {
	$pwd = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
}

/*
// OLD
$CFG_CNMS = array(
	array(
		'hidx' => '1',
		'cid' => 'default',
      'descr' => 'Default client',
		'db1_name' => 'onm',
		'db1_server' => 'localhost',
		'db1_user' => 'onm',
		'db1_pwd' => $pwd,
		'db2_name' => 'onmgraph',
		'db2_server' => 'localhost',
		'db2_user' => 'onm',
		'db2_pwd' => $pwd,
      'host_ip' => $ip,
      'host_name' => $name,
      'host_descr' => 'localhost',
      'id_client' => '1',
	),
);
*/

$CFG_CNMS = array(
   array(
      'hidx' => '1',
      'cid' => 'default',
      'descr' => 'Default client',
      'db1_name' => 'onm',
//      'db1_server' => 'localhost',
//      'db1_user' => 'onm',
//      'db1_pwd' => $pwd,
//      'db2_name' => 'onmgraph',
//      'db2_server' => 'localhost',
//      'db2_user' => 'onm',
//      'db2_pwd' => $pwd,
      'host_ip' => $ip,
      'host_name' => $name,
      'host_descr' => 'localhost',
      'id_client' => '1',
   ),
);

?>
