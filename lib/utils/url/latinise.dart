// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.
// Credit to http://semplicewebsites.com/removing-accents-javascript

import 'latin_map.dart';

String map(String x) {
  return latinMap[x] ?? x;
}

String latinise(String input) {
  return input.replaceAll(RegExp(r'[^A-Za-z0-9]'), map);
}