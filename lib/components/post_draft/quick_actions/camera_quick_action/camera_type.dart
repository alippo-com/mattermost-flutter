// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'package:mattermost_flutter/types/components/post_draft_quick_action.dart';

class CameraType extends StatelessWidget {
  final Function(CameraOptions) onPress;

  CameraType({required this.onPress});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final intl = Intl.of(context);

    final style = getStyle(theme);

    void onPhoto() async {
      final options = CameraOptions(
        quality: 0.8,
        mediaType: 'photo',
        saveToPhotos: true,
      );

      await dismissBottomSheet(context);
      onPress(options);
    }

    void onVideo() async {
      final options = CameraOptions(
        videoQuality: 'high',
        mediaType: 'video',
        saveToPhotos: true,
      );

      await dismissBottomSheet(context);
      onPress(options);
    }

    return Column(
      children: [
        if (!isTablet)
          FormattedText(
            id: 'mobile.camera_type.title',
            defaultMessage: 'Camera options',
            style: style['title'],
          ),
        SlideUpPanelItem(
          leftIcon: Icons.camera_alt,
          onPress: onPhoto,
          testID: 'camera_type.photo',
          text: intl.formatMessage(
            id: 'camera_type.photo.option',
            defaultMessage: 'Capture Photo',
          ),
        ),
        SlideUpPanelItem(
          leftIcon: Icons.videocam,
          onPress: onVideo,
          testID: 'camera_type.video',
          text: intl.formatMessage(
            id: 'camera_type.video.option',
            defaultMessage: 'Record Video',
          ),
        ),
      ],
    );
  }

  Map<String, TextStyle> getStyle(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    };
  }
}

class CameraOptions {
  final double quality;
  final String mediaType;
  final bool saveToPhotos;
  final String? videoQuality;

  CameraOptions({
    required this.quality,
    required this.mediaType,
    required this.saveToPhotos,
    this.videoQuality,
  });
}
