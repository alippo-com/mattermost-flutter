
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/actions/remote/file.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatelessWidget {
  final String? authorId;
  final String? overrideIconUrl;

  Avatar({this.authorId, this.overrideIconUrl});

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl(context);
    final avatarUri = _getAvatarUri(serverUrl, authorId, overrideIconUrl);

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      margin: EdgeInsets.all(2),
      width: 32,
      height: 32,
      child: avatarUri != null
          ? CachedNetworkImage(
              imageUrl: avatarUri,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            )
          : CompassIcon(
              name: 'account-outline',
              size: 32,
              color: changeOpacity(Colors.white, 0.48),
            ),
    );
  }

  String? _getAvatarUri(String serverUrl, String? authorId, String? overrideIconUrl) {
    try {
      if (overrideIconUrl != null) {
        return buildAbsoluteUrl(serverUrl, overrideIconUrl);
      } else if (authorId != null) {
        final pictureUrl = buildProfileImageUrl(serverUrl, authorId);
        return '$serverUrl$pictureUrl';
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
