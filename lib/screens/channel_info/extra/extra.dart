import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mattermost_flutter/components/custom_status_expiry.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/formatted_date.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/constants/snack_bar.dart';
import 'package:mattermost_flutter/constants/versions.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:clipboard/clipboard.dart';
import 'package:moment/moment.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Extra extends StatelessWidget {
  final String channelId;
  final int createdAt;
  final String createdBy;
  final UserCustomStatus? customStatus;
  final String? header;
  final bool isCustomStatusEnabled;

  Extra({
    required this.channelId,
    required this.createdAt,
    required this.createdBy,
    required this.isCustomStatusEnabled,
    this.customStatus,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = useTheme();
    final managedConfig = useManagedConfig<ManagedConfig>();

    final styles = getStyleSheet(theme);
    final blockStyles = getMarkdownBlockStyles(theme);
    final textStyles = getMarkdownTextStyles(theme);
    final created = {
      'user': createdBy,
      'date': FormattedDate(
        style: styles.created,
        value: createdAt,
      ),
    };

    void onCopy(String text, {bool isLink = false}) async {
      Clipboard.setData(ClipboardData(text: text));
      await dismissBottomSheet();
      if ((Platform.isAndroid && Platform.version < ANDROID_33) || Platform.isIOS) {
        showSnackBar(
          barType: isLink ? SNACK_BAR_TYPE.LINK_COPIED : SNACK_BAR_TYPE.TEXT_COPIED,
        );
      }
    }

    void handleLongPress({String? url}) {
      if (managedConfig?.copyAndPasteProtection != 'true') {
        void renderContent() {
          return Column(
            children: [
              SlideUpPanelItem(
                leftIcon: Icons.content_copy,
                onPress: () => onCopy(header!),
                text: intl.formatMessage(
                  id: 'mobile.markdown.copy_header',
                  defaultMessage: 'Copy header text',
                ),
              ),
              if (url != null)
                SlideUpPanelItem(
                  leftIcon: Icons.link,
                  onPress: () => onCopy(url, isLink: true),
                  text: intl.formatMessage(
                    id: 'mobile.markdown.link.copy_url',
                    defaultMessage: 'Copy URL',
                  ),
                ),
              SlideUpPanelItem(
                destructive: true,
                leftIcon: Icons.cancel,
                onPress: () => dismissBottomSheet(),
                text: intl.formatMessage(
                  id: 'mobile.post.cancel',
                  defaultMessage: 'Cancel',
                ),
              ),
            ],
          );
        }

        bottomSheet(
          context,
          closeButtonId: 'close-markdown-link',
          renderContent: renderContent,
          snapPoints: [1, bottomSheetSnapPoint(url != null ? 3 : 2, ITEM_HEIGHT, bottomInsets)],
          title: intl.formatMessage({id: 'post.options.title', defaultMessage: 'Options'}),
          theme: theme,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCustomStatusEnabled && customStatus != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormattedText(
                  id: 'channel_info.custom_status',
                  defaultMessage: 'Custom status:',
                  style: styles.extraHeading,
                ),
                Row(
                  children: [
                    if (customStatus!.emoji != null)
                      Emoji(
                        emojiName: customStatus!.emoji!,
                        size: 24,
                      ),
                    if (customStatus!.text != null)
                      Text(
                        customStatus!.text!,
                        style: styles.customStatusLabel,
                      ),
                    if (customStatus!.duration != null)
                      CustomStatusExpiry(
                        time: moment(customStatus!.expiresAt),
                        theme: theme,
                        textStyles: styles.customStatusExpiry,
                        withinBrackets: false,
                        showPrefix: true,
                        showToday: true,
                        showTimeCompulsory: false,
                      ),
                  ],
                ),
              ],
            ),
          if (header != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormattedText(
                  id: 'channel_info.header',
                  defaultMessage: 'Header:',
                  style: styles.extraHeading,
                ),
                TouchableWithFeedback(
                  type: TouchableType.opacity,
                  activeOpacity: 0.8,
                  onLongPress: () => handleLongPress(),
                  child: Markdown(
                    channelId: channelId,
                    baseTextStyle: styles.header,
                    blockStyles: blockStyles,
                    disableBlockQuote: true,
                    disableCodeBlock: true,
                    disableGallery: true,
                    disableHeading: true,
                    disableTables: true,
                    location: Screens.CHANNEL_INFO,
                    textStyles: textStyles,
                    layoutHeight: 48,
                    layoutWidth: 100,
                    theme: theme,
                    imagesMetadata: headerMetadata,
                    value: header!,
                    onLinkLongPress: handleLongPress,
                  ),
                ),
              ],
            ),
          if (createdAt != null && createdBy != null)
            FormattedText(
              id: 'channel_intro.createdBy',
              defaultMessage: 'Created by {user} on {date}',
              style: styles.created,
              values: created,
            ),
          if (createdAt != null && createdBy == null)
            FormattedText(
              id: 'channel_intro.createdOn',
              defaultMessage: 'Created on {date}',
              style: styles.created,
              values: created,
            ),
        ],
      ),
    );
  }
}

getStyleSheet(ThemeData theme) {
  return {
    'container': {
      'marginBottom': 20,
    },
    'item': {
      'marginTop': 16,
    },
    'extraHeading': {
      'color': changeOpacity(theme.centerChannelColor, 0.56),
      'marginBottom': 8,
    },
    'header': {
      'color': theme.centerChannelColor,
    },
    'created': {
      'color': changeOpacity(theme.centerChannelColor, 0.48),
    },
    'customStatus': {
      'alignItems': 'center',
      'flexDirection': 'row',
    },
    'customStatusEmoji': {
      'marginRight': 10,
    },
    'customStatusLabel': {
      'color': theme.centerChannelColor,
      'marginRight': 8,
    },
    'customStatusExpiry': {
      'color': changeOpacity(theme.centerChannelColor, 0.64),
    },
  };
}
