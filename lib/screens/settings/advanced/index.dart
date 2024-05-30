// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/fs.dart';

const EMPTY_FILES = <ReadDirItem>[];

class AdvancedSettings extends StatefulWidget {
  final AvailableScreens componentId;

  AdvancedSettings({required this.componentId});

  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  late ThemeData theme;
  late IntlShape intl;
  late String serverUrl;
  int? dataSize;
  List<ReadDirItem> files = EMPTY_FILES;

  @override
  void initState() {
    super.initState();
    theme = useTheme(context);
    intl = IntlShape.of(context);
    serverUrl = useServerUrl(context);
    getAllCachedFiles();
  }

  Future<void> getAllCachedFiles() async {
    final result = await getAllFilesInCachesDirectory(serverUrl);
    setState(() {
      dataSize = result['totalSize'] ?? 0;
      files = result['files'] ?? EMPTY_FILES;
    });
  }

  void onPressDeleteData() async {
    if (files.isNotEmpty) {
      final formatMessage = intl.formatMessage;

      final shouldDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(formatMessage('settings.advanced.delete_data', 'Delete local files')),
            content: Text(formatMessage('settings.advanced.delete_message.confirmation', '\nThis will delete all files downloaded through the app for this server. Please confirm to proceed.\n')),
            actions: [
              TextButton(
                child: Text(formatMessage('settings.advanced.cancel', 'Cancel')),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(formatMessage('settings.advanced.delete', 'Delete')),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (shouldDelete ?? false) {
        await deleteFileCache(serverUrl);
        getAllCachedFiles();
      }
    }
  }

  void close() {
    popTopScreen(widget.componentId);
  }

  @override
  Widget build(BuildContext context) {
    useAndroidHardwareBackHandler(widget.componentId, close);

    final hasData = dataSize != null && dataSize! > 0;
    final styles = getStyleSheet(theme);

    return SettingContainer(
      testID: 'advanced_settings',
      child: GestureDetector(
        onTap: hasData ? onPressDeleteData : null,
        child: SettingOption(
          containerStyle: styles.itemStyle,
          destructive: true,
          icon: Icons.delete_outline,
          info: getFormattedFileSize(dataSize ?? 0),
          label: intl.formatMessage('settings.advanced.delete_data', 'Delete local files'),
          testID: 'advanced_settings.delete_data.option',
          type: 'none',
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleSheet(ThemeData theme) {
  return {
    'itemStyle': {
      'backgroundColor': theme.colorScheme.surface,
      'paddingHorizontal': 20.0,
    },
  };
}