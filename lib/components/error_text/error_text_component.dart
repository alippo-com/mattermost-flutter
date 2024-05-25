
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:intl/intl.dart';

class ErrorTextComponent extends StatelessWidget {
  final dynamic error;
  final String? testID;
  final TextStyle? textStyle;

  ErrorTextComponent({
    required this.error,
    this.testID,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final message = getErrorMessage(error, context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Text(
        message,
        key: Key(testID ?? ''),
        style: textStyle != null ? style.errorLabel.merge(textStyle) : style.errorLabel,
      ),
    );
  }

  _ErrorTextStyle getStyleSheet(ThemeData theme) {
    return _ErrorTextStyle(
      errorLabel: TextStyle(
        color: theme.errorColor ?? Color(0xFFDA4A4A),
        fontSize: 12,
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _ErrorTextStyle {
  final TextStyle errorLabel;

  _ErrorTextStyle({required this.errorLabel});
}
