#$Id: Engine.pm,v 1.3 2004/03/09 20:34:26 zagap Exp $

package HTML::WebDAO::Engine;
use Data::Dumper;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Container);
use Carp;
#use strict;
attributes qw(Par);
sub _sysinit{
my ($self,$ref)=@_;
#! Setup $init_hash;
my $my_name=shift(@{$ref});
unshift(@{$ref},{
	ref_engine=>$self,	#! Setup _engine refernce for childs!
	name_obj=>"$my_name"});	#! Setup _my_name 
#	name_obj=>"applic"});	#! Setup _my_name 
$self->SUPER::_sysinit($ref);
#!init _runtime variables;
$self->_set_parent($self);

#hash "function" -"package"
$self->_runtime("_obj",{});
#hash "function" - "describtion"
$self->_runtime("_describe",{});
#hash "function" - "use"
$self->_runtime("_use",{});
#init hash of evens names  -> @Array of pointers of sub in objects
$self->_runtime("_events",{});


}

sub Init{
my ($self,$raw_html)=@_;
#Register modules;
sub find_desc {
my ($pkg_name)=@_;
foreach my $key ( sort grep {!/main::/} keys %{"$pkg_name"})
{   
   if ($key=~/::$/) { 
   	find_desc($pkg_name.$key)
	    } else {
    	(my $prepared=$pkg_name)=~s/::$//;
	 $self->RegistrPack($prepared) if $key=~/Desc/;
    }
}
}#find_desc
find_desc('main::');

#Create childs from source
foreach( @{$self->_parse_html($raw_html)}){
$self->AddChild($_);
$self->Par("hi");
}
#register event _sess_loaded
$self->RegEvent($self,"_sess_loaded",\&SessionLoaded);
}

sub SessionLoaded {
my ($self,$event_name,$par)=@_;
#logmsgs $self q/SessionLoaded/;
#$self->_session_loaded();
$self->SUPER::SessionLoaded;
}

sub SetParam {
my ($self,$par_ref)=@_;
    my $ref;
    my $tr;
foreach my $key(keys %{$par_ref}){
    next if ($par_ref->{$key} eq "");
    my $str;
    $str='$ref->'.(join "",map {"\{$_\}"} split (/\./,$key))."=\'".$par_ref->{$key}."\'";
    eval $str;
}
$ref=$ref->{$self->MyName()} if (exists($ref->{$self->MyName()}));
$self->_set_vars($ref);
}

#This method call from _set_vars then
#setup unknown var (i.e. from form)
sub _set_unknown_var{
my ($self,$par,$val)=@_;
for ($par) {do{
    /sess/  && do {
	    $self->SetSession($val);
	    return 1;#do not inheritance SUPER
		    }
	    || do {
	    $self->SUPER::_set_unknown_var($par,$val)
		    }
    }}
}

sub Work{
my $self=shift;
SendEvent $self "_begin_work";
#logmsgs $self q/SendEvent $self "_begin_work";/;
$self->SUPER::Work;
}


#fill $self->runtime("_events") hash event - method
sub RegEvent {
my ($self,$ref_obj,$event_name,$ref_sub)=@_;
my $ev_hash=$self->_runtime("_events");
$ev_hash->{$event_name}->{scalar($ref_obj)}={
	ref_obj=>$ref_obj,
	ref_sub=>$ref_sub} if (ref($ref_sub));
}

sub SendEvent{
my ($self,$event_name,@Par)=@_;
my $ev_hash=$self->_runtime("_events");
return 0  unless (exists($ev_hash->{$event_name}));
foreach my $ref_rec (keys %{$ev_hash->{$event_name}}) {
    my $ref_sub=$ev_hash->{$event_name}->{$ref_rec}->{ref_sub};
    my $ref_obj=$ev_hash->{$event_name}->{$ref_rec}->{ref_obj};
    $ref_obj->$ref_sub($event_name,@Par);
		}
};

sub _createObj{
my ($self,$name_obj,$name_func,@par)=@_;
if (my $pack=_pack4name $self $name_func){
    my $ref_init_hash={
		ref_engine=>$self->GetEngine(), #! Setup _engine refernce for childs!
		name_obj=>$name_obj};		#! Setup _my_name
    my $obj_ref=eval "$pack\-\>new(\$ref_init_hash,\@par)";
    carp "Error in eval:  _createObj $@" if $@;
    return $obj_ref;
}
}

#sub _parse_html(\@html)
#return \@Objects
sub _parse_html{
my ($self,$raw_html)=@_;
#remove special symbols
#*tags="createObj|newObj";
#map {~s/[\n\r]+//} @{$raw_html};
#my $mass=[split(/<!--(?:[\s]+)?((?:createObj|newObj)(?:[\s]+)?(?:[^\s]*))(?:[\s]+)?-->/,
my $mass=[split(/<!--(?:[\s]+)?((?:createObj|newObj)(?:[\s]+)?(?:(?:(?!-->).)*))(?:[\s]+)?-->/msg,
			    join("",@{$raw_html}))];
#At this section analize and generates refs
#unshift (@mass,"createObj error('No_function_')");
##{
###local $/;
##local $,;
###$/="\n";
##$,="\n--\n";
##open (FH,">/tmp/ZZZ");
##print FH @$mass;
##close FH;
##}
my $ref;
my @res;
foreach (@$mass){
#unless (/^(?:createObj|newObj)(?:[\s]+)?([\w]+)\((.*)\)/) {
#<!--createObj Text1{text}("Sample")-->
unless (/^(?:createObj|newObj)(?:[\s]+)?([\w]+)\{([\w]+)\}\((.*)\)/s) {
$ref=$self->_createObj("none","_rawhtml_element",\$_);
}
    else {
my $name_obj=$1;
my $mod_name=$2;    
my @par=split(/[,]/,$3);
map {~s/["']//g} @par;#remove"
#no strict 'subs';
$ref=$self->_createObj($name_obj,$mod_name, eval($3));
}

push(@res,$ref) if ref($ref);
}
return \@res;
}

#Get package for functions name
sub _pack4name {
my ($self,$name)=@_;
my $ref=_runtime $self "_obj";
return $$ref{$name} if (exists $$ref{$name});
}

sub _list_func{
my $self=shift;
return (sort keys %{_runtime $self "_obj"});
}

sub GetPackFunc {
my $self=shift;
my $pack_name=shift;
my @func;
local *sym=eval"\$${pack_name}::{Desc}" if defined eval"\$${pack_name}::{Desc}";
return (defined @sym) ? eval "\@${pack_name}::Desc":();
#else {return  0;}
}

sub RegistrPack {
my ($self,$pack_name)=@_;
my @arr;
my ($i,$use,$describe,$name);
my ($_obj,
    $_describe,
    $_use
    )=(
    $self->_runtime("_obj"),
    $self->_runtime("_describe"),
    $self->_runtime("_use")
    );
if (@arr=$self->GetPackFunc($pack_name)) {
    for ($i=0;$i < @arr/3;++$i){
	$name=$arr[$i*3];
	$use=$arr[$i*3+1];
	$describe=$arr[$i*3+2];
	$$_obj{$name}=$pack_name;
	$$_describe{$name}=$describe;
	$$_use{$name}=$use;
	    }
    }
}
1;
