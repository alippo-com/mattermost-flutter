// Dart (Flutter)
import 'package:mattermost_flutter/types/database/models/servers/channel_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/draft.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_settings.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_search_history.dart';

String buildDraftKey(dynamic draft) {
  if (draft is DraftModel) {
    return '${draft.channel_id}-${draft.root_id}';
  }
  return '${draft.channelId}-${draft.rootId}';
}

String buildPreferenceKey(dynamic pref) {
  return '${pref.category}-${pref.name}';
}

String buildTeamMembershipKey(dynamic member) {
  if (member is TeamMembershipModel) {
    return '${member.team_id}-${member.user_id}';
  }
  return '${member.teamId}-${member.userId}';
}

String buildChannelMembershipKey(dynamic membership) {
  if (membership is ChannelMembershipModel) {
    return '${membership.user_id}-${membership.channel_id}';
  }
  return '${membership.userId}-${membership.channelId}';
}

String buildTeamSearchHistoryKey(dynamic history) {
  if (history is TeamSearchHistoryModel) {
    return '${history.team_id}-${history.term}';
  }
  return '${history.teamId}-${history.term}';
}

String buildMyChannelKey(dynamic myChannel) {
  if (myChannel is MyChannelModel || myChannel is MyChannelSettingsModel) {
    return myChannel.channel_id;
  }
  return myChannel.id;
}
