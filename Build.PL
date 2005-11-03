use strict;
use warnings;
use Module::Build;

Module::Build->new(
    module_name        => 'Log::Dispatch::Atom',
    license            => 'bsd',
    dist_author        => 'Dominic Mitchell <cpan (at) happygiraffe.net>',
    dist_version_from  => 'lib/Log/Dispatch/Atom.pm',
    add_to_cleanup     => ['Log-Dispatch-Atom-*'],
    create_makefile_pl => 'passthrough',
    requires           => {
        'Test::More' => 0,
        # We need this version to get proper insert mode working.
        'XML::Atom' => '0.15',
    },
)->create_build_script();
