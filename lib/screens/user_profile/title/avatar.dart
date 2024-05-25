import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/user_model.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:cached_network_image/cached_network_image.dart';

const double DEFAULT_IMAGE_SIZE = 96;

class UserProfileAvatar extends StatelessWidget {
  final bool enablePostIconOverride;
  final double? imageSize;
  final UserModel user;
  final String? userIconOverride;
  final GlobalKey? forwardRef; // Flutter uses GlobalKey for referencing widgets

  UserProfileAvatar({
    required this.enablePostIconOverride,
    this.imageSize,
    required this.user,
    this.userIconOverride,
    this.forwardRef,
  });

  @override
  Widget build(BuildContext context) {
    final double size = imageSize ?? DEFAULT_IMAGE_SIZE;

    if (enablePostIconOverride && userIconOverride != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CachedNetworkImage(
            imageUrl: userIconOverride!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ProfilePicture(
      user: user,
      size: size,
      showStatus: true,
      statusSize: 24,
      forwardRef: forwardRef,
    );
  }
}
