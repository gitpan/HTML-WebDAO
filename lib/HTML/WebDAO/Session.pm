#$Id: Session.pm,v 1.2 2004/03/09 20:34:26 zagap Exp $

package HTML::WebDAO::Session;
use HTML::WebDAO::Base;
use CGI;
use base qw( HTML::WebDAO::Base );
attributes qw (Cgi_obj Cgi_env U_id Header Params  Events Switch_sos_id Switch_sos_flag);

sub _init(){
my $self=shift;
$self->Init(@_);
return 1;
}

#Need to be forever called from over classes;
sub Init{
#Parametrs is realm 
$self=shift;
U_id $self undef;
Cgi_obj $self CGI::new();
Cgi_env $self ({
	url => $self->Cgi_obj->url(),			#http://eng.zag
	path_info => $self->Cgi_obj->path_info(),
	path_info_elments =>[],
	file	=> "",
				});
Params $self ($self->_get_params());
$self->Cgi_env->{path_info_elments}=[split(/\//,$self->Cgi_env->{path_info})];

Header $self ({});
Events $self ({});
#init hash of describe content 
# single object state 
Switch_sos_id $self ({});
Switch_sos_flag $self ("0");
}

#Can be overlap if you choose another
#alghoritm generate unique session ID (i.e cookie,http_auth)
sub get_id {
my $self=shift;
my $coo=U_id $self;
return $coo if ($coo);
return rand(100);
}

#this method first need overlapped;
#see store_session() and load_session()
#{		id		=>$id, 		session ID
#		eng_name	=>$eng_name,	request name of Engine 
#		tree		=>$tree		refer to tree fo this Engine
#}
#note: if for load()  parametr "tree" is string (always !) eq this: .applic.container1.text1
#load() mast return value for this request
# if tree not reference to hash for store() it equ to parametr for load(), but
#must save this  path into requested Engine name .applic.container1.text1.rewd=[parametr]
sub load{};
sub store{};
#--------------------------------------------------
sub set_engine_state(){
my ($self,$eng_ref,$object_state_tree)=@_;
#Store object's state tree
$eng_ref->_set_vars($object_state_tree);
return 1;
}
sub get_engine_state(){
my ($self,$eng_ref)=@_;
#Fetch object's state tree
my $object_state_tree=$eng_ref->_get_vars();
return $object_state_tree;
}
#--------------------------------------------------

#Method for store enigine_state
#these method need to overlap for convert tree Engine 
#format store state to database store data format
#
sub store_session(){
my ($self,$eng_ref)=@_;
my $id =$self->get_id();
my $object_state_tree=$self->get_engine_state($eng_ref);
my $stored_hash=$self->load({	id=>$id,
				eng_name=>$eng_ref->MyName()});
$object_state_tree=$self->merge_stored_and_new_tree($stored_hash,$object_state_tree);
$self->store({  id=>$id,
		tree=>$object_state_tree,
		eng_name=>$eng_ref->MyName()});
return 1;
}
#Method for load engine_state
#these method need to overlap for convert database
#store data format to tree Engine format store state
#
sub load_session(){
my ($self,$eng_ref)=@_;
my $id =$self->get_id();
my $object_state_tree=$self->load({"id"=>$id,
				   "eng_name"=>$eng_ref->MyName()});
my $par=$self->_prepare_params($eng_ref);
#if we merged stored and new parametrs we lost  info : what is new parametrs?
$self->set_engine_state($eng_ref,
		$self->merge_stored_and_new_tree(
		$object_state_tree,
		$par->{$eng_ref->MyName()}
			)
		);
##first restore stored state
#$self->set_engine_state($eng_ref,$object_state_tree);
##setup new parameters
#$self->set_engine_state($eng_ref,$par->{$eng_ref->MyName()});
}
#--------------------------------------------------
#$ref_sos={	data_type=>"text\/html",
#	raw_data=>\@,
#	obj_ref=>$self,
#	obj_method=>\&read_image
#	store_session=>0}
sub switch2sos{
my ($self,$name,$ref_sos)=@_;
Switch_sos_id $self ($ref_sos);
Switch_sos_flag $self ("1");
}

#Session interface to device(HTTP protocol) specific function
#$self->SendEvent("_sess_servise",{
#		funct 	=> geturl,
#		par	=> $ref,
#		result	=> \$res
#});

sub sess_servise {
my ($self,$event_name,$par)=@_;
my %service=(
		geturl 	=> sub {$self->sess_servise_geturl(@_)},
		getform => sub {$self->sess_servise_getform(@_)},
		getenv => sub {$self->sess_servise_getenv(@_)},
		#added noew
		getsess => sub {return $self},
		);
if (exists($service{$par->{funct}})) {${$par->{result}}=$service{$par->{funct}}->($par->{par})}
	else {
	logmsgs $self "not exist request funct !".$par->{funct};
	};
}


#
#{variable=>{
#			name=>Par,
#			value=>"10"},
#event	=>{
#			name=>"_info_on",
#			value=>"10"
#			}})
sub sess_servise_geturl{
my ($self,$par)=@_;
my $str=join("",@{$self->Cgi_env}{"url","path_info"});
if (exists($par->{event})){
	$str.="ev/evn_".$par->{event}->{name}."/".$par->{event}->{value}."/"
	}
if (exists($par->{variable})){
	$par->{variable}->{name}=~s/\./\//g;
	$str.="par/".$par->{variable}->{name}."/".$par->{variable}->{value}."/"
	}
$str.=(exists($par->{file})) ? $par->{file}:$self->Cgi_env->{file};
return $str;
}

#sess_servise_getform({data =>\@,url=>"root for form")
sub sess_servise_getform {
my ($self,$par)=@_;
my ($data,$ref,$enctype)= @{$par}{"data","url","enctype"};
my $root_url = ($ref) ? $ref :$self->Cgi_env->{path_info}.$self->Cgi_env->{file};
return \eval '<<END;
<form action="$root_url" method="post" name="tester" id="test" enctype="$enctype">@{$data}</form>
END';
}
#get current session enviro-ent
sub sess_servise_getenv{
my ($self)=@_;
return $self->Cgi_env;
}

sub LoadSession {
my ($self,$eng_ref)=@_;
#register special event
#for switch to single object state
$eng_ref->RegEvent($self,"_switch_sos",\&switch2sos);
$eng_ref->RegEvent($self,"_sess_servise",\&sess_servise);
$self->load_session($eng_ref);
#send Event after load all parametrs
$eng_ref->SendEvent("_sess_loaded");
}

sub ExecEngine(){
my ($self,$eng_ref)=@_;
#Load session
$self->LoadSession($eng_ref);
#send events from urls;
map {$eng_ref->SendEvent($_,$self->Events->{$_})} keys %{$self->Events};
$eng_ref->SendEvent("_is_switch_sos");

#check for Switch_sos_flag
if ($self->Switch_sos_flag) {
my $ref_sos=$self->Switch_sos_id;
my (	$obj_ref,
	$obj_method,
	$store_session,
	)=(
	$ref_sos->{obj_ref},
	$ref_sos->{obj_method},
	$ref_sos->{store_session},
	);
#$obj_ref->$obj_method($self) if ( ref($obj_ref) && ref($obj_method));
$obj_ref->$obj_method($self) if ( ref($obj_ref));

}else{
print $self->print_header();
$eng_ref->Work();
print @{$eng_ref->Fetch()};
$self->store_session($eng_ref);
}
}

#for setup Output headers
sub set_header() {
my ($self,$name,$par)=@_;
$self->Header()->{$name}=$par;
}
#Get cgi params;
sub _get_params {
my $self=shift;
my $_cgi=$self->Cgi_obj();
my $params={};
my $extra=$self->Cgi_env->{path_info};
#srtrip event's from url's
while ($extra=~s/(?:ev)\/(.*?)\/(.*?)\///g){
	$params{$1}=$2;
	}
#strip variable from url
while ($extra=~s/(?:par)\/((?! par|evn).*)\/(.*)\///g){
      my ($var,$val)=($1,$2);
      $var=~s/\//\./g;
      $params{$var}=$val;
	}
if ($extra=~s/((?:(?!\/).)*)$//) {$self->Cgi_env->{file}=$1;}
$extra.="\/" unless ($extra=~/\/$/);
$self->Cgi_env->{path_info}=$extra;
foreach my $i ($_cgi->param()){
	$params{$i}=$_cgi->param($i);
	}
return \%params;
}

#Filtered Param's for current Engine
#and store ather parametrs for ather Engines.

#return tree of parametrs
#Also filtered evens(i.e. env_strike=KKSDKSDSD) - may be :-)
#return tree for current name of Engine
sub _prepare_params{
my $self=shift;
while (my ($ev,$par)=each (%{$self->Params()})){
# events after init engine tree of variables
if ($ev=~/^evn_(.*)/) {
	$self->Events->{$1}=$par;
	delete $self->Params()->{$ev}}
}
return $self->_get_tree_param($self->Params());
}

#Stored tree MUST BE MERGED with exists tree !
#this is need for store param for ucontainer with
#dynamic content
#If !correct overlaped this method - feacher is lost
#parametrs is \%stored_hash, \%new_hashe
#return recurcive merged tree
sub merge_stored_and_new_tree {
my ($self,$h1,$h2)=@_;
while (my($key,$val) = each (%$h2)){
unless (ref($val)){
    $h1->{$key}=$val }
    else {
    $h1->{$key}=$self->merge_stored_and_new_tree($h1->{$key},$h2->{$key});
    }
}
return $h1;
}

#build tree
sub _get_tree_param {
 my ($self,$par_ref)=@_;
 my $ref;
 foreach my $key(keys %{$par_ref}){
   next if ($par_ref->{$key} eq "");
   my $str;
   $str='$ref->'.(join "",map {"\{$_\}"} split (/\./,$key))."=\'".$par_ref->{$key}."\'";
   eval $str;}
return $ref;
}


sub print_header(){
my ($self)=@_;
my $_cgi=$self->Cgi_obj();
my $ref=$self->Header();
return $_cgi->header( map {$_=>$ref->{$_}} keys %{$self->Header()});
}

1;
