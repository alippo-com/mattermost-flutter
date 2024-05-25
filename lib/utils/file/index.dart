// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime_type/mime_type.dart';

import 'constants.dart';
import 'general.dart';
import 'key_mirror.dart';
import 'log.dart';
import 'mattermost_managed.dart';
import 'security.dart';

import 'types/pasted_file.dart';
import 'types/file_model.dart';
import 'types/intl_shape.dart';
import 'types/document_picker_response.dart';
import 'types/asset.dart';

const EXTRACT_TYPE_REGEXP = r'^\s*([^;\s]*)(?:;|\s|$)';
const CONTENT_DISPOSITION_REGEXP = r'inline;filename=".*\.([a-z]+)";';
const DEFAULT_SERVER_MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 Mb

const FileFilters = {
  'ALL': null,
  'DOCUMENTS': null,
  'SPREADSHEETS': null,
  'PRESENTATIONS': null,
  'CODE': null,
  'IMAGES': null,
  'AUDIO': null,
  'VIDEOS': null,
};

typedef FileFilter = String;

const GENERAL_SUPPORTED_DOCS_FORMAT = [
  'application/json',
  'application/msword',
  'application/pdf',
  'application/rtf',
  'application/vnd.ms-excel',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/x-x509-ca-cert',
  'application/xml',
  'text/csv',
  'text/plain',
];

const SUPPORTED_DOCS_FORMAT = kIsWeb
    ? GENERAL_SUPPORTED_DOCS_FORMAT
    : defaultTargetPlatform == TargetPlatform.iOS
        ? [
            ...GENERAL_SUPPORTED_DOCS_FORMAT,
            'application/vnd.apple.pages',
            'application/vnd.apple.numbers',
            'application/vnd.apple.keynote',
          ]
        : GENERAL_SUPPORTED_DOCS_FORMAT;

const SUPPORTED_VIDEO_FORMAT = defaultTargetPlatform == TargetPlatform.iOS
    ? ['video/mp4', 'video/x-m4v', 'video/quicktime']
    : ['video/3gpp', 'video/x-matroska', 'video/mp4', 'video/webm', 'video/quicktime'];

final Map<String, String> types = {};
final Map<String, List<String>> extensions = {};

String filterFileExtensions(FileFilter filter) {
  List<String> searchTerms = [];
  switch (filter) {
    case 'ALL':
      return '';
    case 'DOCUMENTS':
      searchTerms = Files.DOCUMENT_TYPES;
      break;
    case 'SPREADSHEETS':
      searchTerms = Files.SPREADSHEET_TYPES;
      break;
    case 'PRESENTATIONS':
      searchTerms = Files.PRESENTATION_TYPES;
      break;
    case 'CODE':
      searchTerms = Files.CODE_TYPES;
      break;
    case 'IMAGES':
      searchTerms = Files.IMAGE_TYPES;
      break;
    case 'AUDIO':
      searchTerms = Files.AUDIO_TYPES;
      break;
    case 'VIDEOS':
      searchTerms = Files.VIDEO_TYPES;
      break;
    default:
      return '';
  }
  return 'ext:' + searchTerms.join(' ext:');
}

void populateMaps() {
  // source preference (least -> most)
  const preference = ['nginx', 'apache', null, 'iana'];

  mimeDB.forEach((type, mime) {
    final exts = mime.extensions;
    if (exts == null || exts.isEmpty) {
      return;
    }

    extensions[type] = exts;

    for (var extension in exts) {
      if (types.containsKey(extension)) {
        final from = preference.indexOf(mimeDB[types[extension]].source);
        final to = preference.indexOf(mime.source);

        if (types[extension] != 'application/octet-stream' &&
            (from > to || (from == to && types[extension].startsWith('application/')))) {
          continue;
        }
      }

      types[extension] = type;
    }
  });
}

Future<void> deleteV1Data() async {
  final dir = defaultTargetPlatform == TargetPlatform.iOS
      ? getIOSAppGroupDetails().appGroupSharedDirectory
      : await getApplicationDocumentsDirectory();

  try {
    final directory = '${dir.path}/mmkv';
    if (await Directory(directory).exists()) {
      await Directory(directory).delete(recursive: true);
    }
  } catch (e) {
    // do nothing
  }

  try {
    final entitiesInfo = '${dir.path}/entities';
    if (await Directory(entitiesInfo).exists()) {
      deleteEntititesFile();
    }
  } catch (e) {
    // do nothing
  }
}

Future<void> deleteFileCache(String serverUrl) async {
  final serverDir = urlSafeBase64Encode(serverUrl);
  await deleteFileCacheByDir(serverDir);
}

Future<void> deleteFileCacheByDir(String dir) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final appGroupCacheDir = '${getIOSAppGroupDetails().appGroupSharedDirectory}/Library/Caches/$dir';
    await deleteFilesInDir(appGroupCacheDir);
  }

  final cacheDir = '${await getTemporaryDirectory().path}/$dir';
  await deleteFilesInDir(cacheDir);

  return true;
}

