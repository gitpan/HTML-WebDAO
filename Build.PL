use Module::Build;
Module::Build->new
    ( module_name => 'HTML::WebDAO',
    license => 'perl',
   prereq => {
	      'FreezeThaw' => 0.43,
	     },
    create_makefile_pl=>$ENV{WebDAO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
