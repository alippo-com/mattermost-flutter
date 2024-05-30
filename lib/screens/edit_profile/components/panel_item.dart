import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/utils/file_picker.dart';
import 'package:mattermost_flutter/utils/intl.dart';

class PanelItem extends StatelessWidget {
  final String pickerAction;
  final PickerUtil? pictureUtils;
  final Future<void> Function()? onRemoveProfileImage;

  PanelItem({
    required this.pickerAction,
    this.pictureUtils,
    this.onRemoveProfileImage,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(context);

    final panelTypes = {
      'takePhoto': {
        'icon': Icons.camera_alt_outlined,
        'onPress': () async {
          await dismissBottomSheet(context);
          pictureUtils?.attachFileFromCamera();
        },
        'testID': 'attachment.takePhoto',
        'text': intl.formatMessage('mobile.file_upload.camera_photo', defaultMessage: 'Take Photo'),
      },
      'browsePhotoLibrary': {
        'icon': Icons.photo_library_outlined,
        'onPress': () async {
          await dismissBottomSheet(context);
          pictureUtils?.attachFileFromPhotoGallery();
        },
        'testID': 'attachment.browsePhotoLibrary',
        'text': intl.formatMessage('mobile.file_upload.library', defaultMessage: 'Photo Library'),
      },
      'browseFiles': {
        'icon': Icons.attach_file_outlined,
        'onPress': () async {
          await dismissBottomSheet(context);
          pictureUtils?.attachFileFromFiles(DocumentPicker.types.images);
        },
        'testID': 'attachment.browseFiles',
        'text': intl.formatMessage('mobile.file_upload.browse', defaultMessage: 'Browse Files'),
      },
      'removeProfilePicture': {
        'icon': Icons.delete_outline,
        'onPress': () async {
          await dismissBottomSheet(context);
          if (onRemoveProfileImage != null) {
            return onRemoveProfileImage!();
          }
        },
        'testID': 'attachment.removeImage',
        'text': intl.formatMessage('mobile.edit_profile.remove_profile_photo', defaultMessage: 'Remove Photo'),
      },
    };

    final item = panelTypes[pickerAction];

    return SlideUpPanelItem(
      leftIcon: item['icon'],
      onPress: item['onPress'],
      testID: item['testID'],
      text: item['text'],
      destructive: pickerAction == 'removeProfilePicture',
    );
  }
}
