#!/usr/bin/perl -w
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Test::More tests => 40;
use Crawler::FXM;
use Data::Dumper;

#------------------------------------------------------------------------------
#my $esp_fx='MAP(0)(1,0,0,0)|MAP(10)(1,0.5,0,0)|MAP(2)(0,0,1,0)|MAP(1)(0,0,0,1)|MAP(11)(0,0.5,0,1)|MAP(12)(0,0.5,1,0)';
#
#my @esp=split(/\|/,$esp_fx);
#foreach my $e (@esp) {
#	if ($e =~ /MAP\(([-|\d+|\,]+)\)\(([-|\d+|\,]+)\)/) { print "a=$1\tb=$2\n"; }
#}
#exit;

#------------------------------------------------------------------------------
my $new_values;
my %desc=();
my @values=();
my $fx='';
my $log_level='debug';
my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level);

#------------------------------------------------------------------------------
my $DESCR= <<DESCR;
----------------------------------------------------------------------------------
Tests sobre la funcion Crawler::FXM::parse_fx encargada de efectuar las operaciones
aritmeticas y logicas al definir fx sobre los valores ox de una metrica dada.
----------------------------------------------------------------------------------

DESCR
print $DESCR;
#------------------------------------------------------------------------------
# +,-,*,/,%
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=(10.3, 12);
$fx='o1+o2';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 22.3, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(10.3, 12);
$fx='o2-o1';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 1.7, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 15);
$fx='o2/o1';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 15);
$fx='o2*o1';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 45, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 15);
$fx='o2*o1+2';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 47, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 15);
$fx='o2*(o1+2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 75, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 17);
$fx='o2%o1';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 2, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 5);
$fx='o2**2+o1**2';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 34, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 5);
$fx='log(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] - 1.6094379124341 < 0.000001, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 5);
$fx='log(o1+o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] - 2.07944154167984 < 0.000001, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
@values=(3, -5);
$fx='abs(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 49);
$fx='sqrt(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 7, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(3, 49.765);
$fx='int(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 49.765, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(7, 10);
$fx='o1-o2';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == -3, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=(7, 10);
$fx='ABS(o1-o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 3, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# INT(ox)
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('+3.5 mWat');
$fx='INT(o1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 3.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('-3,5 mWat');
$fx='INT(o1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == -3.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('3.5 mWat', '1,0 mWat');
$fx='INT(o1)+INT(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 4.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('+3.5 mWat', '-1,0 mWat');
$fx='INT(o1)+INT(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 2.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('+3.5 mWat', '+1,0 mWat');
$fx='INT(o1)+INT(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 4.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('+3.5 mWat', '-1,0 mWat');
$fx='INT(o1)-INT(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 4.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('+3.5 mWat', '+1,0 mWat');
$fx='INT(o1)-INT(o2)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 2.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# IF (cond,vok,vnok)
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('"power down"', '"power up"');
$fx='IF(o1 eq "power down",1,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 1, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('"power down"', '"power up"');
$fx='IF(o1 eq "power down",1,0)+IF(o2 eq "power up",1,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0]== 2 , "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('"power down"', '"power up"');
$fx='IF(o1 eq "power down",1,0)|IF(o2 eq "power up",1,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0]+$new_values->[1] == 2 , "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# CSV(ox,separator,value)
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('11,22,33', '2,4,6');
$fx='CSV(o1,",",3)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 33, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
@values=('11,22,33', '2,4,6');
$fx='CSV(o1,",",3)+CSV(o1,",",1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 44, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('11,22,33', '2,4,6');
$fx='CSV(o1,",",3)+CSV(o2,",",3)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 39, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# BIT(num,ox)
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('010101', '101010');
$fx='BIT(1)(o0)+BIT(2)(o1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 2, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# MAP()()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('0');
$fx='MAP(0)(0,1,0)|MAP(1)(1,0,0)|MAP(2)(0,0,1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 0) && ($new_values->[1] == 1) && ($new_values->[2] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('1');
$fx='MAP(0)(0,1,0)|MAP(1)(1,0,0)|MAP(2)(0,0,1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 0) && ($new_values->[2] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('2');
$fx='MAP(0)(0,1,0)|MAP(1)(1,0,0)|MAP(2)(0,0,1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 0) && ($new_values->[1] == 0) && ($new_values->[2] == 1), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('10');
#$fx='MAP(0)(2,0,0,0)|MAP(10)(2,1,0,0)|MAP(2)(0,0,2,0)|MAP(1)(0,0,0,2)|MAP(11)(0,1,0,2)|MAP(12)(0,1,2,0)';
$fx='MAP(0)(1,0,0,0)|MAP(10)(1,0.5,0,0)|MAP(2)(0,0,1,0)|MAP(1)(0,0,0,1)|MAP(11)(0,0.5,0,1)|MAP(12)(0,0.5,1,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 0.5) && ($new_values->[2] == 0) && ($new_values->[3] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('0');
#$fx='MAP(0)(2,0,0,0)|MAP(10)(2,1,0,0)|MAP(2)(0,0,2,0)|MAP(1)(0,0,0,2)|MAP(11)(0,1,0,2)|MAP(12)(0,1,2,0)';
$fx='MAP(0)(1,0,0,0,0,0)|MAP(10)(1,0.5,0,0,0,0)|MAP(2)(0,0,1,0,0,0)|MAP(1)(0,0,0,1,0,0)|MAP(11)(0,0.5,0,1,0,0)|MAP(12)(0,0.5,1,0,0,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 0) && ($new_values->[2] == 0) && ($new_values->[3] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('10');
#$fx='MAP(0)(2,0,0,0)|MAP(10)(2,1,0,0)|MAP(2)(0,0,2,0)|MAP(1)(0,0,0,2)|MAP(11)(0,1,0,2)|MAP(12)(0,1,2,0)';
$fx='MAP(0)(1,0,0,0,0,0)|MAP(10)(1,0.5,0,0,0,0)|MAP(2)(0,0,1,0,0,0)|MAP(1)(0,0,0,1,0,0)|MAP(11)(0,0.5,0,1,0,0)|MAP(12)(0,0.5,1,0,0,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 0.5) && ($new_values->[2] == 0) && ($new_values->[3] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
# MAPS()()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('running');
$fx='MAPS("running")(1,0)|MAPS("notRunning")(0,1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 0), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

