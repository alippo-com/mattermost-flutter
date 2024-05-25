// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:path_provider/path_provider.dart';
import 'package:mattermost_flutter/utils/helpers.dart';

class DeviceConstants {
  static Future<String> get documentsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/Documents';
  }

  static final bool isTablet = isTablet();
  static const String pushNotifyAndroidReactNative = 'android_rn';
  static const String pushNotifyAppleReactNative = 'apple_rn';
}
