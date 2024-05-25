import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/remote/permalink.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/file_info.dart';
import 'package:mattermost_flutter/types/gallery_action.dart';
import 'package:mattermost_flutter/types/typography.dart';

class OptionMenus extends HookWidget {
  final bool? canDownloadFiles;
  final bool? enablePublicLink;
  final FileInfo fileInfo;
  final Function(GalleryAction action) setAction;

  OptionMenus({
    this.canDownloadFiles,
    this.enablePublicLink,
    required this.fileInfo,
    required this.setAction,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final isTablet = useIsTablet();
    final intl = useIntl();

    final handleDownload = useCallback(() async {
      if (!isTablet) {
        await dismissBottomSheet();
      }
      setAction(GalleryAction.downloading);
    }, [setAction]);

    final handleCopyLink = useCallback(() async {
      if (!isTablet) {
        await dismissBottomSheet();
      }
      setAction(GalleryAction.copying);
    }, [setAction]);

    final handlePermalink = useCallback(() async {
      if (fileInfo.postId != null) {
        if (!isTablet) {
          await dismissBottomSheet();
        }
        showPermalink(serverUrl, '', fileInfo.postId!);
        setAction(GalleryAction.opening);
      }
    }, [intl, serverUrl, fileInfo.postId, setAction]);

    return Column(
      children: [
        if (canDownloadFiles != null && canDownloadFiles!)
          OptionItem(
            key: Key('download'),
            action: handleDownload,
            label: intl.formatMessage(
              id: 'screen.search.results.file_options.download',
              defaultMessage: 'Download',
            ),
            icon: Icons.download_outlined,
            type: 'default',
          ),
        OptionItem(
          key: Key('permalink'),
          action: handlePermalink,
          label: intl.formatMessage(
            id: 'screen.search.results.file_options.open_in_channel',
            defaultMessage: 'Open in channel',
          ),
          icon: Icons.language,
          type: 'default',
        ),
        if (enablePublicLink != null && enablePublicLink!)
          OptionItem(
            key: Key('copylink'),
            action: handleCopyLink,
            label: intl.formatMessage(
              id: 'screen.search.results.file_options.copy_link',
              defaultMessage: 'Copy link',
            ),
            icon: Icons.link,
            type: 'default',
          ),
      ],
    );
  }
}
