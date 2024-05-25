
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/local/user.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/tablet_title.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/components/profile_form.dart';
import 'package:mattermost_flutter/components/profile_error.dart';
import 'package:mattermost_flutter/components/updating.dart';
import 'package:mattermost_flutter/components/user_profile_picture.dart';
import 'package:mattermost_flutter/types/user_model.dart';

// Define the EditProfile widget
class EditProfile extends HookWidget {
  final String componentId;
  final UserModel currentUser;
  final bool isModal;
  final bool isTablet;
  final bool lockedFirstName;
  final bool lockedLastName;
  final bool lockedNickname;
  final bool lockedPosition;
  final bool lockedPicture;

  EditProfile({
    required this.componentId,
    required this.currentUser,
    required this.isModal,
    required this.isTablet,
    required this.lockedFirstName,
    required this.lockedLastName,
    required this.lockedNickname,
    required this.lockedPosition,
    required this.lockedPicture,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final theme = useTheme();
    final changedProfilePicture = useRef<NewProfileImage?>(null);
    final scrollViewRef = useRef<ScrollController?>(null);
    final hasUpdateUserInfo = useRef<bool>(false);
    final userInfo = useState<UserInfo>({
      'email': currentUser.email ?? '',
      'firstName': currentUser.firstName ?? '',
      'lastName': currentUser.lastName ?? '',
      'nickname': currentUser.nickname ?? '',
      'position': currentUser.position ?? '',
      'username': currentUser.username ?? '',
    });
    final canSave = useState<bool>(false);
    final error = useState<Exception?>(null);
    final usernameError = useState<Exception?>(null);
    final updating = useState<bool>(false);

    final buttonText = intl.formatMessage(
      id: 'mobile.account.settings.save',
      defaultMessage: 'Save',
    );

    final rightButton = useMemo(() {
      return isTablet
          ? null
          : {
              'id': 'update-profile',
              'enabled': false,
              'showAsAction': 'always',
              'testID': 'edit_profile.save.button',
              'color': theme.sidebarHeaderTextColor,
              'text': buttonText,
            };
    }, [isTablet, theme.sidebarHeaderTextColor]);

    final leftButton = useMemo(() {
      return isTablet
          ? null
          : {
              'id': 'close-edit-profile',
              'icon': CompassIcon.getImageSourceSync(
                  'close', 24, theme.centerChannelColor),
              'testID': 'close.edit_profile.button',
            };
    }, [isTablet, theme.centerChannelColor]);

    useEffect(() {
      if (!isTablet) {
        setButtons(componentId, {
          'rightButtons': [rightButton],
          'leftButtons': [leftButton],
        });
      }
    }, []);

    void close() {
      if (isModal) {
        dismissModal(componentId: componentId);
      } else if (isTablet) {
        DeviceEventEmitter.emit(Events.ACCOUNT_SELECT_TABLET_VIEW, '');
      } else {
        popTopScreen(componentId);
      }
    }

    void enableSaveButton(bool value) {
      if (!isTablet) {
        final buttons = {
          'rightButtons': [
            {
              ...rightButton,
              'enabled': value,
            }
          ],
        };
        setButtons(componentId, buttons);
      }
      canSave.value = value;
    }

    Future<void> submitUser() async {
      if (currentUser == null) {
        return;
      }
      enableSaveButton(false);
      error.value = null;
      updating.value = true;
      try {
        final newUserInfo = {
          'email': userInfo.value['email'].trim(),
          'firstName': userInfo.value['firstName'].trim(),
          'lastName': userInfo.value['lastName'].trim(),
          'nickname': userInfo.value['nickname'].trim(),
          'position': userInfo.value['position'].trim(),
          'username': userInfo.value['username'].trim(),
        };

        final localPath = changedProfilePicture.current?.localPath;
        final profileImageRemoved = changedProfilePicture.current?.isRemoved;

        if (localPath != null) {
          final now = DateTime.now();
          final uploadError = await uploadUserProfileImage(serverUrl, localPath);
          if (uploadError != null) {
            resetScreen(uploadError);
            return;
          }
          updateLocalUser(serverUrl, {'last_picture_update': now});
        } else if (profileImageRemoved) {
          await setDefaultProfileImage(serverUrl, currentUser.id);
        }

        if (hasUpdateUserInfo.current) {
          final reqError = await updateMe(serverUrl, newUserInfo);
          if (reqError != null) {
            resetScreenForProfileError(reqError);
            return;
          }
        }

        close();
      } catch (e) {
        resetScreen(e);
      }
    }

    useAndroidHardwareBackHandler(componentId, close);
    useNavButtonPressed('update-profile', componentId, submitUser);
    useNavButtonPressed('close-edit-profile', componentId, close);

    void onUpdateProfilePicture(NewProfileImage newProfileImage) {
      changedProfilePicture.current = newProfileImage;
      enableSaveButton(true);
    }

    void onUpdateField(String fieldKey, String name) {
      final update = {...userInfo.value};
      update[fieldKey] = name;
      userInfo.value = update;

      final currentValue = currentUser[fieldKey];
      final didChange = currentValue != name;
      hasUpdateUserInfo.current = didChange;
      enableSaveButton(didChange);
    }

    void resetScreenForProfileError(Exception resetError) {
      usernameError.value = resetError;
      FocusScope.of(context).unfocus();
      updating.value = false;
      enableSaveButton(true);
    }

    void resetScreen(Exception resetError) {
      error.value = resetError;
      FocusScope.of(context).unfocus();
      updating.value = false;
      enableSaveButton(true);
      scrollViewRef.current?.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }

    final content = currentUser != null
        ? ScrollView(
            controller: scrollViewRef.current,
            child: Column(
              children: [
                if (updating.value) Updating(),
                if (error.value != null) ProfileError(error: error.value),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: UserProfilePicture(
                    currentUser: currentUser,
                    lockedPicture: lockedPicture,
                    onUpdateProfilePicture: onUpdateProfilePicture,
                  ),
                ),
                ProfileForm(
                  canSave: canSave.value,
                  currentUser: currentUser,
                  isTablet: isTablet,
                  lockedFirstName: lockedFirstName,
                  lockedLastName: lockedLastName,
                  lockedNickname: lockedNickname,
                  lockedPosition: lockedPosition,
                  error: usernameError.value,
                  onUpdateField: onUpdateField,
                  userInfo: userInfo.value,
                  submitUser: submitUser,
                ),
              ],
            ),
          )
        : null;

    return Scaffold(
      appBar: isTablet
          ? null
          : AppBar(
              title: Text(
                intl.formatMessage(
                  id: 'mobile.screen.your_profile',
                  defaultMessage: 'Your Profile',
                ),
              ),
              actions: [
                if (canSave.value)
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: submitUser,
                  ),
              ],
            ),
      body: SafeArea(
        child: content,
      ),
    );
  }
}
