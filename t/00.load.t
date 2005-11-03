#!perl -w
# @(#) $Id$

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok( 'Log::Dispatch::Atom' );
}

diag( "Testing Log::Dispatch::Atom $Log::Dispatch::Atom::VERSION" );

# vim: set ai et sw=4 syntax=perl :
