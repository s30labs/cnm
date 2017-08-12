<?
	$CFG_MONITOR[]=array(
		'monitor' => 'disp_icmp',
		'description' => 'ICMP AVAILABILITY (ping)',
		'items' => 'Available|Not computable|Not available|Unknown',
		'vlabel' => 'status',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_icmp',
		'description' => 'ICMP SERVICE (ping)',
		'items' => 'Response time',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ip_icmp2',
		'description' => 'ICMP SERVICE - MEDIUM PRIORITY (ping)',
		'items' => 'Response time',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ip_icmp3',
		'description' => 'ICMP SERVICE - LOW PRIORITY (ping)',
		'items' => 'Response time',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_http',
		'description' => 'WWW - RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httprc',
		'description' => 'WWW - SERVER RESPONSE',
		'items' => 'Response code',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httplinks',
		'description' => 'WWW - NUMBER OF LINKS',
		'items' => 'Link Number',
		'vlabel' => 'num',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httppage',
		'description' => 'WWW - PAGE DIFFERENCES',
		'items' => 'Number of differencees',
		'vlabel' => 'diffs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_pop3',
		'description' => 'POP3 RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_imap',
		'description' => 'IMAP RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_smtp',
		'description' => 'SMTP RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_dns',
		'description' => 'DNS RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_tcp',
		'description' => 'TCP PORT RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ssh',
		'description' => 'SSH RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_snmp',
		'description' => 'SNMP Variable monitor',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_smb',
		'description' => 'SMB/CIFS - FILE ACCESS',
		'items' => 'Size',
		'vlabel' => 'bytes',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ntp',
		'description' => 'NTP RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_xagent',
		'description' => 'REMOTE AGENT MONITOR (XAGENT)',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap',
		'description' => 'LDAP RESPONSE TIME',
		'items' => 'Response time',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap_attr',
		'description' => 'LDAP ATTRIBUTE',
		'items' => '0 NOK, 1 OK',
		'vlabel' => 'time',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap_val',
		'description' => 'LDAP VALUE',
		'items' => 'value',
		'vlabel' => 'time',
	);

?>
