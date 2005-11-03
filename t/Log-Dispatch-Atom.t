#!perl
# @(#) $Id$

use strict;
use warnings;

use File::Temp qw( tempfile );
use Test::More 'no_plan';
use XML::Atom::Feed;
use Log::Dispatch::Atom;

test_basics();
test_feed_extras();

sub test_basics {
    my $fn  = tempfilename();
    my $log = Log::Dispatch::Atom->new(
        name      => 'foo',
        min_level => 'debug',
        file      => $fn
    );
    isa_ok( $log, 'Log::Dispatch::Atom' );
    can_ok( $log, qw( log ) );

    $log->log( level => 'info', message => 'hello world' );
    my $feed = eval { XML::Atom::Feed->new( $fn ) };
    is( $@, '', 'log(1) No problems parsing feed.' );
    my @entries = $feed->entries;
    is( scalar( @entries ), 1, 'log(1) produced 1 entry' );
    is( $entries[0]->title, 'hello world', 'log(1) made correct title' );
    is( $entries[0]->content->body,
        'hello world', 'log(1) made correct content' );

    $log->log( level => 'info', message => 'hello world#2' );
    $feed = eval { XML::Atom::Feed->new( $fn ) };
    is( $@, '', 'log(2) No problems parsing feed.' );
    @entries = $feed->entries;
    is( scalar( @entries ), 2, 'log(2) produced 1 more entry' );
    is( $entries[0]->title, 'hello world#2', 'log(2) made correct title' );
    is(
        $entries[0]->content->body,
        'hello world#2',
        'log(2) made correct content'
    );
    return;
}

sub test_feed_extras {
    my $fn  = tempfilename();
    my $log = Log::Dispatch::Atom->new(
        name       => 'test_feed_extras',
        min_level  => 'debug',
        file       => $fn,
        feed_title => 'My Test Log',
        feed_id    => 'http://example.com/log/',
    );
    isa_ok( $log, 'Log::Dispatch::Atom' );

    $log->log( level => 'info', message => 'hello world' );
    my $feed = eval { XML::Atom::Feed->new( $fn ) };
    is( $@, '', 'test_feed_extras: No problems parsing feed.' );
    is( $feed->title, 'My Test Log', 'test_feed_extras: title' )
        or diag( slurp( $fn ) );
    is( $feed->id, 'http://example.com/log/', 'test_feed_extras: id' );
    return;
}

sub tempfilename {
    my ( $fh, $filename ) = tempfile( 'XML-Atom-Log.XXXXXX', UNLINK => 1 );
    close $fh;
    return $filename;
}

sub slurp {
    my ( $file ) = @_;
    open my $fh, '<', $file or die "open($file): $!\n";
    my $contents = do { local $/; <$fh> };
    close $fh;
    return $contents;
}

# vim: set ai et sw=4 syntax=perl :
