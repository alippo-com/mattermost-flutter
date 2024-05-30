import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_participant_interface.dart';

const THREAD = MM_TABLES.SERVER.THREAD;
const THREAD_PARTICIPANT = MM_TABLES.SERVER.THREAD_PARTICIPANT;
const USER = MM_TABLES.SERVER.USER;

/// The ThreadParticipant model contains participants data of a thread.
class ThreadParticipantModel extends Model implements ThreadParticipantModelInterface {
  static String table = THREAD_PARTICIPANT;

  static final Map<String, Association> associations = {
    THREAD: Association.belongsTo(THREAD, 'thread_id'),
    USER: Association.belongsTo(USER, 'user_id'),
  };

  @Field('thread_id')
  String threadId;

  @Field('user_id')
  String userId;

  @immutableRelation(THREAD, 'thread_id')
  final thread = HasOne<ThreadModel>();

  @immutableRelation(USER, 'user_id')
  final user = HasOne<UserModel>();
}
