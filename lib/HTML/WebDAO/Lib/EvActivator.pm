#$Id: EvActivator.pm,v 1.1.1.1 2003/12/31 09:57:26 zagap Exp $

package HTML::WebDAO::Lib::EvActivator;
#use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Activator);
@Desc=("eventactivator","","Dynamic content manager by events");
use strict 'vars';
sub Init{
my $self=shift;
$self->SUPER::Init(@_);
}
sub SessionLoaded {
my $self =shift;
map {$self->RegEvent($_,\&do_init)} $self->GetActiveItems();
$self->SUPER::SessionLoaded();
}
sub do_init{
my ($self,$name,@par)=@_;
$self->ActiveItem($name);
}


1;
