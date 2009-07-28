use Test::More tests => 4;

BEGIN {
    use_ok('URI::Find::Schemeless');
    use_ok('HTML::Entities');
    use_ok('App::ZofCMS::Plugin::Base');
	use_ok( 'App::ZofCMS::Plugin::LinkifyText' );
}

diag( "Testing App::ZofCMS::Plugin::LinkifyText $App::ZofCMS::Plugin::LinkifyText::VERSION, Perl $], $^X" );
