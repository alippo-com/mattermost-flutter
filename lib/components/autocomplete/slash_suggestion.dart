import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/command.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/managers/integrations_manager.dart';
import 'package:mattermost_flutter/components/app_command_parser/app_command_parser.dart';
import 'package:mattermost_flutter/components/slash_suggestion_item.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const List<String> commandsToImplementLater = ['collapse', 'expand', 'logout'];
const List<String> nonMobileCommands = ['shortcuts', 'search', 'settings'];
final Set<String> commandsToHideOnMobile = {...commandsToImplementLater, ...nonMobileCommands};

bool commandFilter(Command command) {
  return !commandsToHideOnMobile.contains(command.trigger);
}

List<AutocompleteSuggestion> filterCommands(String matchTerm, List<Command> commands) {
  final data = commands.where((command) {
    if (!command.autoComplete) return false;
    if (matchTerm.isEmpty) return true;
    return command.displayName.startsWith(matchTerm) || command.trigger.startsWith(matchTerm);
  }).toList();

  return data.map((command) {
    return AutocompleteSuggestion(
      complete: command.trigger,
      suggestion: '/' + command.trigger,
      hint: command.autoCompleteHint,
      description: command.autoCompleteDesc,
      iconData: command.iconUrl ?? command.autocompleteIconData ?? '',
    );
  }).toList();
}

class SlashSuggestion extends StatefulWidget {
  final String currentTeamId;
  final ValueChanged<String> updateValue;
  final ValueChanged<bool> onShowingChange;
  final String value;
  final bool nestedScrollEnabled;
  final String rootId;
  final String channelId;
  final bool isAppsEnabled;
  final TextStyle listStyle;

  const SlashSuggestion({
    Key? key,
    required this.currentTeamId,
    required this.updateValue,
    required this.onShowingChange,
    required this.value,
    required this.nestedScrollEnabled,
    required this.rootId,
    required this.channelId,
    required this.isAppsEnabled,
    required this.listStyle,
  }) : super(key: key);

  @override
  _SlashSuggestionState createState() => _SlashSuggestionState();
}

class _SlashSuggestionState extends State<SlashSuggestion> {
  late AppCommandParser appCommandParser;
  bool mounted = false;
  String? noResultsTerm;
  List<AutocompleteSuggestion> dataSource = [];
  List<Command>? commands;

  bool get active => dataSource.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final serverUrl = context.read<ServerUrl>();
    final intl = context.read<Internationalization>();
    appCommandParser = AppCommandParser(serverUrl, intl, widget.channelId, widget.currentTeamId, widget.rootId);
    mounted = true;
    fetchCommands();
  }

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  Future<void> fetchCommands() async {
    final serverUrl = context.read<ServerUrl>();

    try {
      final res = await IntegrationsManager.getManager(serverUrl).fetchCommands(widget.currentTeamId);
      if (mounted) {
        setState(() {
          commands = res.where(commandFilter).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          commands = [];
        });
      }
    }
  }

  void updateSuggestions(List<AutocompleteSuggestion> matches) {
    setState(() {
      dataSource = matches;
    });
    widget.onShowingChange(matches.isNotEmpty);
  }

  void runFetch(String sUrl, String term, String tId, String cId, String? rId) async {
    try {
      final res = await fetchSuggestions(sUrl, term, tId, cId, rId);
      if (!mounted) return;
      if (res.containsKey('error')) {
        updateSuggestions([]);
      } else if (res['suggestions'].isEmpty) {
        updateSuggestions([]);
        setState(() {
          noResultsTerm = term;
        });
      } else {
        updateSuggestions(res['suggestions']);
      }
    } catch (e) {
      updateSuggestions([]);
    }
  }

  List<AutocompleteSuggestion> getAppBaseCommandSuggestions(String pretext) {
    appCommandParser.setChannelContext(widget.channelId, widget.currentTeamId, widget.rootId);
    return appCommandParser.getSuggestionsBase(pretext);
  }

  void showBaseCommands(String text) {
    List<AutocompleteSuggestion> matches = [];

    if (widget.isAppsEnabled) {
      final appCommands = getAppBaseCommandSuggestions(text);
      matches.addAll(appCommands);
    }

    matches.addAll(filterCommands(text.substring(1), commands ?? []));

    matches.sort((match1, match2) {
      if (match1.suggestion == match2.suggestion) return 0;
      return match1.suggestion.compareTo(match2.suggestion);
    });

    updateSuggestions(matches);
  }

  void completeSuggestion(String command) {
    final serverUrl = context.read<ServerUrl>();
    analytics.get(serverUrl)?.trackCommand('complete_suggestion', '/$command ');

    String completedDraft = '/$command ';
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      completedDraft = '//$command ';
    }

    widget.updateValue(completedDraft);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      Future.delayed(Duration(milliseconds: 100), () {
        widget.updateValue(completedDraft.replaceFirst('//', '/'));
      });
    }
  }

  Widget renderItem(AutocompleteSuggestion item) {
    return SlashSuggestionItem(
      description: item.description,
      hint: item.hint,
      onPress: () => completeSuggestion(item.complete),
      suggestion: item.suggestion,
      complete: item.complete,
      icon: item.iconData,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Container();
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: dataSource.length,
      itemBuilder: (context, index) {
        return renderItem(dataSource[index]);
      },
    );
  }
}
