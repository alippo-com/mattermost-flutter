
import 'package:nozbe_watermelondb/nozbe_watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/query_description.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_participant.dart';

const THREAD_PARTICIPANT = MM_TABLES.SERVER.THREAD_PARTICIPANT;

Future<Map<String, dynamic>> sanitizeThreadParticipants({
  required Database database,
  required bool skipSync,
  required String threadId,
  required List<UserProfile> rawParticipants,
}) async {
  final List<Clause> clauses = [Q.where('thread_id', threadId)];

  if (skipSync) {
    clauses.add(
      Q.where('user_id', Q.oneOf(rawParticipants.map((participant) => participant.id).toList())),
    );
  }

  final List<ThreadParticipantModel> participants = await database.collections
      .get<ThreadParticipantModel>(THREAD_PARTICIPANT)
      .query(clauses)
      .fetch();

  final Set<ThreadParticipantModel> similarObjects = {};
  final List<RecordPair> createParticipants = [];
  final Map<String, ThreadParticipantModel> participantsMap = {
    for (var participant in participants) participant.userId: participant
  };

  for (var rawParticipant in rawParticipants) {
    final exists = participantsMap[rawParticipant.id];

    if (exists != null) {
      similarObjects.add(exists);
    } else {
      createParticipants.add(RecordPair(raw: rawParticipant));
    }
  }

  if (skipSync) {
    return {'createParticipants': createParticipants, 'deleteParticipants': []};
  }

  final List<ThreadParticipantModel> deleteParticipants = participants
      .where((participant) => !similarObjects.contains(participant))
      .map((outCast) => outCast.prepareDestroyPermanently())
      .toList();

  return {'createParticipants': createParticipants, 'deleteParticipants': deleteParticipants};
}
