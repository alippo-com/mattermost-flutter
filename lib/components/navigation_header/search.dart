
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming typography is defined here

class NavigationSearch extends StatefulWidget {
  final AnimatedStyleProp? topStyle;
  final VoidCallback? hideHeader;
  final SearchProps searchProps;
  final Theme theme;

  const NavigationSearch({
    Key? key,
    this.topStyle,
    this.hideHeader,
    required this.searchProps,
    required this.theme,
  }) : super(key: key);

  @override
  _NavigationSearchState createState() => _NavigationSearchState();
}

class _NavigationSearchState extends State<NavigationSearch> {
  late Map<String, TextStyle> cancelButtonProps;

  @override
  void initState() {
    super.initState();
    cancelButtonProps = {
      'buttonTextStyle': TextStyle(
        color: changeOpacity(widget.theme.sidebarText, 0.72),
        ...typography('Body', 100, 'Regular'),
      ),
      'color': widget.theme.sidebarText,
    };

    _addKeyboardListeners();
  }

  @override
  void dispose() {
    _removeKeyboardListeners();
    super.dispose();
  }

  void _addKeyboardListeners() {
    if (Platform.isAndroid) {
      SystemChannels.textInput.invokeMethod('TextInput.show');
      // Add any necessary listeners for Android
    }
  }

  void _removeKeyboardListeners() {
    if (Platform.isAndroid) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      // Remove any necessary listeners for Android
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(widget.theme);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      style: [styles['container'], widget.topStyle],
      child: Search(
        searchProps: widget.searchProps,
        cancelButtonProps: cancelButtonProps,
        clearIconColor: widget.theme.sidebarText,
        inputContainerStyle: styles['inputContainerStyle'],
        inputStyle: styles['inputStyle'],
        onFocus: _handleFocus,
        placeholderTextColor: changeOpacity(widget.theme.sidebarText, Platform.isAndroid ? 0.56 : 0.72),
        searchIconColor: widget.theme.sidebarText,
        selectionColor: widget.theme.sidebarText,
        testID: 'navigation.header.search_bar',
      ),
    );
  }

  void _handleFocus() {
    widget.hideHeader?.call();
    widget.searchProps.onFocus?.call();
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        backgroundColor: theme.sidebarBg,
        paddingHorizontal: 20,
        width: double.infinity,
        zIndex: 10,
      ),
      'inputContainerStyle': TextStyle(
        backgroundColor: changeOpacity(theme.sidebarText, 0.12),
      ),
      'inputStyle': TextStyle(
        color: theme.sidebarText,
      ),
    };
  }
}
