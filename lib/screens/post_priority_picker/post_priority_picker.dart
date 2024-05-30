
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:react_intl/react_intl.dart';

import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'components/picker_option.dart';
import 'utils.dart';

import 'package:mattermost_flutter/types/bottom_sheet_footer_props.dart';

class PostPriorityPicker extends HookWidget {
  final String componentId;
  final bool isPostAcknowledgementEnabled;
  final bool isPersistenNotificationsEnabled;
  final PostPriority postPriority;
  final Function(PostPriority) updatePostPriority;
  final String closeButtonId;
  final int persistentNotificationInterval;

  const PostPriorityPicker({
    required this.componentId,
    required this.isPostAcknowledgementEnabled,
    required this.isPersistenNotificationsEnabled,
    required this.postPriority,
    required this.updatePostPriority,
    required this.closeButtonId,
    required this.persistentNotificationInterval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final isTablet = useIsTablet();
    final data = useState<PostPriority>(postPriority);

    final style = getStyleSheet(theme);

    void closeBottomSheet() {
      dismissBottomSheet(Screens.POST_PRIORITY_PICKER);
    }

    useNavButtonPressed(closeButtonId, componentId, closeBottomSheet);
    useAndroidHardwareBackHandler(componentId, closeBottomSheet);

    final displayPersistentNotifications = isPersistenNotificationsEnabled &&
        data.value.priority == PostPriorityType.URGENT;

    final snapPoints = useMemo(() {
      const paddingBottom = 10;
      const bottomSheetAdjust = 5;
      var COMPONENT_HEIGHT = TITLE_HEIGHT +
          OPTIONS_PADDING +
          FOOTER_HEIGHT +
          bottomSheetSnapPoint(3, ITEM_HEIGHT, MediaQuery.of(context).padding.bottom) +
          paddingBottom +
          bottomSheetAdjust;

      if (isPostAcknowledgementEnabled) {
        COMPONENT_HEIGHT += OPTIONS_SEPARATOR_HEIGHT + TOGGLE_OPTION_MARGIN_TOP + getItemHeightWithDescription(2);
        if (displayPersistentNotifications) {
          COMPONENT_HEIGHT += OPTIONS_SEPARATOR_HEIGHT + TOGGLE_OPTION_MARGIN_TOP + getItemHeightWithDescription(2);
        }
      }

      return [1, COMPONENT_HEIGHT];
    }, [displayPersistentNotifications, isPostAcknowledgementEnabled, MediaQuery.of(context).padding.bottom]);

    void handleUpdatePriority(String priority) {
      data.value = data.value.copyWith(priority: priority, persistent_notifications: null);
    }

    void handleUpdateRequestedAck(bool requested_ack) {
      data.value = data.value.copyWith(requested_ack: requested_ack);
    }

    void handleUpdatePersistentNotifications(bool persistent_notifications) {
      data.value = data.value.copyWith(persistent_notifications: persistent_notifications);
    }

    void handleSubmit() {
      updatePostPriority(data.value);
      closeBottomSheet();
    }

    Widget renderContent() {
      return Container(
        color: theme.centerChannelBg,
        child: Column(
          children: [
            if (!isTablet)
              Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    FormattedText(
                      id: 'post_priority.picker.title',
                      defaultMessage: 'Message priority',
                      style: style.title,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: PostPriorityColors.IMPORTANT,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      margin: const EdgeInsets.only(left: 8),
                      child: FormattedText(
                        id: 'post_priority.picker.beta',
                        defaultMessage: 'BETA',
                        style: style.beta,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: OPTIONS_PADDING),
              child: Column(
                children: [
                  PickerOption(
                    action: handleUpdatePriority,
                    icon: Icons.message,
                    label: intl.formatMessage(labels.standard.label),
                    selected: data.value.priority == '',
                    value: PostPriorityType.STANDARD,
                  ),
                  PickerOption(
                    action: handleUpdatePriority,
                    icon: Icons.message,
                    iconColor: PostPriorityColors.IMPORTANT,
                    label: intl.formatMessage(labels.important.label),
                    selected: data.value.priority == PostPriorityType.IMPORTANT,
                    value: PostPriorityType.IMPORTANT,
                  ),
                  PickerOption(
                    action: handleUpdatePriority,
                    icon: Icons.message,
                    iconColor: PostPriorityColors.URGENT,
                    label: intl.formatMessage(labels.urgent.label),
                    selected: data.value.priority == PostPriorityType.URGENT,
                    value: PostPriorityType.URGENT,
                  ),
                  if (isPostAcknowledgementEnabled)
                    Column(
                      children: [
                        Divider(
                          color: changeOpacity(theme.centerChannelColor, 0.08),
                          height: OPTIONS_SEPARATOR_HEIGHT,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: TOGGLE_OPTION_MARGIN_TOP),
                          child: PickerOption(
                            action: handleUpdateRequestedAck,
                            label: intl.formatMessage(labels.requestAck.label),
                            description: intl.formatMessage(labels.requestAck.description),
                            icon: Icons.check_circle_outline,
                            type: ToggleType.toggle,
                            selected: data.value.requested_ack,
                            descriptionNumberOfLines: 2,
                          ),
                        ),
                        if (displayPersistentNotifications)
                          Container(
                            margin: EdgeInsets.only(top: TOGGLE_OPTION_MARGIN_TOP),
                            child: PickerOption(
                              action: handleUpdatePersistentNotifications,
                              label: intl.formatMessage(labels.persistentNotifications.label),
                              description: intl.formatMessage(
                                labels.persistentNotifications.description,
                                params: {'interval': persistentNotificationInterval},
                              ),
                              icon: Icons.bell_ring,
                              type: ToggleType.toggle,
                              selected: data.value.persistent_notifications,
                              descriptionNumberOfLines: 2,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget renderFooter(BottomSheetFooterProps props) {
      return Footer(
        onCancel: closeBottomSheet,
        onSubmit: handleSubmit,
      );
    }

    return BottomSheet(
      renderContent: renderContent,
      closeButtonId: closeButtonId,
      componentId: Screens.POST_PRIORITY_PICKER,
      footerComponent: renderFooter,
      initialSnapIndex: 1,
      snapPoints: snapPoints,
    );
  }
}

const TITLE_HEIGHT = 30;
const OPTIONS_PADDING = 12;
const OPTIONS_SEPARATOR_HEIGHT = 1;
const TOGGLE_OPTION_MARGIN_TOP = 16;

getStyleSheet(Theme theme) {
  return {
    'container': {
      'backgroundColor': theme.centerChannelBg,
    },
    'titleContainer': {
      'alignment': Alignment.center,
      'flexDirection': 'row',
    },
    'title': {
      'color': theme.centerChannelColor,
      ...typography('Heading', 600, 'SemiBold'),
    },
    'betaContainer': {
      'backgroundColor': PostPriorityColors.IMPORTANT,
      'borderRadius': 4,
      'paddingHorizontal': 4,
      'marginLeft': 8,
    },
    'beta': {
      'color': Colors.white,
      ...typography('Body', 25, 'SemiBold'),
    },
    'optionsContainer': {
      'paddingTop': OPTIONS_PADDING,
    },
    'optionsSeparator': {
      'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
      'height': OPTIONS_SEPARATOR_HEIGHT,
    },
    'toggleOptionContainer': {
      'marginTop': TOGGLE_OPTION_MARGIN_TOP,
    },
  };
}
