#$Id: Graph.pm,v 1.1.1.1 2003/12/31 09:57:23 zagap Exp $

package HTML::WebDAO::Comp::Graph;
use GD::Graph::bars3d;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Comp::Image);
#@ISA=("image");
attributes qw(Text_color Bar1_color Bar2_color Back_color Title Mode Data);
@Desc=("graph","","Simple graphics");
use strict 'vars';

sub Init{
my $self=shift;
Text_color	$self ("black");
Bar1_color	$self ("red");
Bar2_color	$self ("green");
Back_color	$self ("white");
Title		$self ("Average Commute Time: 3D Bar Charts");
Mode		$self (0);
Data  $self  ($self->ref2str([
    [ qw( Mon  Tue  Wed  Thu  Fri ) ],
    [      rand(40),  rand(40),  rand(40),  rand(40), rand(40)   ],
    [      rand(40),  rand(40), rand(40),  rand(40),  rand(40)   ],
]));

${$self->_format_subs()}[1]=sub{$self->MyFormat(@_)};
}

sub OutRaw{
my ($self,$sess)=@_;
set_header $sess ("-TYPE","image\/png");
print $sess->print_header();
binmode STDOUT; #for perl for Windoze

my $graph = new GD::Graph::bars3d( 400, 300 );
#my @data  = (
#    [ qw( Mon  Tue  Wed  Thu  Fri ) ],
#    [      33,  24,  23,  19,  21   ],
#    [      17,  15,  19,  15,  24   ],
#);
my @data=@{$self->str2ref($self->Data)};
$graph->set( 
    title           => $self->Title,
    x_label         => "Day",
    y_label         => "Minutes",
    long_ticks      => 1,
    y_max_value     => 40,
    y_min_value     => 0,
    y_tick_number   => 8,
    y_label_skip    => 2,
    bar_spacing     => 4,
    accent_treshold => 400,
    dclrs	    =>[$self->Bar1_color,$self->Bar2_color],
    boxclr   =>$self->Back_color
);
$graph->set_legend( "Morning", "Evening" );
$graph->set_text_clr($self->Text_color);
#$graph->shadowclr($self->Back_color);
my $gd_image = $graph->plot( \@data );
print $gd_image->png;
$sess->store_session($self->GetEngine);
}
sub MyPreFormat{
my $self=shift;
my $res=$self->PreFormat(@_);
unshift @$res,eval "<<PRE_TABLE;
<table border=0 ><tr><td>
PRE_TABLE";
return $res;
}
sub MyPostFormat{
my $self=shift;
my $res=$self->PostFormat(@_);
push @$res,"</td><td>",$self->Form(),"</td></tr></table>";
return $res;
}
sub Mode {
my ($self,$val)=@_;
if ($val) {
	$self->_format_subs([
		sub{$self->MyPreFormat(@_)},
		sub{$self->Format(@_)},
		sub{$self->MyPostFormat(@_)}
	]);
	$self->SendEvent("_switch_sos",{
			obj_ref=>$self,
			obj_method=>"DrawEdit"
			});
	}
return 0;
}

sub Form {
my $self=shift;
my @res;
my $GD_colors=[	white, lgray, gray, dgray, black, lblue, blue, 
		dblue, gold, lyellow, yellow, dyellow, lgreen,
		green, dgreen, lred, red, dred, lpurple, purple,
		dpurple, lorange, orange, pink, dpink, marine,
		cyan, lbrown, dbrown];
sort @$GD_colors;
push @res,$self->PrepareForm(
#onChange=submit()
#	{type=>text,name=>Text_color,size=>20,value=>$self->Text_color()},
	"Image Property",
	"<table bgcolor='#C0C0C0' border='1'><tr><td>",
	"<font face=Verdana,Arial,Helvetica size=-1 >",
	"text","</td><td>",
	"</font>",
	{type=>input,name=>Title,value=>$self->Title,onChange=>'submit()',size=>10},
	"</td></tr><tr><td>",
	"<font face=Verdana,Arial,Helvetica size=-1 >",
	"text","</td><td>",
	"</font>",
	{type=>"select",name=>Text_color,ref_values=>$GD_colors,
			selected=>$self->Text_color,onChange=>'submit()'},
	"</td></tr><tr><td>",
	"<font face=Verdana,Arial,Helvetica size=-1 >",
	"Morning bars",
	"</font>",
	"</td><td>",
	{type=>"select",name=>Bar1_color,ref_values=>$GD_colors,
			selected=>$self->Bar1_color,onChange=>'submit()'},
	"</td></tr><tr><td>",
	"<font face=Verdana,Arial,Helvetica size=-1 >",
	"Evening bars",
	"</font>",
	"</td><td>",
	{type=>"select",name=>Bar2_color,ref_values=>$GD_colors,
			selected=>$self->Bar2_color,onChange=>'submit()'},
	"</td></tr><tr><td>",
	"<font face=Verdana,Arial,Helvetica size=-1 >",
	"Background",
	"</font>",
	"</td><td>",
	{type=>"select",name=>Back_color,ref_values=>$GD_colors,
			selected=>$self->Back_color,onChange=>'submit()'},
	"</td></tr>",
	"</table>",
	'<div><input type="submit" value="Close" onclick="javascript:opener.document.location.reload();window.close()"></div>'
	);
return $self->CompileForm({data=>\@res,url=>$self->GetURL({variable=>{name=>"Mode",value=>1}})});
}

sub PreFormat{
my $self=shift;
return ["<table border=0 width=420 height=320><tr><td>"]
}

sub Fetch {
my $self=shift;
my $url=$self->GetImageURL;
return ["<img SRC=\"$url\" border=0>"];
}
sub MyFormat{
my ($self,$var)=@_;
my $url=$self->GetURL({variable=>{name=>"Mode",value=>1}});
my $str_open=eval '<<END;
onClick="window.open(\'${url}\',\''.$self->MyName().'\', \'scrollbars=no, resizable=no, width=640, height=355\'); return false;"
END';
return "<a href=$url $str_open>".$var."</a>";
}
sub DrawEdit {
my ($self,$sess)=@_;
print $sess->print_header();
print @{$self->_format};
$sess->store_session($self->GetEngine);
}

sub PostFormat{
my $self=shift;
#my $url=$self->GetURL({variable=>{name=>"Mode",value=>1}});
#my $str_open=eval '<<END;
#onClick="window.open(\'${url}\',\''.$self->MyName().'\', \'scrollbars=no, resizable=no, width=600, height=355\'); return false;"
#END';
return ["</td></tr><tr ><td align ='center'></td></tr></td></table>"];
#return ["</td></tr><tr ><td align ='center'><a href=$url $str_open>Edit</a></tr></td></table>"];
#return ["</td></tr><tr ><td align ='center'><img src='http://www.learn.zag/doc/perlbookshelf/gifs/txtnexta.gif' $str_open></tr></td></table>"];
}
1;
