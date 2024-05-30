
// Converted Dart content based on the provided TypeScript file

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/calls/caption.dart';
import 'package:flutter_reanimated/flutter_reanimated.dart';

class GalleryManagerSharedValues {
  SharedValue<double> width;
  SharedValue<double> height;
  SharedValue<double> x;
  SharedValue<double> y;
  SharedValue<double> opacity;
  SharedValue<double> activeIndex;
  SharedValue<double> targetWidth;
  SharedValue<double> targetHeight;

  GalleryManagerSharedValues({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.opacity,
    required this.activeIndex,
    required this.targetWidth,
    required this.targetHeight,
  });
}

typedef Context = Map<String, dynamic>;

typedef Handler<T, TContext extends Context> = void Function(T event, TContext context);

typedef OnEndHandler<T, TContext extends Context> = void Function(
  T event,
  TContext context,
  bool isCanceled,
);

typedef ReturnHandler<T, TContext extends Context, R> = R Function(
  T event,
  TContext context,
);

class GestureHandlers<T, TContext extends Context> {
  Handler<T, TContext>? onInit;
  Handler<T, TContext>? onEvent;
  ReturnHandler<T, TContext, bool>? shouldHandleEvent;
  ReturnHandler<T, TContext, bool>? shouldCancel;
  Handler<T, TContext>? onGesture;
  Handler<T, TContext>? beforeEach;
  Handler<T, TContext>? afterEach;
  Handler<T, TContext>? onStart;
  Handler<T, TContext>? onActive;
  OnEndHandler<T, TContext>? onEnd;
  Handler<T, TContext>? onFail;
  Handler<T, TContext>? onCancel;
  void Function(T event, TContext context, bool isCanceledOrFailed)? onFinish;
}

typedef OnGestureEvent<T extends GestureHandlerGestureEvent> = void Function(T event);

class GalleryItemType {
  final String type;
  final String id;
  final double width;
  final double height;
  final String uri;
  final int lastPictureUpdate;
  final String name;
  final String? posterUri;
  final String? extension;
  final String mimeType;
  final String? authorId;
  final int? size;
  final String? postId;
  final Map<String, dynamic>? postProps;

  GalleryItemType({
    required this.type,
    required this.id,
    required this.width,
    required this.height,
    required this.uri,
    required this.lastPictureUpdate,
    required this.name,
    this.posterUri,
    this.extension,
    required this.mimeType,
    this.authorId,
    this.size,
    this.postId,
    this.postProps,
  });
}

enum GalleryAction {
  none,
  downloading,
  copying,
  sharing,
  opening,
  external,
}
