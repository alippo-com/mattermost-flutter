
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/types/user_model.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/components/selected_chip.dart';

class SelectedUser extends StatelessWidget {
  final String teammateNameDisplay;
  final UserProfile user;
  final Function(String) onRemove;
  final String? testID;

  const SelectedUser({
    Key? key,
    required this.teammateNameDisplay,
    required this.user,
    required this.onRemove,
    this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userItemTestID = '${testID ?? ''}.${user.id}';

    return SelectedChip(
      id: user.id,
      text: displayUsername(user, teammateNameDisplay),
      extra: ProfilePicture(
        author: user,
        size: 20,
        iconSize: 20,
        testID: '$userItemTestID.profile_picture',
      ),
      onRemove: onRemove,
      testID: userItemTestID,
    );
  }
}
