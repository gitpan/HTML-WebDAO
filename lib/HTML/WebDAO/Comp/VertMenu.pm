#$Id: VertMenu.pm,v 1.2 2004/01/22 08:02:15 zagap Exp $

package HTML::WebDAO::Comp::VertMenu;
use base qw(HTML::WebDAO::Component);
use HTML::WebDAO::Base;
attributes qw ( Color Select );
rtl_attributes qw (Par);
@Desc=("smpmenu","","Sample vertical manu");
use strict;
sub Init{
my ($self,@par)=@_;
my $menu=[];
while (my($evn,$name)=splice(@par,0,2)){
push @{$menu},{name=>$name,event=>$evn};
}
$self->Par($self->ref2str($menu));
$self->Color("C2DD8AB");
Select $self (${$menu}[0]->{event});
foreach (@$menu){
$self->RegEvent($_->{event},\&do_event);
}
}
sub do_event{
my ($self,$event,@par)=@_;
Select $self ($event);
}

sub PreFormat{
my $self=shift;
return ["<table border=0 width=30 cellpadding=0 cellspacing=10 bgcolor=FFFFFF><tr><td>"]
}
sub Work{
}
sub RandomHTMLColor{
my @chars=("A".."F","1".."9"); 
return join("",@chars[map {rand @chars} (1..7)]);
}

sub Format{
my ($self,$item)=@_;
my ($n1,$n2,$n3)=(split(/\|/,$item),1);
my $color=$self->Color();
my $sel_color=$color;
my $selected=$self->Select();
$sel_color="89D94D8" if ($n1=~/$selected/);
if ($n1=~/_info_off/) {$n1="_info",$n3=0};
if ($n1=~/_info_on/) {$n1="_info",$n3=1};
my $set_url=$self->GetURL({event=>{name=>$n1,value=>$n3}});
#my $sel_color=$self->RandomHTMLColor();
return eval '<<END
<table border=0 width=100 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
<a href=$set_url >
<table border=0 width=100 cellpadding=2 cellspacing=1 bgcolor=\"$sel_color\"><tr><td align=\"center\">

<table border=0 width=100 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
<table border=0 width=100 cellpadding=2 cellspacing=1 bgcolor=\"$color\"><tr><td align=\"center\">

 <font face=Verdana,Arial,Helvetica size=2 >
<a href=$set_url >$n2</a></font>
</td></tr></table>
</td></tr></table>

</td></tr></table>
</a>
</td></tr></table>
<table border=0 width=1 cellpadding=0 cellspacing=1 bgcolor=FFFFFF><tr><td>
</td></tr></table>
END';
}

sub PostFormat{
my $self=shift;
return ["</td></tr></table>"]
}

sub Fetch {
my $self=shift;
my $array_par=$self->str2ref($self->Par);
return [map {$_->{event}."|".$_->{name}} @{$array_par}];
}
1;
