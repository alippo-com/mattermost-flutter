
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class NativeShareExtension {
    final Function close;
    final Function getCurrentActivityName;
    final Function getSharedData;
      NativeShareExtension({required this.close, required this.getCurrentActivityName, required this.getSharedData});
    }

    class ShareExtensionDataToSend {
      final String channelId;
      final List<SharedItem> files;
      final String message;
      final String serverUrl;
      final String userId;
      ShareExtensionDataToSend({required this.channelId, required this.files, required this.message, required this.serverUrl, required this.userId});
    }

    class SharedItem {
      final String extension;
      final String filename;
      final bool isString;
      final int size;
      final String type;
      final String value;
      final int height;
      final int width;
      final String videoThumb;
      SharedItem({required this.extension, required this.filename, required this.isString, required this.size, required this.type, required this.value, required this.height, required this.width, required this.videoThumb});
    }

    class ShareExtensionState {
      final String channelId;
      final Function closeExtension;
      final List<SharedItem> files;
      final bool globalError;
      final String linkPreviewUrl;
      final String message;
      final String serverUrl;
      final String userId;
      ShareExtensionState({required this.channelId, required this.closeExtension, required this.files, required this.globalError, required this.linkPreviewUrl, required this.message, required this.serverUrl, required this.userId});
    }
}
