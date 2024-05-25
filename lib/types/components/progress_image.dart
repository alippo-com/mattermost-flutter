// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Dart representation of progressive image properties in a Mattermost environment.
class ProgressiveImageProps {
  final String? defaultSourceUri;
  final String? imageUri;
  final bool? inViewPort;
  final String? thumbnailUri;

  ProgressiveImageProps({
    this.defaultSourceUri,
    this.imageUri,
    this.inViewPort,
    this.thumbnailUri,
  });

  factory ProgressiveImageProps.fromJson(Map<String, dynamic> json) {
    return ProgressiveImageProps(
      defaultSourceUri: json['defaultSource']?['uri'],
      imageUri: json['imageUri'],
      inViewPort: json['inViewPort'],
      thumbnailUri: json['thumbnailUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultSourceUri': defaultSourceUri,
      'imageUri': imageUri,
      'inViewPort': inViewPort,
      'thumbnailUri': thumbnailUri,
    };
  }
}
