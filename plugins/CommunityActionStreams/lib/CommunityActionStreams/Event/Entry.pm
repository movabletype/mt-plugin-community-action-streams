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

package CommunityActionStreams::Event::Entry;

use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties({
    class_type => 'community_entries',
});

sub post_save_entry {
    my ($cb, $entry, $original) = @_;
    if ( $entry->status == MT->model('entry')->RELEASE() ) {
        add_event($original);    # use original for ts type date
    }
    else {
        remove_event($entry);
        require CommunityActionStreams::Event::Comment;
        CommunityActionStreams::Event::Comment::remove_entry_related_events($entry->id);
    }
    return 1;
}

sub post_remove_entry {
    my ($cb, $entry) = @_;
    remove_event($entry);
    return 1;
}

sub pre_direct_remove_entry {
    my ($cb, $class, $terms, $args) = @_;
    ## FIXME: This could be written more smart by using JOIN statement.
    my @entries = $class->load($terms, $args);
    for my $entry (@entries) {
        remove_event($entry);
        require CommunityActionStreams::Event::Comment;
        CommunityActionStreams::Event::Comment::remove_entry_related_events($entry->id);
    }
}

sub add_event {
    my $entry = shift;
    my $blog = $entry->blog();
    my ($authored_on, $modified_on)
        = map { __PACKAGE__->localtime_to_utc($_, blog => $blog) }
            ($entry->authored_on, $entry->modified_on);

    __PACKAGE__->build_results(
        items   => [ {
            title       => $entry->title,
            created_on  => $authored_on,
            modified_on => $modified_on,
            identifier  => $entry->id,
        } ],
        stream  => __PACKAGE__->registry_entry(),
        author  => $entry->author(),
        profile => {},
    );

    require CommunityActionStreams::Event::Comment;
    my $comment_iter = MT->model('comment')->load_iter({
        entry_id => $entry->id
    });
    while ( my $comment = $comment_iter->() ) {
        if ( $comment->is_published() ) {
            CommunityActionStreams::Event::Comment::add_event( $comment );
        }
    }
}

sub remove_event {
    my $entry = shift;
    my @events = __PACKAGE__->load({identifier => $entry->id});
    for my $event ( @events ) {
        $event->remove;
    }
}

sub entry {
    my $event = shift;
    return MT->model('entry')->load($event->identifier);
}

sub tag_entry {
    my ($ctx, $args, $cond) = @_;
    my $event = $ctx->stash('stream_action')
        or return $ctx->else($args, $cond);

    my $entry = $event->entry() if $event->can('entry');
    return $ctx->else($args, $cond) if !$entry;
    return $ctx->else($args, $cond)
        if $entry->status != MT->model('entry')->RELEASE();

    local $ctx->{__stash}{entry} = $entry;
    local $ctx->{__stash}{blog}  = $entry->blog;
    return $ctx->slurp($args, $cond);
}

sub url { $_[0]->entry->permalink; }

1;
