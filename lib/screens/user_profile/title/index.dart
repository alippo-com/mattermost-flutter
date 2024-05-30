import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/user_profile_avatar.dart';
import 'package:mattermost_flutter/components/user_profile_tag.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/services/network_manager.dart';
import 'package:mattermost_flutter/utils/gallery.dart';

class UserProfileTitle extends HookWidget {
  final bool enablePostIconOverride;
  final bool enablePostUsernameOverride;
  final String? headerText;
  final int? imageSize;
  final bool isChannelAdmin;
  final bool isSystemAdmin;
  final bool isTeamAdmin;
  final String teammateDisplayName;
  final UserModel user;
  final String? userIconOverride;
  final String? usernameOverride;
  final bool hideGuestTags;

  const UserProfileTitle({
    required this.enablePostIconOverride,
    required this.enablePostUsernameOverride,
    this.headerText,
    this.imageSize,
    required this.isChannelAdmin,
    required this.isSystemAdmin,
    required this.isTeamAdmin,
    required this.teammateDisplayName,
    required this.user,
    this.userIconOverride,
    this.usernameOverride,
    required this.hideGuestTags,
  });

  @override
  Widget build(BuildContext context) {
    final galleryIdentifier = '${user.id}-avatarPreview';
    final intl = useIntl();
    final isTablet = useIsTablet();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final override = enablePostUsernameOverride && usernameOverride != null;

    String displayName;
    if (override) {
      displayName = usernameOverride!;
    } else {
      displayName = displayUsername(user, intl.locale, teammateDisplayName, false);
    }

    void onPress() async {
      String? imageUrl;
      if (enablePostIconOverride && userIconOverride != null) {
        imageUrl = userIconOverride;
      } else {
        try {
          final client = NetworkManager.getClient(serverUrl);
          final lastPictureUpdate = user.isBot ? (user.props?.bot_last_icon_update ?? 0) : user.lastPictureUpdate;
          final pictureUrl = client.getProfilePictureUrl(user.id, lastPictureUpdate);
          imageUrl = '$serverUrl$pictureUrl';
        } catch (e) {
          // handle below that the client is not set
        }
      }

      if (imageUrl != null) {
        final item = GalleryItemType(
          id: user.id,
          uri: imageUrl,
          width: 400,
          height: 400,
          lastPictureUpdate: user.lastPictureUpdate,
          name: displayName,
          mimeType: 'image/png',
          authorId: user.id,
          type: 'avatar',
        );
        openGalleryAtIndex(galleryIdentifier, 0, [item]);
      }
    }

    final galleryItem = useGalleryItem(
      galleryIdentifier,
      0,
      onPress,
    );

    final hideUsername = override || (displayName.isNotEmpty && displayName == user.username);
    final prefix = hideUsername ? '@' : '';

    return Column(
      children: [
        if (headerText != null)
          Text(
            headerText!,
            style: styles.heading,
            testID: 'user_profile.heading',
          ),
        Container(
          margin: EdgeInsets.only(top: isTablet ? 20 : 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: galleryItem.onGestureEvent,
                child: UserProfileAvatar(
                  forwardRef: galleryItem.ref,
                  enablePostIconOverride: enablePostIconOverride,
                  imageSize: imageSize,
                  user: user,
                  userIconOverride: userIconOverride,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfileTag(
                      isBot: user.isBot || userIconOverride != null || usernameOverride != null,
                      isChannelAdmin: isChannelAdmin,
                      showGuestTag: user.isGuest && !hideGuestTags,
                      isSystemAdmin: isSystemAdmin,
                      isTeamAdmin: isTeamAdmin,
                    ),
                    Text(
                      '$prefix$displayName',
                      style: styles.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      testID: 'user_profile.display_name',
                    ),
                    if (!hideUsername)
                      Text(
                        '@${user.username}',
                        style: styles.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        testID: 'user_profile.username',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static getStyleSheet(Theme theme) {
    return {
      'container': {'flexDirection': 'row', 'marginBottom': 20},
      'details': {'marginLeft': 24, 'justifyContent': 'center', 'flex': 1},
      'displayName': {'color': theme.centerChannelColor, ...typography('Heading', 600, 'SemiBold')},
      'username': {'color': changeOpacity(theme.centerChannelColor, 0.64), ...typography('Body', 200)},
      'heading': {'height': HEADER_TEXT_HEIGHT, 'color': theme.centerChannelColor, 'marginBottom': 20, ...typography('Heading', 600, 'SemiBold')},
      'tablet': {'marginTop': 20},
    };
  }
}

class UserModel {
  final String id;
  final bool isBot;
  final bool isGuest;
  final String username;
  final int lastPictureUpdate;
  final Map<String, dynamic>? props;

  UserModel({
    required this.id,
    required this.isBot,
    required this.isGuest,
    required this.username,
    required this.lastPictureUpdate,
    this.props,
  });
}

class GalleryItemType {
  final String id;
  final String uri;
  final int width;
  final int height;
  final int lastPictureUpdate;
  final String name;
  final String mimeType;
  final String authorId;
  final String type;

  GalleryItemType({
    required this.id,
    required this.uri,
    required this.width,
    required this.height,
    required this.lastPictureUpdate,
    required this.name,
    required this.mimeType,
    required this.authorId,
    required this.type,
  });
}
