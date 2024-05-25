// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/init/push_notifications.dart';

class UserUtils {
  static String displayUsername(UserProfile? user, {String? locale, String? teammateDisplayNameSetting, bool useFallbackUsername = true}) {
    String name = useFallbackUsername ? getLocalizedMessage(locale ?? DEFAULT_LOCALE, 'channel_loader.someone', 'Someone') : '';

    if (user != null) {
      if (teammateDisplayNameSetting == Preferences.DISPLAY_PREFER_NICKNAME) {
        name = user.nickname ?? getFullName(user);
      } else if (teammateDisplayNameSetting == Preferences.DISPLAY_PREFER_FULL_NAME) {
        name = getFullName(user);
      } else {
        name = user.username;
      }

      if (name.isEmpty || name.trim().isEmpty) {
        name = user.username;
      }
    }

    return name;
  }

  static String displayGroupMessageName(List<UserProfile> users, {String? locale, String? teammateDisplayNameSetting, String? excludeUserId}) {
    List<String> names = [];
    int sortUsernames(String a, String b) {
      return a.compareTo(b);
    }

    users.forEach((user) {
      if (user.id != excludeUserId) {
        names.add(displayUsername(user, locale: locale, teammateDisplayNameSetting: teammateDisplayNameSetting, useFallbackUsername: false) ?? user.username);
      }
    });

    names.sort(sortUsernames);
    return names.join(', ').trim();
  }

  static String getFullName(UserProfile user) {
    String firstName = user.firstName ?? '';
    String lastName = user.lastName ?? '';

    if (firstName.isNotEmpty && lastName isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName isNotEmpty) {
      return firstName;
    } else if (lastName isNotEmpty) {
      return lastName;
    }

    return '';
  }

  static String getUserIdFromChannelName(String knownUserId, String channelName) {
    List<String> ids = channelName.split('__');
    if (ids[0] == knownUserId) {
      return ids[1];
    }
    return ids[0];
  }

  static bool isRoleInRoles(String roles, String role) {
    List<String> rolesArray = roles.split(' ');
    return rolesArray.contains(role);
  }

  static bool isGuest(String roles) {
    return isRoleInRoles(roles, Permissions.SYSTEM_GUEST_ROLE);
  }

  static bool isSystemAdmin(String roles) {
    return isRoleInRoles(roles, Permissions.SYSTEM_ADMIN_ROLE);
  }

  static bool isChannelAdmin(String roles) {
    return isRoleInRoles(roles, Permissions.CHANNEL_ADMIN_ROLE);
  }

  static Map<String, UserProfile> getUsersByUsername(List<UserModel> users) {
    Map<String, UserProfile> usersByUsername = {};

    for (UserModel user in users) {
      usersByUsername[user.username] = user;
    }

    return usersByUsername;
  }

  static Map<String, dynamic> getUserTimezoneProps(UserModel? currentUser) {
    if (currentUser?.timezone != null) {
      return {
        ...currentUser?.timezone,
        'useAutomaticTimezone': currentUser?.timezone?.useAutomaticTimezone == 'true',
      };
    }

    return {
      'useAutomaticTimezone': true,
      'automaticTimezone': '',
      'manualTimezone': '',
    };
  }

  static String getUserTimezone(UserModel? user) {
    return getTimezone(user?.timezone);
  }

  static String getTimezone(UserTimezone? timezone) {
    if (timezone == null) {
      return '';
    }

    bool useAutomatic = timezone.useAutomaticTimezone;
    if (timezone.useAutomaticTimezone is String) {
      useAutomatic = timezone.useAutomaticTimezone == 'true';
    }

    if (useAutomatic) {
      return timezone.automaticTimezone;
    }

    return timezone.manualTimezone;
  }

  static String getTimezoneRegion(String timezone) {
    if (timezone.isNotEmpty) {
      List<String> split = timezone.split('/');
      if (split.length > 1) {
        return split.last.replaceAll('_', ' ');
      }
    }

    return timezone;
  }

