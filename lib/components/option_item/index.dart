
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/radio_item.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const double ITEM_HEIGHT = 48.0;
const double DESCRIPTION_MARGIN_TOP = 2.0;

double getItemHeightWithDescription(int descriptionNumberOfLines) {
  const double labelHeight = 24.0; // typography 200 line height
  const double descriptionLineHeight = 16.0; // typography 75 line height

  return (labelHeight + DESCRIPTION_MARGIN_TOP + (descriptionLineHeight * descriptionNumberOfLines)).clamp(48.0, double.infinity);
}

class OptionItem extends StatelessWidget {
  final Function(String)? action;
  final TextStyle? arrowStyle;
  final BoxDecoration? containerStyle;
  final String? description;
  final bool? destructive;
  final String? icon;
  final String? iconColor;
  final String? info;
  final bool? inline;
  final String label;
  final BoxDecoration? labelContainerStyle;
  final Function? onRemove;
  final TextStyle? optionDescriptionTextStyle;
  final TextStyle? optionLabelTextStyle;
  final RadioItemProps? radioItemProps;
  final bool? selected;
  final String? testID;
  final OptionType type;
  final String? value;
  final Function(LayoutChangedEvent)? onLayout;
  final int? descriptionNumberOfLines;

  const OptionItem({
    required this.label,
    required this.type,
    this.action,
    this.arrowStyle,
    this.containerStyle,
    this.description,
    this.destructive,
    this.icon,
    this.iconColor,
    this.info,
    this.inline = false,
    this.labelContainerStyle,
    this.onRemove,
    this.optionDescriptionTextStyle,
    this.optionLabelTextStyle,
    this.radioItemProps,
    this.selected,
    this.testID = 'optionItem',
    this.value,
    this.onLayout,
    this.descriptionNumberOfLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    final bool isInLine = inline! && description != null;

    final labelStyle = isInLine ? styles['inlineLabel'] : styles['label'];
    final labelTextStyle = [
      isInLine ? styles['inlineLabelText'] : styles['labelText'],
      if (destructive!) styles['destructive'],
    ];

    final descriptionTextStyle = [
      isInLine ? styles['inlineDescription'] : styles['description'],
      if (destructive!) styles['destructive'],
    ];

    Widget? actionComponent;
    Widget? radioComponent;
    if (type == OptionType.SELECT && selected!) {
      actionComponent = CompassIcon(
        color: theme.linkColor,
        name: 'check',
        size: 24,
        testID: '$testID.selected',
      );
    } else if (type == OptionType.RADIO) {
      final radioComponentTestId = selected! ? '$testID.selected' : '$testID.not_selected';
      radioComponent = RadioItem(
        selected: selected!,
        testID: radioComponentTestId,
        ...radioItemProps!,
      );
    } else if (type == OptionType.TOGGLE) {
      final trackColor = Switch.adaptive(
        activeTrackColor: theme.buttonBg.withOpacity(0.32),
        inactiveTrackColor: theme.centerChannelColor.withOpacity(0.24),
        activeColor: theme.buttonBg,
        inactiveThumbColor: const Color(0xFFF3F3F3),
        value: selected!,
        onChanged: (bool value) => action!(value.toString()),
      );
      actionComponent = trackColor;
    } else if (type == OptionType.ARROW) {
      actionComponent = CompassIcon(
        color: theme.centerChannelColor.withOpacity(0.32),
        name: 'chevron-right',
        size: 24,
        style: arrowStyle,
      );
    } else if (type == OptionType.REMOVE) {
      actionComponent = TouchableWithFeedback(
        onPress: onRemove!,
        style: styles['iconContainer'],
        type: 'opacity',
        testID: '$testID.remove.button',
        child: CompassIcon(
          name: 'close',
          size: 18,
          color: theme.centerChannelColor.withOpacity(0.64),
        ),
      );
    }

    final component = Container(
      decoration: containerStyle,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null)
                  Container(
                    margin: EdgeInsets.only(right: 16.0),
                    child: OptionIcon(
                      icon: icon!,
                      iconColor: iconColor,
                      destructive: destructive!,
                    ),
                  ),
                if (type == OptionType.RADIO) radioComponent!,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: optionLabelTextStyle?.merge(labelTextStyle),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: optionDescriptionTextStyle?.merge(descriptionTextStyle),
                          overflow: TextOverflow.ellipsis,
                          maxLines: descriptionNumberOfLines,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (info != null)
            Text(
              info!,
              style: styles['info'],
              overflow: TextOverflow.ellipsis,
            ),
          if (actionComponent != null) actionComponent,
        ],
      ),
    );

    if (TouchableOptionTypes.values.contains(type)) {
      return GestureDetector(
        onTap: () => action!(value!),
        child: component,
      );
    }

    return component;
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'actionContainer': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'actionSubContainer': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'container': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'destructive': TextStyle(
        color: theme.dndIndicator,
      ),
      'description': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.64),
        fontSize: 16.0,
      ),
      'iconContainer': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'info': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.56),
        textAlign: TextAlign.right,
      ),
      'inlineLabel': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'inlineLabelText': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      'inlineDescription': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 16.0,
      ),
      'label': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'labelContainer': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'labelText': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 16.0,
      ),
      'removeContainer': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      'row': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4.0),
      ),
    };
  }
}

enum OptionType {
  NONE,
  TOGGLE,
  ARROW,
  DEFAULT,
  RADIO,
  REMOVE,
  SELECT,
}

class RadioItemProps {
  final bool selected;
  final String testID;
  const RadioItemProps({required this.selected, required this.testID});
}
