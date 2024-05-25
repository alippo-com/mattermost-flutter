import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/hooks/safe_area.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/indicator.dart';

class BottomSheetProps {
  final String? closeButtonId;
  final String componentId;
  final TextStyle? contentStyle;
  final int initialSnapIndex;
  final Widget? footerComponent;
  final Widget Function() renderContent;
  final List<dynamic> snapPoints;
  final String? testID;

  BottomSheetProps({
    this.closeButtonId,
    required this.componentId,
    this.contentStyle,
    this.initialSnapIndex = 1,
    this.footerComponent,
    required this.renderContent,
    this.snapPoints = const [1, '50%', '80%'],
    this.testID,
  });
}

class BottomSheet extends HookWidget {
  final BottomSheetProps props;

  BottomSheet({required this.props});

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final interaction = useRef<Handle?>(null);
    final timeoutRef = useRef<Timer?>(null);

    useEffect(() {
      interaction.value = InteractionManager.instance.createInteractionHandle();
      return () {
        interaction.value = null;
      };
    }, []);

    final bottomSheetBackgroundStyle = useMemo(() {
      return [
        styles['bottomSheetBackground'],
        {'borderWidth': isTablet ? 0 : 1}
      ];
    }, [isTablet, styles]);

    void close() {
      dismissModal(props.componentId);
    }

    useEffect(() {
      final listener = DeviceEventEmitter.addListener(Events.CLOSE_BOTTOM_SHEET, () {
        if (sheetRef.current != null) {
          sheetRef.current.close();
        } else {
          close();
        }
      });

      return () => listener.remove();
    }, [close]);

    void handleAnimationStart() {
      if (interaction.value == null) {
        interaction.value = InteractionManager.instance.createInteractionHandle();
      }
    }

    void handleClose() {
      if (sheetRef.current != null) {
        sheetRef.current.close();
      } else {
        close();
      }
    }

    void handleChange(int index) {
      timeoutRef.value = Timer(Duration(milliseconds: 300), () {
        if (interaction.value != null) {
          InteractionManager.instance.clearInteractionHandle(interaction.value!);
          interaction.value = null;
        }
      });

      if (index <= 0) {
        close();
      }
    }

    useAndroidHardwareBackHandler(props.componentId, handleClose);
    useNavButtonPressed(props.closeButtonId ?? '', props.componentId, close, [close]);

    useEffect(() {
      hapticFeedback();
      Keyboard.dismiss();

      return () {
        if (timeoutRef.value != null) {
          timeoutRef.value!.cancel();
        }

        if (interaction.value != null) {
          InteractionManager.instance.clearInteractionHandle(interaction.value!);
        }
      };
    }, []);

    Widget renderBackdrop(BottomSheetBackdropProps props) {
      return BottomSheetBackdrop(
        disappearsOnIndex: 0,
        appearsOnIndex: 1,
        opacity: 0.6,
      );
    }

    Widget renderContainerContent() {
      return Container(
        style: [
          styles['content'],
          isTablet ? styles['contentTablet'] : null,
          props.contentStyle
        ],
        child: props.renderContent(),
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Container(style: styles['separator']),
          renderContainerContent()
        ],
      );
    }

    return BottomSheetM(
      ref: sheetRef,
      index: props.initialSnapIndex,
      snapPoints: props.snapPoints,
      animateOnMount: true,
      backdropComponent: renderBackdrop,
      onAnimate: handleAnimationStart,
      onChange: handleChange,
      animationConfigs: animatedConfig,
      handleComponent: Indicator(),
      style: styles['bottomSheet'],
      backgroundStyle: bottomSheetBackgroundStyle,
      footerComponent: props.footerComponent,
      keyboardBehavior: 'extend',
      keyboardBlurBehavior: 'restore',
      onClose: close,
      child: renderContainerContent(),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'bottomSheet': {
        'backgroundColor': theme.centerChannelBg,
        'borderTopStartRadius': 24,
        'borderTopEndRadius': 24,
        'shadowOffset': {'width': 0, 'height': 8},
        'shadowOpacity': 0.12,
        'shadowRadius': 24,
        'shadowColor': '#000',
        'elevation': 24,
      },
      'bottomSheetBackground': {
        'backgroundColor': theme.centerChannelBg,
        'borderColor': changeOpacity(theme.centerChannelColor, 0.16),
      },
      'content': {
        'flex': 1,
        'paddingHorizontal': 20,
        'paddingTop': PADDING_TOP_MOBILE,
      },
      'contentTablet': {
        'paddingTop': PADDING_TOP_TABLET,
      },
      'separator': {
        'height': 1,
        'borderTopWidth': 1,
        'borderColor': changeOpacity(theme.centerChannelColor, 0.08),
      },
    };
  }
}
