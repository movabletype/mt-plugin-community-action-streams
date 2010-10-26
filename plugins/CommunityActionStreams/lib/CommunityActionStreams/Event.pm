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
