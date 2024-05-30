import 'package:mattermost_flutter/utils/datetime.dart';

import 'package:mattermost_flutter/client/base.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/network_client.dart';

abstract class ClientFilesMix {
  String getFileUrl(String fileId, int timestamp);
  String getFileThumbnailUrl(String fileId, int timestamp);
  String getFilePreviewUrl(String fileId, int timestamp);
  Future<Map<String, dynamic>> getFilePublicLink(String fileId);
  void Function() uploadPostAttachment(
      FileInfo file,
      String channelId,
      Function(double fractionCompleted, [int? bytesRead]) onProgress,
      Function(ClientResponse response) onComplete,
      Function(ClientResponseError response) onError, [
        int skipBytes,
      ]);
  Future<FileSearchRequest> searchFiles(String teamId, String terms);
  Future<FileSearchRequest> searchFilesWithParams(String teamId, String params);
}

mixin ClientFiles<TBase extends ClientBase> on TBase implements ClientFilesMix {
  @override
  String getFileUrl(String fileId, int timestamp) {
    var url = '${this.apiClient.baseUrl}${this.getFileRoute(fileId)}';
    if (timestamp != null) {
      url += '?$timestamp';
    }
    return url;
  }

  @override
  String getFileThumbnailUrl(String fileId, int timestamp) {
    var url = '${this.apiClient.baseUrl}${this.getFileRoute(fileId)}/thumbnail';
    if (timestamp != null) {
      url += '?$timestamp';
    }
    return url;
  }

  @override
  String getFilePreviewUrl(String fileId, int timestamp) {
    var url = '${this.apiClient.baseUrl}${this.getFileRoute(fileId)}/preview';
    if (timestamp != null) {
      url += '?$timestamp';
    }
    return url;
  }

  @override
  Future<Map<String, dynamic>> getFilePublicLink(String fileId) async {
    return await this.doFetch('${this.getFileRoute(fileId)}/link', {'method': 'get'});
  }

  @override
  void Function() uploadPostAttachment(
      FileInfo file,
      String channelId,
      Function(double fractionCompleted, [int? bytesRead]) onProgress,
      Function(ClientResponse response) onComplete,
      Function(ClientResponseError response) onError, [
        int skipBytes = 0,
      ]) {
    final url = this.getFilesRoute();
    final options = UploadRequestOptions(
      skipBytes: skipBytes,
      method: 'POST',
      multipart: {
        'data': {
          'channel_id': channelId,
        },
      },
      timeoutInterval: toMilliseconds(minutes: 3),
    );
    if (file.localPath == null) {
      throw Error('file does not have local path defined');
    }

    final promise = this.apiClient.upload(url, file.localPath, options) as ProgressPromise<ClientResponse>;
    promise.progress(onProgress).then(onComplete).catchError(onError);
    return promise.cancel;
  }

  @override
  Future<FileSearchRequest> searchFilesWithParams(String teamId, String params) async {
    this.analytics?.trackAPI('api_files_search');
    final endpoint = teamId != null ? '${this.getTeamRoute(teamId)}/files/search' : '${this.getFilesRoute()}/search';
    return await this.doFetch(endpoint, {'method': 'post', 'body': params});
  }

  @override
  Future<FileSearchRequest> searchFiles(String teamId, String terms, bool isOrSearch) async {
    return await this.searchFilesWithParams(teamId, {'terms': terms, 'is_or_search': isOrSearch});
  }
}
