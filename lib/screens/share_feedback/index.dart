
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/illustrations/share_feedback.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/back_navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/nps.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

class ShareFeedback extends HookWidget {
  final String componentId;

  ShareFeedback({required this.componentId});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final serverUrl = useServerUrl();

    final show = useState(true);
    final executeAfterDone = useRef<Function>(() => dismissOverlay(componentId));

    void close(Function afterDone) {
      executeAfterDone.current = afterDone;
      show.value = false;
    }

    Future<void> onPressYes() async {
      close(() async {
        await dismissOverlay(componentId);
        await goToNPSChannel(serverUrl);
        giveFeedbackAction(serverUrl);
      });
    }

    void onPressNo() {
      close(() => dismissOverlay(componentId));
    }

    useBackNavigation(onPressNo);
    useAndroidHardwareBackHandler(componentId, onPressNo);

    void doAfterAnimation() {
      executeAfterDone.current();
    }

    return Scaffold(
      backgroundColor: changeOpacity(Colors.black, 0.50),
      body: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * 0.95,
          child: show.value
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onPressNo,
                      child: CompassIcon(
                        name: 'close',
                        size: 24,
                        color: changeOpacity(theme.centerChannelColor, 0.56),
                      ),
                    ),
                    ShareFeedbackIllustration(theme: theme),
                    Text(
                      intl.formatMessage(
                        id: 'share_feedback.title',
                        defaultMessage: 'Would you share your feedback?',
                      ),
                      style: typography('Heading', 600, 'SemiBold').copyWith(
                        color: theme.centerChannelColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      intl.formatMessage(
                        id: 'share_feedback.subtitle',
                        defaultMessage: 'We'd love to hear how we can make your experience better.',
                      ),
                      style: typography('Body', 200, 'Regular').copyWith(
                        color: changeOpacity(theme.centerChannelColor, 0.72),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Button(
                          theme: theme,
                          size: 'lg',
                          emphasis: 'tertiary',
                          onPress: onPressNo,
                          text: intl.formatMessage(
                            id: 'share_feedback.button.no',
                            defaultMessage: 'No, thanks',
                          ),
                          backgroundStyle: styles.leftButton,
                        ),
                        Button(
                          theme: theme,
                          size: 'lg',
                          onPress: onPressYes,
                          text: intl.formatMessage(
                            id: 'share_feedback.button.yes',
                            defaultMessage: 'Yes',
                          ),
                          backgroundStyle: styles.rightButton,
                        ),
                      ],
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'leftButton': TextStyle(
        marginRight: 5,
      ),
      'rightButton': TextStyle(
        marginLeft: 5,
      ),
    };
  }
}
