
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/i18n.dart';

class AppVersion extends HookWidget {
  final bool isWrapped;
  final TextStyle? textStyle;

  AppVersion({this.isWrapped = true, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final opacity = useAnimationController(duration: Duration(milliseconds: 250), lowerBound: 0, upperBound: 1);
    final deviceInfo = DeviceInfoPlugin();
    final version = useFuture(deviceInfo.androidInfo.then((info) => info.version.release));
    final buildNumber = useFuture(deviceInfo.androidInfo.then((info) => info.version.sdkInt));

    useEffect(() {
      final willHide = KeyboardVisibilityController().onChange.listen((isVisible) {
        if (isVisible) {
          opacity.reverse();
        } else {
          opacity.forward();
        }
      });

      return willHide.cancel;
    }, []);

    final appVersion = FormattedText(
      id: t('mobile.about.appVersion'),
      defaultMessage: 'App Version: {version} (Build {number})',
      style: textStyle ?? TextStyle(fontSize: 12),
      values: {'version': version.data ?? 'Unknown', 'number': buildNumber.data?.toString() ?? 'Unknown'},
    );

    if (!isWrapped) {
      return appVersion;
    }

    return AnimatedOpacity(
      opacity: opacity,
      duration: Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20, bottom: 12),
          child: appVersion,
        ),
      ),
    );
  }
}
