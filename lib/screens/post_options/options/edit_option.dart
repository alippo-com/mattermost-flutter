
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Equivalent for context
import 'package:mattermost_flutter/components/common_post_options.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types.dart'; // Equivalent for @typing directive

class EditOption extends StatelessWidget {
  final String bottomSheetId;
  final PostModel post;
  final bool canDelete;

  EditOption({
    required this.bottomSheetId,
    required this.post,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final theme = Provider.of<Theme>(context);

    void onPress() async {
      await dismissBottomSheet(bottomSheetId);

      final String title = intl.formatMessage('mobile.edit_post.title', defaultMessage: 'Editing Message');
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);
      final String closeButtonId = 'close-edit-post';
      final passProps = {'post': post, 'closeButtonId': closeButtonId, 'canDelete': canDelete};
      final options = {
        'topBar': {
          'leftButtons': [
            {
              'id': closeButtonId,
              'testID': 'close.edit_post.button',
              'icon': closeButton,
            }
          ],
        },
      };
      showModal(Screens.EDIT_POST, title, passProps, options);
    }

    return BaseOption(
      i18nId: t('post_info.edit'),
      defaultMessage: 'Edit',
      onPress: onPress,
      iconName: 'pencil-outline',
      testID: 'post_options.edit_post.option',
    );
  }
}
