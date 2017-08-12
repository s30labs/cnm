#!/usr/bin/perl -w
use strict;

package mylock;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw(init_lock close_lock);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';



sub init_lock
{
  my ($lock_file,$max_lock_seconds,$kill,$log_text)=@_;
  my $act_time=time;
  my $mypid=$$;

  if (! -r  $lock_file)
   {
    system("echo $mypid > $lock_file");
    return(0);
   }
  else
   {
    # ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
    # data[9] es $mtime;
      my @data = stat($lock_file);
      my $chktime=($act_time - $data[9]);
      if ($chktime > $max_lock_seconds  )
       {
        if ($kill==0){print "$log_text\n"; return(1);}
        else
         {
          open (FICH,"< $lock_file");
          my @dat=<FICH>;
          my $pid=$dat[0];
          if ($pid )
          {
           $pid=~ s/\n//g;
           if ( -r "/proc/$pid")
             {
              system ("kill -9 $pid");
             }
          }
          system("echo $mypid > $lock_file");
          return(0);
         }
       }
     else {return(1);}
   }
}

sub close_lock
{
 my $lock_file = shift;
 system("rm -f $lock_file");
}
#
#my $res = &init_lock('/opt/lock/p.lock',10,1,"Mensaje de log");
#if ($res == 1){print "Fichero de bloqueo activo, exit\n";exit;}
#sleep (120);
#&close_lock('lock.lock');


#my $lock='/var/manage_port.lock';
#my $res = &init_lock($lock,600,1,"Bloqueo por fichero");


