#$Id: Element.pm,v 1.2 2004/03/09 20:34:26 zagap Exp $

package HTML::WebDAO::Element;
use HTML::WebDAO::Base;
use base qw/ HTML::WebDAO::Base/;
use strict 'vars';

sub _init{
	my $self=shift;
	$self->_sysinit(\@_);#For system internal inherites
	$self->Init(@_);# if (@_);
	return 1;
}

sub RegEvent{
	my $self=shift;
	my $ref_eng=$self->GetEngine;
	$ref_eng->RegEvent($self,@_);
}

#
sub _sysinit{
	my $self=shift;
#Init runtime Varables;
	$self->set_attribute("_runtime",{});
#get init hash reference
	my $ref_init_hash=shift(@{$_[0]});

#_engine - reference to engine
	$self->_runtime("_engine",$ref_init_hash->{ref_engine});

#_my_name - name of this object
	$self->_runtime("_my_name",$ref_init_hash->{name_obj});

#init curent object ID
	$self->_runtime("_child_ID",undef);
#init hash of attribute_names
	my $ref_names_hash={};
	map {$ref_names_hash->{$_}=1} $self->get_attribute_names();
	$self->_runtime("_attribute_names",$ref_names_hash);
#init hash of _unknown_vars (i.e. from <form>)
	$self->_runtime("_unknown_vars",{});

#init array of _format sub's references
	$self->_runtime("_format_subs",[]);
	$self->_format_subs([	
		sub{$self->PreFormat(@_)},
		sub{$self->Format(@_)},
		sub{$self->PostFormat(@_)},
		]);

}

sub Init{
#Public Init metod for modules;
}

# $obj->_runtime(name => 'John', age => 23);     
#
# Or, $obj->_runtime (['name', 'age'], ['John', 23]);
#hints:
#	use 1 parametr to read value
#		$obj->_runtime("ID")
#	use anonym array to read multiple read
#		$obj->_runtime(["ID","runtime_exept"])
#	use hash for multiple or individual set
#		$obj->_runtime("ID"=>$id,"runtime_exept"=>$err)
sub _runtime {
	my $self = shift;
	my @res;
	my $ref=$self->get_attribute("_runtime");
	if (@_ == 1){
		if (ref($_[0])) {
			foreach my $attr_name (@{$_[0]}) {
				push(@res,@{$$ref{"$attr_name"}});
			}
			return @res;
		}else {
    #not ref && @_==1
			return $$ref{$_[0]};
		} 
	} else {# > 1 par
		my ($attr_name, $attr_value);
		while (@_) {
			$attr_name = shift;
			$attr_value = shift;
			$$ref{$attr_name}=$attr_value;
		}
	}
};


sub _child_ID{
	my $self=shift;
	@_ ? $self->_runtime("_child_ID",$_[0]):return $self->_runtime("_child_ID");
}

sub Edit{
	my $self=shift;
}

##sub GetAttr{
##	my $self=shift;
##	my $res;
##	my @keys;
##	for my $key ($self->get_attribute_names($self)){
##		my $val=$self->get_attribute($key);
##		no strict 'vars';
##		if (defined($val)){
##			my $str;
###$str=defined($self->_child_ID) ? $self->_child_ID."ID".$key:$key;
##			$res->{$self->_child_ID.$_delim_.$key}=$val
##		}
##		use strict 'vars';
##	}
##	return $res;
##}
sub _get_vars{
	my $self=shift;
	my $res;
	for my $key (keys %{$self->_runtime("_attribute_names")}){
		my $val=$self->get_attribute($key);
		no strict 'vars';
		$res->{$key}=$val if (defined($val));
		use strict 'vars';
	}
	return $res;
}


sub _set_vars{
	my ($self,$ref,$names)=@_;
	$names=$self->_runtime("_attribute_names");
	for my $key (keys %{$ref}){
		next if (ref($ref->{$key}) eq "HASH");
		if (exists($names->{$key})){
			$self->${key}($ref->{$key})
		}else{
			$self->_set_unknown_var(${key},\$ref->{$key})
		}
	}
}

sub _set_unknown_var{
	my ($self,$par,$val)=@_;
	my ($ref_unknown_vars)=$self->_runtime("_unknown_vars");
	$ref_unknown_vars->{$par}=$$val;
}

sub GetFormData{
	my ($self)=@_;
	return $self->_runtime("_unknown_vars");
}
sub _set_parent{
	my ($self,$parent)=@_;
	$self->_runtime("_parent",$parent);
	$self->_set_path2me();
}

sub _set_path2me{
	my $self=shift;
	my $parent=$self->_runtime("_parent");
	if ($self != $parent){
		(my $parents_path=$parent->_runtime("_path2me"))||="unknown";
		my $my_path=$parents_path."\.".$self->_runtime("_my_name");
		$self->_runtime("_path2me",$my_path);
	} else {
		$self->_runtime("_path2me",$self->_runtime("_my_name"))};
}

sub MyName {
	my $self=shift;
	return $self->_runtime("_my_name");

}
sub GetEngine{
	my $self=shift;
	return $self->_runtime("_engine");
}

sub GetParent{
	my $self=shift;
	return $self->_runtime("_parent");
}
sub SendEvent{
	my $self=shift;
	my $parent=GetParent $self;
	$parent->SendEvent(@_);
}
#set & get special procedures
sub _format_subs{
my $self=shift;
#init array of _format sub's references
@_ ? $self->_runtime("_format_subs",shift):$self->_runtime("_format_subs");
}


sub _preformat{	
	my $self=shift;
	return [];}

sub PreFormat{
	my $self=shift;
	return [];}

sub _format{
	my $self=shift;
	my @res;
	my $format_subs=$self->_format_subs();
	push(@res,@{$self->_preformat});
	push(@res,@{$format_subs->[0]->()});
	push(@res,map {$format_subs->[1]->($_)} @{$self->Fetch});
	push(@res,@{$format_subs->[2]->()});
	push(@res,@{$self->_postformat});
	return \@res;
	}

sub Format{
	my $self=shift;
	return shift;}

sub PostFormat{
	my $self=shift;
	return [];}

sub _postformat{
	my $self=shift;
	return [];}

#private subroute for handled recurcive(for class inheritance)
#call Session Loaded
##sub _session_loaded {
##my $self=shift;
##logmsgs $self "_session_loaded";
##$self->SUPER::_session_loaded();
##
##}
sub SessionLoaded{my $self=shift;}
sub Work{my $self=shift;}
sub Fetch {my $self=shift;return []}

1;