Future<void> deleteFilesInDir(String directory) async {
  if (directory.isNotEmpty) {
    if (await Directory(directory).exists()) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Directory(directory).delete(recursive: true);
        await Directory(directory).create();
      } else {
        final lstat = Directory(directory).listSync();
        for (var stat in lstat) {
          await File(stat.path).delete();
        }
      }
    }
  }
}

String lookupMimeType(String filename) {
  if (extensions.isEmpty) {
    populateMaps();
  }

  final ext = filename.split('.').last.toLowerCase();
  return types[ext] ?? 'application/octet-stream';
}

String? getExtensionFromMime(String type) {
  if (extensions.isEmpty) {
    populateMaps();
  }

  if (type.isEmpty || type is! String) {
    return null;
  }

  final match = RegExp(EXTRACT_TYPE_REGEXP).firstMatch(type);

  // get extensions
  final exts = match != null ? extensions[match.group(1)!.toLowerCase()] : null;

  if (exts == null || exts.isEmpty) {
    return null;
  }

  return exts[0];
}

String? getExtensionFromContentDisposition(String contentDisposition) {
  final match = RegExp(CONTENT_DISPOSITION_REGEXP).firstMatch(contentDisposition);
  String? extension = match != null ? match.group(1) : null;
  if (extension != null) {
    if (types.isEmpty) {
      populateMaps();
    }

    extension = extension.toLowerCase();
    if (types.containsKey(extension)) {
      return extension;
    }

    return null;
  }

  return null;
}

int getAllowedServerMaxFileSize(ClientConfig config) {
  return config != null && config.MaxFileSize != null
      ? int.parse(config.MaxFileSize)
      : DEFAULT_SERVER_MAX_FILE_SIZE;
}

bool isGif(FileInfo? file) {
  if (file == null) {
    return false;
  }

  String? mime = file.mimeType;
  if (mime != null && mime.contains(';')) {
    mime = mime.split(';')[0];
  } else if (mime == null && file.name != null) {
    mime = lookupMimeType(file.name);
  }

  return mime == 'image/gif';
}

bool isImage(FileInfo? file) {
  if (file == null) {
    return false;
  }

  if (isGif(file)) {
    return true;
  }

  String? mimeType = file.mimeType;
  if (mimeType == null) {
    mimeType = lookupMimeType(file.extension) ?? lookupMimeType(file.name);
  }

  return mimeType != null && mimeType.startsWith('image/');
}

bool isDocument(FileInfo? file) {
  if (file == null) {
    return false;
  }

  String? mime = file.mimeType;
  if (mime != null && mime.contains(';')) {
    mime = mime.split(';')[0];
  } else if (mime == null && file.name != null) {
    mime = lookupMimeType(file.name);
  }

  return SUPPORTED_DOCS_FORMAT.contains(mime);
}

bool isVideo(FileInfo? file) {
  if (file == null) {
    return false;
  }

  String? mime = file.mimeType;
  if (mime != null && mime.contains(';')) {
    mime = mime.split(';')[0];
  } else if (mime == null && file.name != null) {
    mime = lookupMimeType(file.name);
  }

  return SUPPORTED_VIDEO_FORMAT.contains(mime);
}

String getFormattedFileSize(int bytes) {
  final fileSizes = [
    ['TB', 1024 * 1024 * 1024 * 1024],
    ['GB', 1024 * 1024 * 1024],
    ['MB', 1024 * 1024],
    ['KB', 1024],
  ];

  final size = fileSizes.firstWhere(
    (unitAndMinBytes) => bytes > unitAndMinBytes[1],
    orElse: () => ['B', 1],
  );

  return '${(bytes / size[1]).floor()} ${size[0]}';
}

String getFileType(FileInfo file) {
  if (file == null || file.extension == null) {
    return 'other';
  }

  final fileExt = file.extension.toLowerCase();
  final fileTypes = [
    'image',
    'code',
    'pdf',
    'video',
    'audio',
    'spreadsheet',
    'text',
    'word',
    'presentation',
    'patch',
    'zip',
  ];

  return fileTypes.firstWhere(
    (fileType) {
      final constForFileTypeExtList = '${fileType}_types'.toUpperCase();
      final fileTypeExts = Files[constForFileTypeExtList];
      return fileTypeExts.contains(fileExt);
    },
    orElse: () => 'other',
  );
}

String getLocalFilePathFromFile(String serverUrl, FileInfo file) {
  final fileIdPath = file.id.replaceAll(RegExp(r'[^0-9a-z]'), '');
  if (serverUrl.isNotEmpty) {
    final server = urlSafeBase64Encode(serverUrl);
    final hasValidFilename = file.name != null && !file.name.contains('/');
    final hasValidExtension = file.extension != null && !file.extension.contains('/');
    if (hasValidFilename) {
      String? extension = file.extension;
      String filename = file.name;

      if (!hasValidExtension) {
        final mimeType = file.mimeType;
        extension = getExtensionFromMime(mimeType);
      }

      if (extension != null && filename.contains('.$extension')) {
        filename = filename.replaceAll('.$extension', '');
      } else {
        final fileParts = file.name.split('.');

        if (fileParts.length > 1) {
          extension = fileParts.removeLast();
          filename = fileParts.join('.');
        }
      }

      return '${(await getTemporaryDirectory()).path}/$server/$filename-$fileIdPath.$extension';
    } else if (file.id.isNotEmpty && hasValidExtension) {
      return '${(await getTemporaryDirectory()).path}/$server/$fileIdPath.${file.extension}';
    } else if (file.id.isNotEmpty) {
      return '${(await getTemporaryDirectory()).path}/$server/$fileIdPath';
    }
  }

  throw Exception('File path could not be set');
}

