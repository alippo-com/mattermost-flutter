import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/components/user_list_row.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:intl/intl.dart';

class UserList extends StatelessWidget {
  final List<UserProfile> profiles;
  final List<ChannelMembership>? channelMembers;
  final String currentUserId;
  final Function(UserProfile) handleSelectProfile;
  final Function? fetchMore;
  final bool loading;
  final bool manageMode;
  final bool showManageMode;
  final bool showNoResults;
  final Map<String, UserProfile> selectedIds;
  final String? term;
  final bool tutorialWatched;
  final bool includeUserMargin;
  final String? testID;

  UserList({
    required this.profiles,
    this.channelMembers,
    required this.currentUserId,
    required this.handleSelectProfile,
    this.fetchMore,
    required this.loading,
    this.manageMode = false,
    this.showManageMode = false,
    required this.showNoResults,
    required this.selectedIds,
    this.term,
    required this.tutorialWatched,
    required this.includeUserMargin,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final serverUrl = useServerUrl(context);
    final keyboardHeight = useKeyboardHeight(context);
    final style = getStyleFromTheme(theme);
    final noResultsStyle = [
      style.noResultContainer,
      {'paddingBottom': keyboardHeight},
    ];

    final data = useMemo(() {
      if (profiles.isEmpty && !loading) {
        return [];
      }

      if (term != null && term!.isNotEmpty) {
        return createProfiles(profiles, channelMembers);
      }

      return createProfilesSections(Intl.defaultLocale, profiles, channelMembers);
    });

    void openUserProfile(UserProfile profile) async {
      UserModel user;
      if (profile.createAt != null) {
        final res = await storeProfile(serverUrl, profile);
        if (res.user == null) {
          return;
        }
        user = res.user!;
      } else {
        user = profile as UserModel;
      }

      final screen = Screens.USER_PROFILE;
      final title = Intl.message('Profile', name: 'mobile.routes.user_profile');
      final closeButtonId = 'close-user-profile';
      final props = {
        'closeButtonId': closeButtonId,
        'userId': user.id,
        'location': Screens.USER_PROFILE,
      };

      SystemChannels.textInput.invokeMethod('TextInput.hide');
      openAsBottomSheet(context, screen, title, theme, closeButtonId, props);
    }

    Widget renderItem(BuildContext context, int index) {
      final item = data[index];
      final selected = selectedIds.containsKey(item.id);
      final canAdd = selectedIds.length < General.MAX_USERS_IN_GM;

      return UserListRow(
        key: ValueKey(item.id),
        highlight: index == 0,
        id: item.id,
        isChannelAdmin: item.schemeAdmin ?? false,
        isMyUser: currentUserId == item.id,
        manageMode: manageMode,
        onPress: () => handleSelectProfile(item),
        onLongPress: () => openUserProfile(item),
        selectable: manageMode || canAdd,
        disabled: !canAdd,
        selected: selected,
        showManageMode: showManageMode,
        testID: 'create_direct_message.user_list.user_item',
        tutorialWatched: tutorialWatched,
        user: item,
        includeMargin: includeUserMargin,
      );
    }

    Widget renderLoading() {
      if (!loading) {
        return Container();
      }
      return Loading(
        color: theme.buttonBg,
        containerStyle: style.loadingContainer,
        size: 'large',
      );
    }

    Widget renderNoResults() {
      if (!showNoResults || term == null || term!.isEmpty) {
        return Container();
      }
      return Container(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        alignment: Alignment.center,
        child: NoResultsWithTerm(term: term!),
      );
    }

    if (term != null && term!.isNotEmpty) {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: renderItem,
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: renderItem,
    );
  }

  List<UserProfileWithChannelAdmin> createProfiles(
      List<UserProfile> profiles, List<ChannelMembership>? members) {
    if (profiles.isEmpty) {
      return [];
    }

    final profileMap = <String, UserProfileWithChannelAdmin>{};
    for (final profile in profiles) {
      profileMap[profile.id] = UserProfileWithChannelAdmin(profile);
    }

    if (members != null) {
      for (final member in members) {
        final profileFound = profileMap[member.userId];
        if (profileFound != null) {
          profileFound.schemeAdmin = member.schemeAdmin;
        }
      }
    }

    return profileMap.values.toList();
  }

  List<SectionListData<UserProfileWithChannelAdmin>> createProfilesSections(
      String locale, List<UserProfile> profiles, List<ChannelMembership>? members) {
    if (profiles.isEmpty) {
      return [];
    }

    final sections = <String, List<UserProfileWithChannelAdmin>>{};

    if (members != null) {
      final membersDictionary = <String, ChannelMembership>{};
      for (final member in members) {
        membersDictionary[member.userId] = member;
      }
      for (final profile in profiles) {
        final member = membersDictionary[profile.id];
        if (member != null) {
          final sectionKey = sectionRoleKeyExtractor(member.schemeAdmin!);
          final section = sections[sectionKey] ?? [];
          section.add(UserProfileWithChannelAdmin(profile)..schemeAdmin = member.schemeAdmin);
          sections[sectionKey] = section;
        }
      }
    } else {
      for (final profile in profiles) {
        final sectionKey = sectionKeyExtractor(profile);
        final section = sections[sectionKey] ?? [];
        section.add(UserProfileWithChannelAdmin(profile));
        sections[sectionKey] = section;
      }
    }

    final results = <SectionListData<UserProfileWithChannelAdmin>>[];
    var index = 0;
    for (final section in sections.entries) {
      if (section.value.isNotEmpty) {
        results.add(SectionListData(
          id: section.key,
          data: section.value,
          first: index == 0,
        ));
        index++;
      }
    }

    return results;
  }

  String sectionKeyExtractor(UserProfile profile) {
    return profile.username[0].toUpperCase();
  }

  String sectionRoleKeyExtractor(bool schemeAdmin) {
    return schemeAdmin
        ? Intl.message('CHANNEL ADMINS', name: 'mobile.manage_members.section_title_admins')
        : Intl.message('MEMBERS', name: 'mobile.manage_members.section_title_members');
  }

  Map<String, TextStyle> getStyleFromTheme(ThemeData theme) {
    return {
      'list': TextStyle(
        backgroundColor: theme.centerChannelBg,
        flex: 1,
      ),
      'container': TextStyle(
        flexGrow: 1,
      ),
      'loadingContainer': TextStyle(
        flex: 1,
        justifyContent: MainAxisAlignment.center,
        alignItems: CrossAxisAlignment.center,
      ),
      'noResultContainer': TextStyle(
        flexGrow: 1,
        alignItems: CrossAxisAlignment.center,
        justifyContent: MainAxisAlignment.center,
      ),
      'sectionContainer': TextStyle(
        backgroundColor: changeOpacity(theme.centerChannelColor, 0.08),
        paddingLeft: 16,
        justifyContent: MainAxisAlignment.center,
        height: 24,
      ),
      'sectionWrapper': TextStyle(
        backgroundColor: theme.centerChannelBg,
      ),
      'sectionText': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 75, 'SemiBold'),
      ),
    };
  }
}

class UserProfileWithChannelAdmin extends UserProfile {
  bool? schemeAdmin;

  UserProfileWithChannelAdmin(UserProfile profile)
      : schemeAdmin = profile.schemeAdmin,
        super(
          id: profile.id,
          username: profile.username,
          firstName: profile.firstName,
          lastName: profile.lastName,
          createAt: profile.createAt,
          updateAt: profile.updateAt,
          deleteAt: profile.deleteAt,
          authService: profile.authService,
          email: profile.email,
          nickname: profile.nickname,
          position: profile.position,
          roles: profile.roles,
          notifyProps: profile.notifyProps,
          lastPasswordUpdate: profile.lastPasswordUpdate,
          lastPictureUpdate: profile.lastPictureUpdate,
          failedAttempts: profile.failedAttempts,
          locale: profile.locale,
          mfaActive: profile.mfaActive,
          lastActivityAt: profile.lastActivityAt,
        );
}
