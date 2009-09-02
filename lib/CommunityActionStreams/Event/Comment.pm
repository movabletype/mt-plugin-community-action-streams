# Movable Type (r) (C) 2007-2009 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package CommunityActionStreams::Event::Comment;
use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties( { class_type => 'community_comments', } );

use MT::Util qw( encode_html );
use MT::I18N qw( first_n_text );

sub post_save_comment {
    my ( $cb, $comment, $original ) = @_;   
    return if !$comment->commenter_id;
    
    if ( $comment->is_published() 
      && $comment->entry->status == MT->model('entry')->RELEASE() ) {
        add_event( $original );    # use original for ts type date
    }
    else {
        remove_event( $comment );
    }
    return 1;
}

sub post_remove_comment {
    my ($cb, $comment) = @_;
    remove_event( $comment );
    return 1;
}

sub pre_direct_remove_comment {
    my ($cb, $class, $terms, $args) = @_;
    my $entry_id = $terms->{entry_id}
        or return 1;
    remove_entry_related_events($entry_id);
    return 1;
}

sub add_event {
    my $comment = shift;
    my $entry = $comment->entry;
    return if $entry->status != MT->model('entry')->RELEASE();
    my $author = MT->model('author')->load( $comment->commenter_id )
      or return;
    my $blog = $comment->blog();

    my ( $created_on, $modified_on ) =
      map { __PACKAGE__->localtime_to_utc( $_, blog => $blog ) }
      ( $comment->created_on, $comment->modified_on );

    __PACKAGE__->build_results(
        items => [
            {
                title       => $entry->title,
                created_on  => $created_on,
                modified_on => $modified_on,
                identifier  => $comment->id,
            },
        ],
        stream  => __PACKAGE__->registry_entry(),
        author  => $author,
        profile => {},
    );
}

sub remove_event {
    my $comment = shift;
    my @events = __PACKAGE__->load({identifier => $comment->id});
    for my $event ( @events ) {
        $event->remove;
    }
}

sub remove_entry_related_events {
    my $entry_id = shift;
    ## FIXME: This could be written more smart by using JOIN statement.
    my @comments = MT->model('comment')->load({entry_id => $entry_id});
    for my $comment ( @comments ) {
        remove_event($comment);
    }
}

sub comment {
    my $event = shift;
    return MT->model('comment')->load( $event->identifier );
}

sub entry {
    my $event = shift;
    return $event->comment->entry;
}

sub tag_comment {
    my ( $ctx, $args, $cond ) = @_;
    my $event = $ctx->stash('stream_action')
      or return $ctx->else( $args, $cond );

    my $comment = $event->comment if $event->can('comment');
    return $ctx->else( $args, $cond ) if !$comment;

    local $ctx->{__stash}{comment} = $comment;
    local $ctx->{__stash}{blog}    = $comment->blog;
    local $ctx->{__stash}{commenter} =
      MT->model('author')->load( $comment->commenter_id )
      if $comment->commenter_id;
    return $ctx->slurp( $args, $cond );
}

sub url {
    my $comment = $_[0]->comment;
    $comment->entry->permalink . '#comment-' . $comment->id;
}

1;
