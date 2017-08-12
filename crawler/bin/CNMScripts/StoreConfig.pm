#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/StoreConfig.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::StoreConfig;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::StoreConfig
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_store_dir} = $arg{store_dir} || '/opt/data/app-data/remote_cfgs';
   $self->{_store_limit} = $arg{store_limit} || 10;
   $self->{_url_base} = $arg{url_base} || './user/remote_cfgs';

   return $self;
}

#----------------------------------------------------------------------------
# store_dir
#----------------------------------------------------------------------------
sub store_dir {
my ($self,$store_dir) = @_;
   if (defined $store_dir) {
      $self->{_store_dir}=$store_dir;
   }
   else { return $self->{_store_dir}; }
}

#----------------------------------------------------------------------------
# store_limit
#----------------------------------------------------------------------------
sub store_limit {
my ($self,$store_limit) = @_;
   if (defined $store_limit) {
      $self->{_store_limit}=$store_limit;
   }
   else { return $self->{_store_limit}; }
}

#----------------------------------------------------------------------------
# url_base
#----------------------------------------------------------------------------
sub url_base {
my ($self,$url_base) = @_;
   if (defined $url_base) {
      $self->{_url_base}=$url_base;
   }
   else { return $self->{_url_base}; }
}

#------------------------------------------------------------------------------------------
# get_stored_files
#
#------------------------------------------------------------------------------------------
sub get_stored_files  {
my ($self,$ip)=@_;

   my $STORE_DIR = $self->store_dir();
   my $STORE_LIMIT = $self->store_limit();

   #--------------------------------------------------------------------------------------
   # Se obtinen los ficheros almacenados
   my $STORE_DIR_DEVICE = $STORE_DIR .'/'.$ip;
   if (! -d $STORE_DIR_DEVICE) { return; }
   opendir (DIR,$STORE_DIR_DEVICE);
   my @cfg_files =  grep { -f "$STORE_DIR_DEVICE/$_" }   readdir(DIR);
   closedir(DIR);
   my @sorted_cfg_files = sort { $b cmp $a } @cfg_files;
	return \@sorted_cfg_files;
}

#------------------------------------------------------------------------------------------
# limit_stored_files
#
#------------------------------------------------------------------------------------------
sub limit_stored_files  {
my ($self,$ip)=@_;

	my $STORE_DIR = $self->store_dir();
	my $STORE_DIR_DEVICE = $STORE_DIR .'/'.$ip;
	my $STORE_LIMIT = $self->store_limit();

	my $stored_files = $self->get_stored_files($ip);

	#--------------------------------------------------------------------------------------
	# Se eliminan los que sobran (segun el limite de almacenamiento definido)
	my $NFILES = scalar (@$stored_files);
	my $extra = $NFILES-$STORE_LIMIT;
	while ($extra>=0) {
   	my $f = pop @$stored_files;
   	unlink "$STORE_DIR_DEVICE/$f";
   	$extra-=1;
	}
}

#------------------------------------------------------------------------------------------
# store_file
# Almacena el fichero solo si es diferente al ultimo
# Tambien controla que el numero de ficheros almacenados no sobrepase store_limit
#------------------------------------------------------------------------------------------
sub store_file  {
my ($self,$ip,$data)=@_;

	my $ts=time;
	my $STORE_LIMIT = $self->store_limit();
	my $STORE_DIR = $self->store_dir();
	my $STORE_DIR_DEVICE = $STORE_DIR .'/'.$ip;
   if (! -d $STORE_DIR_DEVICE) {  `/bin/mkdir -p $STORE_DIR_DEVICE`;  }

	my $stored_files = $self->get_stored_files($ip);
	my $last_stored_file = $stored_files->[0];

   #--------------------------------------------------------------------------------------
   # Se eliminan los que sobran (segun el limite de almacenamiento definido)
   my $NFILES = scalar (@$stored_files);
   my $extra = $NFILES-$STORE_LIMIT;
   while ($extra>=0) {
      my $f = pop @$stored_files;
      unlink "$STORE_DIR_DEVICE/$f";
      $extra-=1;
   }

   #--------------------------------------------------------------------------------------
	# Solo se almacena el fichero si es distinto delultimo guardado
	my $file_cfg = $STORE_DIR_DEVICE.'/'.$ip.'-'.$ts;

	my $cfg = join ('',@$data);	
	my $new_sign=md5_hex($cfg);

	my $previous_file = $STORE_DIR_DEVICE.'/'.$stored_files->[0];
	$cfg = $self->slurp_file($previous_file);	
	my $old_sign=md5_hex($cfg);


	if ($new_sign eq $old_sign) { 

#http://10.2.254.222/onm/remote_cfgs/192.168.1.254/192.168.1.254-1333735317
		$ts = ($last_stored_file =~ /\S+-(\d+)$/) ? $1  : 0 ;
      my $url = $self->url_base().'/'.$ip.'/'.$last_stored_file;
      my $file_url = '<a onclick="winopen(this.href,this.target,900,600,1); return false;" target="_blank" href="'.$url.'">'.$self->time2date($ts).'</a>';

		return {'rc'=>'[OK]', 'rcstr'=>"SIN CAMBIOS - No se genera fichero", 'file'=>$file_url, 'changes'=>''}; 
	}


	open (F,">$file_cfg");
	foreach my $l (@$data) { print F $l; }
	close F;

	#----------------------------------------------------------------------------
	my $diff_vector = $self->check_files($ip,[$file_cfg, $last_stored_file]);
	my $changes = $diff_vector->[0]->{'changes'};

	#----------------------------------------------------------------------------
   my $url = $self->url_base().'/'.$ip.'/'.$file_cfg;
   my $file_url = '<a onclick="winopen(this.href,this.target,900,600,1); return false;" target="_blank" href="'.$url.'">'.$self->time2date($ts).'</a>';

	return {'rc'=>'[OK]', 'rcstr'=>"CON CAMBIOS - Se genera fichero", 'file'=>$file_url, 'changes'=>$changes}; 
}

