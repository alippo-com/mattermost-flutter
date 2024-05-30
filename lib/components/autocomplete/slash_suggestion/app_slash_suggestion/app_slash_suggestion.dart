import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/at_mention_item.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/components/slash_suggestion_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/app_command_parser.dart';
import 'package:mattermost_flutter/types/autocomplete_suggestion.dart';

class AppSlashSuggestion extends StatefulWidget {
  final String currentTeamId;
  final bool isSearch;
  final ValueChanged<String> updateValue;
  final ValueChanged<bool> onShowingChange;
  final String value;
  final bool nestedScrollEnabled;
  final String rootId;
  final String channelId;
  final bool isAppsEnabled;
  final TextStyle listStyle;

  AppSlashSuggestion({
    required this.currentTeamId,
    required this.updateValue,
    required this.onShowingChange,
    required this.value,
    required this.channelId,
    required this.isAppsEnabled,
    required this.listStyle,
    this.isSearch = false,
    this.nestedScrollEnabled = false,
    this.rootId = '',
  });

  @override
  _AppSlashSuggestionState createState() => _AppSlashSuggestionState();
}

class _AppSlashSuggestionState extends State<AppSlashSuggestion> {
  late AppCommandParser appCommandParser;
  late List<AutocompleteSuggestion> dataSource;
  late bool active;
  late bool mounted;

  @override
  void initState() {
    super.initState();
    appCommandParser = AppCommandParser(
      serverUrl: context.read<ServerUrl>().value,
      intl: context.read<Intl>(),
      channelId: widget.channelId,
      currentTeamId: widget.currentTeamId,
      rootId: widget.rootId,
    );
    dataSource = [];
    active = widget.isAppsEnabled && dataSource.isNotEmpty;
    mounted = true;
  }

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  void fetchAndShowAppCommandSuggestions(
    String pretext,
    String cId,
    String tId,
    String? rId,
  ) async {
    appCommandParser.setChannelContext(cId, tId, rId);
    final suggestions = await appCommandParser.getSuggestions(pretext);
    if (!mounted) return;
    updateSuggestions(suggestions);
  }

  void updateSuggestions(List<AutocompleteSuggestion> matches) {
    setState(() {
      dataSource = matches;
      widget.onShowingChange(matches.isNotEmpty);
    });
  }

  void completeSuggestion(String command) {
    context
        .read<Analytics>()
        .get(context.read<ServerUrl>().value)
        ?.trackCommand('complete_suggestion', '/$command ');

    String completedDraft = '/$command ';
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      completedDraft = '//$command ';
      widget.updateValue(completedDraft);
      Timer(Duration(milliseconds: 100), () {
        widget.updateValue(completedDraft.replaceFirst('//', '/'));
      });
    } else {
      widget.updateValue(completedDraft);
    }
  }

  void completeIgnoringSuggestion(String base) {
    completeSuggestion(base);
  }

  Widget renderItem(AutocompleteSuggestion item) {
    switch (item.type) {
      case COMMAND_SUGGESTION_USER:
        final user = item.item as UserProfile?;
        if (user == null) return Container();
        return AtMentionItem(
          user: user,
          onTap: () => completeIgnoringSuggestion(item.complete),
          testID: 'autocomplete.slash_suggestion.at_mention_item',
        );
      case COMMAND_SUGGESTION_CHANNEL:
        final channel = item.item as Channel?;
        if (channel == null) return Container();
        return ChannelItem(
          channel: channel,
          onTap: () => completeIgnoringSuggestion(item.complete),
          testID: 'autocomplete.slash_suggestion.channel_mention_item',
          isOnCenterBg: true,
          showChannelName: true,
        );
      default:
        return SlashSuggestionItem(
          description: item.description,
          hint: item.hint,
          onTap: () => completeSuggestion(item.complete),
          suggestion: item.suggestion,
          icon: item.iconData,
        );
    }
  }

  bool isAppCommand(String pretext, String channelID, String teamID, String? rootID) {
    appCommandParser.setChannelContext(channelID, teamID, rootID);
    return appCommandParser.isAppCommand(pretext);
  }

  @override
  Widget build(BuildContext context) {
    if (!active) return Container();

    return ListView.builder(
      itemCount: dataSource.length,
      itemBuilder: (context, index) {
        return renderItem(dataSource[index]);
      },
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.all(8),
      style: widget.listStyle,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
