
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/actions/remote/command.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/apps.dart';
import 'package:mattermost_flutter/types/app_binding.dart';
import 'package:mattermost_flutter/types/app_call_response.dart';
import 'package:mattermost_flutter/types/app_form.dart';

typedef OnSuccess = void Function(AppCallResponse callResponse, String message);
typedef OnError = void Function(AppCallResponse callResponse, String message);
typedef OnForm = void Function(AppForm form);
typedef OnNavigate = void Function(AppCallResponse callResp);

class UseAppBindingContext {
  final String channelId;
  final String teamId;
  final String? postId;
  final String? rootId;

  UseAppBindingContext({
    required this.channelId,
    required this.teamId,
    this.postId,
    this.rootId,
  });
}

class UseAppBindingConfig {
  final OnSuccess onSuccess;
  final OnError onError;
  final OnForm? onForm;
  final OnNavigate? onNavigate;

  UseAppBindingConfig({
    required this.onSuccess,
    required this.onError,
    this.onForm,
    this.onNavigate,
  });
}

Function useAppBinding(UseAppBindingContext context, UseAppBindingConfig config) {
  final serverUrl = useServerUrl();
  final intl = useIntl();

  return (AppBinding binding) async {
    final callContext = createCallContext(
      binding.appId,
      binding.location,
      context.channelId,
      context.teamId,
      context.postId,
      context.rootId,
    );

    final res = await handleBindingClick(serverUrl, binding, callContext, intl);

    return () async {
      if (res.error) {
        final errorResponse = res.error;
        final errorMessage = errorResponse.text ?? intl.formatMessage(
          id: 'apps.error.unknown',
          defaultMessage: 'Unknown error occurred.',
        );

        config.onError(errorResponse, errorMessage);
        return;
      }

      final callResp = res.data!;
      switch (callResp.type) {
        case AppCallResponseTypes.OK:
          if (callResp.text != null) {
            config.onSuccess(callResp, callResp.text!);
          }
          return;
        case AppCallResponseTypes.NAVIGATE:
          if (callResp.navigateToUrl != null) {
            if (config.onNavigate != null) {
              config.onNavigate!(callResp);
            } else {
              await handleGotoLocation(serverUrl, intl, callResp.navigateToUrl!);
            }
          }
          return;
        case AppCallResponseTypes.FORM:
          if (callResp.form != null) {
            if (config.onForm != null) {
              config.onForm!(callResp.form!);
            } else {
              await showAppForm(callResp.form!, callContext);
            }
          }
          return;
        default:
          final errorMessage = intl.formatMessage(
            id: 'apps.error.responses.unknown_type',
            defaultMessage: 'App response type not supported. Response type: {type}.',
            values: {'type': callResp.type},
          );

          config.onError(callResp, errorMessage);
      }
    };
  };
}
