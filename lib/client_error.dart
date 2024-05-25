import 'package:mattermost_flutter/types/url.dart';

class ClientError extends Error {
  String url;
  ClientErrorIntl? intl;
  String? serverErrorId;
  int? statusCode;
  dynamic details;
  String _message;

  ClientError(String baseUrl, ClientErrorProps data)
      : _message = '${data.message}: ${cleanUrlForLogging(baseUrl, data.url)}',
        super() {
    this.url = data.url;
    this.intl = data.intl;
    this.serverErrorId = data.serverErrorId;
    this.statusCode = data.statusCode;
    this.details = data.details;
  }

  @override
  String toString() => _message;
}