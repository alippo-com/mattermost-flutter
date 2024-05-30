import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'url_parse.dart';

final ytRegex = RegExp(
    r'(?:http|https):\/\/(?:www\.|m\.)?(?:(?:youtube\.com\/(?:(?:v\/)|(?:(?:watch|embed\/watch)(?:\/|.*v=))|(?:embed\/)|(?:user\/[^/]+\/u\/[0-9]\/)))|(?:youtu\.be\/))([^#&?]*)');

bool isValidUrl(String url) {
  final regex = RegExp(r'^https?:\/\//i');
  return regex.hasMatch(url);
}

String sanitizeUrl(String url, {bool useHttp = false}) {
  var preUrl = Uri.parse(url);
  var protocol = preUrl.scheme;

  if (preUrl.host.isEmpty || preUrl.scheme == 'file') {
    preUrl = Uri.parse('https://' + stripTrailingSlashes(url));
  }

  if (preUrl.scheme == 'http' && !useHttp) {
    protocol = 'https';
  } else if (protocol.isEmpty) {
    protocol = useHttp ? 'http' : 'https';
  }

  return stripTrailingSlashes(
    '$protocol://${preUrl.host}${preUrl.path}',
  );
}

Future<Map<String, dynamic>> getServerUrlAfterRedirect(String serverUrl, {bool useHttp = false}) async {
  var url = sanitizeUrl(serverUrl, useHttp: useHttp);

  try {
    final response = await http.head(Uri.parse(url));
    if (response.isRedirect && response.redirects.isNotEmpty) {
      url = response.redirects.last.location.toString();
    }
  } catch (error) {
    logDebug('getServerUrlAfterRedirect error', url, error);
    return {'error': error};
  }

  return {'url': sanitizeUrl(url, useHttp: useHttp)};
}

String stripTrailingSlashes(String url) {
  return url.replaceAll(' ', '').replaceAll(RegExp(r'^\/+'), '').replaceAll(RegExp(r'\/+$'), '');
}

String removeProtocol(String url) {
  return url.replaceAll(RegExp(r'(^\w+:|^)\/\/'), '');
}

String? extractFirstLink(String text) {
  final pattern = RegExp(
      r'(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[-A-Z0-9+\u0026\u2019@#/%?=()~_|!:,.;]*[-A-Z0-9+\u0026@#/%=~()_|])',
      caseSensitive: false);
  var inText = text;

  // Strip out code blocks
  inText = inText.replaceAll(RegExp(r'`[^`]*`'), '');

  // Strip out inline markdown images
  inText = inText.replaceAll(RegExp(r'!\[[^\]]*]\([^)]*\)'), '');

  final match = pattern.firstMatch(inText);
  return match?.group(0)?.trim();
}

String? extractStartLink(String text) {
  final pattern = RegExp(
      r'^((?:https?|ftp):\/\/[-A-Z0-9+\u0026\u2019@#/%?=()~_|!:,.;]*[-A-Z0-9+\u0026@#/%=~()_|])',
      caseSensitive: false);
  var inText = text;

  // Strip out code blocks
  inText = inText.replaceAll(RegExp(r'`[^`]*`'), '');

  // Strip out inline markdown images
  inText = inText.replaceAll(RegExp(r'!\[[^\]]*]\([^)]*\)'), '');

  final match = pattern.firstMatch(inText);
  return match?.group(0)?.trim();
}

bool isYoutubeLink(String link) {
  return ytRegex.hasMatch(link.trim());
}

bool isImageLink(String link) {
  var linkWithoutQuery = link;
  if (link.contains('?')) {
    linkWithoutQuery = link.split('?')[0];
  }

  for (final imageType in Files.IMAGE_TYPES) {
    if (linkWithoutQuery.endsWith('.$imageType') ||
        linkWithoutQuery.endsWith('=$imageType')) {
      return true;
    }
  }

  return false;
}

String normalizeProtocol(String url) {
  final index = url.indexOf(':');
  if (index == -1) {
    // There's no protocol on the link to be normalized
    return url;
  }

  final protocol = url.substring(0, index);
  return protocol.toLowerCase() + url.substring(index);
}

