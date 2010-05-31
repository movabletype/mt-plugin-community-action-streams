# Community Action Streams (C) 2009-2010 Six Apart, Ltd. All Rights Reserved.
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
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
