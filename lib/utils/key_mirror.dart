
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Constructs an enumeration with keys equal to their value.
///
/// For example:
///
///   var COLORS = keyMirror({blue: null, red: null});
///   var myColor = COLORS.blue;
///   var isColorValid = !!COLORS[myColor];
///
/// The last line could not be performed if the values of the generated enum were
/// not equal to their keys.
///
///   Input:  {key1: val1, key2: val2}
///   Output: {key1: key1, key2: key2}
///
/// @param {object} obj
/// @return {object}

Map<String, String> keyMirror(Map<String, dynamic> obj) {
  Map<String, String> ret = {};
  obj.forEach((key, value) {
    ret[key] = key;
  });
  return ret;
}
