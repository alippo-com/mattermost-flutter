import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/models/user_model.dart';
import 'package:mattermost_flutter/screens/edit_profile/components/disabled_fields.dart';
import 'package:mattermost_flutter/screens/edit_profile/components/email_field.dart';
import 'package:mattermost_flutter/screens/edit_profile/components/field.dart';
import 'package:mattermost_flutter/theme/theme_provider.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ProfileForm extends StatefulWidget {
  final bool canSave;
  final UserModel currentUser;
  final bool? isTablet;
  final bool lockedFirstName;
  final bool lockedLastName;
  final bool lockedNickname;
  final bool lockedPosition;
  final Function(String, String) onUpdateField;
  final dynamic error;
  final Map<String, dynamic> userInfo;
  final VoidCallback submitUser;

  const ProfileForm({
    required this.canSave,
    required this.currentUser,
    this.isTablet,
    required this.lockedFirstName,
    required this.lockedLastName,
    required this.lockedNickname,
    required this.lockedPosition,
    required this.onUpdateField,
    this.error,
    required this.userInfo,
    required this.submitUser,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late ThemeProvider _themeProvider;
  late NetworkManager _networkManager;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _nicknameController;
  late TextEditingController _positionController;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _networkManager = NetworkManager();

    _firstNameController = TextEditingController(text: widget.userInfo['firstName']);
    _lastNameController = TextEditingController(text: widget.userInfo['lastName']);
    _usernameController = TextEditingController(text: widget.userInfo['username']);
    _emailController = TextEditingController(text: widget.userInfo['email']);
    _nicknameController = TextEditingController(text: widget.userInfo['nickname']);
    _positionController = TextEditingController(text: widget.userInfo['position']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _onFocusNextField(String fieldKey) {
    final userProfileFields = {
      'firstName': _firstNameController,
      'lastName': _lastNameController,
      'username': _usernameController,
      'email': _emailController,
      'nickname': _nicknameController,
      'position': _positionController,
    };

    final fields = userProfileFields.keys.toList();
    final curIndex = fields.indexOf(fieldKey);
    final searchIndex = curIndex + 1;

    if (curIndex == -1 || searchIndex > fields.length) {
      return;
    }

    final remainingFields = fields.sublist(searchIndex);

    final nextFieldIndex = remainingFields.indexWhere((f) => !_isFieldDisabled(f));

    if (nextFieldIndex == -1) {
      if (widget.canSave) {
        // performs form submission
        FocusScope.of(context).unfocus();
        widget.submitUser();
      }
    } else {
      final fieldName = remainingFields[nextFieldIndex];
      userProfileFields[fieldName]?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeProvider.theme;

    return Column(
      children: [
        if (_hasDisabledFields())
          DisabledFields(isTablet: widget.isTablet),
        Field(
          controller: _firstNameController,
          label: 'First Name',
          isDisabled: _isFieldDisabled('firstName'),
          onTextChange: (value) => widget.onUpdateField('firstName', value),
        ),
        SizedBox(height: 15),
        Field(
          controller: _lastNameController,
          label: 'Last Name',
          isDisabled: _isFieldDisabled('lastName'),
          onTextChange: (value) => widget.onUpdateField('lastName', value),
        ),
        SizedBox(height: 15),
        Field(
          controller: _usernameController,
          label: 'Username',
          isDisabled: _isFieldDisabled('username'),
          onTextChange: (value) => widget.onUpdateField('username', value),
          error: widget.error != null ? widget.error.toString() : null,
        ),
        SizedBox(height: 15),
        if (widget.userInfo['email'] != null)
          EmailField(
            controller: _emailController,
            label: 'Email',
            isDisabled: _isFieldDisabled('email'),
            onTextChange: (value) => widget.onUpdateField('email', value),
          ),
        SizedBox(height: 15),
        Field(
          controller: _nicknameController,
          label: 'Nickname',
          isDisabled: _isFieldDisabled('nickname'),
          onTextChange: (value) => widget.onUpdateField('nickname', value),
        ),
        SizedBox(height: 15),
        Field(
          controller: _positionController,
          label: 'Position',
          isDisabled: _isFieldDisabled('position'),
          onTextChange: (value) => widget.onUpdateField('position', value),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  bool _isFieldDisabled(String fieldKey) {
    final service = widget.currentUser.authService;
    switch (fieldKey) {
      case 'firstName':
        return (service.contains('ldap') || service.contains('saml')) && widget.lockedFirstName;
      case 'lastName':
        return (service.contains('ldap') || service.contains('saml')) && widget.lockedLastName;
      case 'username':
        return service.isNotEmpty;
      case 'email':
        return true;
      case 'nickname':
        return (service.contains('ldap') || service.contains('saml')) && widget.lockedNickname;
      case 'position':
        return (service.contains('ldap') || service.contains('saml')) && widget.lockedPosition;
      default:
        return false;
    }
  }

  bool _hasDisabledFields() {
    return ['firstName', 'lastName', 'username', 'email', 'nickname', 'position']
        .any((field) => _isFieldDisabled(field));
  }
}
