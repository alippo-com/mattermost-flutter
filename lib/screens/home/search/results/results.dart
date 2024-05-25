
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/files_search/file_results.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/search.dart';
import 'package:mattermost_flutter/screens/home/search/results/post_results.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const int duration = 250;

class Results extends HookWidget {
  final bool appsEnabled;
  final bool canDownloadFiles;
  final String currentTimezone;
  final List<String> customEmojiNames;
  final List<Channel> fileChannels;
  final List<FileInfo> fileInfos;
  final bool loading;
  final List<Post> posts;
  final SearchMatches? matches;
  final bool publicLinkEnabled;
  final double scrollPaddingTop;
  final String searchValue;
  final TabType selectedTab;

  Results({
    required this.appsEnabled,
    required this.canDownloadFiles,
    required this.currentTimezone,
    required this.customEmojiNames,
    required this.fileChannels,
    required this.fileInfos,
    required this.loading,
    required this.posts,
    this.matches,
    required this.publicLinkEnabled,
    required this.scrollPaddingTop,
    required this.searchValue,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = useTheme();

    final containerStyle = useMemo(() {
      return BoxDecoration(
        color: theme.buttonBg,
        transform: selectedTab == TabTypes.messages
            ? Matrix4.translationValues(0, 0, 0)
            : Matrix4.translationValues(-width, 0, 0),
      );
    }, [selectedTab, width, loading]);

    final paddingTopStyle = useMemo(() {
      return EdgeInsets.only(top: scrollPaddingTop);
    }, [scrollPaddingTop]);

    return Stack(
      children: [
        if (loading)
          Loading(
            color: theme.buttonBg,
            size: 'large',
            containerStyle: paddingTopStyle,
          ),
        if (!loading)
          Container(
            decoration: containerStyle,
            child: Row(
              children: [
                Expanded(
                  child: PostResults(
                    appsEnabled: appsEnabled,
                    currentTimezone: currentTimezone,
                    customEmojiNames: customEmojiNames,
                    posts: posts,
                    matches: matches,
                    paddingTop: paddingTopStyle,
                    searchValue: searchValue,
                  ),
                ),
                Expanded(
                  child: FileResults(
                    canDownloadFiles: canDownloadFiles,
                    fileChannels: fileChannels,
                    fileInfos: fileInfos,
                    paddingTop: paddingTopStyle,
                    publicLinkEnabled: publicLinkEnabled,
                    searchValue: searchValue,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
