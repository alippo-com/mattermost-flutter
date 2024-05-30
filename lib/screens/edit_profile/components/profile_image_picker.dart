
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/local/user.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/components/panel_item.dart';
import 'package:mattermost_flutter/utils/file_picker.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/user_model.dart';

// Define the ProfileImagePicker widget
class ProfileImagePicker extends StatelessWidget {
  final Function onRemoveProfileImage;
  final Function uploadFiles;
  final UserModel user;

  ProfileImagePicker({
    required this.onRemoveProfileImage,
    required this.uploadFiles,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final bottom = MediaQuery.of(context).padding.bottom;
    final serverUrl = useServerUrl();
    final pictureUtils = useMemo(() => PickerUtil(intl, uploadFiles), [uploadFiles, intl]);
    final canRemovePicture = hasPictureUrl(user, serverUrl);
    final styles = getStyleSheet(theme);
    final isTablet = useIsTablet();

    void showFileAttachmentOptions() {
      final renderContent = () {
        return Column(
          children: [
            if (!isTablet)
              FormattedText(
                id: 'user.edit_profile.profile_photo.change_photo',
                defaultMessage: 'Change profile photo',
                style: styles.title,
              ),
            PanelItem(
              pickerAction: 'takePhoto',
              pictureUtils: pictureUtils,
            ),
            PanelItem(
              pickerAction: 'browsePhotoLibrary',
              pictureUtils: pictureUtils,
            ),
            PanelItem(
              pickerAction: 'browseFiles',
              pictureUtils: pictureUtils,
            ),
            if (canRemovePicture)
              PanelItem(
                pickerAction: 'removeProfilePicture',
                onRemoveProfileImage: onRemoveProfileImage,
              ),
          ],
        );
      };

      final snapPoint = bottomSheetSnapPoint(4, ITEM_HEIGHT, bottom) + TITLE_HEIGHT;

      bottomSheet(
        context: context,
        closeButtonId: 'close-edit-profile',
        renderContent: renderContent,
        snapPoints: [1, snapPoint],
        title: 'Change profile photo',
        theme: theme,
      );
    }

    return GestureDetector(
      onTap: showFileAttachmentOptions,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.centerChannelBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.centerChannelBg),
        ),
        child: Center(
          child: CompassIcon(
            name: 'camera-outline',
            size: 24,
            color: changeOpacity(theme.centerChannelColor, 0.6),
          ),
        ),
      ),
    );
  }

  bool hasPictureUrl(UserModel user, String serverUrl) {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final profileImageUrl = client.getProfilePictureUrl(user.id, user.lastPictureUpdate);
      return profileImageUrl.contains('image?_');
    } catch (e) {
      return false;
    }
  }

  TextStyle getStyleSheet(Theme theme) {
    return TextStyle(
      fontFamily: 'Heading',
      fontWeight: FontWeight.w600,
      color: theme.centerChannelColor,
      fontSize: 16,
    );
  }
}