Future<List<ExtractedFileInfo>> extractFileInfo(List<Asset> files) async {
  final out = <ExtractedFileInfo>[];

  await Future.wait(files.map((file) async {
    if (file == null || file.uri == null) {
      logError('extractFileInfo no file or url');
      return;
    }

    final outFile = ExtractedFileInfo(
      progress: 0,
      localPath: file.uri,
      clientId: generateId(),
      loading: true,
    );

    if (file.fileSize != null) {
      outFile.size = file.fileSize!;
      outFile.name = file.fileName ?? '';
    } else {
      final localPath = defaultTargetPlatform == TargetPlatform.iOS
          ? (file.uri ?? '').replaceAll('file://', '')
          : file.uri ?? '';
      try {
        final fileInfo = await File(localPath).stat();
        outFile.size = fileInfo.size;
        outFile.name = localPath.split('/').last;
      } catch (e) {
        logError('extractFileInfo', e);
        return;
      }
    }

    if (file.type != null) {
      outFile.mimeType = file.type!;
    } else {
      outFile.mimeType = lookupMimeType(outFile.name);
    }

    out.add(outFile);
  }));

  return out;
}

String fileSizeWarning(IntlShape intl, int maxFileSize) {
  return intl.formatMessage(
    id: 'file_upload.fileAbove',
    defaultMessage: 'Files must be less than {max}',
    params: {'max': getFormattedFileSize(maxFileSize)},
  );
}

String fileMaxWarning(IntlShape intl, int maxFileCount) {
  return intl.formatMessage(
    id: 'mobile.file_upload.max_warning',
    defaultMessage: 'Uploads limited to {count} files maximum.',
    params: {'count': maxFileCount},
  );
}

String uploadDisabledWarning(IntlShape intl) {
  return intl.formatMessage(
    id: 'mobile.file_upload.disabled2',
    defaultMessage: 'File uploads from mobile are disabled.',
  );
}

Future<bool> fileExists(String path) async {
  try {
    final filePath = defaultTargetPlatform == TargetPlatform.iOS
        ? path.replaceAll('file://', '')
        : path;
    return File(filePath).existsSync();
  } catch (e) {
    return false;
  }
}

Future<bool> hasWriteStoragePermission(IntlShape intl) async {
  if (defaultTargetPlatform == TargetPlatform.android && Platform.version < 33) {
    final storagePermission = Permission.storage;
    var permissionRequest;
    final hasPermissionToStorage = await storagePermission.status;
    switch (hasPermissionToStorage) {
      case PermissionStatus.denied:
        permissionRequest = await storagePermission.request();
        return permissionRequest == PermissionStatus.granted;
      case PermissionStatus.permanentlyDenied:
        final applicationName = await DeviceInfoPlugin().appName;
        final title = intl.formatMessage(
          id: 'mobile.storage_permission_denied_title',
          defaultMessage: '{applicationName} would like to access your files',
          params: {'applicationName': applicationName},
        );
        final text = intl.formatMessage(
          id: 'mobile.write_storage_permission_denied_description',
          defaultMessage:
              'Save files to your device. Open Settings to grant {applicationName} write access to files on this device.',
          params: {'applicationName': applicationName},
        );

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: Text(intl.formatMessage(
                  id: 'mobile.permission_denied_dismiss',
                  defaultMessage: "Don't Allow",
                )),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(intl.formatMessage(
                  id: 'mobile.permission_denied_retry',
                  defaultMessage: 'Settings',
                )),
                onPressed: () => openAppSettings(),
              ),
            ],
          ),
        );

        return false;
      default:
        return true;
    }
  }

  return true;
}

Future<Map<String, dynamic>> getAllFilesInCachesDirectory(String serverUrl) async {
  try {
    final files = <FileSystemEntity>[];

    final promises = [
      Directory('${(await getTemporaryDirectory()).path}/${urlSafeBase64Encode(serverUrl)}').listSync(),
    ];
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final cacheDir =
          '${getIOSAppGroupDetails().appGroupSharedDirectory}/Library/Caches/${urlSafeBase64Encode(serverUrl)}';
      promises.add(Directory(cacheDir).listSync());
    }

    final dirs = await Future.wait(promises);
    dirs.forEach((dir) {
      files.addAll(dir);
    });

    final totalSize = files.fold(
      0,
      (acc, file) => acc + (file.statSync().size ?? 0),
    );

    return {
      'files': files,
      'totalSize': totalSize,
    };
  } catch (error) {
    return {'error': error};
  }
}