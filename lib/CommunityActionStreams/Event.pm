# Movable Type (r) (C) 2007-2009 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package CommunityActionStreams::Event;
use strict;
use warnings;

use MT::Util qw( epoch2ts ts2epoch offset_time );

sub localtime_to_utc {
    my $class = shift;
    my ($time, %param) = @_;
    my $blog = $param{blog};

    return undef unless $time;
    $time =~ s{\D}{}xmsg;  # timestamps are numbers only
    my $epoch = ts2epoch(undef, $time);
    # Remove the existing local time offset.
    my $utc = offset_time($epoch, $blog, q{-});
    return epoch2ts(undef, $utc);
}

1;
