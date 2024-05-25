// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> hasBluetoothPermission() async {
  Permission bluetoothPermission;

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    bluetoothPermission = Permission.bluetooth;
  } else {
    bluetoothPermission = Permission.bluetoothConnect;
  }

  var status = await bluetoothPermission.status;

  if (status.isDenied || status.isRestricted) {
    var result = await bluetoothPermission.request();
    return result.isGranted;
  } else if (status.isPermanentlyDenied) {
    return false;
  } else {
    return true;
  }
}

Future<bool> hasMicrophonePermission() async {
  Permission microphonePermission = Permission.microphone;

  var status = await microphonePermission.status;

  if (status.isDenied || status.isRestricted) {
    var result = await microphonePermission.request();
    return result.isGranted;
  } else if (status.isPermanentlyDenied) {
    return false;
  } else {
    return true;
  }
}
