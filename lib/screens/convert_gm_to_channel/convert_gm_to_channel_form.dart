import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/constants/server_errors.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/user.dart';

import 'channel_name_input.dart';
import 'message_box/message_box.dart';
import 'team_selector.dart';
import 'no_common_teams_form.dart';

class ConvertGMToChannelForm extends StatefulWidget {
  final String channelId;
  final List<Team> commonTeams;
  final List<UserProfile> profiles;
  final String? locale;
  final String? teammateNameDisplay;

  ConvertGMToChannelForm({
    required this.channelId,
    required this.commonTeams,
    required this.profiles,
    this.locale,
    this.teammateNameDisplay,
  });

  @override
  _ConvertGMToChannelFormState createState() => _ConvertGMToChannelFormState();
}

class _ConvertGMToChannelFormState extends State<ConvertGMToChannelForm> {
  late final ThemeData theme;
  late final String serverUrl;
  late final TextStyle errorMessageStyle;
  late final TextStyle buttonTextStyle;
  Team? selectedTeam;
  String newChannelName = '';
  String errorMessage = '';
  String channelNameErrorMessage = '';
  bool conversionInProgress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = context.read<ThemeContext>().theme;
    serverUrl = context.read<ServerContext>().serverUrl;
    errorMessageStyle = TextStyle(color: theme.dndIndicator);
    buttonTextStyle = TextStyle(color: theme.centerChannelColor);
    selectedTeam = widget.commonTeams[0];
  }

  void _setSelectedTeam(Team team) {
    setState(() {
      selectedTeam = team;
    });
  }

  void _setNewChannelName(String name) {
    setState(() {
      newChannelName = name;
    });
  }

  void _setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void _setChannelNameErrorMessage(String message) {
    setState(() {
      channelNameErrorMessage = message;
    });
  }

  Future<void> _convertGroupMessageToPrivateChannel() async {
    setState(() {
      conversionInProgress = true;
    });

    final result = await convertGroupMessageToPrivateChannel(serverUrl, widget.channelId, selectedTeam!.id, newChannelName);
    if (result.error != null) {
      if (isServerError(result.error) && result.error.serverErrorId == ServerErrors.DUPLICATE_CHANNEL_NAME && isErrorWithMessage(result.error)) {
        _setChannelNameErrorMessage(result.error.message);
      } else if (isErrorWithMessage(result.error)) {
        _setErrorMessage(result.error.message);
      } else {
        _setErrorMessage('Something went wrong. Failed to convert Group Message to Private Channel.');
      }

      setState(() {
        conversionInProgress = false;
      });
      return;
    }

    if (result.updatedChannel == null) {
      logError('No updated channel received from server when converting GM to private channel');
      _setErrorMessage('Something went wrong. Failed to convert Group Message to Private Channel.');
      setState(() {
        conversionInProgress = false;
      });
      return;
    }

    _setErrorMessage('');
    switchToChannelById(serverUrl, result.updatedChannel!.id, selectedTeam!.id);
    setState(() {
      conversionInProgress = false;
    });
  }

  void _onPress() {
    if (conversionInProgress || selectedTeam == null || newChannelName.trim().isEmpty) {
      return;
    }
    _convertGroupMessageToPrivateChannel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.commonTeams.isEmpty) {
      return NoCommonTeamForm(
        containerStyles: BoxDecoration(
          color: theme.backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        ),
      );
    }

    final messageBoxHeader = 'Conversation history will be visible to any channel members';
    final textConvert = 'Convert to Private Channel';
    final textConverting = 'Converting...';
    final confirmButtonText = conversionInProgress ? textConverting : textConvert;
    final userDisplayNames = widget.profiles.map((profile) => displayUsername(profile, widget.locale, widget.teammateNameDisplay)).toList();
    final memberNames = userDisplayNames.join(', ') ?? 'yourself';
    final messageBoxBody = 'You are about to convert the Group Message with $memberNames to a Channel. This cannot be undone.';
    final buttonIcon = conversionInProgress ? Loading(containerStyle: TextStyle(marginRight: 10, padding: 0, top: -2), color: changeOpacity(theme.centerChannelColor, 0.32)) : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            MessageBox(
              header: messageBoxHeader,
              body: messageBoxBody,
            ),
            if (widget.commonTeams.length > 1)
              TeamSelector(
                commonTeams: widget.commonTeams,
                onSelectTeam: _setSelectedTeam,
                selectedTeamId: selectedTeam?.id,
              ),
            ChannelNameInput(
              onChange: _setNewChannelName,
              error: channelNameErrorMessage,
            ),
            Button(
              onPress: _onPress,
              text: confirmButtonText,
              theme: theme,
              buttonType: !conversionInProgress && selectedTeam != null && newChannelName.trim().isNotEmpty ? 'destructive' : 'disabled',
              size: 'lg',
              iconComponent: buttonIcon,
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: errorMessageStyle,
              ),
          ],
        ),
      ),
    );
  }
}
