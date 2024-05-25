// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/models/app/info.dart';

String buildAppInfoKey(dynamic info) {
  if (info is InfoModel) {
    return '\${info.versionNumber}-\${info.buildNumber}';
  }
  
  if (info is AppInfo) {
    return '\${info.versionNumber}-\${info.buildNumber}';
  }
  
  throw ArgumentError('Invalid info type');
}