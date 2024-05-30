import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/utils/draft.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/change_opacity.dart';

import 'channel_dropdown.dart';
import 'channel_list.dart';

class BrowseChannels extends HookWidget {
  final String componentId;
  final ImageResource closeButton;
  final String currentTeamId;
  final bool canCreateChannels;
  final bool sharedChannelsEnabled;
  final bool canShowArchivedChannels;
  final String typeOfChannels;
  final Function(String) changeChannelType;
  final String term;
  final Function(String) searchChannels;
  final Function stopSearch;
  final bool loading;
  final Function onEndReached;
  final List<Channel> channels;

  const BrowseChannels({
    Key? key,
    required this.componentId,
    required this.closeButton,
    required this.currentTeamId,
    required this.canCreateChannels,
    required this.sharedChannelsEnabled,
    required this.canShowArchivedChannels,
    required this.typeOfChannels,
    required this.changeChannelType,
    required this.term,
    required this.searchChannels,
    required this.stopSearch,
    required this.loading,
    required this.onEndReached,
    required this.channels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final serverUrl = useServerUrl();
    final adding = useState(false);

    void setHeaderButtons(bool createEnabled) {
      final buttons = NavButtons(
        leftButtons: [makeLeftButton(closeButton)],
        rightButtons: [],
      );

      if (canCreateChannels) {
        buttons.rightButtons = [makeRightButton(theme, intl.formatMessage, createEnabled)];
      }

      setButtons(componentId, buttons);
    }

    Future<void> onSelectChannel(Channel channel) async {
      setHeaderButtons(false);
      adding.value = true;

      final result = await joinChannel(serverUrl, currentTeamId, channel.id, '', false);

      if (result.error) {
        alertErrorWithFallback(
          intl,
          result.error,
          {
            'id': 'mobile.join_channel.error',
            'defaultMessage': "We couldn't join the channel {displayName}.",
          },
          {
            'displayName': channel.displayName,
          },
        );
        setHeaderButtons(true);
        adding.value = false;
      } else {
        switchToChannelById(serverUrl, channel.id, currentTeamId);
        close();
      }
    }

    void onSearch() {
      searchChannels(term);
    }

    void handleCreate() {
      final screen = Screens.CREATE_OR_EDIT_CHANNEL;
      final title = intl.formatMessage({'id': 'mobile.create_channel.title', 'defaultMessage': 'New channel'});
      goToScreen(screen, title);
    }

    useNavButtonPressed(CLOSE_BUTTON_ID, componentId, close, [close]);
    useNavButtonPressed(CREATE_BUTTON_ID, componentId, handleCreate, [handleCreate]);
    useAndroidHardwareBackHandler(componentId, close);

    useEffect(() {
      setHeaderButtons(!adding.value);
    }, [theme, canCreateChannels, adding.value]);

    Widget content;
    if (adding.value) {
      content = Loading(
        containerStyle: style.loadingContainer,
        size: 'large',
        color: theme.buttonBg,
      );
    } else {
      Widget? channelDropdown;
      if (canShowArchivedChannels || sharedChannelsEnabled) {
        channelDropdown = ChannelDropdown(
          onPress: changeChannelType,
          typeOfChannels: typeOfChannels,
          canShowArchivedChannels: canShowArchivedChannels,
          sharedChannelsEnabled: sharedChannelsEnabled,
        );
      }

      content = Column(
        children: [
          Container(
            key: ValueKey('browse_channels.screen'),
            margin: EdgeInsets.only(
              left: 12,
              right: Platform.isIOS ? 4 : 12,
              top: 12,
            ),
            child: Search(
              key: ValueKey('browse_channels.search_bar'),
              placeholder: intl.formatMessage({'id': 'search_bar.search', 'defaultMessage': 'Search'}),
              cancelButtonTitle: intl.formatMessage({'id': 'mobile.post.cancel', 'defaultMessage': 'Cancel'}),
              placeholderTextColor: changeOpacity(theme.centerChannelColor, 0.5),
              onChangeText: searchChannels,
              onSubmitEditing: onSearch,
              onCancel: stopSearch,
              autoCapitalize: TextCapitalization.none,
              keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
              value: term,
            ),
          ),
          if (channelDropdown != null) channelDropdown,
          ChannelList(
            channels: channels,
            onEndReached: onEndReached,
            loading: loading,
            onSelectChannel: onSelectChannel,
            term: term,
          ),
        ],
      );
    }

    return SafeArea(
      child: Scaffold(
        body: content,
      ),
    );
  }
}