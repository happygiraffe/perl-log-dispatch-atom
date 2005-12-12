#!perl -w
# @(#) $Id$

use strict;
use warnings;

use Test::More tests => 1;
use XML::Atom;

BEGIN {
    use_ok( 'Log::Dispatch::Atom' );
}

# Spit out useful information for reporting back to the author.
diag( "" );
diag( "" );
diag( "Log::Dispatch::Atom $Log::Dispatch::Atom::VERSION" );
diag( "XML::Atom $XML::Atom::VERSION" );
diag( "" );

# vim: set ai et sw=4 syntax=perl :
