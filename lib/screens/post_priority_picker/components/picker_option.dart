
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/option_item.dart';

class PickerOption extends StatelessWidget {
  final OptionType? type;
  final OptionItemProps props;

  const PickerOption({
    Key? key,
    this.type,
    required this.props,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String testID = 'post_priority_picker_item.${props.value ?? 'standard'}';

    return OptionItem(
      labelContainerStyle: _styles['labelContainer'],
      testID: testID,
      type: type ?? OptionType.select,
      props: props,
    );
  }
}

const _styles = {
  'labelContainer': BoxDecoration(
    alignment: Alignment.topLeft,  // Corrected to match alignItems: 'flex-start'
  ),
};
