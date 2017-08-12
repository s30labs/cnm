<?
	$TIPS[]=array(
		'id_ref' => 'disp_icmp',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Sends several 64 bytes length ICMP packets (icmp request) tothe remote host. If it loses more than 30% reports an error. Monitors device availability in a 60 second time lapse',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_icmp',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Sends several 64 bytes length ICMP packets (icmp request) tothe remote host. If it loses more than 30% reports an error. Monitors response time in a 300 second time lapse',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ip_icmp2',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Sends several 64 bytes length ICMP packets (icmp request) tothe remote host. If it loses more than 30% reports an error. Monitors response time in a 300 second time lapse',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ip_icmp3',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Sends several 64 bytes length ICMP packets (icmp request) tothe remote host. If it loses more than 30% reports an error. Monitors response time in a 300 second time lapse',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_http',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Monitors the response time of a web server by making an HTTP/HTTPS (GET/POST) request.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_httprc',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Monitors the return code of a web page by making an HTTP/HTTPS (GET/POST) request. The results are set according to the following rules: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_httplinks',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the number of links of a web page by making an HTTP/HTTPS (GET/POST) request.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_httppage',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the number of differences of a web page by making an HTTP/HTTPS (GET/POST) request. It checks the received content against the one tha is stored and returns the number of differences.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_pop3',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a POP3 connection performing the login phase.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_imap',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of an IMAP4 connection performing the login phase.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_smtp',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of an SMTP connection issuing a SMTP HELO.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_dns',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a DNS A record query.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_tcp',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a TCP connection sendig a TCP SYN packet to the remote host.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ssh',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a SSH connection. Waits for the SSH banner.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_smb',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Checks the existence of a shared file by SMB/CIFS.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ntp',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a NTP query.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ldap',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a LDAP query.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ldap_attr',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Checks if the specified LDAP attribute matches with the supplied one.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_ldap_val',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Gets the value of a LDAP attribute.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_smtp_ext',
		'tip_type' => 'latency',
		'name' => 'Description',
		'descr' => 'Obtains the response time of a SMTP server.',
	);

?>
