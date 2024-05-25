import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/draft.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/managers/draft_upload_manager.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class UploadRemove extends StatefulWidget {
  final String channelId;
  final String rootId;
  final String clientId;

  UploadRemove({
    required this.channelId,
    required this.rootId,
    required this.clientId,
  });

  @override
  _UploadRemoveState createState() => _UploadRemoveState();
}

class _UploadRemoveState extends State<UploadRemove> {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final serverUrl = useServerUrl(context);

    void onPress() {
      DraftUploadManager.cancel(widget.clientId);
      removeDraftFile(serverUrl, widget.channelId, widget.rootId, widget.clientId);
    }

    return TouchableWithFeedback(
      style: style['tappableContainer'],
      onPress: onPress,
      type: 'opacity',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.centerChannelBg,
        ),
        margin: EdgeInsets.only(
          top: Platform.isIOS ? 5.4 : 4.75,
        ),
        width: 24,
        height: 25,
        child: Center(
          child: CompassIcon(
            name: 'close-circle',
            color: changeOpacity(theme.centerChannelColor, 0.64),
            size: 24,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'tappableContainer': {
        'position': 'absolute',
        'elevation': 11,
        'top': -7,
        'right': -8,
        'width': 24,
        'height': 24,
      },
      'removeButton': {
        'borderRadius': 12,
        'alignSelf': 'center',
        'marginTop': Platform.isIOS ? 5.4 : 4.75,
        'backgroundColor': theme.centerChannelBg,
        'width': 24,
        'height': 25,
      },
    };
  }
}
