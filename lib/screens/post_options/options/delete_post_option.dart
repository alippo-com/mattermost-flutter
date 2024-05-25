import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/common_post_options/base_option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class DeletePostOption extends StatefulWidget {
  final AvailableScreens bottomSheetId;
  final PostModel post;
  final PostModel? combinedPost;

  const DeletePostOption({
    required this.bottomSheetId,
    this.combinedPost,
    required this.post,
  });

  @override
  _DeletePostOptionState createState() => _DeletePostOptionState();
}

class _DeletePostOptionState extends State<DeletePostOption> {
  late String serverUrl;
  late BuildContext intl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    serverUrl = useServerUrl();
    intl = context;
  }

  void onPress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(intl.formatMessage(id: 'mobile.post.delete_title', defaultMessage: 'Delete Post')),
          content: Text(
            intl.formatMessage(id: 'mobile.post.delete_question', defaultMessage: 'Are you sure you want to delete this post?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel')),
              style: TextButton.styleFrom(primary: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(intl.formatMessage(id: 'post_info.del', defaultMessage: 'Delete')),
              style: TextButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                await dismissBottomSheet(widget.bottomSheetId);
                deletePost(serverUrl, widget.combinedPost ?? widget.post);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseOption(
      i18nId: t('post_info.del'),
      defaultMessage: 'Delete',
      iconName: 'trash-can-outline',
      onPress: onPress,
      testID: 'post_options.delete_post.option',
      isDestructive: true,
    );
  }
}
