import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/theme.dart';

class ChannelNameInput extends StatelessWidget {
  final String? error;
  final ValueChanged<String> onChange;

  ChannelNameInput({this.error, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final theme = Provider.of<Theme>(context);

    final labelDisplayName = intl.formatMessage(id: 'channel_modal.name', defaultMessage: 'Name');
    final placeholder = intl.formatMessage(id: 'channel_modal.name', defaultMessage: 'Channel Name');

    return FloatingTextInput(
      autoCorrect: false,
      autoCapitalize: TextCapitalization.none,
      blurOnSubmit: false,
      disableFullscreenUI: true,
      enablesReturnKeyAutomatically: true,
      label: labelDisplayName,
      placeholder: placeholder,
      maxLength: Channel.MAX_CHANNEL_NAME_LENGTH,
      keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
      returnKeyType: TextInputAction.next,
      showErrorIcon: true,
      spellCheck: false,
      testID: 'gonvert_gm_to_channel.channel_display_name.input',
      theme: theme,
      error: error,
      onChanged: onChange,
    );
  }
}

String getKeyboardAppearanceFromTheme(Theme theme) {
  // Assuming the Theme class has a method or property
  // to get the keyboard appearance
  return theme.keyboardAppearance;
}