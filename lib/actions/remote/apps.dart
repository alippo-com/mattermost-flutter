void postEphemeralCallResponseForPost(
    String serverUrl, AppCallResponse response, String message, PostModel post) {
  sendEphemeralPost(
    serverUrl,
    message,
    post.channelId,
    post.rootId ?? post.id,
    response.appMetadata?.botUserId,
  );
}

void postEphemeralCallResponseForChannel(
    String serverUrl, AppCallResponse response, String message, String channelID) {
  sendEphemeralPost(
    serverUrl,
    message,
    channelID,
    '',
    response.appMetadata?.botUserId,
  );
}

void postEphemeralCallResponseForContext(
    String serverUrl, AppCallResponse response, String message, AppContext context) {
  sendEphemeralPost(
    serverUrl,
    message,
    context.channelId!,
    context.rootId ?? context.postId,
    response.appMetadata?.botUserId,
  );
}

void postEphemeralCallResponseForCommandArgs(
    String serverUrl, AppCallResponse response, String message, CommandArgs args) {
  sendEphemeralPost(
    serverUrl,
    message,
    args.channelId,
    args.rootId,
    response.appMetadata?.botUserId,
  );
}
