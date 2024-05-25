
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/custom_list_row.dart';

class ChannelListRow extends StatelessWidget {
  final String id;
  final Theme theme;
  final Channel channel;
  final void Function(Channel) onPress;
  final bool enabled;
  final bool selectable;
  final bool selected;
  final String testID;

  ChannelListRow({
    required this.id,
    required this.theme,
    required this.channel,
    required this.onPress,
    required this.enabled,
    required this.selectable,
    required this.selected,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleFromTheme(theme);

    void onPressRow() {
      onPress(channel);
    }

    Widget renderPurpose(String channelPurpose) {
      if (channelPurpose.isEmpty) {
        return Container();
      }
      return Text(
        channelPurpose,
        style: style.purpose,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    final itemTestID = '$testID.$id';
    final channelDisplayNameTestID = '$testID.display_name';
    final channelIcon = _getIconForChannel(channel);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomListRow(
        id: id,
        onPress: onPressRow,
        enabled: enabled,
        selectable: selectable,
        selected: selected,
        testID: testID,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CompassIcon(
                    name: channelIcon,
                    style: style.icon,
                  ),
                  SizedBox(width: 5),
                  Text(
                    channel.displayName,
                    style: style.displayName,
                    key: Key(channelDisplayNameTestID),
                  ),
                ],
              ),
              renderPurpose(channel.purpose),
            ],
          ),
        ),
      ),
    );
  }

  String _getIconForChannel(Channel selectedChannel) {
    String icon = 'globe';

    if (selectedChannel.type == 'P') {
      icon = 'padlock';
    }

    if (selectedChannel.deleteAt != null) {
      icon = 'archive-outline';
    } else if (selectedChannel.shared) {
      icon = 'circle-multiple-outline';
    }

    return icon;
  }

  _StyleSheet _getStyleFromTheme(Theme theme) {
    return _StyleSheet(
      titleContainer: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.2),
      ),
      displayName: TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200, FontWeight.w400),
      ),
      icon: TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200, FontWeight.w400),
      ),
      container: BoxDecoration(
        color: theme.centerChannelBg,
      ),
      outerContainer: BoxDecoration(
        color: theme.centerChannelBg,
      ),
      purpose: TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.5),
        ...typography('Body', 100, FontWeight.w400),
      ),
    );
  }
}

class _StyleSheet {
  final BoxDecoration titleContainer;
  final TextStyle displayName;
  final TextStyle icon;
  final BoxDecoration container;
  final BoxDecoration outerContainer;
  final TextStyle purpose;

  _StyleSheet({
    required this.titleContainer,
    required this.displayName,
    required this.icon,
    required this.container,
    required this.outerContainer,
    required this.purpose,
  });
}
