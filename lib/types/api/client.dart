
  // Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
  // See LICENSE.txt for license information.
  
  enum LogLevel {
    error, 
    warning, 
    info
  }
  
  class ClientOptions {
    dynamic body;
    String? method;
    bool? noRetry;
    int? timeoutInterval;
    Map<String, dynamic>? headers;
  
    ClientOptions({this.body, this.method, this.noRetry, this.timeoutInterval, this.headers});
  }
  
  class ClientErrorIntl {
    String? defaultMessage;
    String id;
    Map<String, dynamic>? values;
  
    ClientErrorIntl({this.defaultMessage, required this.id, this.values});
  }
  
  class ClientErrorProps {
    dynamic? details;
    ClientErrorIntl? intl;
    String url;
    String? serverErrorId;
    int? statusCode;
    String message;
  
    ClientErrorProps({this.details, this.intl, required this.url, this.serverErrorId, this.statusCode, required this.message});
  }
  