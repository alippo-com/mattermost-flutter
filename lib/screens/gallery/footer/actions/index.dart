import 'package:flutter/material.dart';
import 'package:mattermost_flutter/screens/gallery/footer/actions/action.dart';
import 'package:mattermost_flutter/types/managed_config.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Actions extends StatelessWidget {
  final bool canDownloadFiles;
  final bool disabled;
  final bool enablePublicLinks;
  final String fileId;
  final VoidCallback onCopyPublicLink;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final bool hasCaptions;
  final bool captionEnabled;
  final VoidCallback onCaptionsPress;

  Actions({
    required this.canDownloadFiles,
    required this.disabled,
    required this.enablePublicLinks,
    required this.fileId,
    required this.onCopyPublicLink,
    required this.onDownload,
    required this.onShare,
    required this.hasCaptions,
    required this.captionEnabled,
    required this.onCaptionsPress,
  });

  @override
  Widget build(BuildContext context) {
    final managedConfig = useManagedConfig<ManagedConfig>();
    final canCopyPublicLink = !fileId.startsWith('uid') &&
        enablePublicLinks &&
        managedConfig.copyAndPasteProtection != 'true';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (canCopyPublicLink)
          Action(
            disabled: disabled,
            iconName: 'link-variant',
            onPress: onCopyPublicLink,
          ),
        if (hasCaptions)
          InvertedAction(
            activated: captionEnabled,
            iconName: 'closed-caption-outline',
            onPress: onCaptionsPress,
          ),
        if (canDownloadFiles) ...[
          Action(
            disabled: disabled,
            iconName: 'download-outline',
            onPress: onDownload,
          ),
          Action(
            disabled: disabled,
            iconName: 'export-variant',
            onPress: onShare,
          ),
        ],
      ],
    );
  }
}
