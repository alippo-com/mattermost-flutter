// Converted from React Native to Flutter

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/search_bar.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'filtered_list.dart';
import 'quick_options.dart';
import 'unfiltered_list.dart';

class FindChannels extends StatefulWidget {
  final String closeButtonId;
  final AvailableScreens componentId;

  FindChannels({required this.closeButtonId, required this.componentId});

  @override
  _FindChannelsState createState() => _FindChannelsState();
}

class _FindChannelsState extends State<FindChannels> {
  late ThemeData theme;
  String term = '';
  bool loading = false;
  late Color color;
  late double containerHeight;
  late bool overlap;
  final listView = GlobalKey();

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    color = changeOpacity(theme.centerChannelColor, 0.72);
    overlap = useKeyboardOverlap(listView, containerHeight);
    useNavButtonPressed(widget.closeButtonId, widget.componentId, close);
    useAndroidHardwareBackHandler(widget.componentId, close);
  }

  void close() {
    FocusScope.of(context).unfocus();
    dismissModal(widget.componentId);
  }

  void onCancel() {
    dismissModal(widget.componentId);
  }

  void onChangeText(String text) {
    setState(() {
      term = text;
      if (text.isEmpty) {
        loading = false;
      }
    });
  }

  void onLayout(Size size) {
    setState(() {
      containerHeight = size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cancelButtonProps = {
      'color': color,
      'buttonTextStyle': typography('Body', 100),
    };

    final styles = {
      'container': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.12),
      ),
      'inputContainerStyle': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.12),
      ),
      'inputStyle': TextStyle(
        color: theme.centerChannelColor,
      ),
      'listContainer': BoxDecoration(
        color: theme.centerChannelColor,
      ),
    };

    return Scaffold(
      body: GestureDetector(
        onTap: close,
        child: Container(
          decoration: styles['container'],
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              SearchBar(
                autoCapitalize: 'none',
                autoFocus: true,
                cancelButtonProps: cancelButtonProps,
                clearIconColor: color,
                inputContainerStyle: styles['inputContainerStyle'],
                inputStyle: styles['inputStyle'],
                keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
                onCancel: onCancel,
                onChangeText: onChangeText,
                placeholderTextColor: color,
                searchIconColor: color,
                selectionColor: color,
                showLoading: loading,
                value: term,
              ),
              if (term == '')
                QuickOptions(close: close),
              Container(
                decoration: styles['listContainer'],
                margin: EdgeInsets.only(top: 8),
                key: listView,
                child: (term == '')
                    ? UnfilteredList(
                        close: close,
                        keyboardOverlap: overlap,
                      )
                    : FilteredList(
                        close: close,
                        keyboardOverlap: overlap,
                        loading: loading,
                        onLoading: (bool value) {
                          setState(() {
                            loading = value;
                          });
                        },
                        term: term,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
