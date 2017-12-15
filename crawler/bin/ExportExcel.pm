package ExportExcel;
#------------------------------------------------------------------------
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#------------------------------------------------------------------------
use Excel::Writer::XLSX;
use Excel::Writer::XLSX::Utility;
use Data::Dumper;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo ExportExcel
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

bless {
      _filename =>$arg{'filename'} || '/tmp/export.xlsx',
      _workbook =>$arg{'workbook'} || undef,
   }, $class;

}

#----------------------------------------------------------------------------
# filename
#----------------------------------------------------------------------------
sub filename {
my ($self,$filename) = @_;
   if (defined $filename) {
      $self->{_filename}=$filename;
   }
   else { return $self->{_filename}; }
}

#----------------------------------------------------------------------------
# workbook
#----------------------------------------------------------------------------
sub workbook {
my ($self,$workbook) = @_;
   if (defined $workbook) {
      $self->{_workbook}=$workbook;
   }
   else { return $self->{_workbook}; }
}


#-----------------------------------------------------------------------
sub create_workbook {
my ($self)=@_;

   my $filename = $self->filename();
   my $workbook  = Excel::Writer::XLSX->new( $filename );
   my $date_format = $workbook->add_format( num_format => 'dd/mm/yyyy' );
	$self->workbook($workbook);
   return 1;
}

#-----------------------------------------------------------------------
sub close_workbook {
my ($self)=@_;

   my $workbook= $self->workbook();
	$workbook->close();
   return 1;
}


#-----------------------------------------------------------------------
sub data_sheet {
my ($self,$data,$params)=@_;

	if (!defined $params) { $params = { 'sheet' => '' }; }
	if (!exists $params->{'sheet'}) { $params->{'sheet'} = 'Data'; }
	if (!exists $params->{'origin'}) { $params->{'origin'} = 'A1'; }

	my $workbook = $self->workbook();
   my $worksheet = $workbook->add_worksheet($params->{'sheet'});

	#0,1,2
	if (exists $params->{'hide_gridlines'}) { $worksheet->hide_gridlines($params->{'hide_gridlines'}); }
	if (exists $params->{'landscape'}) { 
		$worksheet->set_landscape();
		$worksheet->center_horizontally();
	}
	my $alert_threshold = undef;
	if (defined $params->{'alert_threshold'}) { 
		$alert_threshold = $params->{'alert_threshold'};
	}


	#FML --> Poner opcion header+footer
   if ((exists $params->{'image_header'}) && (-f $params->{'image_header'})) {
		$worksheet->set_header( '&L&G&RInforme de Capacidad', 0.3, { image_left => $params->{'image_header'} });
   }
	$worksheet->set_footer('&C&P de &N');


   my ($row0, $col0) = xl_cell_to_rowcol($params->{'origin'});
	my ($row, $col) = ($row0, $col0);
   my @fields=();

#print "***DEBUG**\n";
#print Dumper($data);
#print "***DEBUG**\n";

	my %font_std = (
    	font  => 'Calibri',
    	size  => 10,
    	color => 'black',
		num_format => '#,##0.00',
	);

   my %font_bold = (
    	size  => 12,
      bold  => 1,
		bottom =>1,
   );

   my %font_header_left = (
      size  => 12,
      bold  => 1,
      bottom =>1,
   );
 
	my $col0_width = (exists $params->{'col0_width'}) ? $params->{'col0_width'} : 20;
	my $col1n_width = (exists $params->{'col1n_width'}) ? $params->{'col1n_width'} : 6;
   $worksheet->set_column( 0, 0, $col0_width );
   $worksheet->set_column( 1, 55, $col1n_width );

	my $format_title_left = $workbook->add_format( %font_std, %font_header_left ); 
	my $format_title = $workbook->add_format( %font_std, %font_bold ); 
	my $format_cell_std = $workbook->add_format( %font_std ); 

   foreach my $key (sort keys %{$data->{'cols'}}) {
      $worksheet->write( $row, $col, $data->{'cols'}->{$key}->{'title'}, $format_title );
      push @fields, $data->{'cols'}->{$key}->{'field'};
      $col++;
   }

   foreach my $key (sort keys %{$data->{'data'}}) {
      $col=$col0;
      $row++;
      foreach my $field (@fields) {
			if (exists $data->{'data'}->{$key}->{$field}) {
         	$worksheet->write( $row, $col, $data->{'data'}->{$key}->{$field}, $format_cell_std );
			}
         $col++;
      }
   }


	my $last_row = $row;

	my %series=();
	foreach my $i (1..scalar(@fields)-1) {
		my %x=();
		$x{'categories'} = "='".$params->{'sheet'}."'!".xl_rowcol_to_cell($row0+1, $col0, 1, 1).':'.xl_rowcol_to_cell($last_row, $col0, 1, 1);		
		$x{'values'} = "='".$params->{'sheet'}."'!".xl_rowcol_to_cell($row0+1, $col0+$i, 1, 1).':'.xl_rowcol_to_cell($last_row, $col0+$i, 1, 1);		

		$x{'name'} = $fields[$i];
		$series{$x{'name'}} = \%x;
	}


   my $first_cell = xl_rowcol_to_cell($row0+1, $col0+1, 1, 1);
   my $last_cell = xl_rowcol_to_cell($last_row, $col0+scalar(@fields)-1, 1, 1);
   my $last_col = xl_rowcol_to_cell(0, $col0+scalar(@fields)-1, 1, 1);

   #if (exists $params->{'chart_title'}) {
	#	$worksheet->write( $last_col, $params->{'chart_title'}, $format_title_left );
	#}


	# Conditional formatting
	if (defined $alert_threshold) {
		# Celda en alerta rojo en negrita sobre fondo rojo)
		my $format_cell_alert = $workbook->add_format(
   		bg_color => '#FFC7CE',
    		color    => '#9C0006',
 
		);

		$worksheet->conditional_formatting( "$first_cell:$last_cell",
   		{
      		type     => 'cell',
        		criteria => '>=',
        		value    => $alert_threshold,
        		format   => $format_cell_alert,
    		}
		);

	}

# series: [   {categories=>'=Data!$A$2:$A$28', values=>'=Data!$C$2:$C$28', name=>'Element Name' },
#          {} ... {} ]

	return \%series;
}


