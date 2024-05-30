
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class SsoOptions extends StatelessWidget {
  final Function(String) goToSso;
  final bool ssoOnly;
  final Map<String, SsoWithOptions> ssoOptions;
  final Theme theme;

  SsoOptions({required this.goToSso, required this.ssoOnly, required this.ssoOptions, required this.theme});

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(theme);
    final styleButtonBackground = buttonBackgroundStyle(theme, 'lg', 'primary');

    SsoInfo getSsoButtonOptions(String ssoType) {
      final sso = SsoInfo();
      final options = ssoOptions[ssoType];
      switch (ssoType) {
        case Sso.SAML:
          sso.text = options.text ?? Intl.message('SAML', name: 'mobile.login_options.saml');
          sso.compassIcon = 'lock';
          break;
        case Sso.GITLAB:
          sso.text = Intl.message('GitLab', name: 'mobile.login_options.gitlab');
          sso.imageSrc = 'assets/images/Icon_Gitlab.png';
          break;
        case Sso.GOOGLE:
          sso.text = Intl.message('Google', name: 'mobile.login_options.google');
          sso.imageSrc = 'assets/images/Icon_Google.png';
          break;
        case Sso.OFFICE365:
          sso.text = Intl.message('Office 365', name: 'mobile.login_options.office365');
          sso.imageSrc = 'assets/images/Icon_Office.png';
          break;
        case Sso.OPENID:
          sso.text = options.text ?? Intl.message('Open ID', name: 'mobile.login_options.openid');
          sso.imageSrc = 'assets/images/Icon_Openid.png';
          break;
        default:
      }
      return sso;
    }

    final enabledSSOs = ssoOptions.keys.where((ssoType) => ssoOptions[ssoType]!.enabled).toList();

    Container styleViewContainer;
    Container styleButtonContainer;
    if (enabledSSOs.length == 2 && !ssoOnly) {
      styleViewContainer = styles['containerAsRow'];
      styleButtonContainer = styles['buttonContainer'];
    }

    List<Widget> componentArray = [];
    for (final ssoType in enabledSSOs) {
      final sso = getSsoButtonOptions(ssoType);
      final handlePress = () => goToSso(ssoType);

      componentArray.add(
        GestureDetector(
          key: Key(ssoType),
          onTap: handlePress,
          child: Container(
            decoration: BoxDecoration(
              color: theme.centerChannelBg,
              border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.16)),
            ),
            child: Row(
              children: [
                if (sso.imageSrc != null)
                  Image.asset(sso.imageSrc, width: 18, height: 18),
                if (sso.compassIcon != null)
                  CompassIcon(
                    name: sso.compassIcon,
                    size: 16,
                    color: theme.centerChannelColor,
                  ),
                Container(
                  padding: EdgeInsets.only(left: 9),
                  child: Text(
                    sso.text,
                    style: TextStyle(
                      color: theme.centerChannelColor,
                      fontFamily: 'OpenSans-SemiBold',
                      fontSize: 16,
                      height: 1.125,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: componentArray,
    );
  }

  Map<String, Container> _getStyleSheet(Theme theme) {
    return {
      'container': Container(margin: EdgeInsets.symmetric(vertical: 24)),
      'containerAsRow': Container(
        child: Row(
          children: componentArray,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      'buttonContainer': Container(
        width: '48%',
        margin: EdgeInsets.only(right: 8),
      ),
      'button': Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.16)),
        ),
      ),
      'buttonTextContainer': Container(
        color: theme.centerChannelColor,
        padding: EdgeInsets.only(left: 9),
        child: Row(
          children: componentArray,
        ),
      ),
      'buttonText': Container(
        color: theme.centerChannelColor,
        padding: EdgeInsets.only(left: 9),
        child: Text(
          '',
          style: TextStyle(
            color: theme.centerChannelColor,
            fontFamily: 'OpenSans-SemiBold',
            fontSize: 16,
            height: 1.125,
          ),
        ),
      ),
      'logoStyle': Container(
        width: 18,
        height: 18,
        margin: EdgeInsets.only(right: 5),
      ),
    };
  }
}
