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

package CommunityActionStreams::L10N::ja;

use strict;

use base 'CommunityActionStreams::L10N::en_us';
use vars qw( %Lexicon );
%Lexicon = (

## config.yaml
 'Action streams for community events: add entry, add comment, add favorite, follow user.' => 'エントリー、コメント、お気に入り、ユーザーの注目などのコミュニティイベント用アクションストリームです。',
 'Community Action Streams' => 'Community Action Streams',
 'Favorites' => 'お気に入り',
 'Followers' => 'フォロワー',
 'Replies' => '返信',
 '[_1] <a href="[_2]">commented</a> on <a href="[_3]">[_4]</a>' => '[_1] は<a href="[_3]">[_4]</a>に<a href="[_2]">コメント</a>しました',
 '[_1] is now following <a href="[_2]">[_3]</a>' => '[_1]は<a href="[_2]">[_3]</a>を注目しました',
 '[_1] posted <a href="[_2]">[_3]</a>' => '[_1]は<a href="[_2]">[_3]</a>を投稿しました',
 '[_1] saved <a href="[_2]">[_3]</a> as a favorite' => '[_1]は<a href="[_2]">[_3]</a>をお気に入りに保存しました',
);

1;
