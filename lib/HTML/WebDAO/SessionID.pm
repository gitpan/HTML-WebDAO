#$Id: SessionID.pm,v 1.1 2004/04/27 07:11:59 zagap Exp $
package HTML::WebDAO::SessionID;
use HTML::WebDAO::Base;
use CGI;
use MIME::Base64;
use base qw( HTML::WebDAO::Sessiondb);

use strict 'vars';


sub get_id {
my $self=shift;
my $coo=U_id $self;
return $coo if ($coo);
($coo)=$self->Cgi_env->{path_info}=~m/sess_(\d{7})/;
$coo ||= do {
	my $tmp=substr(time(),-7,7);
	$self->Cgi_env->{path_info}.="sess_$tmp/";
	$tmp
	};
U_id $self $coo;
return $coo;
}
1;
__END__
