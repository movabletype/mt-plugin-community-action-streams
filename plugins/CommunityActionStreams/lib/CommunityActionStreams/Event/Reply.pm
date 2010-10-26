############################################################################
# Copyright © 2010 Six Apart Ltd.
# This program is free software: you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# version 2 for more details. You should have received a copy of the GNU
# General Public License version 2 along with this program. If not, see
# <http://www.gnu.org/licenses/>.

package CommunityActionStreams::Event::Reply;

use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties( { class_type => 'community_replies', } );

use MT::Util qw( encode_html );
use MT::I18N qw( first_n_text );

sub post_save_comment {
    my ( $cb, $app, $comment ) = @_;
    return if !$comment->is_published();
    return if !$comment->commenter_id;

    my $entry = $comment->entry;
    return if $entry->status != MT->model('entry')->RELEASE();

    my $author;
    if ( $comment->parent ) {
        my $p = $comment->parent;
        $author = MT->model('author')->load( $p->commenter_id )
            if $p && $p->commenter_id;
    } else {
        $author = $comment->entry->author;
    }
    return unless $author;

    my $commenter = MT->model('author')->load( $comment->commenter_id )
      or return;

    # don't save reply-to-own-comments
    return if ($author->id == $commenter->id);

    # don't save replies for users the author is already following
    use MT::Community::Friending;
    my $following = MT::Community::Friending::is_following( $author, $commenter->id );

    # if following they'll get a notice anyway
    return if $following;

    my $blog = $comment->blog();

    my ( $created_on, $modified_on ) =
      map { __PACKAGE__->localtime_to_utc( $_, blog => $blog ) }
      ( $comment->created_on, $comment->modified_on );
    __PACKAGE__->build_results(
        items => [
            {
                title        => $entry->title,
                url          => $entry->permalink . '#comment-' . $comment->id,
                created_on   => $created_on,
                modified_on  => $modified_on,
                identifier   => $comment->id
            },
        ],
        stream  => __PACKAGE__->registry_entry(),
        author  => $author,
        profile => {},
    );
    return 1;
}

sub comment {
    my $event = shift;
    return MT->model('comment')->load( $event->identifier );
}

sub entry {
    my $event = shift;
    return $event->comment->entry;
}

1;
