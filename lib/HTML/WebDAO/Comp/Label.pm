#$Id: Label.pm,v 1.1.1.1 2003/12/31 09:57:26 zagap Exp $

package HTML::WebDAO::Comp::Label;
use HTML::WebDAO::Base;
#@ISA="ucomponent";
use base qw(HTML::WebDAO::Component);
attributes qw(Par editme);
@Desc=("label","<string>","Show label message");
sub Init{
my $self=shift;
$self->Par(shift);
}
sub PreFormat{
my @out=<<END;
<table><tr><td>&nbsp;</td><td>
END
return \@out;
}


sub PostFormat{
my @out=<<END;
</td><td>&nbsp;<b>:</b>&nbsp;</td>
</tr><tr><td></td><td bgcolor="#000000" height="1">
</td><td></td></tr></table>
END
return \@out;
}
sub Fetch {
my $self=shift;
return ["SSS"] if Edit $self;
#if (exists($self->{"Var"}->{editme}));
return ["infoooo"] if ($self->_info()=~/On/);
$self->Par ? return [$self->Par] :return [];
}
sub Editing{
my $self=shift;
#logmsgs $self "Generating form";
delete $self->{"Var"}->{editme};
my @form=$self->AddCommand();
#return \@form;
#logmsgs $self "Print array:";
#map {$self->logmsgs("$_")} @form;
push(@res,"<table><tr><td><form action=\"\" method=\"post\">",
#	    "<input type=\"text\" value=\"".$self->Par."\">",
	    "<input type=\"text\" value=\"".$self->Par."\" name=\"".$self->{ID}."IDPar"."\" size=\"5\">",
	@form,"<input type=\"submit\" name=\"se\" value=\".\"></form></td><tr></table>");

return \@res;
}
1;
