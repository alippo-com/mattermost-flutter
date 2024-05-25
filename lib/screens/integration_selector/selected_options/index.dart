import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/constants/view_constants.dart';
import 'package:mattermost_flutter/screens/integration_selector/selected_option.dart';

class SelectedOptions extends StatelessWidget {
  final Theme theme;
  final List<dynamic> selectedOptions;
  final String dataSource;
  final Function(dynamic) onRemove;

  SelectedOptions({
    required this.theme,
    required this.selectedOptions,
    required this.dataSource,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleFromTheme(theme);
    final List<Widget> options = selectedOptions.map((optionItem) {
      String key;

      switch (dataSource) {
        case ViewConstants.DATA_SOURCE_USERS:
          key = (optionItem as UserProfile).id;
          break;
        case ViewConstants.DATA_SOURCE_CHANNELS:
          key = (optionItem as Channel).id;
          break;
        default:
          key = (optionItem as DialogOption).value;
          break;
      }

      return SelectedOption(
        key: Key(key),
        option: optionItem,
        theme: theme,
        dataSource: dataSource,
        onRemove: onRemove,
      );
    }).toList();

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: 5, bottom: 5),
        constraints: BoxConstraints(maxHeight: 100),
        child: Wrap(
          alignment: WrapAlignment.start,
          direction: Axis.horizontal,
          children: options,
        ),
      ),
    );
  }

  _StyleSheet _getStyleFromTheme(Theme theme) {
    return _StyleSheet(
      container: BoxDecoration(
        margin: EdgeInsets.only(left: 5, bottom: 5),
        constraints: BoxConstraints(maxHeight: 100),
      ),
      users: BoxDecoration(
        alignment: AlignmentDirectional.topStart,
        direction: Axis.horizontal,
      ),
    );
  }
}

class _StyleSheet {
  final BoxDecoration container;
  final BoxDecoration users;

  _StyleSheet({
    required this.container,
    required this.users,
  });
}
