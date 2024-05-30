import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moment/moment.dart';

class CustomStatus extends StatefulWidget {
  final bool customStatusExpirySupported;
  final UserModel? currentUser;
  final List<UserCustomStatus> recentCustomStatuses;
  final AvailableScreens componentId;

  CustomStatus({
    required this.customStatusExpirySupported,
    this.currentUser,
    required this.recentCustomStatuses,
    required this.componentId,
  });

  @override
  _CustomStatusState createState() => _CustomStatusState();
}

class _CustomStatusState extends State<CustomStatus> {
  late NewStatusType newStatus;
  bool isTablet = false; // Assume a method to check if device is a tablet
  bool isStatusSet = false;
  final String BTN_UPDATE_STATUS = 'update-custom-status';
  final List<Edge> edges = [Edge.bottom, Edge.left, Edge.right];
  final String DEFAULT_DURATION = 'today';

  @override
  void initState() {
    super.initState();
    newStatus = initialStatus();
    isStatusSet = newStatus.emoji != null || newStatus.text != null;
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible && !isTablet) {
        Navigator.of(context).pop();
      }
    });
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.paused") {
        if (!isTablet) {
          Navigator.of(context).pop();
        }
      }
      return;
    });
  }

  NewStatusType initialStatus() {
    String userTimezone = getTimezone(widget.currentUser?.timezone);
    bool isCustomStatusExpired = verifyExpiredStatus(widget.currentUser);
    Moment currentTime = getCurrentMomentForTimezone(userTimezone);

    Moment initialCustomExpiryTime = getRoundedTime(currentTime);
    bool isCurrentCustomStatusSet = !isCustomStatusExpired &&
        (storedStatus()?.text != null || storedStatus()?.emoji != null);
    if (isCurrentCustomStatusSet &&
        storedStatus()?.duration == 'date_and_time' &&
        storedStatus()?.expires_at != null) {
      initialCustomExpiryTime = Moment(storedStatus()?.expires_at);
    }

    return NewStatusType(
      duration: isCurrentCustomStatusSet
          ? storedStatus()?.duration ?? CustomStatusDurationEnum.DONT_CLEAR
          : DEFAULT_DURATION,
      emoji: isCurrentCustomStatusSet ? storedStatus()?.emoji : '',
      expiresAt: initialCustomExpiryTime,
      text: isCurrentCustomStatusSet ? storedStatus()?.text : '',
    );
  }

  UserCustomStatus? storedStatus() {
    return getUserCustomStatus(widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    final Theme theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Set a custom status'),
        actions: [
          TextButton(
            onPressed: handleSetStatus,
            child: Text(
              'Done',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: KeyboardAvoidingView(
          behavior: Platform.isIOS ? 'padding' : null,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomStatusInput(
                  emoji: newStatus.emoji,
                  isStatusSet: isStatusSet,
                  onChangeText: handleTextChange,
                  onClearHandle: handleClear,
                  onOpenEmojiPicker: openEmojiPicker,
                  text: newStatus.text,
                  theme: theme,
                ),
                if (isStatusSet && widget.customStatusExpirySupported)
                  ClearAfter(
                    duration: newStatus.duration,
                    expiresAt: newStatus.expiresAt,
                    onOpenClearAfterModal: openClearAfterModal,
                    theme: theme,
                  ),
                if (widget.recentCustomStatuses.isNotEmpty)
                  RecentCustomStatuses(
                    onHandleClear: handleRecentCustomStatusClear,
                    onHandleSuggestionClick:
                    handleRecentCustomStatusSuggestionClick,
                    recentCustomStatuses: widget.recentCustomStatuses,
                    theme: theme,
                  ),
                CustomStatusSuggestions(
                  onHandleCustomStatusSuggestionClick:
                  handleCustomStatusSuggestionClick,
                  recentCustomStatuses: widget.recentCustomStatuses,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleClear() {
    setState(() {
      newStatus = NewStatusType(
        emoji: '',
        text: '',
        duration: DEFAULT_DURATION,
        expiresAt: newStatus.expiresAt,
      );
    });
  }

  void handleTextChange(String value) {
    setState(() {
      newStatus = NewStatusType(
        emoji: newStatus.emoji,
        text: value,
        duration: newStatus.duration,
        expiresAt: newStatus.expiresAt,
      );
    });
  }

  void handleEmojiClick(String value) {
    setState(() {
      newStatus = NewStatusType(
        emoji: value,
        text: newStatus.text,
        duration: newStatus.duration,
        expiresAt: newStatus.expiresAt,
      );
    });
  }

  void handleClearAfterClick(CustomStatusDuration duration, String expiresAt) {
    setState(() {
      newStatus = NewStatusType(
        emoji: newStatus.emoji,
        text: newStatus.text,
        duration: duration,
        expiresAt: duration == 'date_and_time'
            ? Moment(expiresAt)
            : newStatus.expiresAt,
      );
    });
  }

  void handleRecentCustomStatusClear(UserCustomStatus status) {
    removeRecentCustomStatus(status);
  }

  void handleCustomStatusSuggestionClick(UserCustomStatus status) {
    setState(() {
      newStatus = NewStatusType(
        emoji: status.emoji,
        text: status.text,
        duration: status.duration!,
        expiresAt: Moment(status.expires_at),
      );
    });
  }

  void openClearAfterModal() {
    // Navigation logic to open clear after modal
  }

  void handleRecentCustomStatusSuggestionClick(UserCustomStatus status) {
    setState(() {
      newStatus = NewStatusType(
        emoji: status.emoji,
        text: status.text,
        duration: status.duration ?? CustomStatusDurationEnum.DONT_CLEAR,
        expiresAt: newStatus.expiresAt,
      );
    });
    if (status.duration == 'date_and_time') {
      openClearAfterModal();
    }
  }

  Future<void> handleSetStatus() async {
    if (!widget.currentUser) {
      return;
    }

    if (isStatusSet) {
      bool isStatusSame = storedStatus()?.emoji == newStatus.emoji &&
          storedStatus()?.text == newStatus.text &&
          storedStatus()?.duration == newStatus.duration;
      String newExpiresAt = calculateExpiryTime(
          newStatus.duration!, widget.currentUser, newStatus.expiresAt);
      if (isStatusSame && newStatus.duration == 'date_and_time') {
        isStatusSame = storedStatus()?.expires_at == newExpiresAt;
      }

      if (!isStatusSame) {
        UserCustomStatus status = UserCustomStatus(
          emoji: newStatus.emoji ?? 'speech_balloon',
          text: newStatus.text?.trim(),
          duration: CustomStatusDurationEnum.DONT_CLEAR,
        );

        if (widget.customStatusExpirySupported) {
          status.duration = newStatus.duration;
          status.expires_at = newExpiresAt;
        }
        var error = await updateCustomStatus(status);
        if (error != null) {
          // Handle error
          return;
        }

        updateLocalCustomStatus(widget.currentUser, status);
        setState(() {
          newStatus = status;
        });
      }
    } else if (storedStatus()?.emoji != null) {
      var error = await unsetCustomStatus();
      if (error == null) {
        updateLocalCustomStatus(widget.currentUser, null);
      }
    }
    if (isTablet) {
      // Navigate to tablet view
    } else {
      Navigator.of(context).pop();
    }
  }

  void openEmojiPicker() {
    // Navigation logic to open emoji picker
  }

  String calculateExpiryTime(
      CustomStatusDuration duration, UserModel currentUser, Moment expiresAt) {
    String userTimezone = getTimezone(currentUser.timezone);
    Moment currentTime = getCurrentMomentForTimezone(userTimezone);

    switch (duration) {
      case 'thirty_minutes':
        return currentTime.add(Duration(minutes: 30)).toIso8601String();
      case 'one_hour':
        return currentTime.add(Duration(hours: 1)).toIso8601String();
      case 'four_hours':
        return currentTime.add(Duration(hours: 4)).toIso8601String();
      case 'today':
        return currentTime.endOf('day').toIso8601String();
      case 'this_week':
        return currentTime.endOf('week').toIso8601String();
      case 'date_and_time':
        return expiresAt.toIso8601String();
      case CustomStatusDurationEnum.DONT_CLEAR:
      default:
        return '';
    }
  }

  void handleBackButton() {
    if (isTablet) {
      // Navigate to tablet view
    } else {
      Navigator.of(context).pop();
    }
  }
}
