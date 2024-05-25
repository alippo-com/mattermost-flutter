
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

double clamp(double value, double lowerBound, double upperBound) {
  return value.clamp(lowerBound, upperBound);
}

double clampVelocity(double velocity, double minVelocity, double maxVelocity) {
  if (velocity > 0) {
    return velocity.clamp(minVelocity, maxVelocity);
  }
  return velocity.clamp(-maxVelocity, -minVelocity);
}

GalleryItemType fileToGalleryItem(
  FileInfo file, {
  String? authorId,
  Map<String, dynamic>? postProps,
  int lastPictureUpdate = 0,
}) {
  var type = GalleryItemType.file;
  if (isVideo(file)) {
    type = GalleryItemType.video;
  } else if (isImage(file)) {
    type = GalleryItemType.image;
  }

  return GalleryItemType(
    authorId: authorId,
    extension: file.extension,
    height: file.height,
    id: file.id ?? generateId('uid'),
    lastPictureUpdate: lastPictureUpdate,
    mimeType: file.mimeType,
    name: file.name,
    posterUri: type == GalleryItemType.video ? file.miniPreview : null,
    postId: file.postId,
    size: file.size,
    type: type,
    uri: file.localPath ?? file.uri ?? '',
    width: file.width,
    postProps: postProps ?? file.postProps,
  );
}

void freezeOtherScreens(bool value) {
  DeviceEventEmitter.emit(Events.FREEZE_SCREEN, value);
}

double friction(double value) {
  const MAX_FRICTION = 30;
  const MAX_VALUE = 200;

  final res = (1 + (value.abs() * (MAX_FRICTION - 1))) / MAX_VALUE;
  return value > 0 ? res.clamp(1, MAX_FRICTION) : -res.clamp(1, MAX_FRICTION);
}

FileInfo galleryItemToFileInfo(GalleryItemType item) {
  return FileInfo(
    id: item.id,
    name: item.name,
    createAt: 0,
    deleteAt: 0,
    updateAt: 0,
    width: item.width,
    height: item.height,
    extension: item.extension ?? '',
    mimeType: item.mimeType,
    hasPreviewImage: false,
    postId: item.postId!,
    size: 0,
    userId: item.authorId!,
  );
}

bool getShouldRender(int index, int activeIndex, [int diffValue = 3]) {
  final diff = (index - activeIndex).abs();
  return diff <= diffValue;
}

void measureItem(GlobalKey key, GalleryManagerSharedValues sharedValues) {
  final context = key.currentContext;
  if (context != null) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      sharedValues.x.value = position.dx;
      sharedValues.y.value = position.dy;
      sharedValues.width.value = renderBox.size.width;
      sharedValues.height.value = renderBox.size.height;
    }
  }
}

void openGalleryAtIndex(
  String galleryIdentifier,
  int initialIndex,
  List<GalleryItemType> items, {
  bool hideActions = false,
}) {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final props = {
    'galleryIdentifier': galleryIdentifier,
    'hideActions': hideActions,
    'initialIndex': initialIndex,
    'items': items,
  };
  final layout = OptionsLayout(orientation: allOrientations);
  final options = Options(
    layout: layout,
    topBar: TopBarOptions(
      background: BackgroundOptions(color: '#000'),
      visible: Platform.isAndroid,
    ),
    statusBar: StatusBarOptions(
      backgroundColor: '#000',
      style: StatusBarStyle.light,
    ),
    animations: AnimationsOptions(
      showModal: AnimationOptions(waitForRender: false, enabled: false),
      dismissModal: AnimationOptions(enabled: false),
    ),
  );

  if (Platform.isIOS) {
    Navigation.setDefaultOptions(options);
    NativeModules.splitView.unlockOrientation();
  }
  showOverlay(Screens.GALLERY, props, options);

  Future.delayed(Duration(milliseconds: 500), () {
    freezeOtherScreens(true);
  });
}

T typedMemo<T>(T Function() fn) => fn();

void workletNoop() {}

bool workletNoopTrue() => true;
