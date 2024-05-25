
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/markdown/latex.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class LatexScreen extends StatelessWidget {
  final AvailableScreens componentId;
  final String content;

  LatexScreen({
    required this.componentId,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final lines = splitLatexCodeInLines(content);

    void close() {
      popTopScreen(componentId);
    }

    // Handle Android back button press
    SystemChannels.platform.setMethodCallHandler((call) {
      if (call.method == 'SystemNavigator.pop') {
        close();
      }
      return Future.value();
    });

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          close();
          return false;
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: lines.map((latexCode) {
                      return Container(
                        padding: style['code'],
                        child: Math.tex(
                          latexCode,
                          onErrorFallback: (error) {
                            return Text(
                              'Render error: ${error.message}',
                              style: style['errorText'],
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'scrollContainer': BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      'container': BoxDecoration(
        minHeight: MediaQuery.of(context).size.height,
      ),
      'mathStyle': TextStyle(
        color: theme.textTheme.bodyText1.color,
      ),
      'scrollCode': BoxDecoration(
        minHeight: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
      ),
      'code': EdgeInsets.symmetric(vertical: Platform.isIOS ? 4 : 0, horizontal: 5),
      'errorText': theme.textTheme.bodyText1.copyWith(
        color: theme.errorColor,
        margin: EdgeInsets.symmetric(horizontal: 5),
      ),
    };
  }
}
