#$Id: Component.pm,v 1.2 2004/03/09 20:34:26 zagap Exp $

package HTML::WebDAO::Component;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Element);
attributes qw(_info _edit_mode_on _info_mode_on);
use strict 'vars';
use Data::Dumper;


sub _sysinit {
my $self=shift;
$self->SUPER::_sysinit(@_);
RegEvent $self ("_info",\&InfoOn);
$self->_info("Off");
}

sub Init{
my $self=shift;
#$self->_info("Off");
}
sub SessionLoaded{
my $self=shift;
$self->SUPER::SessionLoaded();
#RegEvent $self ("_info",\&InfoOn);
}

sub InfoOn{
my ($self,$name,$par)=@_;
#logmsgs $self "InfoOn".Dumper($name,$par);
return unless defined($par);
($par==1) ? $self->_info("On") :$self->_info("Off");
}
#$self->GetURL({variable=>{
#			name=>Par,
#			value=>"10"},
#		event	=>{
#			name=>"_info_on",
#			value=>"10"
#			}})
#
sub GetURL {
my ($self,$ref)=@_;
my $res;
if (exists($ref->{variable})) {
 $ref->{variable}->{name}=$self->_runtime("_path2me").".".$ref->{variable}->{name} unless (!exists($ref->{variable}) && $ref->{variable}->{name} =~/^\./ && $ref->{variable}->{name}=~s/^\.//);
	}
$self->SendEvent("_sess_servise",{
		funct 	=> geturl,
		par	=> $ref,
		result	=> \$res
			});
return $res;
}

#??????
sub SetEvent{
my ($self,$event_name,$subaddr)=@_;
$event_name=$self->_runtime("_path2me").".".$event_name;
#logmsgs $self "reg event name :".$event_name;
$self->RegEvent($event_name,$subaddr);
return {name=>$event_name, value=>1}
}

#PrepareForm (\%hash,\%hash,"<br>,$string,\%hash)
sub PrepareForm{
my ($self,@par)=@_;
my @test;
foreach my $par (@par){
unless (ref($par)) {
	push @test,$par;
	next;
}
$par->{name}=$self->_runtime("_path2me").".".$par->{name} unless ($par->{name} =~/^\./ && $par->{name}=~s/^\.//);
if ($par->{type}=~/select/) {
my ($ref_val,$sel)=@$par{ref_values,selected};
my %hash=();
@hash{@$ref_val}=(0) x @$ref_val;
$hash{$sel}=1;
delete($par->{ref_values});delete($par->{selected});delete($par->{type});
push @test,join " ",("<select ",
			(map {"$_=\"".$par->{$_}."\""} keys %{$par}),
			">",
			join ("",map {"<option ".($hash{$_} ? "selected" : "").">$_</option>"}  @$ref_val),
			"</select >");
next;
}
push @test,join " ",("<input",(map {"$_=\"".$par->{$_}."\""} keys %{$par}),">");
}
return @test if (wantarray());
return join "",@test;
}
#Compile Form
sub CompileForm {
my ($self,$ref_to_params)=@_;
#my $ref_to_params = shift;
#my ($par,$url,$res);
my $res;
$self->SendEvent("_sess_servise",{
		funct 	=> getform,
		par	=> $ref_to_params,
		result	=> \$res
			});
return $$res;
}


sub Edit{
my $self=shift;
return (exists($self->{"Var"}->{editme})) ? 1:0;
}

sub _preformat{
my $self=shift;
if ( $self->_info()=~/On/){
my ($color_edit,$mode_edit)=($self->_edit_mode_on()?("red",0):("green",1));
my ($color_info,$mode_info)=($self->_info_mode_on()?("red",0):("yellow",1));
my $url_edit_mode=$self->GetURL({
			variable=>{	
				name => "_edit_mode_on",
				value=> $mode_edit
					}
				});
my $url_info_mode=$self->GetURL({
			variable=>{	
				name => "_info_mode_on",
				value=> $mode_info
					}
				});
return [eval '<<PREFORM;
<table border="0" cellpadding=0 cellspacing=1 bgcolor=red><tr><td>
<table border="0" cellpadding=0 cellspacing=0 bgcolor=white><tr><td align="right" valign="top">

<table border=0 width=30 height=10 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
	<a href='.$url_edit_mode.'>
	<table border=0 width=15 height=10 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
	<table border=0 width=15 height=10 cellpadding=0 cellspacing=0 bgcolor="$color_edit"><tr><td align="center">
	 <font face=Arial,Helvetica size=-4 >
	E</font>
	</td></tr></table>
	</td></tr></table>
	</a>
</td><td>
	<a href='.$url_info_mode.'>
	<table border=0 width=15 height=10 cellpadding=0 cellspacing=1 bgcolor=000000><tr><td>
	<table border=0 width=15 height=10 cellpadding=0 cellspacing=0 bgcolor="$color_info"><tr><td align="center">
	 <font face=Arial,Helvetica size=-4 >
	I</font>
	</td></tr></table>
	</td></tr></table>
	</a>
</td></tr></table>

</td></tr><tr><td>
<table border="0"><tr><td>
PREFORM'];
}
return [];
}
sub _postformat{
my $self=shift;
if ($self->_info()=~/On/){
return [eval '<<PREFORM;
</td></tr></table>
</td></tr></table>
</td></tr></table>

PREFORM'];
}
return [];
}

sub _format{
my $self=shift;
my @res;
return $self->SUPER::_format(@_) unless Edit $self ;
return \@res; 
}
sub PreEdit{};
sub Editing{};
sub PostEdit{};
1;
