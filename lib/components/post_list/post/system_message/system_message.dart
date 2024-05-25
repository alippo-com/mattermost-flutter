
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/user.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/markdown/markdown.dart';
import 'package:mattermost_flutter/components/post_list/combined_user_activity/messages.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/post_list/post/system_message/messages.dart';
import 'package:mattermost_flutter/components/post_list/post/system_message/system_message.dart';

class SystemMessage extends StatelessWidget {
  final UserModel? author;
  final String location;
  final PostModel post;
  final bool hideGuestTags;

  SystemMessage({
    this.author,
    required this.location,
    required this.post,
    required this.hideGuestTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);
    final textStyles = getMarkdownTextStyles(theme);
    final styles = {
      'messageStyle': style['systemMessage'],
      'textStyles': textStyles,
      'containerStyle': style['container'],
    };

    if (post.type == Post.POST_TYPES.GUEST_JOIN_CHANNEL) {
      return _renderGuestJoinChannelMessage(post, styles, theme);
    }
    if (post.type == Post.POST_TYPES.ADD_GUEST_TO_CHANNEL) {
      return _renderAddGuestToChannelMessage(post, styles, theme);
    }

    final renderer = _systemMessageRenderers[post.type];
    if (renderer == null) {
      return Markdown(
        baseTextStyle: styles['messageStyle'],
        channelId: post.channelId,
        location: location,
        disableGallery: true,
        textStyles: styles['textStyles'],
        value: post.message,
        theme: theme,
      );
    }

    return renderer(post, styles, theme);
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        marginBottom: 5,
      ),
      'systemMessage': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.6),
        ...typography('Body', 200, 'Regular'),
      ),
    };
  }

  Widget _renderGuestJoinChannelMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    if (post.props.username == null) {
      return Container();
    }

    final username = _renderUsername(post.props.username);
    final localeHolder = hideGuestTags
        ? postTypeMessages[Post.POST_TYPES.JOIN_CHANNEL].one
        : {
            'id': t('api.channel.guest_join_channel.post_and_forget'),
            'defaultMessage': '{username} joined the channel as a guest.',
          };

    final values = hideGuestTags ? {'firstUser': username} : {'username': username};
    return _renderMessage(post, styles, localeHolder, values, theme);
  }

  Widget _renderAddGuestToChannelMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    if (post.props.username == null || post.props.addedUsername == null) {
      return Container();
    }

    final username = _renderUsername(post.props.username);
    final addedUsername = _renderUsername(post.props.addedUsername);

    final localeHolder = hideGuestTags
        ? postTypeMessages[Post.POST_TYPES.ADD_TO_CHANNEL].one
        : {
            'id': t('api.channel.add_guest.added'),
            'defaultMessage': '{addedUsername} added to the channel as a guest by {username}.',
          };

    final values = hideGuestTags ? {'firstUser': addedUsername, 'actor': username} : {'username': username, 'addedUsername': addedUsername};
    return _renderMessage(post, styles, localeHolder, values, theme);
  }

  Widget _renderMessage(PostModel post, Map<String, dynamic> styles, Map<String, String> localeHolder, Map<String, String> values, Theme theme) {
    final containerStyle = styles['containerStyle'];
    final messageStyle = styles['messageStyle'];
    final textStyles = styles['textStyles'];

    return Container(
      child: Markdown(
        baseTextStyle: messageStyle,
        channelId: post.channelId,
        disableGallery: true,
        location: location,
        textStyles: textStyles,
        value: formatMessage(localeHolder, values),
        theme: theme,
      ),
    );
  }

  String _renderUsername(String value) {
    if (value.isNotEmpty) {
      return (value[0] == '@') ? value : '@$value';
    }
    return value;
  }

  static const Map<String, Function> _systemMessageRenderers = {
    Post.POST_TYPES.HEADER_CHANGE: _renderHeaderChangeMessage,
    Post.POST_TYPES.DISPLAYNAME_CHANGE: _renderDisplayNameChangeMessage,
    Post.POST_TYPES.PURPOSE_CHANGE: _renderPurposeChangeMessage,
    Post.POST_TYPES.CHANNEL_DELETED: _renderArchivedMessage,
    Post.POST_TYPES.CHANNEL_UNARCHIVED: _renderUnarchivedMessage,
  };

  static Widget _renderHeaderChangeMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    // Implementation for rendering header change message
  }

  static Widget _renderDisplayNameChangeMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    // Implementation for rendering display name change message
  }

  static Widget _renderPurposeChangeMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    // Implementation for rendering purpose change message
  }

  static Widget _renderArchivedMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    // Implementation for rendering archived message
  }

  static Widget _renderUnarchivedMessage(PostModel post, Map<String, dynamic> styles, Theme theme) {
    // Implementation for rendering unarchived message
  }
}
