// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/server_data_operator_base.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/category.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/channel.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/group.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/team.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/team_threads_sync.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/thread.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/handlers/user.dart';
import 'package:watermelondb/watermelondb.dart';

mixin CategoryHandlerMix on CategoryHandler {}
mixin ChannelHandlerMix on ChannelHandler {}
mixin GroupHandlerMix on GroupHandler {}
mixin PostHandlerMix on PostHandler {}
mixin TeamHandlerMix on TeamHandler {}
mixin TeamThreadsSyncHandlerMix on TeamThreadsSyncHandler {}
mixin ThreadHandlerMix on ThreadHandler {}
mixin UserHandlerMix on UserHandler {}

class ServerDataOperator extends ServerDataOperatorBase with 
    CategoryHandler, 
    ChannelHandler, 
    GroupHandler, 
    PostHandler, 
    TeamHandler, 
    ThreadHandler, 
    TeamThreadsSyncHandler, 
    UserHandler {
  
  ServerDataOperator(Database database) : super(database);
}
