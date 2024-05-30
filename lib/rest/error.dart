
class ClientError extends Error {
  String url;
  ClientErrorIntl? intl;
  String? serverErrorId;
  int? statusCode;
  dynamic details;
  ClientError(String baseUrl, ClientErrorProps data) : super() {
    this.message = '${data.message}: ${cleanUrlForLogging(baseUrl, data.url)}';
    this.url = data.url;
    this.intl = data.intl;
    this.serverErrorId = data.serverErrorId;
    this.statusCode = data.statusCode;
    this.details = data.details;

    // Ensure message is treated as a property of this class when object spreading. Without this,
    // copying the object by using `{...error}` would not include the message.
    this.message = data.message;
  }

  @override
  String toString() {
    return message;
  }
}