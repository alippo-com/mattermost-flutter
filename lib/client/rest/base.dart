
  Future<dynamic> doFetch(String url, ClientOptions options, {bool returnDataOnly = true}) async {
    Function? request;
    final method = options.method?.toLowerCase();
    switch (method) {
      case 'get':
        request = apiClient.get;
        break;
      case 'put':
        request = apiClient.put;
        break;
      case 'post':
        request = apiClient.post;
        break;
      case 'patch':
        request = apiClient.patch;
        break;
      case 'delete':
        request = apiClient.delete;
        break;
      default:
        throw ClientError(apiClient.baseUrl, {
          'message': 'Invalid request method',
          'intl': {
            'id': t('mobile.request.invalid_request_method'),
            'defaultMessage': 'Invalid request method',
          },
          'url': url,
        });
    }

    final requestOptions = RequestOptions(
      body: options.body,
      headers: getRequestHeaders(method!),
    );
    if (options.noRetry == true) {
      requestOptions.retryPolicyConfiguration = RetryPolicyConfiguration(retryLimit: 0);
    }
    if (options.timeoutInterval != null) {
      requestOptions.timeoutInterval = options.timeoutInterval;
    }

    if (options.headers != null) {
      if (requestOptions.headers != null) {
        requestOptions.headers?.addAll(options.headers!);
      } else {
        requestOptions.headers = options.headers;
      }
    }

    late ClientResponse response;
    try {
      response = await request!(url, requestOptions);
    } catch (error) {
      throw ClientError(apiClient.baseUrl, {
        'message': 'Received invalid response from the server.',
        'intl': {
          'id': t('mobile.request.invalid_response'),
          'defaultMessage': 'Received invalid response from the server.',
        },
        'url': url,
        'details': error,
      });
    }

    final headers = response.headers ?? {};
    final serverVersion = semverFromServerVersion(headers[ClientConstants.HEADER_X_VERSION_ID] ?? headers[ClientConstants.HEADER_X_VERSION_ID.toLowerCase()]);
    final hasCacheControl = headers[ClientConstants.HEADER_CACHE_CONTROL] != null || headers[ClientConstants.HEADER_CACHE_CONTROL.toLowerCase()] != null;
    if (serverVersion != null && !hasCacheControl && this.serverVersion != serverVersion) {
      this.serverVersion = serverVersion;
      DeviceEventEmitter.emit(Events.SERVER_VERSION_CHANGED, {'serverUrl': apiClient.baseUrl, 'serverVersion': serverVersion});
    }

    final bearerToken = headers[ClientConstants.HEADER_TOKEN] ?? headers[ClientConstants.HEADER_TOKEN.toLowerCase()];
    if (bearerToken != null) {
      setBearerToken(bearerToken);
    }

    if (response.ok) {
      return returnDataOnly ? response.data ?? {} : response;
    }

    throw ClientError(apiClient.baseUrl, {
      'message': response.data?['message'] ?? 'Response with status code ${response.code}',
      'server_error_id': response.data?['id'],
      'status_code': response.code,
      'url': url,
    });
  }
}
