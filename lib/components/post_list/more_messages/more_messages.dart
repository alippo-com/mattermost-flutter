// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reanimated/flutter_reanimated.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/calls/hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const HIDDEN_TOP = -60;
const SHOWN_TOP = 5;
const MIN_INPUT = 0;
const MAX_INPUT = 1;
