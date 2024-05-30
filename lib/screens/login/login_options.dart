import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_aware_scroll_view/flutter_keyboard_aware_scroll_view.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/background.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'login_options_separator.dart';
import 'sso_options.dart';
import 'package:mattermost_flutter/types.dart';

class LoginOptions extends HookWidget {
  final String? closeButtonId;
  final String componentId;
  final ClientConfig config;
  final bool hasLoginForm;
  final ClientLicense license;
  final String serverDisplayName;
  final String serverUrl;
  final SsoWithOptions ssoOptions;
  final Theme theme;

  LoginOptions({
    this.closeButtonId,
    required this.componentId,
    required this.config,
    required this.hasLoginForm,
    required this.license,
    required this.serverDisplayName,
    required this.serverUrl,
    required this.ssoOptions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final styles = useMemoized(() => getStyles(theme), [theme]);
    final keyboardAwareRef = useRef<KeyboardAwareScrollViewState>(null);
    final dimensions = MediaQuery.of(context).size;
    final defaultHeaderHeight = useDefaultHeaderHeight();
    final isTablet = useIsTablet();
    final translateX = useAnimationController(duration: Duration(milliseconds: 350), lowerBound: -dimensions.width, upperBound: dimensions.width);
    final contentFillScreen = useState(false);
    final numberSSOs = useMemo(() => ssoOptions.values.where((v) => v.enabled).length, [ssoOptions]);
    final description = useMemo(() {
      if (hasLoginForm) {
        return FormattedText(
          style: styles.subheader,
          id: 'mobile.login_options.enter_credentials',
          testID: 'login_options.description.enter_credentials',
          defaultMessage: 'Enter your login details below.',
        );
      } else if (numberSSOs) {
        return FormattedText(
          style: styles.subheader,
          id: 'mobile.login_options.select_option',
          testID: 'login_options.description.select_option',
          defaultMessage: 'Select a login option below.',
        );
      }

      return FormattedText(
        style: styles.subheader,
        id: 'mobile.login_options.none',
        testID: 'login_options.description.none',
        defaultMessage: "You can't log in to your account yet. At least one login option must be configured. Contact your System Admin for assistance.",
      );
    }, [hasLoginForm, numberSSOs, theme]);

    void goToSso(String ssoType) {
      goToScreen(Screens.SSO, '', {
        'config': config,
        'extra': extra,
        'launchError': launchError,
        'launchType': launchType,
        'license': license,
        'theme': theme,
        'ssoType': ssoType,
        'serverDisplayName': serverDisplayName,
        'serverUrl': serverUrl,
      }, loginAnimationOptions());
    }

    final optionsSeparator = hasLoginForm && numberSSOs > 0 ? LoginOptionsSeparator(theme: theme) : null;

    useEffect(() {
      translateX.forward(from: 0);
    }, []);

    void dismiss() {
      dismissModal(componentId);
    }

    void pop() {
      popTopScreen(componentId);
    }

    void onLayout(LayoutChangeEvent e) {
      final height = e.size.height;
      contentFillScreen.value = dimensions.height < height + defaultHeaderHeight;
    }

    useEffect(() {
      translateX.forward(from: 0);
    }, []);

    useEffect(() {
      final listener = {
        componentDidAppear: () => translateX.forward(from: 0),
        componentDidDisappear: () => translateX.reverse(from: dimensions.width),
      };
      final unsubscribe = Navigation.events().registerComponentListener(listener, Screens.LOGIN);

      return unsubscribe.remove;
    }, [dimensions]);

    useNavButtonPressed(closeButtonId ?? '', componentId, dismiss, []);
    useAndroidHardwareBackHandler(componentId, pop);

    var additionalContainerStyle;
    if (!contentFillScreen.value && (numberSSOs < 3 || !hasLoginForm || (isTablet && dimensions.height > dimensions.width))) {
      additionalContainerStyle = styles.flex;
    }

    var title;
    if (hasLoginForm || numberSSOs > 0) {
      title = FormattedText(
        defaultMessage: 'Log In to Your Account',
        id: 'mobile.login_options.heading',
        testID: 'login_options.title.login_to_account',
        style: styles.header,
      );
    } else {
      title = FormattedText(
        defaultMessage: "Can't Log In",
        id: 'mobile.login_options.cant_heading',
        testID: 'login_options.title.cant_login',
        style: styles.header,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Background(theme: theme),
          AnimatedBuilder(
            animation: translateX,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(translateX.value, 0),
                child: child,
              );
            },
            child: SafeArea(
              child: KeyboardAwareScrollView(
                ref: keyboardAwareRef,
                contentContainerStyle: [styles.innerContainer, additionalContainerStyle],
                onLayout: onLayout,
                child: Column(
                  children: [
                    title,
                    description,
                    if (hasLoginForm)
                      Form(
                        config: config,
                        extra: extra,
                        launchError: launchError,
                        launchType: launchType,
                        theme: theme,
                        serverDisplayName: serverDisplayName,
                        serverUrl: serverUrl,
                      ),
                    if (optionsSeparator != null) optionsSeparator,
                    if (numberSSOs > 0)
                      SsoOptions(
                        goToSso: goToSso,
                        ssoOnly: !hasLoginForm,
                        ssoOptions: ssoOptions,
                        theme: theme,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyles(Theme theme) {
    return {
      'centered': {
        'width': '100%',
        'maxWidth': 600,
      },
      'container': {
        'flex': 1,
        if (Platform.isAndroid) 'marginTop': 56,
      },
      'flex': {
        'flex': 1,
      },
      'header': {
        'color': theme.centerChannelColor,
        'marginBottom': 12,
        ...typography('Heading', 1000, 'SemiBold'),
      },
      'innerContainer': {
        'alignItems': 'center',
        'justifyContent': 'center',
        'paddingHorizontal': 24,
      },
      'subheader': {
        'color': changeOpacity(theme.centerChannelColor, 0.6),
        'marginBottom': 12,
        ...typography('Body', 200, 'Regular'),
      },
    };
  }
}
