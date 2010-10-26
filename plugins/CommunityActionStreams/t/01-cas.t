#!/usr/bin/perl -w
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

use strict;
use warnings;

use lib 't/lib';
use MT::Test qw( :time :db );


package Test::Wtf;
use base qw( Test::Class );
use Test::More;

sub test_lt2utc : Tests(2) {
    die "TimeOffset must be zero\n"
        if MT->config->TimeOffset > 0;

    require CommunityActionStreams::Event;

    is(CommunityActionStreams::Event->localtime_to_utc('20081125100400'), '20081125100400',
        'system local time is equivalent to UTC outside of DST');
    is(CommunityActionStreams::Event->localtime_to_utc('20080625100400'), '20080625090400',
        'system local time is an hour ahead of UTC inside DST');
}

sub test_objectscore : Tests(4) {
    my @tests = (
        {
            # 2008-11-25 10:04:00 PST = 2008-11-25 18:04:00 UTC
            time     => 1227636240,
            expected => '20081125180400',
            about    => q{object's created_on matches UTC time},
        },
        {
            # 2008-06-25 10:04:00 PDT = 2008-06-25 17:04:00 UTC
            time     => 1214413440,
            expected => '20080625180400',  # 17:04 plus DST's one hour
            about    => q{object's created_on precedes UTC time by an hour},
        },
    );

    my $i = 0;
    for my $test (@tests) {
        my ($time, $expected, $about) = @$test{qw( time expected about )};

        local $MT::Test::CORE_TIME = $time;

        my $os = MT->model('objectscore')->new;
        $os->set_values({
            object_ds => 'author',
            object_id => 1,
            namespace => 'awesome' . ++$i,  # so we can save many
            score     => 7,
            author_id => 1,
        });
        $os->save() or die "Could not save OS #$i: " . $os->errstr . "\n";

        ok($os->created_on, 'object got a created_on');
        is($os->created_on, $expected, $about);
    }
}


package main;

Test::Class->runtests();
