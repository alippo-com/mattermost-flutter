import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/theme.dart'; // Assuming this is where the useTheme directive is imported from
import 'package:mattermost_flutter/hooks/device.dart'; // Assuming this is where the useIsTablet directive is imported from
import 'package:mattermost_flutter/utils/theme.dart'; // Assuming this is where the makeStyleSheetFromTheme directive is imported from

class ImageFileOverlay extends StatelessWidget {
  final int value;

  const ImageFileOverlay({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final dimensions = MediaQuery.of(context).size;
    final style = getStyleSheet(theme);
    final textStyles = useMemo(() {
      final scale = isTablet ? MediaQuery.of(context).devicePixelRatio : 1.0;
      return [
        style['moreImagesText'],
        TextStyle(fontSize: (24 * scale).roundToDouble()),
      ];
    });

    return Container(
      decoration: style['moreImagesWrapper'],
      child: Center(
        child: Text(
          '+$value',
          style: textStyles,
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(theme) {
    return {
      'moreImagesWrapper': BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(5.0),
      ),
      'moreImagesText': TextStyle(
        color: theme.sidebarHeaderTextColor,
        fontFamily: 'OpenSans',
        textAlign: TextAlign.center,
      ),
    };
  }

  List<dynamic> useMemo(Function func) {
    return func();
  }
}
