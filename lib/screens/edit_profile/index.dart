import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/with_database.dart';
import 'package:mattermost_flutter/database/with_observables.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types.dart';

import 'edit_profile.dart';

class Enhanced {
  final WithDatabaseArgs args;

  Enhanced(this.args);

  Map<String, dynamic> call() {
    final ldapFirstNameAttributeSet = observeConfigBooleanValue(args.database, 'LdapFirstNameAttributeSet');
    final ldapLastNameAttributeSet = observeConfigBooleanValue(args.database, 'LdapLastNameAttributeSet');
    final ldapNicknameAttributeSet = observeConfigBooleanValue(args.database, 'LdapNicknameAttributeSet');
    final ldapPositionAttributeSet = observeConfigBooleanValue(args.database, 'LdapPositionAttributeSet');

    final samlFirstNameAttributeSet = observeConfigBooleanValue(args.database, 'SamlFirstNameAttributeSet');
    final samlLastNameAttributeSet = observeConfigBooleanValue(args.database, 'SamlLastNameAttributeSet');
    final samlNicknameAttributeSet = observeConfigBooleanValue(args.database, 'SamlNicknameAttributeSet');
    final samlPositionAttributeSet = observeConfigBooleanValue(args.database, 'SamlPositionAttributeSet');

    return {
      'currentUser': observeCurrentUser(args.database),
      'lockedFirstName': combineLatest([ldapFirstNameAttributeSet, samlFirstNameAttributeSet]).map((values) => values.any((v) => v)),
      'lockedLastName': combineLatest([ldapLastNameAttributeSet, samlLastNameAttributeSet]).map((values) => values.any((v) => v)),
      'lockedNickname': combineLatest([ldapNicknameAttributeSet, samlNicknameAttributeSet]).map((values) => values.any((v) => v)),
      'lockedPosition': combineLatest([ldapPositionAttributeSet, samlPositionAttributeSet]).map((values) => values.any((v) => v)),
      'lockedPicture': observeConfigBooleanValue(args.database, 'LdapPictureAttributeSet'),
    };
  }
}

Enhanced enhanced(WithDatabaseArgs args) {
  return Enhanced(args)();
}

void main() {
  final args = WithDatabaseArgs(database: Database());
  final enhancedProfile = enhanced(args);
  runApp(EditProfile(enhancedProfile));
}
