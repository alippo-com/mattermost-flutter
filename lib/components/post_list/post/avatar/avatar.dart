import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:fast_image/fast_image.dart';

class Avatar extends StatelessWidget {
  final UserModel? author;
  final bool enablePostIconOverride;
  final bool isAutoResponse;
  final String location;
  final PostModel post;

  Avatar({
    this.author,
    this.enablePostIconOverride = false,
    required this.isAutoResponse,
    required this.location,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final theme = Provider.of<ThemeModel>(context);
    final serverUrl = Provider.of<ServerModel>(context).serverUrl;
    Client? client;
    try {
      client = NetworkManager.getClient(serverUrl);
    } catch (e) {
      // do nothing, client is not set
    }

    final fromWebHook = post.props?.fromWebhook == 'true';
    final iconOverride = enablePostIconOverride && post.props?.useUserIcon != 'true';
    if (fromWebHook && iconOverride) {
      final isEmoji = post.props?.overrideIconEmoji == true;
      final frameSize = ViewConstant.PROFILE_PICTURE_SIZE;
      final pictureSize = isEmoji ? ViewConstant.PROFILE_PICTURE_EMOJI_SIZE : ViewConstant.PROFILE_PICTURE_SIZE;
      final borderRadius = isEmoji ? 0 : ViewConstant.PROFILE_PICTURE_SIZE / 2;
      final overrideIconUrl = client?.getAbsoluteUrl(post.props?.overrideIconUrl);

      Widget iconComponent;
      if (overrideIconUrl != null) {
        final source = FastImageProvider(Uri.parse(overrideIconUrl));
        iconComponent = FastImage(
          imageProvider: source,
          height: pictureSize,
          width: pictureSize,
        );
      } else {
        iconComponent = CompassIcon(
          icon: Icons.webhook,
          size: 32,
        );
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        height: frameSize,
        width: frameSize,
        child: Center(
          child: iconComponent,
        ),
      );
    }

    void openUserProfile() {
      if (author == null) {
        return;
      }
      final screen = Screens.USER_PROFILE;
      final title = intl.formatMessage(id: 'mobile.routes.user_profile', defaultMessage: 'Profile');
      final closeButtonId = 'close-user-profile';
      final props = {
        'closeButtonId': closeButtonId,
        'userId': author!.id,
        'channelId': post.channelId,
        'location': location,
        'userIconOverride': post.props?.overrideUsername,
        'usernameOverride': post.props?.overrideIconUrl,
      };

      FocusScope.of(context).unfocus();
      openAsBottomSheet(context, screen: screen, title: title, theme: theme, closeButtonId: closeButtonId, props: props);
    }

    Widget component = ProfilePicture(
      author: author,
      size: ViewConstant.PROFILE_PICTURE_SIZE,
      iconSize: 24,
      showStatus: !isAutoResponse || (author?.isBot ?? false),
      testID: 'post_avatar.${author?.id}.profile_picture',
    );

    if (!fromWebHook) {
      component = GestureDetector(
        onTap: () => preventDoubleTap(openUserProfile),
        child: component,
      );
    }

    return component;
  }
}
