#$Id: ListEnv.pm,v 1.2 2004/03/09 20:34:27 zagap Exp $

package HTML::WebDAO::Comp::ListEnv;
use base qw(HTML::WebDAO::Component);
#@ISA="ucomponent";
@Desc=("listenv","","List Envirompent variables");
sub Init{
my $self=shift;
$self->Par(shift);
}
sub Par{
my $self=shift;
@_ ? $self->{"Var"}->{"Par"}=shift : $self->{"Var"}->{"Par"};
}

sub PreFormat{
my $self=shift;
my @Out=<<END;
<table border="1" align="center">
END
return \@Out;
}
sub Format{
my $self=shift;
my ($p1,$p2)=split(/\|/,shift);
return "<tr><td>$p1</td><td><b>$p2</b></td></tr>"
};
sub PostFormat{
my $self=shift;
return ["</table>"];
}
sub Fetch {
my $self=shift;
foreach $var (sort(keys(%ENV))) {
    $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    push(@Out, "${var}|${val}");
}
return \@Out;
}
1;
