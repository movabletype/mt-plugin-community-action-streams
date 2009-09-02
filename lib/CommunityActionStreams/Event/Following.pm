# Movable Type (r) (C) 2007-2009 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package CommunityActionStreams::Event::Following;
use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties({
    class_type => 'community_followers',
});

sub post_save_following {
    my ($cb, $app, $score) = @_;

    return if !eval { require MT::App::Community; 1 };
    return if !eval { require MT::Community::Friending; 1; };
    return if $score->namespace ne MT::Community::Friending::FRIENDING();

    my $author_id = $score->author_id                     or return;
    my $author    = MT->model('author')->load($author_id) or return;
    my $obj_class = MT->model($score->object_ds)          or return;
    my $object    = $obj_class->load($score->object_id)   or return;

    my ($created_on, $modified_on)
        = map { __PACKAGE__->localtime_to_utc($_) }
            ($score->created_on, $score->modified_on);
    my %data = (
        created_on  => $created_on,
        modified_on => $modified_on,
        identifier  => $score->object_id,
    );
    if ($object->isa(MT->model('author'))) {
        $data{title} = $object->name;
        $data{url}   = "#";
    }
    else {
        return;
    }

    __PACKAGE__->build_results(
        items   => [ \%data ],
        stream  => __PACKAGE__->registry_entry(),
        author  => $author,
        profile => {},
    );

    return 1;
}

sub followed {
    my $event = shift;
    return MT->model('author')->load($event->identifier);
}

sub tag_followed {
    my ($ctx, $args, $cond) = @_;
    my $event = $ctx->stash('stream_action')
        or return $ctx->else($args, $cond);

    my $followed = $event->followed() if $event->can('followed');
    return $ctx->else($args, $cond) if !$followed;

    local $ctx->{__stash}{author} = $followed;
    return $ctx->slurp($args, $cond);
}

1;