String getShortenedURL(String url, {int getLength = 27}) {
  if (url.length > 35) {
    final subLength = getLength - 14;
    return url.substring(0, 10) +
        '...' +
        url.substring(url.length - subLength, url.length) +
        '/';
  }
  return url + '/';
}

String cleanUpUrlable(String input) {
  var cleaned = latinise(input);
  cleaned = cleaned
      .trim()
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'[^\w\s]', caseSensitive: false), '')
      .toLowerCase()
      .replaceAll(' ', '-');
  cleaned = cleaned.replaceAll(RegExp(r'-{2,}'), '-');
  cleaned = cleaned.replaceAll(RegExp(r'^-+'), '');
  cleaned = cleaned.replaceAll(RegExp(r'-+$'), '');
  return cleaned;
}

String? getScheme(String url) {
  final match = RegExp(r'([a-z0-9+.-]+):', caseSensitive: false).firstMatch(url);
  return match?.group(1);
}

String getYouTubeVideoId(String? link) {
  if (link == null) {
    return '';
  }

  // https://youtube.com/watch?v=<id>
  var match = RegExp(r'youtube\.com\/watch\?\S*\bv=([a-zA-Z0-9_-]{6,11})').firstMatch(link);
  if (match != null) {
    return match.group(1) ?? '';
  }

  // https://youtube.com/embed/<id>
  match = RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{6,11})').firstMatch(link);
  if (match != null) {
    return match.group(1) ?? '';
  }

  // https://youtu.be/<id>
  match = RegExp(r'youtu.be\/([a-zA-Z0-9_-]{6,11})').firstMatch(link);
  if (match != null) {
    return match.group(1) ?? '';
  }

  return '';
}

Future<void> tryOpenURL(String url, {Function? onError, Function? onSuccess}) async {
  if (await canLaunch(url)) {
    await launch(url).then((_) => onSuccess?.call()).catchError(onError);
  } else {
    onError?.call('Could not launch $url');
  }
}

String cleanUrlForLogging(String baseUrl, String apiUrl) {
  var url = apiUrl;

  // Trim the host name
  url = url.substring(baseUrl.length);

  // Filter the query string
  final index = url.indexOf('?');
  if (index != -1) {
    url = url.substring(0, index);
  }

  // A non-exhaustive whitelist to exclude parts of the URL that are unimportant (eg IDs) or may be sensitive
  final whitelist = {
    'api',
    'v4',
    'users',
    'teams',
    'scheme',
    'name',
    'members',
    'channels',
    'posts',
    'reactions',
    'commands',
    'files',
    'preferences',
    'hooks',
    'incoming',
    'outgoing',
    'oauth',
    'apps',
    'emoji',
    'brand',
    'image',
    'data_retention',
    'jobs',
    'plugins',
    'roles',
    'system',
    'timezones',
    'schemes',
    'redirect_location',
    'patch',
    'mfa',
    'password',
    'reset',
    'send',
    'active',
    'verify',
    'terms_of_service',
    'login',
    'logout',
    'ids',
    'usernames',
    'me',
    'username',
    'email',
    'default',
    'sessions',
    'revoke',
    'all',
    'device',
    'status',
    'search',
    'switch',
    'authorized',
    'authorize',
    'deauthorize',
    'tokens',
    'disable',
    'enable',
    'exists',
    'unread',
    'invite',
    'batch',
    'stats',
    'import',
    'schemeRoles',
    'direct',
    'group',
    'convert',
    'view',
    'search_autocomplete',
    'thread',
    'info',
    'flagged',
    'pinned',
    'pin',
    'unpin',
    'opengraph',
    'actions',
    'thumbnail',
    'preview',
    'link',
    'delete',
    'logs',
    'ping',
    'license',
    'config',
    'client',
    'test',
    'email_test',
    'database',
    'migrate',
    'recycle',
    'purge',
    's3_test',
    'elasticsearch',
    'invalidate_caches',
    'cluster',
    'compliance',
    'report',
    'uploads',
    'sharedchannels',
    'remotecluster',
  };

  // Add the parts of the URL that are whitelisted
  final parts = url.split('/').where(whitelist.contains).join('/');
  url = parts.isEmpty ? '/' : '/$parts';

  return url;
}
