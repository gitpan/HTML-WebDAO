#$Id: RawHTML.pm,v 1.2 2004/03/09 20:34:27 zagap Exp $

package HTML::WebDAO::Lib::RawHTML;
use HTML::WebDAO::Base;
#@ISA="ucomponent";
use base qw(HTML::WebDAO::Component);
@Desc=("_rawhtml_element","<string>","Put string as is (for _ingeine inernal use)");
sub Init{
my ($self,$ref_raw_html)=@_;
$self->_runtime("_raw_html",$ref_raw_html);
$self->RegEvent("_info",sub{});
}
sub Fetch {
my $self=shift;
return [${$self->_runtime("_raw_html")}];
}
sub Event{
}
1;