#----------------------------------------------------------------------------
# exclude_lines
#----------------------------------------------------------------------------
sub exclude_lines {
my ($self,$indata,$exclude_vector)=@_;

	my @outdata=();
  	my $include = 1;
	my ($pattern,$mode);
	foreach my $l (@$indata) {
		my $line=$l;
   	chomp $l;
   	foreach my $x (@$exclude_vector) {
			($pattern,$mode)=($x->{'pattern'},$x->{'mode'});
      	if ($l=~/$pattern/) { 
				$include = 0; 
				last;
			}
   	}
		if ($include) { push @outdata,$line; }
		if ($mode == 0) { $include = 1; }
	}
	return \@outdata;
}


#----------------------------------------------------------------------------
# check_files
#----------------------------------------------------------------------------
sub check_files {
my ($self,$ip,$stored_files)=@_;

   my $STORE_LIMIT = $self->store_limit();
   my $STORE_DIR = $self->store_dir();
   my $STORE_DIR_DEVICE = $STORE_DIR .'/'.$ip;
	my @DIFFERENCES=();

	if ( (! defined $stored_files) || (ref($stored_files) ne 'ARRAY') ) {
		$stored_files = $self->stored_files();
	}

#	opendir (DIR,$STORE_DIR_DEVICE);
#	my @cfg_files =  grep { -f "$STORE_DIR_DEVICE/$_" }   readdir(DIR);
#	closedir(DIR);

	my $NFILES = scalar (@$stored_files);
	if ($NFILES <= 1) {
   	return [{ 'file'=>'', 'ins'=>0 , 'del'=>0, 'changes'=>"NADA QUE HACER (Hay $NFILES ficheros)"}];
	}

#	my @sorted_cfg_files = sort { $b cmp $a } @cfg_files;
	# 0 mas reciente $NFILES-1 mas antiguo
	for my $n (0..$NFILES-2) {

	   my $file_last = $STORE_DIR_DEVICE .'/'.$stored_files->[$n];
   	my $file_previous = $STORE_DIR_DEVICE .'/'.$stored_files->[$n+1];

		my %result=('file'=>'' , 'ins'=>0 , 'del'=>0, 'changes'=>'' );
		#$result{'file'} = ($file_last =~ /\S+-(\d+)$/) ? $self->time2date($1)  : '' ;
		my $ts = ($file_last =~ /\S+-(\d+)$/) ? $1  : 0 ;

			
		my $url = $self->url_base().'/'.$ip.'/'.$ip.'-'.$ts;
		$result{'file'} = '<a onclick="winopen(this.href,this.target,900,600,1); return false;" target="_blank" href="'.$url.'">'.$self->time2date($ts).'</a>';
		#$result{'file'} = '<a href="'.$url.'" target="_blank">'.$self->time2date($ts).'</a>';

#http://10.2.254.222/onm/remote_cfgs/192.168.1.254/192.168.1.254-1333735317


#		if ($file_last =~ /\S+-(\d+)$/) { $result{'file'} = $1; }
#		if ($file_previous =~ /\S+-(\d+)$/) { $result{'date2'} = $1; }
#   	print '-'x80 ."\n";
#   	print "file_last=$file_last\n";
#   	print "file_previous=$file_previous\n";

   	# "Unified", "Context", "OldStyle",
   	$result{'changes'} = diff $file_last, $file_previous, { STYLE => "Unified"};

		my @output = split (/\n/, $result{'changes'});
		foreach my $l (@output) {
			if ( ($l =~ /^-/) && ($l !~ /^---/)) { $result{'del'} +=1; }
			if ( ($l =~ /^\+/) && ($l !~ /^\+\+\+/)) { $result{'ins'} +=1; }
		}

		push @DIFFERENCES, \%result;
	}

	return \@DIFFERENCES;
}

#----------------------------------------------------------------------------
# slurp_file
#----------------------------------------------------------------------------
sub slurp_file {
my ($self,$file)=@_;

   #local($/) = undef;  # slurp
   open (F,"<$file");
   my @content = <F>;
   close F;
   return join ('',@content);
}

1;
__END__

