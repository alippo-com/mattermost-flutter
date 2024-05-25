import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/background.dart';
import 'package:mattermost_flutter/components/form.dart';
import 'package:mattermost_flutter/components/header.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/models/servers.dart';
import 'package:mattermost_flutter/database/database_manager.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class EditServer extends StatefulWidget {
  final String? closeButtonId;
  final String componentId;
  final ServersModel server;
  final ThemeData theme;

  EditServer({
    this.closeButtonId,
    required this.componentId,
    required this.server,
    required this.theme,
  });

  @override
  _EditServerState createState() => _EditServerState();
}

class _EditServerState extends State<EditServer> {
  final _keyboardAwareController = ScrollController();
  bool _saving = false;
  late String _displayName;
  bool _buttonDisabled = true;
  String? _displayNameError;

  @override
  void initState() {
    super.initState();
    _displayName = widget.server.displayName;
    _buttonDisabled = _displayName.isEmpty || _displayName == widget.server.displayName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      useNavButtonPressed(widget.closeButtonId ?? '', widget.componentId, _close);
      useAndroidHardwareBackHandler(widget.componentId, _close);
    });
  }

  void _close() {
    dismissModal(widget.componentId);
  }

  void _handleUpdate() async {
    if (_buttonDisabled) return;

    setState(() {
      _displayNameError = null;
      _saving = true;
    });

    final knownServer = await DatabaseManager.getServerByDisplayName(_displayName);
    if (knownServer != null && knownServer.lastActiveAt > 0 && knownServer.url != widget.server.url) {
      setState(() {
        _buttonDisabled = true;
        _displayNameError = 'You are using this name for another server.';
        _saving = false;
      });
      return;
    }

    await DatabaseManager.updateServerDisplayName(widget.server.url, _displayName);
    dismissModal(widget.componentId);
  }

  void _handleDisplayNameTextChanged(String text) {
    setState(() {
      _displayName = text;
      _displayNameError = null;
      _buttonDisabled = _displayName.isEmpty || _displayName == widget.server.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final styles = _getStyles(theme);

    return ChangeNotifierProvider(
      create: (_) => KeyboardVisibilityProvider(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Background(theme: theme),
              Expanded(
                child: SingleChildScrollView(
                  controller: _keyboardAwareController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Header(theme: theme),
                      Form(
                        buttonDisabled: _buttonDisabled,
                        connecting: _saving,
                        displayName: _displayName,
                        displayNameError: _displayNameError,
                        handleUpdate: _handleUpdate,
                        handleDisplayNameTextChanged: _handleDisplayNameTextChanged,
                        keyboardAwareController: _keyboardAwareController,
                        serverUrl: widget.server.url,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _getStyles(ThemeData theme) {
    return BoxDecoration(
      color: changeOpacity(theme.primaryColor, 0.56),
    );
  }
}
