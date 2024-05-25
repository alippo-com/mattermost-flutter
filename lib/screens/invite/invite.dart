
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/theme.dart';
import 'package:mattermost_flutter/hooks/server.dart';
import 'package:mattermost_flutter/screens/invite/selection.dart';
import 'package:mattermost_flutter/screens/invite/summary.dart';

class Invite extends StatefulWidget {
  final String componentId;
  final String teamId;
  final String teamDisplayName;
  final int teamLastIconUpdate;
  final String teamInviteId;
  final String teammateNameDisplay;
  final bool isAdmin;

  Invite({
    required this.componentId,
    required this.teamId,
    required this.teamDisplayName,
    required this.teamLastIconUpdate,
    required this.teamInviteId,
    required this.teammateNameDisplay,
    required this.isAdmin,
  });

  @override
  _InviteState createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  String term = '';
  List<SearchResult> searchResults = [];
  Map<String, SearchResult> selectedIds = {};
  bool loading = false;
  Result result = DEFAULT_RESULT;
  Stage stage = Stage.SELECTION;
  String sendError = '';

  @override
  void initState() {
    super.initState();
    // Initialize navigation buttons and other useEffect hooks here
  }

  void handleSearchChange(String text) {
    setState(() {
      loading = true;
      term = text;
    });
    // ... search logic
  }

  void handleSelectItem(SearchResult item) {
    // ... selection logic
  }

  void handleSend() {
    // ... send logic
  }

  void handleRetry() {
    // ... retry logic
  }

  void handleClearSearch() {
    setState(() {
      term = '';
      searchResults = [];
    });
  }

  void handleReset() {
    setState(() {
      stage = Stage.LOADING;
      sendError = '';
      term = '';
      searchResults = [];
      result = DEFAULT_RESULT;
      stage = Stage.SELECTION;
    });
  }

  Widget renderContent() {
    switch (stage) {
      case Stage.LOADING:
        return Loading(
          containerStyle: TextStyle(
            flex: 1,
            justifyContent: 'center',
            alignItems: 'center',
          ),
          size: 'large',
          color: theme.centerChannelColor,
        );
      case Stage.RESULT:
        return Summary(
          result: result,
          selectedIds: selectedIds,
          error: sendError,
          onClose: closeModal,
          onRetry: handleRetry,
          onBack: handleReset,
          testID: 'invite.screen.summary',
        );
      default:
        return Selection(
          teamId: widget.teamId,
          teamDisplayName: widget.teamDisplayName,
          teamLastIconUpdate: widget.teamLastIconUpdate,
          teamInviteId: widget.teamInviteId,
          teammateNameDisplay: widget.teammateNameDisplay,
          serverUrl: serverUrl,
          term: term,
          searchResults: searchResults,
          selectedIds: selectedIds,
          keyboardOverlap: keyboardOverlap,
          wrapperHeight: wrapperHeight,
          loading: loading,
          onSearchChange: handleSearchChange,
          onSelectItem: handleSelectItem,
          onRemoveItem: handleRemoveItem,
          onClose: closeModal,
          testID: 'invite.screen.selection',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return renderContent();
          },
        ),
      ),
    );
  }
}