#-----------------------------------------------------------------------
# IN: $params -> { k=>v }
#     sheet : Nombre de la hoja del dashboard
#     series: { 'Element Name 01' =>  {categories=>'=Data!$A$2:$A$28', values=>'=Data!$C$2:$C$28', name=>'Element Name 01' },
#               'Element Name 02' =>  {categories=>'=Data!$A$2:$A$28', values=>'=Data!$D$2:$D$28', name=>'Element Name 02' },
#					 ... 'Element Name 0N' => {} ]
#		tpl	: [ {'position'=>'B1', 'chart_type'=>'column', 'chart_title'=>'Titulo del grafico', 'chart_data'=>[] }
#-----------------------------------------------------------------------
sub dashboard_create {
my ($self,$params)=@_;

   if (!defined $params) { $params = { 'sheet' => '' }; }
   if (!exists $params->{'sheet'}) { $params->{'sheet'} = 'Dashboard'; }
   if (!exists $params->{'series'}) { return; }

   my $workbook = $self->workbook();
	my $worksheet_dashboard = $workbook->get_worksheet_by_name($params->{'sheet'});
	if (! $worksheet_dashboard) { 
   	$worksheet_dashboard = $workbook->add_worksheet($params->{'sheet'});
	}
   $worksheet_dashboard->hide_gridlines(2);

   if (exists $params->{'landscape'}) {
      $worksheet_dashboard->set_landscape();
      $worksheet_dashboard->center_horizontally();
   }

	#---------------------
	foreach my $x (@{$params->{'tpl'}}) {

		my $position = $x->{'position'};
		my $chart_data = $x->{'chart_data'};
		# area | bar | column | line | pie | doughnut | scatter | stock | radar
		my $chart_type = (exists $x->{'chart_type'}) ? $x->{'chart_type'} : 'column';
		my $chart_title = (exists $x->{'chart_title'}) ? $x->{'chart_title'} : 'Titulo del grafico';
		my $chart_width = (exists $x->{'chart_width'}) ? $x->{'chart_width'} : '480';
		my $chart_height = (exists $x->{'chart_height'}) ? $x->{'chart_height'} : '288';
		my $xname = (exists $x->{'xname'}) ? $x->{'xname'} : 'Valores';
		my $yname = (exists $x->{'yname'}) ? $x->{'yname'} : 'Elementos';


		my $chart = $self->create_chart({ 

				'chart_type' => $chart_type, 
				'chart_title'=>$chart_title, 
				'chart_width'=>$chart_width, 
				'chart_height'=>$chart_height, 
				'xname'=>$xname, 
				'yname'=>$yname, 
				'series'=>$params->{'series'}, 
				'chart_data'=>$chart_data 

		});

   	$worksheet_dashboard->insert_chart( $position , $chart );

	}
}

