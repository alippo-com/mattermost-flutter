
class PostModel {
  final int createAt;
  final int deleteAt;
  final String id;
  final String message;
  final String metadata;
  final int pendingPostId;
  final String rootId;
  final int updateAt;
  final bool isPinned;
  final int channelId;

  PostModel({
    required this.createAt,
    required this.deleteAt,
    required this.id,
    required this.message,
    required this.metadata,
    required this.pendingPostId,
    required this.rootId,
    required this.updateAt,
    required this.isPinned,
    required this.channelId,
  });
}
