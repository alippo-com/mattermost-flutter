
    final getUsernames = useCallback((List<String> userIds) {
      final someone = intl.formatMessage(id: 'channel_loader.someone', defaultMessage: 'Someone');
      final you = intl.formatMessage(id: 'combined_system_message.you', defaultMessage: 'You');
      final usernamesValues = usernamesById.values.toList();
      final usernames = userIds.fold<List<String>>([], (acc, id) {
        if (id != currentUserId && id != currentUsername) {
          final name = usernamesById[id] ?? usernamesValues.firstWhere((n) => n == id, orElse: () => '');
          acc.add(name.isNotEmpty ? '@$name' : someone);
        }
        return acc;
      });

      if (currentUserId != null && userIds.contains(currentUserId)) {
        usernames.insert(0, you);
      } else if (currentUsername != null && userIds.contains(currentUsername)) {
        usernames.insert(0, you);
      }

      return usernames;
    }, [currentUserId, currentUsername, usernamesById]);

    final onLongPress = useCallback(() {
      if (!canDelete || post == null) {
        return;
      }

      final passProps = {
        'post': post,
        'sourceScreen': location,
      };
      final title = isTablet ? intl.formatMessage(id: 'post.options.title', defaultMessage: 'Options') : '';

      if (isTablet) {
        showModal(Screens.POST_OPTIONS, title, passProps, bottomSheetModalOptions(theme, 'close-post-options'));
      } else {
        showModalOverCurrentContext(Screens.POST_OPTIONS, passProps, bottomSheetModalOptions(theme));
      }
    }, [post, canDelete, isTablet, intl, location]);

    final renderMessage = useCallback((String postType, List<String> userIds, String actorId) {
      if (post == null) {
        return null;
      }
      var actor = usernamesById[actorId] ?? '';
      if (actor.isNotEmpty && (actorId == currentUserId || actorId == currentUsername)) {
        actor = intl.formatMessage(id: 'combined_system_message.you', defaultMessage: 'You').toLowerCase();
      }

      final usernames = getUsernames(userIds);
      final numOthers = usernames.length - 1;

      if (numOthers > 1) {
        return LastUsers(
          key: '$postType$actorId',
          channelId: post!.channelId,
          actor: actor,
          location: location,
          postType: postType,
          theme: theme,
          usernames: usernames,
        );
      }

      final firstUser = usernames[0];
      final secondUser = usernames.length > 1 ? usernames[1] : '';
      final localeHolder = numOthers == 0
          ? (userIds[0] == currentUserId || userIds[0] == currentUsername
              ? postTypeMessages[postType]['one_you']
              : postTypeMessages[postType]['one'])
          : postTypeMessages[postType]['two'];
      final formattedMessage = intl.formatMessage(localeHolder, {'firstUser': firstUser, 'secondUser': secondUser, 'actor': actor});

      return Markdown(
        key: '$postType$actorId',
        channelId: post!.channelId,
        baseTextStyle: styles.baseText,
        location: location,
        textStyles: textStyles,
        value: formattedMessage,
        theme: theme,
      );
    }, [post, currentUserId, currentUsername, usernamesById, getUsernames, theme, intl, styles.baseText, location, textStyles]);

    if (post == null) {
      return Container();
    }

    final itemTestID = '$testID.${post.id}';
    final messageData = post.props['user_activity']['messageData'];
    for (final message in messageData) {
      final postType = message['postType'];
      final actorId = message['actorId'];
      final userIds = Set<String>.from(message['userIds']);

      if (!showJoinLeave && currentUserId != null && actorId != currentUserId) {
        if (userIds.contains(currentUserId)) {
          userIds.add(currentUserId);
        } else {
          continue;
        }
      }

      if (postType == PostConstants.POST_TYPES.REMOVE_FROM_CHANNEL) {
        removedUserIds.value.addAll(userIds);
        continue;
      }

      content.value.add(renderMessage(postType, userIds.toList(), actorId));
    }

    if (removedUserIds.value.isNotEmpty) {
      final uniqueRemovedUserIds = removedUserIds.value.toSet().toList();
      content.value.add(renderMessage(PostConstants.POST_TYPES.REMOVE_FROM_CHANNEL, uniqueRemovedUserIds, currentUserId ?? ''));
    }

    return Container(
      decoration = style,
      child = GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          decoration: styles.container,
          child: Row(
            children: [
              SystemAvatar(theme: theme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SystemHeader(createAt: post!.createAt, theme: theme),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: content.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'baseText': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.6),
        fontSize: 16,
        height: 1.25,
      ),
      'body': {
        'flex': 1,
        'paddingBottom': 2,
        'paddingTop': 2,
      },
      'container': BoxDecoration(
        flexDirection: Axis.horizontal,
        paddingHorizontal: 20,
        marginTop: 10,
      ),
      'content': {
        'flex': 1,
        'flexDirection': Axis.vertical,
        'marginLeft': 12,
      },
    };
  }
}
