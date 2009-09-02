# Movable Type (r) (C) 2007-2009 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package CommunityActionStreams::Event::Favorite;
use CommunityActionStreams::Event::Following;
use strict;
use warnings;

use base qw( ActionStreams::Event CommunityActionStreams::Event );

__PACKAGE__->install_properties({
    class_type => 'community_favorites',
});

sub post_save_score {
    my ($cb, $app, $score) = @_;
    return if !eval { require MT::App::Community; 1 };
    return if !eval { require MT::Community::Friending; 1; };
    if ($score->namespace eq MT::App::Community->NAMESPACE()) {
        CommunityActionStreams::Event::Favorite->post_save_favorite(@_);
    }
    elsif ($score->namespace eq MT::Community::Friending->FRIENDING()) {
        CommunityActionStreams::Event::Following->post_save_following(@_);
    }
    return 1;
}

sub post_save_favorite {
    my ($cb, $app, $score) = @_;
    return if !eval { require MT::App::Community; 1 };
    return if  $score->namespace ne MT::App::Community->NAMESPACE();

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
        identifier  => $score->id,
    );
    if ($object->isa(MT->model('entry'))) {
        $data{title} = $object->title;
    }
    elsif ($object->isa(MT->model('comment'))) {
        $data{title} = $object->entry->title;
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

sub comment {
    my $event = shift;
    my $score = MT->model('objectscore')->load($event->identifier);
    return if (!$score || $score->object_ds ne 'comment');
    return MT->model('comment')->load($score->object_id);
}

sub entry {
    my $event = shift;
    my $score = MT->model('objectscore')->load($event->identifier);
    return if !$score;
	return MT->model('entry')->load($score->object_id)
        if $score->object_ds eq 'entry';
    return if $score->object_ds ne 'comment';
    my $comment = MT->model('comment')->load($score->object_id)
        or return;
    return $comment->entry;
}

sub url {
    my $event = shift;
    my $score = MT->model('objectscore')->load($event->identifier) or return;
    my $obj_class = MT->model($score->object_ds)        or return;
    my $object    = $obj_class->load($score->object_id) or return;

    if ($object->isa(MT->model('entry'))) {
        return $object->permalink;
    }
    elsif ($object->isa(MT->model('comment'))) {
        return $object->entry->permalink . '#comment-' . $object->id;
    }
    else {
        return;
    }
}

1;
