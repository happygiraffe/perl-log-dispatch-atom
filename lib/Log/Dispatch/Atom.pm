# @(#) $Id$

package Log::Dispatch::Atom;

$VERSION = 0.01;

use warnings;
use strict;

use Carp qw( carp croak );
use Fcntl qw( :flock );
use XML::Atom 0.15;    # We need add_entry(mode=>insert).
use XML::Atom::Entry;
use XML::Atom::Feed;

sub new {
    my $class = shift;
    my %args  = @_;
    croak "usage: new(file=>'filename')" unless $args{ file };
    return bless \%args, $class;
}

sub log {
    my $self = shift;
    my %args = @_;
    croak "usage: log(message=>'message')"
        unless defined $args{ message };
    my $fh = eval {
        my $fh    = $self->_lock_and_open();
        my $feed  = $self->_get_feed_from_handle( $fh );
        $self->_new_entry( $feed, \%args );
        $self->_write_feed( $fh, $feed );
        return $fh;
    };
    # Take care to avoid clobbering $@.
    my $err = $@;
    eval { $self->_unlock_and_close( $fh ) };
    die $err if $err;
    return;
}

sub _get_feed_from_handle {
    my $self = shift;
    my ( $fh ) = @_;

    my $size = ( stat( $fh ) )[7];
    if ( $size > 0 ) {
        return XML::Atom::Feed->new( $fh );
    }
    else {
        # Create a new feed.
        my $feed = XML::Atom::Feed->new( Version => '1.0' );
        $feed->id( $self->{ feed_id } ) if $self->{ feed_id };
        $feed->title( $self->{ feed_title } ) if $self->{ feed_title };
        return $feed;
    }
}

sub _new_entry {
    my $self = shift;
    my ( $feed, $args ) = @_;
    my $entry = XML::Atom::Entry->new( Version => '1.0' );
    $entry->title( "$args->{message}" );
    $entry->content( "$args->{message}" );
    $feed->add_entry( $entry, { mode => 'insert' } );
    return $entry;
}

sub _write_feed {
    my $self = shift;
    my ( $fh, $feed ) = @_;

    seek $fh, 0, 0;
    print $fh $feed->as_xml();
    return;
}

sub _lock_and_open {
    my $self = shift;
    open my $fh, '+<', $self->{ file }
        or croak "open($self->{file}): $!";
    flock( $fh, LOCK_EX )
        or croak "flock($self->{file}): $!";
    return $fh;
}

sub _unlock_and_close {
    my $self = shift;
    my ( $fh ) = @_;
    return unless $fh;

    flock( $fh, LOCK_UN )
        or carp "unlock($self->{file}): $!";
    close( $fh )
        or carp "close($self->{file}): $!";
    return;
}

1;
__END__

=head1 NAME

Log::Dispatch::Atom - Log to an atom feed.

=head1 VERSION

This document describes Log::Dispatch::Atom version 0.01

=head1 SYNOPSIS

    use Log::Dispatch::Atom;

    my $log = Log::Dispatch::Atom->new( file => 'file.atom' );
    $log->log( message => 'A problem happened' );
    $log->log( message => 'Another problem happened' );

=head1 DESCRIPTION

This class implements logging backed by an Atom feed so that you can
subscribe to the errors produced by your application.

=head1 METHODS

=over 4

=item new()

Takes a hash of arguments.  Returns a new Log::Dispatch::Atom object.  The
following parameters are used:

=over 4

=item I<file> [mandatory]

Specifies the location of the file to read/write the feed from.

=item I<feed_id> [optional]

Specifies the identity of the feed itself.  Normally, this should be
set to the published URI of the feed.

If not specified, it will be omitted, which is in violation of the
Atom specification.  For more information, see
L<http://www.atomenabled.org/developers/syndication/#requiredFeedElements>.

=item I<feed_title> [optional]

The title of the feed.  This should probably be set to the name of
your application.

If not specified, it will be omitted, which is in violation of the
Atom specification.  For more information, see
L<http://www.atomenabled.org/developers/syndication/#requiredFeedElements>.

=back

=item log()

Takes a hash of arguments.  Has no return value.  The following
parameters are used.

=over 4

=item I<message> [mandatory]

The actual log message.

=back

=back

=head1 DIAGNOSTICS

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 SEE ALSO

L<XML::Atom>, the module used for Atom processing.

The spec for the atom syndication format,
L<http://www.atomenabled.org/developers/syndication/>.

=head1 DEPENDENCIES

L<XML::Atom> version 0.14.

This module uses flock() to the lock the feed file whilst it's writing,
so your version of Perl will need support for that.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-xml-atom-log@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Dominic Mitchell  C<< <cpan (at) happygiraffe.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2005, Dominic Mitchell C<< <cpan (at) happygiraffe.net> >>.
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

# vim: set ai et sw=4 :
