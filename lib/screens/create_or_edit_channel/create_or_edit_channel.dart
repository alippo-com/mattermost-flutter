
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/actions/channel.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/channel.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_info.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/navigation.dart';

class CreateOrEditChannel extends StatefulWidget {
  final AvailableScreens componentId;
  final ChannelModel? channel;
  final ChannelInfoModel? channelInfo;
  final bool headerOnly;
  final bool isModal;

  const CreateOrEditChannel({
    Key? key,
    required this.componentId,
    this.channel,
    this.channelInfo,
    this.headerOnly = false,
    required this.isModal,
  }) : super(key: key);

  @override
  _CreateOrEditChannelState createState() => _CreateOrEditChannelState();
}

class _CreateOrEditChannelState extends State<CreateOrEditChannel> {
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late String _purpose;
  late String _header;
  late bool _canSave;
  late bool _saving;
  late String _error;

  @override
  void initState() {
    super.initState();
    _displayName = widget.channel?.displayName ?? '';
    _purpose = widget.channelInfo?.purpose ?? '';
    _header = widget.channelInfo?.header ?? '';
    _canSave = false;
    _saving = false;
    _error = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isModal) {
        setButtons(
          widget.componentId,
          leftButtons: [makeCloseButton()],
        );
      }
      setButtons(
        widget.componentId,
        rightButtons: [rightButton()],
      );
    });
  }

  NavigationButton rightButton() {
    return NavigationButton(
      id: widget.channel != null ? EDIT_BUTTON_ID : CREATE_BUTTON_ID,
      title: widget.channel != null ? 'Save' : 'Create',
      enabled: _canSave,
      showAsAction: NavigationButtonAction.always,
      color: Theme.of(context).textTheme.titleMedium?.color,
      onPress: widget.channel != null ? _onUpdateChannel : _onCreateChannel,
    );
  }

  NavigationButton makeCloseButton() {
    return NavigationButton(
      id: CLOSE_BUTTON_ID,
      icon: CompassIcon.getImageSourceSync('close', 24, Theme.of(context).textTheme.titleMedium?.color),
      onPress: _handleClose,
    );
  }

  void _handleClose() {
    Keyboard.dismiss();
    if (widget.isModal) {
      dismissModal(widget.componentId);
    } else {
      popTopScreen(widget.componentId);
    }
  }

  Future<void> _onCreateChannel() async {
    if (!_validateDisplayName()) return;

    setState(() {
      _saving = true;
    });

    final result = await createChannel(
      serverUrl: useServerUrl(),
      displayName: _displayName,
      purpose: _purpose,
      header: _header,
      type: widget.channel?.type ?? General.OPEN_CHANNEL,
    );

    if (result.error != null) {
      setState(() {
        _error = result.error!;
        _saving = false;
      });
      return;
    }

    _handleClose();
    switchToChannelById(useServerUrl(), result.channel.id, result.channel.teamId);
  }

  Future<void> _onUpdateChannel() async {
    if (!_validateDisplayName()) return;

    setState(() {
      _saving = true;
    });

    final patchChannel = ChannelPatch(
      header: _header,
      displayName: _displayName,
      purpose: _purpose,
    );

    final result = await handlePatchChannel(
      serverUrl: useServerUrl(),
      channelId: widget.channel!.id,
      patchChannel: patchChannel,
    );

    if (result.error != null) {
      setState(() {
        _error = result.error!;
        _saving = false;
      });
      return;
    }

    _handleClose();
  }

  bool _validateDisplayName() {
    if (isDirect(widget.channel)) return true;

    final result = validateDisplayName(useIntl(), _displayName);
    if (result.error != null) {
      setState(() {
        _error = result.error!;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ChannelInfoForm(
      formKey: _formKey,
      error: _error,
      saving: _saving,
      channelType: widget.channel?.type,
      editing: widget.channel != null,
      onTypeChange: (type) {
        setState(() {
          _canSave = _displayName.length >= MIN_CHANNEL_NAME_LENGTH &&
              (_displayName != widget.channel?.displayName ||
                  _purpose != widget.channelInfo?.purpose ||
                  _header != widget.channelInfo?.header ||
                  type != widget.channel?.type);
        });
      },
      type: widget.channel?.type ?? General.OPEN_CHANNEL,
      displayName: _displayName,
      onDisplayNameChange: (value) {
        setState(() {
          _displayName = value;
          _canSave = _displayName.length >= MIN_CHANNEL_NAME_LENGTH &&
              (_displayName != widget.channel?.displayName ||
                  _purpose != widget.channelInfo?.purpose ||
                  _header != widget.channelInfo?.header);
        });
      },
      header: _header,
      headerOnly: widget.headerOnly,
      onHeaderChange: (value) {
        setState(() {
          _header = value;
          _canSave = _displayName.length >= MIN_CHANNEL_NAME_LENGTH &&
              (_displayName != widget.channel?.displayName ||
                  _purpose != widget.channelInfo?.purpose ||
                  _header != widget.channelInfo?.header);
        });
      },
      purpose: _purpose,
      onPurposeChange: (value) {
        setState(() {
          _purpose = value;
          _canSave = _displayName.length >= MIN_CHANNEL_NAME_LENGTH &&
              (_displayName != widget.channel?.displayName ||
                  _purpose != widget.channelInfo?.purpose ||
                  _header != widget.channelInfo?.header);
        });
      },
    );
  }
}
