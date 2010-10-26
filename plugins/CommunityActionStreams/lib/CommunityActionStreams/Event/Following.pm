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

package CommunityActionStreams::Event::Following;

use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties({
    class_type => 'community_followers',
});

sub post_save_following {
    my ($cb, $score, $orig_score) = @_;
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
        $data{title} = $object->nickname;
        if ( my $community = MT->config->CommunityScript ) {
            $data{url} = MT->app->base . MT->app->path . $community . "?__mode=view&blog_id=0&id=" . $object->id;
        }
        else {
            $data{url} = '#';
        }
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
