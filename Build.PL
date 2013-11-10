use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::ZofCMS::Plugin::LinkifyText',
    license             => 'perl',
    dist_author         => q|'Zoffix <'zoffix@cpan.org'>|,
    dist_version_from   => 'lib/App/ZofCMS/Plugin/LinkifyText.pm',
    build_requires => {
        'Test::More' => 0,
    },
    build_recommends => {
        'App::ZofCMS::Test::Plugin' => '0.0104',
    },
    requires => {
        'URI::Find::Schemeless'     => 20090319,
        'HTML::Entities'            => 1.35,
        'App::ZofCMS::Plugin::Base' => 0.0103,
        'perl' => '5.006',
    },
    configure_requires => { 'Module::Build' => 0 },
    add_to_cleanup      => [ 'App-ZofCMS-Plugin-LinkifyText-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
