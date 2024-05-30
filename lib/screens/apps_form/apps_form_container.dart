// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/actions/remote/apps.dart';
import 'package:mattermost_flutter/actions/remote/command.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/apps.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class AppsFormContainer extends StatefulWidget {
  final AppForm? form;
  final AppContext? context;
  final AvailableScreens componentId;

  AppsFormContainer({this.form, this.context, required this.componentId});

  @override
  _AppsFormContainerState createState() => _AppsFormContainerState();
}

class _AppsFormContainerState extends State<AppsFormContainer> {
  late AppForm? currentForm;
  late String serverUrl;

  @override
  void initState() {
    super.initState();
    currentForm = widget.form;
    serverUrl = useServerUrl(context);
    useAndroidHardwareBackHandler(widget.componentId, close);
  }

  Future<Map<String, dynamic>> submit(AppFormValues submission) async {
    String makeErrorMsg(String msg) {
      return Intl.message(
        'There has been an error submitting the modal. Contact the app developer. Details: {details}',
        name: 'apps.error.form.submit.pretext',
        args: [msg],
        desc: 'Error message for form submission',
      ).replaceFirst('{details}', msg);
    }

    if (currentForm == null) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        '`form` is not defined',
        name: 'apps.error.form.no_form',
      )))};
    }

    if (currentForm!.submit == null) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        '`submit` is not defined',
        name: 'apps.error.form.no_submit',
      )))};
    }

    if (widget.context == null) {
      return {'error': makeCallErrorResponse('unreachable: empty context')};
    }

    var creq = createCallRequest(currentForm!.submit!, widget.context!, {}, submission);
    var res = await doAppSubmit<FormResponseData>(serverUrl, creq, Intl.defaultLocale!);

    if (res.containsKey('error')) {
      return res;
    }

    var callResp = res['data'] as AppCallResponse<FormResponseData>;
    switch (callResp.type) {
      case AppCallResponseTypes.OK:
        if (callResp.text != null) {
          postEphemeralCallResponseForContext(serverUrl, callResp, callResp.text!, creq.context);
        }
        break;
      case AppCallResponseTypes.FORM:
        setState(() {
          currentForm = callResp.form;
        });
        break;
      case AppCallResponseTypes.NAVIGATE:
        if (callResp.navigate_to_url != null) {
          handleGotoLocation(serverUrl, Intl.defaultLocale!, callResp.navigate_to_url!);
        }
        break;
      default:
        return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
          'App response type not supported. Response type: {type}.',
          name: 'apps.error.responses.unknown_type',
          args: [callResp.type],
        )))};
    }
    return res;
  }

  Future<Map<String, dynamic>> refreshOnSelect(AppField field, AppFormValues values) async {
    String makeErrorMsg(String message) {
      return Intl.message(
        'There has been an error updating the modal. Contact the app developer. Details: {details}',
        name: 'apps.error.form.refresh',
        args: [message],
        desc: 'Error message for form refresh',
      ).replaceFirst('{details}', message);
    }

    if (currentForm == null) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        '`form` is not defined.',
        name: 'apps.error.form.no_form',
      )))};
    }

    if (currentForm!.source == null) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        '`source` is not defined.',
        name: 'apps.error.form.no_source',
      )))};
    }

    if (!field.refresh) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        'Called refresh on no refresh field.',
        name: 'apps.error.form.refresh_no_refresh',
      )))};
    }

    if (widget.context == null) {
      return {'error': makeCallErrorResponse('unreachable: empty context')};
    }

    var creq = createCallRequest(currentForm!.source!, widget.context!, {}, values);
    creq.selected_field = field.name;

    var res = await doAppFetchForm<FormResponseData>(serverUrl, creq, Intl.defaultLocale!);

    if (res.containsKey('error')) {
      return res;
    }
    var callResp = res['data'] as AppCallResponse<FormResponseData>;
    switch (callResp.type) {
      case AppCallResponseTypes.FORM:
        setState(() {
          currentForm = callResp.form;
        });
        break;
      case AppCallResponseTypes.OK:
      case AppCallResponseTypes.NAVIGATE:
        return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
          'App response type was not expected. Response type: {type}.',
          name: 'apps.error.responses.unexpected_type',
          args: [callResp.type],
        )))};
      default:
        return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
          'App response type not supported. Response type: {type}.',
          name: 'apps.error.responses.unknown_type',
          args: [callResp.type],
        )))};
    }
    return res;
  }

  Future<Map<String, dynamic>> performLookupCall(AppField field, AppFormValues values, String userInput) async {
    String makeErrorMsg(String message) {
      return Intl.message(
        'There has been an error fetching the select fields. Contact the app developer. Details: {details}',
        name: 'apps.error.form.refresh',
        args: [message],
        desc: 'Error message for form field lookup',
      ).replaceFirst('{details}', message);
    }

    if (field.lookup == null) {
      return {'error': makeCallErrorResponse(makeErrorMsg(Intl.message(
        '`lookup` is not defined.',
        name: 'apps.error.form.no_lookup',
      )))};
    }

    if (widget.context == null) {
      return {'error': makeCallErrorResponse('unreachable: empty context')};
    }

    var creq = createCallRequest(field.lookup!, widget.context!, {}, values);
    creq.selected_field = field.name;
    creq.query = userInput;

    return doAppLookup<AppLookupResponse>(serverUrl, creq, Intl.defaultLocale!);
  }

  void close() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    dismissModal({'componentId': widget.componentId});
  }

  @override
  Widget build(BuildContext context) {
    if (currentForm?.submit == null || widget.context == null) {
      return Container();
    }

    return AppsFormComponent(
      form: currentForm!,
      componentId: widget.componentId,
      performLookupCall: performLookupCall,
      refreshOnSelect: refreshOnSelect,
      submit: submit,
    );
  }
}
