use strict;
use warnings;
use Module::Build;
use lib './t/lib';

my $builder = Module::Build->new(
    module_name       => 'TAP::Harness::Archive',
    license           => 'perl',
    dist_author       => 'Michael Peters <mpeters@plusthree.com>',
    dist_version_from => 'lib/TAP/Harness/Archive.pm',
    requires          => {
        'TAP::Harness'     => 0.52,
        'Archive::Builder' => 1.12,
        'Test::More'       => 0,
        'Cwd'              => 0,
        'File::Basename'   => 0,
        'File::Temp'       => 0,
        'File::Spec'       => 0,
        'File::Path'       => 0,
        'File::Find'       => 0,
        'YAML::Tiny'       => 0,
    },
    recommends         => {'Archive::Extract' => 0.22,},
    create_makefile_pl => 'traditional',
    create_readme      => 1,
);

$builder->create_build_script()
