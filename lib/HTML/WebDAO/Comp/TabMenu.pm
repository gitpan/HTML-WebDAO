#$Id: TabMenu.pm,v 1.3 2004/01/22 08:02:15 zagap Exp $

package HTML::WebDAO::Comp::TabMenu;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Activator  HTML::WebDAO::Component);
#attributes qw (MenuMap);
@Desc=("tabmenu","","Sample tabs manu");
use strict 'vars';
use Data::Dumper;

sub _sysinit{
my $self=shift;
#First invoke parent _init;
$self->SUPER::_sysinit(@_);
#Store subtree of parametrs for use at later when 
#store tmp of objects
$self->_runtime("_tmp_items",{});
}


#[{name=>item1, color=>red}, {name=>item1, color=>blue, file=>"page1.html"}]
#
#
sub Init {
my ($self,$par)=@_;
my $menu=ref($par) 
		? 	$par 
		:	[{
		name=>"dummy1",
		color=>"red",
		},{
		name=>"dummy2",
		color=>"green"
		},{
		name=>"dummy3",
		color=>"blue"
		},{
		name=>"dummy4",
		color=>"yellow"
		}
		];
#my %hash;
#my %hash1;
#my $i;
#foreach my $rec (@$par){
#	my ($objects,$name,$color)=@$rec{qw/objects name color/};
#		$i++;
#		$hash{$i}=$objects;
#		$hash1{$i}={ 
#			name=>$name,
#			color=>$color
#			};
#	}
#$self->SUPER::Init(\%hash);
#MenuMap $self $self->ref2str(\%hash1);
$self->InitMenu($menu);
}
sub InitMenu{
my ($self,$par)=@_;
my (%hash,%hash1,$i);
foreach my $rec (@$par){
	my ($objects,$name,$color)=@$rec{qw/objects name color/};
		$i++;
		$hash{$i}=$objects;
		$hash1{$i}={ 
			name=>$name,
			color=>$color
			};
	}
$self->InitItems(\%hash);
MenuMap $self $self->ref2str(\%hash1);
}

sub Selected{
return 	shift()->ActiveItem();
}

sub TmpItems {
my ($self,$par)=@_;
if ($par) {$self->_runtime("_tmp_items",$par)}
return $self->_runtime("_tmp_items")
}
sub MenuMap {
my ($self,$par)=@_;
if ($par) {
	$self->set_attribute("MenuMap",$par);
	$self->TmpItems($self->str2ref($par));
}
return $self->ref2str($self->TmpItems());

}
sub DrawMenu{
my ($self)=@_;
my $str;
my %hash_map=%{$self->TmpItems()};
foreach my $key (keys %hash_map){
my (	$name		,
	$item_color	,
	$flag_color	,
	$url4set	,	
		)=(
	$hash_map{$key}->{name},
	$key == $self->Selected() ? "white":"lightgray",
	$key == $self->Selected() ? "red":"white",
	$self->GetURL({variable=>{name=>"ActiveItem",value=>$key}})
	);
$str.=eval'<<END
<td bgcolor="$item_color"><a href="$url4set">
<table border=0 width=100 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
<table border=0 width=100 cellpadding=2 cellspacing=1 bgcolor=FFFFFF><tr>
<td align="center" bgcolor=$item_color>
<table border=0 ><tr><td>
     <table border=0  cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
     <table border=0  cellpadding=2 cellspacing=1 bgcolor=FFFFFF><tr><td align="center" bgcolor=$flag_color>

     </td></tr></table>
     </td></tr></table>
</td><td>
     <font face=Verdana,Arial,Helvetica size=2 >
     <a href=$url4set >$name</a></font>
</td></tr></table>
</td></tr></table>
</td></tr></table>
</a>
</td>
END'
}
return [eval '<<END
<table border=0><tr>
$str
</tr></table>
END']
}

sub PreFormat{
my $self=shift;
return [eval '<<END
<table border=0  cellpadding=0 cellspacing=1 bgcolor=white><tr><td>
@{$self->DrawMenu()}
</td></tr><td height=500 bgcolor=lightgray>
<table border=0 width=100% height=100% cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
<table border=0 width=100% height=100% cellpadding=2 cellspacing=1 bgcolor=FFFFFF><tr><td align=\"center\">
END']
}

sub _Format{
my ($self,$item)=@_;
return eval '<<END;
<b>TabMenu</b>
END'
}

sub PostFormat{
my $self=shift;
return ["</td></tr></table>
</td></tr></table>
</td></tr></table>"]
}

1;
