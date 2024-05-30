// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/types/screens/edit_profile/components/field.dart';
import 'package:flutter/widgets.dart';

class UserInfo {
  String email;
  String firstName;
  String lastName;
  String nickname;
  String position;
  String username;
  Map<String, dynamic> additionalProps;

  UserInfo({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.position,
    required this.username,
    this.additionalProps = const {},
  });
}

class EditProfileProps {
  String componentId;
  UserModel? currentUser;
  bool? isModal;
  bool? isTablet;
  bool lockedFirstName;
  bool lockedLastName;
  bool lockedNickname;
  bool lockedPosition;
  bool lockedPicture;

  EditProfileProps({
    required this.componentId,
    this.currentUser,
    this.isModal,
    this.isTablet,
    required this.lockedFirstName,
    required this.lockedLastName,
    required this.lockedNickname,
    required this.lockedPosition,
    required this.lockedPicture,
  });
}

class NewProfileImage {
  String? localPath;
  bool? isRemoved;

  NewProfileImage({this.localPath, this.isRemoved});
}

class FieldSequence {
  RefObject<FloatingTextInputRef> ref;
  bool isDisabled;

  FieldSequence({required this.ref, required this.isDisabled});
}

class FieldConfig {
  bool blurOnSubmit;
  bool enablesReturnKeyAutomatically;
  Function? onFocusNextField;
  Function? onTextChange;
  TextInputType returnKeyType;

  FieldConfig({
    required this.blurOnSubmit,
    required this.enablesReturnKeyAutomatically,
    this.onFocusNextField,
    this.onTextChange,
    required this.returnKeyType,
  });
}
