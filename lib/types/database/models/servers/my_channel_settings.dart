// Dart (Flutter)
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_settings_interface.dart';

const MY_CHANNEL = MM_TABLES.SERVER.MY_CHANNEL;
const MY_CHANNEL_SETTINGS = MM_TABLES.SERVER.MY_CHANNEL_SETTINGS;

class MyChannelSettingsModel extends Model implements MyChannelSettingsModelInterface {
  static String table = MY_CHANNEL_SETTINGS;

  static final Map<String, Association> associations = {
    MY_CHANNEL: Association.belongsTo(MY_CHANNEL, 'id'),
  };

  @Field('notify_props')
  Map<String, dynamic> get notifyProps => safeParseJSON(get('notify_props') as String);

  @immutableRelation(MY_CHANNEL, 'id')
  final myChannel = HasOne<MyChannelModel>();
}
