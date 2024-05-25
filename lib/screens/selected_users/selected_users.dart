import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/components/selected_chip.dart';
import 'package:mattermost_flutter/components/toast.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/user_profile.dart';

class SelectedUsers extends StatefulWidget {
  final String buttonIcon;
  final String buttonText;
  final int keyboardOverlap;
  final Function(Map<String, bool>?) onPress;
  final Function(String) onRemove;
  final Map<String, UserProfile> selectedIds;
  final Function(bool)? setShowToast;
  final bool showToast;
  final String teammateNameDisplay;
  final String? testID;
  final String? toastIcon;
  final String? toastMessage;
  final int? maxUsers;

  const SelectedUsers({
    Key? key,
    required this.buttonIcon,
    required this.buttonText,
    this.keyboardOverlap = 0,
    required this.onPress,
    required this.onRemove,
    required this.selectedIds,
    this.setShowToast,
    this.showToast = false,
    required this.teammateNameDisplay,
    this.testID,
    this.toastIcon,
    this.toastMessage,
    this.maxUsers,
  }) : super(key: key);

  @override
  _SelectedUsersState createState() => _SelectedUsersState();
}

class _SelectedUsersState extends State<SelectedUsers> {
  late ThemeData theme;
  late Map<String, dynamic> style;
  late double keyboardHeight;
  late EdgeInsets insets;
  late double usersChipsHeight;
  late bool isVisible;
  late int numberSelectedIds;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    style = getStyleFromTheme(theme);
    keyboardHeight = useKeyboardHeightWithDuration();
    insets = MediaQuery.of(context).viewInsets;
    usersChipsHeight = 0;
    isVisible = false;
    numberSelectedIds = widget.selectedIds.length;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        isVisible = numberSelectedIds > 0;
      });
    });

    if (widget.showToast) {
      Future.delayed(Duration(seconds: 4), () {
        widget.setShowToast?.call(false);
      });
    }
  }

  Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
    return {
      'container': {
        'backgroundColor': theme.backgroundColor,
        'borderBottomWidth': 0,
        'borderColor': changeOpacity(theme.dividerColor, 0.16),
        'borderTopLeftRadius': 12,
        'borderTopRightRadius': 12,
        'borderWidth': 1,
        'maxHeight': PANEL_MAX_HEIGHT,
        'overflow': 'hidden',
        'paddingHorizontal': 20,
        'shadowColor': theme.shadowColor,
        'shadowOffset': Offset(0, 8),
        'shadowOpacity': 0.16,
        'shadowRadius': 24,
      },
      'toast': {
        'backgroundColor': theme.errorColor,
      },
      'usersScroll': {
        'marginTop': SCROLL_MARGIN_TOP,
        'marginBottom': SCROLL_MARGIN_BOTTOM,
      },
      'users': {
        'flexDirection': Axis.horizontal,
        'flexGrow': 1,
        'flexWrap': WrapAlignment.start,
      },
      'message': {
        'color': theme.backgroundColor,
        'fontSize': 12,
        'marginRight': 5,
        'marginTop': 10,
        'marginBottom': 2,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.only(bottom: widget.keyboardOverlap + TABLET_MARGIN_BOTTOM),
      color: isVisible ? theme.backgroundColor : Colors.transparent,
      child: Column(
        children: [
          if (widget.showToast)
            Toast(
              iconName: widget.toastIcon,
              style: style['toast'],
              message: widget.toastMessage,
              bottom: TOAST_BOTTOM_MARGIN + usersChipsHeight + insets.bottom,
              opacity: 1,
            ),
          Container(
            decoration: BoxDecoration(
              color: style['container']['backgroundColor'],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(
                color: style['container']['borderColor'],
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: style['container']['shadowColor'],
                  offset: style['container']['shadowOffset'],
                  blurRadius: style['container']['shadowRadius'],
                  spreadRadius: 0.16,
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: PANEL_MAX_HEIGHT),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: SCROLL_MARGIN_TOP,
                      bottom: SCROLL_MARGIN_BOTTOM,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.selectedIds.entries.map((entry) {
                        return SelectedUser(
                          key: ValueKey(entry.key),
                          user: entry.value,
                          teammateNameDisplay: widget.teammateNameDisplay,
                          onRemove: widget.onRemove,
                          testID: '${widget.testID}.selected_user',
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Opacity(
                  opacity: isVisible ? 1 : 0,
                  child: Button(
                    onPressed: () => widget.onPress(),
                    iconName: widget.buttonIcon,
                    text: widget.buttonText,
                    iconSize: 20,
                    theme: theme,
                    buttonType: isDisabled ? ButtonType.disabled : ButtonType.defaultType,
                    emphasis: ButtonEmphasis.primary,
                    size: ButtonSize.large,
                    testID: '${widget.testID}.start.button',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get isDisabled => widget.maxUsers != null && numberSelectedIds > widget.maxUsers;
}
