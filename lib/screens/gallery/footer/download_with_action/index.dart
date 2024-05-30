// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:camera_roll/camera_roll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/actions/local/file.dart';
import 'package:mattermost_flutter/actions/remote/file.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/progress_bar.dart';
import 'package:mattermost_flutter/components/toast.dart';
import 'package:mattermost_flutter/constants/gallery.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/document.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/files.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:device_info/device_info.dart';
import 'package:file_viewer/file_viewer.dart';
import 'package:file_system/file_system.dart';
import 'package:share/share.dart';

class DownloadWithAction extends StatefulWidget {
  final GalleryAction action;
  final GalleryItemType item;
  final bool galleryView;
  final Function(String)? onDownloadSuccess;
  final Function(GalleryAction) setAction;

  const DownloadWithAction({
    Key? key,
    required this.action,
    required this.item,
    required this.setAction,
    this.galleryView = true,
    this.onDownloadSuccess,
  }) : super(key: key);

  @override
  _DownloadWithActionState createState() => _DownloadWithActionState();
}

class _DownloadWithActionState extends State<DownloadWithAction> {
  final _intl = useIntl();
  final _serverUrl = useServerUrl();
  final _insets = useSafeAreaInsets();
  bool? _showToast;
  String _error = '';
  bool _saved = false;
  double _progress = 0.0;
  bool _mounted = false;
  late ProgressPromise<ClientResponse> _downloadPromise;

  String? _title;
  String? _iconName;
  String? _message;
  late TextStyle _toastStyle;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _showToast = true;
    _startDownload();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _cancel() async {
    try {
      await _downloadPromise.cancel();
      final path = getLocalFilePathFromFile(_serverUrl, galleryItemToFileInfo(widget.item));
      _downloadPromise = null;
      await FileSystem.unlink(path);
    } catch (_) {
      // do nothing
    } finally {
      if (_mounted) {
        setState(() {
          _showToast = false;
        });
      }
    }
  }

  Future<void> _externalAction(ClientResponse response) async {
    if (response.data?.path != null && widget.onDownloadSuccess != null) {
      widget.onDownloadSuccess!(response.data!.path as String);
    }
    setState(() {
      _showToast = false;
    });
  }

  Future<void> _openFile(ClientResponse response) async {
    if (_mounted) {
      if (response.data?.path != null) {
        final path = response.data!.path as String;
        widget.onDownloadSuccess?.call(path);
        await FileViewer.open(path, {
          'displayName': widget.item.name,
          'showAppsSuggestions': true,
          'showOpenWithDialog': true,
        }).catchError((_) {
          final file = galleryItemToFileInfo(widget.item);
          alertFailedToOpenDocument(file, _intl);
        });
      }
      setState(() {
        _showToast = false;
      });
    }
  }

  Future<void> _saveFile(String path) async {
    if (_mounted) {
      if (Platform.isAndroid) {
        try {
          await MethodChannel('mattermost').invokeMethod('saveFile', path);
        } catch (_) {
          // do nothing in case the user decides not to save the file
        }
        widget.setAction(GalleryAction.none);
        return;
      }

      updateLocalFilePath(_serverUrl, widget.item.id, path);

      await Share.shareFiles([pathWithPrefix('file://', path)], text: '');

      widget.setAction(GalleryAction.none);
    }
  }

  Future<void> _saveImageOrVideo(String path) async {
    if (_mounted) {
      try {
        final applicationName = DeviceInfoPlugin().androidInfo.then((info) => info.version.baseOS);
        final cameraType = widget.item.type == 'avatar' ? 'image' : widget.item.type;
        await CameraRoll.save(path, {
          'type': cameraType == 'image' ? 'photo' : 'video',
          'album': applicationName,
        });
        setState(() {
          _saved = true;
        });
        if (widget.item.type != 'avatar') {
          updateLocalFilePath(_serverUrl, widget.item.id, path);
        }
      } catch (_) {
        setState(() {
          _error = _intl.formatMessage({'id': 'gallery.save_failed', 'defaultMessage': 'Unable to save the file'});
        });
      }
    }
  }

