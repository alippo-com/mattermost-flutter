import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class Channel {
  final String name;
  final String displayName;
  final String? purpose;
  final bool shared;
  final int deleteAt;

  Channel({
    required this.name,
    required this.displayName,
    this.purpose,
    required this.shared,
    required this.deleteAt,
  });
}

class ChannelListRowProps {
  final Channel channel;
  final Function(Channel) onPress;
  final String? testID;
  final bool selectable;
  final bool selected;

  ChannelListRowProps({
    required this.channel,
    required this.onPress,
    this.testID,
    this.selectable = false,
    this.selected = false,
  });
}

class ChannelListRow extends StatelessWidget {
  final ChannelListRowProps props;

  const ChannelListRow({required this.props});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = getStyleFromTheme(theme);

    void handlePress() {
      props.onPress(props.channel);
    }

    Widget? selectionIcon;
    if (props.selectable) {
      selectionIcon = Icon(
        props.selected ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 28,
        color: props.selected ? theme.buttonColor : theme.iconTheme.color,
      );
    }

    Widget? purposeComponent;
    if (props.channel.purpose != null) {
      purposeComponent = Text(
        props.channel.purpose!,
        style: style['purpose'],
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    final itemTestID = '${props.testID}.${props.channel.name}';
    final channelDisplayNameTestID = '${itemTestID}.display_name';

    String icon = 'globe';
    if (props.channel.deleteAt > 0) {
      icon = 'archive';
    } else if (props.channel.shared) {
      icon = 'group';
    }

    return GestureDetector(
      onTap: handlePress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            CompassIcon(
              icon: icon,
              size: 20,
              style: style['icon'],
            ),
            Container(
              margin: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    props.channel.displayName,
                    style: style['displayName'],
                    key: Key(channelDisplayNameTestID),
                  ),
                  if (purposeComponent != null) purposeComponent,
                ],
              ),
            ),
            if (selectionIcon != null) selectionIcon,
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleFromTheme(ThemeData theme) {
    return {
    'displayName': TextStyle(
    color: theme.textTheme.bodyText1!.color,
    ...typography('Body', 200),
    ),
    'icon': TextStyle(
    padding: EdgeInsets.all(2),
    color: theme.iconTheme.color!.withOpacity(0.56),
    ),
    'purpose': TextStyle(
    color: theme.textTheme.bodyText1!.color!.withOpacity(0.64),
    ...typography('Body', 75),
    ),
    };
    }
}