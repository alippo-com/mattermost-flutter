
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:moor/moor.dart';
import 'package:mattermost_flutter/types.dart';

@DataClassName('System')
class SystemTable extends Table {
  TextColumn get value => text().named('value')();

  @override
  Set<Column> get primaryKey => {value};
}
