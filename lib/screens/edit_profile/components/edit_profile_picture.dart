// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'profile_image.dart'; // Custom Profile Image widget
import 'constants.dart'; // Custom constants file
import 'server_context.dart'; // Custom server context provider
import 'theme_context.dart'; // Custom theme context provider
import 'network_manager.dart'; // Custom network manager
import 'theme_utils.dart'; // Custom theme utilities
import 'profile_image_picker.dart'; // Custom Profile Image Picker widget
import 'user_model.dart'; // Custom user model

class EditProfilePicture extends StatefulWidget {
  final UserModel user;
  final Function({String? localPath, bool? isRemoved}) onUpdateProfilePicture;

  const EditProfilePicture({
    required this.user,
    required this.onUpdateProfilePicture,
  });

  @override
  _EditProfilePictureState createState() => _EditProfilePictureState();
}

class _EditProfilePictureState extends State<EditProfilePicture> {
  static const double SIZE = 128.0;
  late String? pictureUrl;
  late Client? client;

  @override
  void initState() {
    super.initState();
    final serverUrl = Provider.of<ServerContext>(context, listen: false).serverUrl;
    final theme = Provider.of<ThemeContext>(context, listen: false).theme;

    client = NetworkManager.getClient(serverUrl);

    pictureUrl = client?.getProfilePictureUrl(widget.user.id, widget.user.lastPictureUpdate);
  }

  @override
  void didUpdateWidget(EditProfilePicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    final url = widget.user.id.isNotEmpty && client != null
        ? client!.getProfilePictureUrl(widget.user.id, widget.user.lastPictureUpdate)
        : null;
    if (url != pictureUrl) {
      setState(() {
        pictureUrl = url;
      });
    }
  }

  void handleProfileImage({List<File>? images}) {
    bool isRemoved = true;
    String? localPath;
    String pUrl = ACCOUNT_OUTLINE_IMAGE;

    final newImage = images?.first.path;
    if (newImage != null) {
      isRemoved = false;
      localPath = newImage;
      pUrl = newImage;
    }

    setState(() {
      pictureUrl = pUrl;
    });
    widget.onUpdateProfilePicture(localPath: localPath, isRemoved: isRemoved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeContext>(context).theme;

    final styles = getStyleSheet(theme);
    final pictureSource = getPictureSource(pictureUrl, Provider.of<ServerContext>(context).serverUrl);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.08),
        borderRadius: BorderRadius.circular(SIZE / 2),
      ),
      height: SIZE,
      width: SIZE,
      child: Stack(
        children: [
          ProfileImage(
            size: SIZE,
            source: pictureSource,
            author: widget.user,
            showStatus: false,
          ),
          Positioned.fill(
            child: ProfileImagePicker(
              onRemoveProfileImage: handleProfileImage,
              uploadFiles: handleProfileImage,
              user: widget.user,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': {
        'alignment': Alignment.center,
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
        'borderRadius': SIZE / 2,
        'height': SIZE,
        'justifyContent': MainAxisAlignment.center,
        'width': SIZE,
      },
      'camera': {
        'position': 'absolute',
        'overflow': 'hidden',
        'height': '100%',
        'width': '100%',
      },
    };
  }

  dynamic getPictureSource(String? pictureUrl, String serverUrl) {
    if (pictureUrl == ACCOUNT_OUTLINE_IMAGE) {
      return AssetImage(ACCOUNT_OUTLINE_IMAGE);
    } else if (pictureUrl != null) {
      String prefix = '';
      if (pictureUrl.contains('/api/')) {
        prefix = serverUrl;
      } else if (Platform.isAndroid &&
          !pictureUrl.startsWith('content://') &&
          !pictureUrl.startsWith('http://') &&
          !pictureUrl.startsWith('https://')) {
        prefix = 'file://';
      }

      return NetworkImage('$prefix$pictureUrl');
    }
    return null;
  }
}
