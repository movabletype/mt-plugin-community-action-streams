# Community Action Streams (C) 2009-2010 Six Apart, Ltd. All Rights Reserved.
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id$

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
