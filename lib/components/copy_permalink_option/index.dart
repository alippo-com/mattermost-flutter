
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/base_option.dart';
import 'package:mattermost_flutter/constants/snack_bar.dart'; 
import 'package:mattermost_flutter/context/server.dart'; 
import 'package:mattermost_flutter/i18n.dart'; 
import 'package:mattermost_flutter/screens/navigation.dart'; 
import 'package:mattermost_flutter/utils/snack_bar.dart'; 

class CopyPermalinkOption extends StatelessWidget {
  final String bottomSheetId;
  final String sourceScreen;
  final PostModel post;
  final String teamName;

  CopyPermalinkOption({
    required this.bottomSheetId,
    required this.sourceScreen,
    required this.post,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = context.watch<ServerUrlProvider>().serverUrl;

    void handleCopyLink() async {
      final permalink = '$serverUrl/$teamName/pl/${post.id}';
      Clipboard.setData(ClipboardData(text: permalink));
      await dismissBottomSheet(bottomSheetId);
      showSnackBar(context, SnackBarType.linkCopied, sourceScreen);
    }

    return BaseOption(
      i18nId: t('get_post_link_modal.title'),
      defaultMessage: 'Copy Link',
      onPress: handleCopyLink,
      iconName: Icons.link, 
      testID: 'post_options.copy_permalink.option',
    );
  }
}
