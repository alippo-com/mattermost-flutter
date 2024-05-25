// Converted from ./mattermost-mobile/app/utils/security.ts

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> getCSRFFromCookie(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.headers['set-cookie'] != null) {
    final cookies = response.headers['set-cookie']!
        .split(';')
        .map((cookie) => cookie.split('='))
        .where((pair) => pair.length == 2)
        .toMap();
    return cookies['MMCSRF'];
  }
  return null;
}

String urlSafeBase64Encode(String str) {
  return base64.encode(utf8.encode(str)).replaceAll('+', '-').replaceAll('/', '_');
}

extension IterableToMap<K, V> on Iterable<List> {
  Map<K, V> toMap() {
    final map = <K, V>{};
    for (final pair in this) {
      map[pair[0] as K] = pair[1] as V;
    }
    return map;
  }
}