#-----------------------------------------------------------------------
# create_chart
#-----------------------------------------------------------------------
# IN:	$params -> { k=>v }
#		chart_type 		: Tipo de grafico
#		chart_title		: Titulo del graico
#		chart_width		: Ancho del grafico
#		chart_height	: Alto del grafico
#		series	: [ 	{categories=>'=Data!$A$2:$A$28', values=>'=Data!$C$2:$C$28', name=>'Element Name' }, 
#							{} ... {} ]
#-----------------------------------------------------------------------
sub create_chart {
my ($self,$params)=@_;

   if (!defined $params) { $params = { 'chart_type' => 'column', 'chart_title'=>'Title', 'chart_width'=>'480', 'chart_height'=>'288',}; }
	if (!exists $params->{'series'}) { return; }
   if (!exists $params->{'chart_type'}) { $params->{'chart_type'} = 'column'; }
   if (!exists $params->{'chart_title'}) { $params->{'chart_title'} = 'Title'; }
   if (!exists $params->{'chart_width'}) { $params->{'chart_width'} = '480'; }
   if (!exists $params->{'chart_height'}) { $params->{'chart_height'} = '288'; }
	my $xname = (exists $params->{'xname'}) ? $params->{'xname'} : 'Valores'; 
	my $yname = (exists $params->{'yname'}) ? $params->{'yname'} : 'Elementos'; 

	my $workbook = $self->workbook();

#print Dumper($params);

   my $chart = $workbook->add_chart( type => $params->{'chart_type'}, embedded => 1 );
	$chart->set_size( width=>$params->{'chart_width'}, height=>$params->{'chart_height'} );

   $chart->set_title(
      name => $params->{'chart_title'},
      name_font => {
         name  => 'Calibri',
         size => '12',
         color => '#595959',
      },
   );

   $chart->set_x_axis( name => $xname ,num_font => { name => 'Calibri', size => 9, color => 'grey' } );
   $chart->set_y_axis( name => $yname , num_font => { name => 'Calibri', size => 9, color => 'grey' } );
   $chart->set_legend( position => 'bottom' );
	my @colors = ('#FFCC66', '#93CDDD', '#FFCC66', '#93CDDD');

	my $i=0;
	foreach my $name (@{$params->{'chart_data'}}) {
	
		my $categories = $params->{'series'}->{$name}->{'categories'};	
		my $values = $params->{'series'}->{$name}->{'values'};	


#print "categories=$categories\n";
#print "values=$values\n";
#print "name=$name\n";
 	
	   $chart->add_series(
   	   categories => $categories,
      	values     => $values,
      	name       => $name,
      	column     => { color => $colors[$i] },
   	);

		$i++;

	}

	return $chart;
}

1;


