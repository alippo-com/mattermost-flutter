// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants/snack_bar.dart';
import 'package:mattermost_flutter/constants/versions.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:react_intl/react_intl.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';

class PublicPrivate extends HookWidget {
  final String? displayName;
  final String? purpose;

  PublicPrivate({this.displayName, this.purpose});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final managedConfig = useManagedConfig<ManagedConfig>();
    final bottom = useSafeAreaInsets().bottom;

    final styles = getStyleSheet(theme);
    final publicPrivateTestId = 'channel_info.title.public_private';

    final onCopy = useCallback(() async {
      Clipboard.setData(ClipboardData(text: purpose!));
      await dismissBottomSheet();
      if ((Platform.isAndroid && int.parse(Platform.operatingSystemVersion) < ANDROID_33) || Platform.isIOS) {
        showSnackBar(SNACK_BAR_TYPE.TEXT_COPIED);
      }
    }, [purpose]);

    final handleLongPress = useCallback(() {
      if (managedConfig?.copyAndPasteProtection != 'true') {
        final renderContent = () {
          return Column(
            children: [
              SlideUpPanelItem(
                leftIcon: Icons.content_copy,
                onPress: onCopy,
                testID: '${publicPrivateTestId}.bottom_sheet.copy_purpose',
                text: intl.formatMessage(id: 'channel_info.copy_purpose_text', defaultMessage: 'Copy Purpose Text'),
              ),
              SlideUpPanelItem(
                destructive: true,
                leftIcon: Icons.cancel,
                onPress: () {
                  dismissBottomSheet();
                },
                testID: '${publicPrivateTestId}.bottom_sheet.cancel',
                text: intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel'),
              ),
            ],
          );
        };

        bottomSheet(
          context: context,
          closeButtonId: 'close-mardown-link',
          renderContent: renderContent,
          snapPoints: [1, bottomSheetSnapPoint(2, ITEM_HEIGHT, bottom)],
          title: intl.formatMessage(id: 'post.options.title', defaultMessage: 'Options'),
          theme: theme,
        );
      }
    }, [
      bottom,
      theme,
      onCopy,
      intl.formatMessage,
      managedConfig?.copyAndPasteProtection,
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName ?? '',
          style: styles.title,
          key: Key('${publicPrivateTestId}.display_name'),
        ),
        if (purpose != null && purpose!.isNotEmpty)
          Text(
            purpose!,
            onLongPress: handleLongPress,
            style: styles.purpose,
            key: Key('${publicPrivateTestId}.purpose'),
          ),
      ],
    );
  }

  getStyleSheet(Theme theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w700,
        fontSize: 20, // Assuming 'Heading' size
      ),
      'purpose': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.72),
        marginTop: 8,
        fontSize: 16, // Assuming 'Body' size
      ),
    };
  }
}

const style = {
  'bottomsheet': {
    'flex': 1,
  }
};