  static UserCustomStatus? getUserCustomStatus(UserModel? user) {
    try {
      if (user?.props?.customStatus is String) {
        return UserCustomStatus.fromJson(jsonDecode(user.props.customStatus));
      }

      return user?.props?.customStatus;
    } catch (e) {
      return null;
    }
  }

  static bool isCustomStatusExpired(UserModel? user) {
    if (user == null) {
      return true;
    }

    UserCustomStatus? customStatus = getUserCustomStatus(user);

    if (customStatus == null) {
      return true;
    }

    if (customStatus.duration == CustomStatusDurationEnum.DONT_CLEAR || customStatus.duration == null) {
      return false;
    }

    DateTime expiryTime = DateTime.parse(customStatus.expiresAt!);
    String timezone = getUserTimezone(user);
    DateTime currentTime = timezone.isNotEmpty ? DateTime.now().toUtc() : DateTime.now();
    return currentTime.isAfter(expiryTime);
  }

  static void confirmOutOfOfficeDisabled(Intl intl, String status, void Function(String) updateStatus) {
    String userStatusId = 'modal.manual_status.auto_responder.message_' + status;
    String translatedStatus;
    if (status == 'dnd') {
      translatedStatus = intl.formatMessage('mobile.set_status.dnd', defaultMessage: 'Do Not Disturb');
    } else {
      translatedStatus = intl.formatMessage('mobile.set_status.\$status', defaultMessage: toTitleCase(status));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(intl.formatMessage('mobile.reset_status.title_ooo', defaultMessage: 'Disable "Out Of Office"?')),
          content: Text(intl.formatMessage('modal.manual_status.auto_responder.message_', defaultMessage: 'Would you like to switch your status to "{status}" and disable Automatic Replies?', args: {'status': translatedStatus})),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(intl.formatMessage('mobile.reset_status.alert_cancel', defaultMessage: 'Cancel')),
            ),
            TextButton(
              onPressed: () {
                updateStatus(status);
              },
              child: Text(intl.formatMessage('mobile.reset_status.alert_ok', defaultMessage: 'OK')),
            ),
          ],
        );
      },
    );
  }

  static bool isBot(UserProfile user) {
    return user.isBot ?? user.is_bot;
  }

  static bool isShared(UserProfile user) {
    return user.remoteId ?? user.remote_id;
  }

  static bool isDeactivated(UserProfile user) {
    return user.deleteAt ?? user.delete_at;
  }

  static List<UserProfile> removeUserFromList(String userId, List<UserProfile> originalList) {
    List<UserProfile> list = List.from(originalList);
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].id == userId) {
        list.removeAt(i);
        return list;
      }
    }

    return list;
  }

  static List<String> getSuggestionsSplitBy(String term, String splitStr) {
    List<String> splitTerm = term.split(splitStr);
    List<String> initialSuggestions = splitTerm.map((st, i) => splitTerm.sublist(i).join(splitStr)).toList();
    List<String> suggestions = [];

    if (splitStr == ' ') {
      suggestions = initialSuggestions;
    } else {
      suggestions = initialSuggestions.fold<List<String>>([], (acc, val) {
        if (acc.isEmpty) {
          acc.add(val);
        } else {
          acc.addAll([splitStr + val, val]);
        }
        return acc;
      });
    }
    return suggestions;
  }

  static List<String> getSuggestionsSplitByMultiple(String term, List<String> splitStrs) {
    Set<String> suggestions = splitStrs.fold<Set<String>>({}, (acc, val) {
      getSuggestionsSplitBy(term, val).forEach((suggestion) => acc.add(suggestion));
      return acc;
    });

    return suggestions.toList();
  }

  static List<UserProfile> filterProfilesMatchingTerm(List<UserProfile> users, String term) {
    String lowercasedTerm = term.toLowerCase();
    String trimmedTerm = lowercasedTerm;
    if (trimmedTerm.startsWith('@')) {
      trimmedTerm = trimmedTerm.substring(1);
    }

    return users.where((user) {
      if (user == null) {
        return false;
      }

      List<String> profileSuggestions = [];
      List<String> usernameSuggestions = getSuggestionsSplitByMultiple(user.username?.toLowerCase() ?? '', General.AUTOCOMPLETE_SPLIT_CHARACTERS);
      profileSuggestions.addAll(usernameSuggestions);
      String first = user.firstName?.toLowerCase() ?? '';
      String last = user.lastName?.toLowerCase() ?? '';
      String full = '\$first \$last';
      profileSuggestions.addAll([first, last, full]);
      profileSuggestions.add(user.nickname?.toLowerCase() ?? '');
      String email = user.email?.toLowerCase() ?? '';
      profileSuggestions.add(email);
      profileSuggestions.add(user.nickname?.toLowerCase() ?? '');

      List<String> split = email.split('@');
      if (split.length > 1) {
        profileSuggestions.add(split[1]);
      }

      return profileSuggestions.where((suggestion) => suggestion.isNotEmpty).any((suggestion) => suggestion.contains(trimmedTerm));
    }).toList();
  }

  static UserNotifyProps getNotificationProps(UserModel? user) {
    if (user?.notifyProps != null) {
      return user!.notifyProps;
    }

    return UserNotifyProps(
      channel: 'true',
      comments: 'any',
      desktop: 'all',
      desktopSound: 'true',
      email: 'true',
      firstName: user?.firstName == null ? 'false' : 'true',
      markUnread: 'all',
      mentionKeys: user != null ? '\${user.username},@\${user.username}' : '',
      highlightKeys: '',
      push: 'mention',
      pushStatus: 'online',
      pushThreads: 'all',
      emailThreads: 'all',
    );
  }

  static int getEmailInterval(bool enableEmailNotification, bool enableEmailBatching, int emailIntervalPreference) {
    const int INTERVAL_NEVER = Preferences.INTERVAL_NEVER;
    const int INTERVAL_IMMEDIATE = Preferences.INTERVAL_IMMEDIATE;
    const int INTERVAL_FIFTEEN_MINUTES = Preferences.INTERVAL_FIFTEEN_MINUTES;
    const int INTERVAL_HOUR = Preferences.INTERVAL_HOUR;

    List<int> validValuesWithEmailBatching = [INTERVAL_IMMEDIATE, INTERVAL_NEVER, INTERVAL_FIFTEEN_MINUTES, INTERVAL_HOUR];
    List<int> validValuesWithoutEmailBatching = [INTERVAL_IMMEDIATE, INTERVAL_NEVER];

    if (!enableEmailNotification) {
      return INTERVAL_NEVER;
    } else if (enableEmailBatching && !validValuesWithEmailBatching.contains(emailIntervalPreference)) {
      return INTERVAL_FIFTEEN_MINUTES;
    } else if (!enableEmailBatching && !validValuesWithoutEmailBatching.contains(emailIntervalPreference)) {
      return INTERVAL_IMMEDIATE;
    } else if (enableEmailNotification and emailIntervalPreference == INTERVAL_NEVER) {
      return INTERVAL_IMMEDIATE;
    }

    return emailIntervalPreference;
  }

  static Map<String, String> getEmailIntervalTexts(String interval) {
    Map<String, Map<String, String>> intervalTexts = {
      Preferences.INTERVAL_FIFTEEN_MINUTES: {'id': 'notification_settings.email.fifteenMinutes', 'defaultMessage': 'Every 15 minutes'},
      Preferences.INTERVAL_HOUR: {'id': 'notification_settings.email.everyHour', 'defaultMessage': 'Every hour'},
      Preferences.INTERVAL_IMMEDIATE: {'id': 'notification_settings.email.immediately', 'defaultMessage': 'Immediately'},
      Preferences.INTERVAL_NEVER: {'id': 'notification_settings.email.never', 'defaultMessage': 'Never'},
    };
    return intervalTexts[interval]!;
  }
}