  Future<void> _save(ClientResponse response) async {
    if (response.data?.path != null) {
      final path = response.data!.path as String;
      widget.onDownloadSuccess?.call(path);
      final hasPermission = await hasWriteStoragePermission(_intl);

      if (hasPermission) {
        switch (widget.item.type) {
          case 'file':
            _saveFile(path);
            break;
          default:
            _saveImageOrVideo(path);
            break;
        }
      }
    }
  }

  Future<void> _shareFile(ClientResponse response) async {
    if (_mounted) {
      if (response.data?.path != null) {
        final path = response.data!.path as String;
        widget.onDownloadSuccess?.call(path);
        updateLocalFilePath(_serverUrl, widget.item.id, path);
        await Share.shareFiles([pathWithPrefix('file://', path)], text: '', sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1));
      }
      setState(() {
        _showToast = false;
      });
    }
  }

  Future<void> _startDownload() async {
    try {
      final path = getLocalFilePathFromFile(_serverUrl, galleryItemToFileInfo(widget.item));
      if (path != null) {
        final exists = await fileExists(path);
        late Future<void> Function(ClientResponse) actionToExecute;
        switch (widget.action) {
          case GalleryAction.sharing:
            actionToExecute = _shareFile;
            break;
          case GalleryAction.opening:
            actionToExecute = _openFile;
            break;
          case GalleryAction.external:
            actionToExecute = _externalAction;
            break;
          default:
            actionToExecute = _save;
            break;
        }
        if (exists) {
          setState(() {
            _progress = 100;
          });
          actionToExecute(ClientResponse(200, true, {'path': path}));
        } else {
          if (widget.item.type == 'avatar') {
            _downloadPromise = downloadProfileImage(_serverUrl, widget.item.id!, widget.item.lastPictureUpdate, path);
          } else {
            _downloadPromise = downloadFile(_serverUrl, widget.item.id!, path);
          }
          _downloadPromise.then(actionToExecute).catchError((_) {
            setState(() {
              _error = _intl.formatMessage({'id': 'download.error', 'defaultMessage': 'Unable to download the file. Try again later'});
            });
          });
          _downloadPromise.progress?.listen((progress) {
            setState(() {
              _progress = progress;
            });
          });
        }
      }
    } catch (e) {
      logDebug('error on startDownload', getFullErrorMessage(e));
      setState(() {
        _showToast = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _toastStyle = TextStyle(
      backgroundColor: _error.isNotEmpty ? const Color(0xFFD24B4E) : (_saved ? const Color(0xFF3DB887) : const Color(0xFF3F4350)),
    );

    switch (widget.action) {
      case GalleryAction.sharing:
        _title = _intl.formatMessage({'id': 'gallery.preparing', 'defaultMessage': 'Preparing...'});
        break;
      case GalleryAction.opening:
        _title = _intl.formatMessage({'id': 'gallery.opening', 'defaultMessage': 'Opening...'});
        break;
      default:
        _title = _intl.formatMessage({'id': 'gallery.downloading', 'defaultMessage': 'Downloading...'});
        break;
    }

    if (_error.isNotEmpty) {
      _iconName = 'alert-circle-outline';
      _message = _error;
    } else if (_saved) {
      _iconName = 'check';

      switch (widget.item.type) {
        case 'image':
        case 'avatar':
          _message = _intl.formatMessage({'id': 'gallery.image_saved', 'defaultMessage': 'Image saved'});
          break;
        case 'video':
          _message = _intl.formatMessage({'id': 'gallery.video_saved', 'defaultMessage': 'Video saved'});
          break;
      }
    }

    final animatedStyle = AnimatedBuilder(
      animation: Listenable.merge([_showToast, _progress]),
      builder: (context, child) {
        final marginBottom = widget.galleryView ? GALLERY_FOOTER_HEIGHT + 8 : 0;
        return Positioned(
          bottom: _insets.bottom + marginBottom,
          child: Opacity(
            opacity: _showToast! ? 1 : 0,
            child: child,
          ),
        );
      },
      child: Toast(
        style: _toastStyle,
        message: _message,
        iconName: _iconName,
        child: _error.isEmpty && !_saved
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        ProgressBar(
                          color: Colors.white,
                          progress: _progress,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _cancel,
                  ),
                ],
              )
            : null,
      ),
    );

    return animatedStyle;
  }
}
