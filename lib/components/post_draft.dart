import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mattermost_flutter/constants/view.dart' as ViewConstants;
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/components/autocomplete.dart';
import 'package:mattermost_flutter/components/archived.dart';
import 'package:mattermost_flutter/components/draft_handler.dart';
import 'package:mattermost_flutter/components/read_only.dart';

const AUTOCOMPLETE_ADJUST = -5;

class PostDraft extends StatefulWidget {
  final String? testID;
  final String? accessoriesContainerID;
  final bool canPost;
  final String channelId;
  final bool? channelIsArchived;
  final bool channelIsReadOnly;
  final bool deactivatedChannel;
  final List<FileInfo>? files;
  final bool? isSearch;
  final String? message;
  final String? rootId;
  final String? scrollViewNativeID;
  final GlobalKey<KeyboardVisibilityState>? keyboardTracker;
  final double containerHeight;
  final bool isChannelScreen;
  final bool? canShowPostPriority;

  PostDraft({
    this.testID,
    this.accessoriesContainerID,
    required this.canPost,
    required this.channelId,
    this.channelIsArchived,
    required this.channelIsReadOnly,
    required this.deactivatedChannel,
    this.files,
    this.isSearch,
    this.message,
    this.rootId,
    this.scrollViewNativeID,
    required this.keyboardTracker,
    required this.containerHeight,
    required this.isChannelScreen,
    this.canShowPostPriority,
  });

  @override
  _PostDraftState createState() => _PostDraftState();
}

class _PostDraftState extends State<PostDraft> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late double _postInputTop;
  late bool _isFocused;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message);
    _focusNode = FocusNode();
    _postInputTop = 0;
    _isFocused = false;
  }

  @override
  void didUpdateWidget(PostDraft oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.channelId != oldWidget.channelId || widget.rootId != oldWidget.rootId) {
      _controller.text = widget.message ?? '';
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet(context);
    final keyboardHeight = useKeyboardHeight(context, widget.keyboardTracker);
    final insets = MediaQuery.of(context).viewInsets;
    final headerHeight = useDefaultHeaderHeight(context);
    final serverUrl = useServerUrl(context);

    final keyboardAdjustment = (isTablet && widget.isChannelScreen) ? ViewConstants.KEYBOARD_TRACKING_OFFSET : 0;
    final insetsAdjustment = (isTablet && widget.isChannelScreen) ? 0 : insets.bottom;
    final autocompletePosition = AUTOCOMPLETE_ADJUST + ((keyboardHeight > 0)
        ? keyboardHeight - keyboardAdjustment
        : _postInputTop + insetsAdjustment);
    final autocompleteAvailableSpace = widget.containerHeight - autocompletePosition - (widget.isChannelScreen ? headerHeight : 0);

    final animatedAutocompletePosition = useAutocompleteDefaultAnimatedValues(autocompletePosition);
    final animatedAutocompleteAvailableSpace = useAutocompleteDefaultAnimatedValues(autocompleteAvailableSpace);

    if (widget.channelIsArchived == true || widget.deactivatedChannel == true) {
      return Archived(
        testID: widget.testID != null ? '${widget.testID}.archived' : null,
        deactivated: widget.deactivatedChannel,
      );
    }

    if (widget.channelIsReadOnly || !widget.canPost) {
      return ReadOnly(
        testID: widget.testID != null ? '${widget.testID}.read_only' : null,
      );
    }

    final draftHandler = DraftHandler(
      testID: widget.testID,
      channelId: widget.channelId,
      cursorPosition: _controller.selection.baseOffset,
      files: widget.files,
      rootId: widget.rootId,
      canShowPostPriority: widget.canShowPostPriority,
      updateCursorPosition: (position) => setState(() {
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: position));
      }),
      updatePostInputTop: (top) => setState(() {
        _postInputTop = top;
      }),
      updateValue: (value) => setState(() {
        _controller.text = value;
      }),
      value: _controller.text,
      setIsFocused: (focused) => setState(() {
        _isFocused = focused;
      }),
    );

    final autoComplete = _isFocused
        ? Autocomplete(
            position: animatedAutocompletePosition,
            updateValue: (value) => setState(() {
              _controller.text = value;
            }),
            rootId: widget.rootId,
            channelId: widget.channelId,
            cursorPosition: _controller.selection.baseOffset,
            value: _controller.text,
            isSearch: widget.isSearch,
            hasFilesAttached: widget.files != null && widget.files!.isNotEmpty,
            inPost: true,
            availableSpace: animatedAutocompleteAvailableSpace,
            serverUrl: serverUrl,
          )
        : null;

    if (Theme.of(context).platform == TargetPlatform.android) {
      return Column(
        children: [
          draftHandler,
          if (autoComplete != null) autoComplete,
        ],
      );
    }

    return Column(
      children: [
        KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Visibility(
              visible: !isKeyboardVisible,
              child: Container(
                key: widget.accessoriesContainerID != null
                    ? GlobalObjectKey(widget.accessoriesContainerID!)
                    : null,
                child: draftHandler,
              ),
            );
          },
        ),
        if (autoComplete != null) autoComplete,
      ],
    );
  }
}
