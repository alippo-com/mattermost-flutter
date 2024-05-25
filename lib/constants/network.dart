// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/datetime.dart';
import 'package:mattermost_flutter/types/key_mirror.dart';

final CERTIFICATE_ERRORS = keyMirror({
    'CLIENT_CERTIFICATE_IMPORT_ERROR': null,
    'CLIENT_CERTIFICATE_MISSING': null,
    'SERVER_INVALID_CERTIFICATE': null,
});

final DOWNLOAD_TIMEOUT = toMilliseconds(minutes: 10);

final constants = {
    'CERTIFICATE_ERRORS': CERTIFICATE_ERRORS,
    'DOWNLOAD_TIMEOUT': DOWNLOAD_TIMEOUT,
};