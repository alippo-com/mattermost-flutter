import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/state/calls.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';

const ITEM_HEIGHT = 50.0;

class AudioDeviceButton extends HookWidget {
  final BoxDecoration pressableDecoration;
  final TextStyle buttonTextStyle;
  final BoxDecoration iconDecoration;
  final CurrentCall currentCall;

  AudioDeviceButton({
    required this.pressableDecoration,
    required this.buttonTextStyle,
    required this.iconDecoration,
    required this.currentCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isTablet = context.read<Device>().isTablet;
    final color = theme.awayIndicator;
    final audioDeviceInfo = currentCall.audioDeviceInfo;
    final phoneLabel = 'Phone';
    final tabletLabel = 'Tablet';
    final speakerLabel = 'SpeakerPhone';
    final bluetoothLabel = 'Bluetooth';
    final headsetLabel = 'Headset';

    final deviceSelector = useCallback(() {
      final currentDevice = audioDeviceInfo.selectedAudioDevice;
      var available = audioDeviceInfo.availableAudioDeviceList;
      if (available.contains(AudioDevice.WiredHeadset)) {
        available = available.where((d) => d != AudioDevice.Earpiece).toList();
      }
      final selectDevice = (AudioDevice device) {
        setPreferredAudioRoute(device);
        Navigator.pop(context);
      };

      final renderContent = () {
        return Column(
          children: [
            if (available.contains(AudioDevice.Earpiece) && isTablet)
              SlideUpPanelItem(
                leftIcon: 'tablet',
                onPress: () => selectDevice(AudioDevice.Earpiece),
                text: tabletLabel,
                rightIcon: currentDevice == AudioDevice.Earpiece ? 'check' : null,
                rightIconStyles: currentDevice == AudioDevice.Earpiece ? style.checkIcon : null,
              ),
            if (available.contains(AudioDevice.Earpiece) && !isTablet)
              SlideUpPanelItem(
                leftIcon: 'cellphone',
                onPress: () => selectDevice(AudioDevice.Earpiece),
                text: phoneLabel,
                rightIcon: currentDevice == AudioDevice.Earpiece ? 'check' : null,
                rightIconStyles: currentDevice == AudioDevice.Earpiece ? style.checkIcon : null,
              ),
            if (available.contains(AudioDevice.Speakerphone))
              SlideUpPanelItem(
                leftIcon: 'volume-high',
                onPress: () => selectDevice(AudioDevice.Speakerphone),
                text: speakerLabel,
                rightIcon: currentDevice == AudioDevice.Speakerphone ? 'check' : null,
                rightIconStyles: currentDevice == AudioDevice.Speakerphone ? style.checkIcon : null,
              ),
            if (available.contains(AudioDevice.Bluetooth))
              SlideUpPanelItem(
                leftIcon: 'bluetooth',
                onPress: () => selectDevice(AudioDevice.Bluetooth),
                text: bluetoothLabel,
                rightIcon: currentDevice == AudioDevice.Bluetooth ? 'check' : null,
                rightIconStyles: currentDevice == AudioDevice.Bluetooth ? style.checkIcon : null,
              ),
            if (available.contains(AudioDevice.WiredHeadset))
              SlideUpPanelItem(
                leftIcon: 'headphones',
                onPress: () => selectDevice(AudioDevice.WiredHeadset),
                text: headsetLabel,
                rightIcon: currentDevice == AudioDevice.WiredHeadset ? 'check' : null,
                rightIconStyles: currentDevice == AudioDevice.WiredHeadset ? style.checkIcon : null,
              ),
          ],
        );
      };

      showBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(bottom: bottom),
            child: renderContent(),
          );
        },
      );
    }, [audioDeviceInfo, color]);

    String icon = 'volume-high';
    String label = speakerLabel;
    switch (audioDeviceInfo.selectedAudioDevice) {
      case AudioDevice.Earpiece:
        icon = isTablet ? 'tablet' : 'cellphone';
        label = isTablet ? tabletLabel : phoneLabel;
        break;
      case AudioDevice.Bluetooth:
        icon = 'bluetooth';
        label = bluetoothLabel;
        break;
      case AudioDevice.WiredHeadset:
        icon = 'headphones';
        label = headsetLabel;
        break;
      default:
        break;
    }

    return GestureDetector(
      onTap: deviceSelector,
      child: Container(
        decoration: pressableDecoration,
        child: Column(
          children: [
            CompassIcon(
              name: icon,
              size: 32,
              decoration: iconDecoration,
            ),
            Text(label, style: buttonTextStyle),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleFromTheme(Theme theme) {
  return {
    'checkIcon': TextStyle(color: theme.buttonBg),
  };
}

void setPreferredAudioRoute(AudioDevice device) {
  // This function should set the preferred audio route
}
