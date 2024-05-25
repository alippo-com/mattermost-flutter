
class PostProps {
  final bool? disableGroupHighlight;
  final bool mentionHighlightDisabled;

  PostProps({this.disableGroupHighlight, required this.mentionHighlightDisabled});
}

class PostResponse {
  final List<String> order;
  final IDMappedObjects<Post> posts;
  final String? prevPostId;

  PostResponse({required this.order, required this.posts, this.prevPostId});
}

class SearchMatches {
  final Map<String, List<String>> matches;

  SearchMatches({required this.matches});
}

class SearchPostResponse extends PostResponse {
  final SearchMatches? matches;

  SearchPostResponse({required List<String> order, required IDMappedObjects<Post> posts, String? prevPostId, this.matches}) : super(order: order, posts: posts, prevPostId: prevPostId);
}

class ProcessedPosts {
  final List<String> order;
  final List<Post> posts;
  final String? previousPostId;

  ProcessedPosts({required this.order, required this.posts, this.previousPostId});
}

class MessageAttachment {
  final int id;
  final String fallback;
  final String color;
  final String pretext;
  final String authorName;
  final String authorLink;
  final String authorIcon;
  final String title;
  final String titleLink;
  final String text;
  final List<MessageAttachmentField> fields;
  final String imageUrl;
  final String thumbUrl;
  final String footer;
  final String footerIcon;
  final dynamic timestamp;
  final List<PostAction>? actions;

  MessageAttachment({required this.id, required this.fallback, required this.color, required this.pretext, required this.authorName, required this.authorLink, required this.authorIcon, required this.title, required this.titleLink, required this.text, required this.fields, required this.imageUrl, required this.thumbUrl, required this.footer, required this.footerIcon, required this.timestamp, this.actions});
}

class MessageAttachmentField {
  final String title;
  final dynamic value;
  final bool short;

  MessageAttachmentField({required this.title, required this.value, required this.short});
}

class PostSearchParams {
  final String terms;
  final bool isOrSearch;
  final bool? includeDeletedChannels;
  final int? timeZoneOffset;
  final int? page;
  final int? perPage;

  PostSearchParams({required this.terms, required this.isOrSearch, this.includeDeletedChannels, this.timeZoneOffset, this.page, this.perPage});
}

class FetchPaginatedThreadOptions {
  final bool? fetchThreads;
  final bool? collapsedThreads;
  final bool? collapsedThreadsExtended;
  final String? direction;
  final bool? fetchAll;
  final int? perPage;
  final int? fromCreateAt;
  final String? fromPost;

  FetchPaginatedThreadOptions({this.fetchThreads, this.collapsedThreads, this.collapsedThreadsExtended, this.direction, this.fetchAll, this.perPage, this.fromCreateAt, this.fromPost});
}
