import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mattermost_flutter/types/state.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/components/tag.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const PROFILE_SIZE = 32.0;

class Participant extends StatelessWidget {
  final CallSession sess;
  final String teammateNameDisplay;
  final VoidCallback onPress;

  Participant({
    required this.sess,
    required this.teammateNameDisplay,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = _getStyleSheet(theme);
    final intl = AppLocalizations.of(context)!;
    final currentCall = useCurrentCall();

    if (currentCall == null) {
      return Container();
    }

    return GestureDetector(
      key: ValueKey(sess.sessionId),
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            sess.userModel != null
                ? ProfilePicture(
              author: sess.userModel!,
              size: PROFILE_SIZE,
              showStatus: false,
              url: currentCall.serverUrl,
            )
                : CompassIcon(
              name: 'account-outline',
              size: PROFILE_SIZE,
              style: styles['profileIcon'],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayUsername(sess.userModel, intl.locale, teammateNameDisplay),
                    style: styles['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sess.sessionId == currentCall.mySessionId)
                    Text(
                      intl.translate('mobile.calls_you', 'defaultMessage': '(you)'),
                      style: styles['you'],
                    ),
                  if (sess.userId == currentCall.hostId)
                    Tag(
                      id: 'mobile.calls_host',
                      defaultMessage: 'host',
                      style: styles['hostTag'],
                    ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Row(
              children: [
                if (sess.reaction?.emoji != null)
                  Emoji(
                    emojiName: sess.reaction!.emoji.name,
                    literal: sess.reaction!.emoji.literal,
                    size: 24 - Platform.isIOS ? 3 : 4,
                  ),
                if (sess.raisedHand != 0)
                  CompassIcon(
                    name: 'hand-right',
                    size: 24,
                    style: styles['raiseHandIcon'],
                  ),
                if (sess.sessionId == currentCall.screenOn)
                  CompassIcon(
                    name: 'monitor',
                    size: 24,
                    style: styles['screenSharingIcon'],
                  ),
                CompassIcon(
                  name: sess.muted ? 'microphone-off' : 'microphone',
                  size: 24,
                  style: sess.muted ? styles['muteIcon'] : styles['unmutedIcon'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'rowContainer': TextStyle(
        flexDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8),
        gap: 16,
        alignItems: CrossAxisAlignment.center,
      ),
      'row': TextStyle(
        flexDirection: Axis.horizontal,
        flex: 1,
        gap: 8,
      ),
      'picture': TextStyle(
        borderRadius: PROFILE_SIZE / 2,
        height: PROFILE_SIZE,
        width: PROFILE_SIZE,
      ),
      'name': typography('Body', 200).copyWith(
        color: theme.centerChannelColor,
        flex: 1,
      ),
      'you': typography('Body', 200).copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.56),
      ),
      'profileIcon': TextStyle(
        color: changeOpacity(theme.buttonColor, 0.56),
      ),
      'icons': TextStyle(
        flexDirection: Axis.horizontal,
        gap: 16,
      ),
      'muteIcon': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.40),
      ),
      'unmutedIcon': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
      ),
      'hostTag': TextStyle(
        padding: const EdgeInsets.symmetric(vertical: 4),
      ),
      'raiseHandIcon': TextStyle(
        color: theme.awayIndicator,
      ),
      'screenSharingIcon': TextStyle(
        color: theme.dndIndicator,
      ),
    };
  }
}
