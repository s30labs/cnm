#!/usr/bin/perl -w
#-------------------------------------------------------------------------
# api_sample_devices_custom_curl.pl
#-------------------------------------------------------------------------
# token=$(curl -ks "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
# curl -ki -g -H "Authorization: $token" -X GET "https://localhost/onm/api/1.0/devices.json"
#-------------------------------------------------------------------------
use strict;
use JSON;
use Data::Dumper;
use URI::Escape;
  

#-------------------------------------------------------------------------
my $result;
my $cnm_ip='localhost';
my ($user,$pwd)=('admin','cnm123');

#-------------------------------------------------------------------------
# Se obtiene el token
$result=`/usr/bin/curl -ks "https://$cnm_ip/onm/api/1.0/auth/token.json?u=$user&p=$pwd"`;
my $data=decode_json($result);

print "$result\n";
print Dumper($data);

#-------------------------------------------------------------------------
# Se obtienen los dispositivos
my $token=$data->{'sessionid'};
$result=`/usr/bin/curl -ks -H "Authorization: $token" "https://$cnm_ip/onm/api/1.0/devices.json"`;
my $devices=decode_json($result);

print "$result\n";
print Dumper($data);

#-------------------------------------------------------------------------
# Se itera sobre los dispositivos y segun el tipo de dispositivo
# se actualiza el campo de usuario Proveedor
foreach my $d (@$devices) {
	my $proveedor_txt='s30labs';
	if ($d->{'devicetype'} =~ /^Serv/) { $proveedor_txt='Proveedor Sistemas'; } 
	elsif ($d->{'devicetype'} =~ /^Serv/) { $proveedor_txt='Proveedor Telco'; }

	my $proveedor = uri_escape($proveedor_txt);

	my $id=$d->{'id'};
	my $ip=$d->{'deviceip'};
	my $r = `/usr/bin/curl -ks -H "Authorization: $token" -X PUT "https://$cnm_ip/onm/api/1.0/devices/$id.json?Proveedor=$proveedor"`;
	print "$id\t$ip : $r\n"
}


