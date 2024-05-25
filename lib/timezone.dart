// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_native_timezone/flutter_native_timezone.dart';

String getDeviceTimezone() {
  return FlutterNativeTimezone.getLocalTimezone();
}