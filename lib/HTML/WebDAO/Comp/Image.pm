#$Id: Image.pm,v 1.1.1.1 2003/12/31 09:57:26 zagap Exp $

package HTML::WebDAO::Comp::Image;
use MIME::Base64;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Component);
#@ISA="ucomponent";
attributes qw(_Get_imagenation);
@Desc=("image","","Simple image component");
use strict 'vars';

sub _Get_imagenation{
my ($self,$par)=@_;
if ($par) {
	$self->SendEvent("_switch_sos",{
			obj_ref=>$self,
			obj_method=>"OutRaw"
			});
			}
   return 0;
}
sub GetImageURL{
my ($self,$object) =@_;
return ($object ||=$self)->GetURL({variable=>{name=>"_Get_imagenation",value=>1}});
}
sub Fetch {
my $self=shift;
my $url=$self->GetImageURL;
return ["<img SRC=\"$url\" border=0>"];
}

sub OutRaw{
my ($self,$sess)=@_;
set_header $sess ("-TYPE","image\/jpeg");
print $sess->print_header();
binmode STDOUT; #for perl for Windoze
#open FH,"</admin/pixmaps/topicbsd.jpg";
my @raw=<DATA>;
#close FH;
print decode_base64(join '',@raw);
$sess->store_session($self->GetEngine);
}

1;
__DATA__
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
AH//2Q==
====
