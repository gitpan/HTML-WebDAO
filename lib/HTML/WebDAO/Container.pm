#$Id: Container.pm,v 1.2 2004/03/09 20:34:26 zagap Exp $

package HTML::WebDAO::Container;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Element);
@Desc=("ucontainer","","Container element");
use strict 'vars';
#no strict 'refs';
sub _sysinit{
my $self=shift;
#First invoke parent _init;
$self->SUPER::_sysinit(@_);

#initalize "childs" array for this container
$self->_runtime("childs",[]);

#initalize "childs" counter for array 
$self->_runtime("last_child_id",0);

}

sub GetChilds{
return $_[0]->_runtime("childs");
}

####sub GetAttr{
####my $self=shift;
####my ($res,$ref);
####for my $tmp (@{$self->GetChilds}){
####    $ref=$tmp->GetAttr;
####    next unless (ref($ref));
####    for my $key (sort keys %{$ref}){
####    $res->{$key}=${$ref}{$key};
####    }	
####}
####return $res;
####}

sub _get_vars{
my $self=shift;
my ($res,$ref);
$res=$self->SUPER::_get_vars;
for my $tmp (@{$self->GetChilds}){
    $ref=$tmp->_get_vars;
    next unless (ref($ref));
    my $my_name=$tmp->_runtime("_my_name");
    for my $key (keys %{$ref}){
    $res->{$my_name}->{$key}=$ref->{$key};
    }
}
return $res;
}


sub _set_vars{
my ($self,$ref)=@_;
my $chld_name;
$self->SUPER::_set_vars($ref);
for my $tmp (@{$self->GetChilds}){
    $chld_name=$tmp->_runtime("_my_name");
    $tmp->_set_vars($ref->{$chld_name}) if (exists($ref->{$chld_name}));
    }
}

sub AddChild{
my ($self,$refer)=@_;
return unless (ref($refer));
my $new_child_id=1;
$self->_runtime("last_child_id",$new_child_id+=$self->_runtime("last_child_id"));
$refer->_child_ID($new_child_id);

#Set new _parent runtime variable and reset _path2me
$refer->_set_parent($self);
push(@{$self->GetChilds},$refer);
}
#it for container
sub _set_parent {
my ($self,$par)=@_;
$self->SUPER::_set_parent($par);
foreach my $ref (@{$self->GetChilds})
{	$ref->_set_parent($self);
	}
}
sub SetChilds{
my ($self,@refs)=@_;
#initalize "childs" array for this container
$self->_runtime("childs",[]);
#initalize "childs" counter for array 
$self->_runtime("last_child_id",0);
foreach (@refs){
 $self->AddChild($_) if (ref($_));
}
}

sub Work{
my $self=shift;
for my $a (@{$self->GetChilds}){
$a->Work;
}
}

sub SessionLoaded{
my $self=shift;
#$self->SUPER::SessionLoaded();
for my $a (@{$self->GetChilds}){
$a->SessionLoaded;
}
}

sub Fetch {
my $self=shift;
my @res;
for my $a (@{$self->GetChilds}){
push(@res,@{$a->_format});
}
return \@res;
}

1;
