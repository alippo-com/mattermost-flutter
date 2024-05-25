// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mattermost_flutter/components/channel_list_row.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ChannelList extends HookConsumerWidget {
  final VoidCallback onEndReached;
  final bool loading;
  final List<Channel> channels;
  final Function(Channel) onSelectChannel;
  final String? term;

  ChannelList({
    required this.onEndReached,
    required this.loading,
    required this.channels,
    required this.onSelectChannel,
    this.term,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme();
    final style = getStyleFromTheme(theme);
    final keyboardHeight = useKeyboardHeight();
    final noResultsStyle = useMemoized(
      () => [
        style.noResultContainer,
        EdgeInsets.only(bottom: keyboardHeight),
      ],
      [style, keyboardHeight],
    );

    Widget renderItem(Channel item) {
      return ChannelListRow(
        channel: item,
        testID: 'browse_channels.custom_list.channel_item',
        onPress: () => onSelectChannel(item),
      );
    }

    Widget renderLoading() {
      if (!loading) return Container();

      return Loading(
        color: theme.buttonBg,
        containerStyle: style.loadingContainer,
        size: 'large',
      );
    }

    Widget renderNoResults() {
      if (term != null && term!.isNotEmpty) {
        return Container(
          padding: noResultsStyle,
          child: NoResultsWithTerm(term: term!),
        );
      }

      return Container(
        padding: noResultsStyle,
        child: FormattedText(
          id: 'browse_channels.noMore',
          defaultMessage: 'No more channels to join',
          style: style.noResultText,
        ),
      );
    }

    Widget renderSeparator() {
      return Container(
        height: 1,
        color: changeOpacity(theme.centerChannelColor, 0.08),
        width: double.infinity,
      );
    }

    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (context, index) => renderItem(channels[index]),
      key: Key('browse_channels.channel_list.flat_list'),
      emptyBuilder: (context) => renderNoResults(),
      footerBuilder: (context) => renderLoading(),
      onEndReached: onEndReached,
      padding: EdgeInsets.symmetric(horizontal: 20),
      separatorBuilder: (context, index) => renderSeparator(),
    );
  }

  Map<String, dynamic> getStyleFromTheme(Theme theme) {
    return {
      'loadingContainer': {
        'flex': 1,
        'justifyContent': MainAxisAlignment.center,
        'alignItems': CrossAxisAlignment.center,
      },
      'listContainer': {
        'paddingHorizontal': 20,
        'flexGrow': 1,
      },
      'noResultContainer': {
        'flexGrow': 1,
        'alignItems': CrossAxisAlignment.center,
        'justifyContent': MainAxisAlignment.center,
      },
      'noResultText': {
        'color': changeOpacity(theme.centerChannelColor, 0.5),
        ...typography('Body', 600, 'Regular'),
      },
      'separator': {
        'height': 1,
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
        'width': '100%',
      },
    };
  }
}