#------------------------------------------------------------------------------
@values=('notRunning');
$fx='MAPS("running")(1,0)|MAPS("notRunning")(0,1)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 0) && ($new_values->[1] == 1), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# TABLE(MATCH)()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values= (           '1248:@:"notRunning"',           '1376:@:"notRunning"',           '1216:@:"notRunning"',           '1296:@:"notRunning"',           '1392:@:"running"',           '1184:@:"notRunning"',           '1264:@:"notRunning"',           '1360:@:"notRunning"',           '1200:@:"notRunning"',           '1440:@:"notRunning"',           '1424:@:"notRunning"',           '1232:@:"notRunning"',           '1280:@:"notRunning"',           '1312:@:"notRunning"',           '1328:@:"notRunning"',           '1456:@:"notRunning"'       );

$fx='TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 1) && ($new_values->[1] == 15), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# TABLE(SUM)()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values= (           '1248:@:"apache":@:10',           '1376:@:"apache":@:10',           '1216:@:"mysqld":@:5',           '1296:@:"notRunning"',           '1392:@:"running"',           '1184:@:"notRunning"',           '1264:@:"notRunning"',           '1360:@:"notRunning"',           '1200:@:"notRunning"',           '1440:@:"notRunning"',           '1424:@:"notRunning"',           '1232:@:"notRunning"',           '1280:@:"notRunning"',           '1312:@:"notRunning"',           '1328:@:"notRunning"',           '1456:@:"notRunning"'       );

$fx='TABLE(SUM)("apache")|TABLE(SUM)("mysqld")';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( ($new_values->[0] == 20) && ($new_values->[1] == 5), "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");


#------------------------------------------------------------------------------
# INT(ox)+IF()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
@values=('+3.5 mWat','"power down"');
$fx='INT(o1)+IF(o2 eq "power down",1,0)';
$new_values=$FXM->parse_fx($fx,\@values,\%desc);

ok( $new_values->[0] == 4.5, "$fx=$new_values->[0] >> values(ox)=@values | new_values(vx)=@$new_values");

