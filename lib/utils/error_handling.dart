
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/locale.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/sentry.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class JavascriptAndNativeErrorHandler {
    void initializeErrorHandling() {
        initializeSentry();
        FlutterError.onError = (FlutterErrorDetails details) {
            if (isBetaApp || details.stack != null) {
                Sentry.captureException(details.exception, stackTrace: details.stack);
            }
            _handleError(details.exception, details.stack, true);
        };
    }

    void _handleError(Object error, StackTrace? stack, bool isFatal) {
        logWarning('Handling Javascript error', error, isFatal);

        if (isBetaApp || isFatal) {
            captureJSException(error, stack, isFatal);
        }

        if (isFatal && error is Error) {
            final translations = getTranslations(DEFAULT_LOCALE);

            showDialog(
                context: navigatorKey.currentContext!,
                builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(translations[t('mobile.error_handler.title')]),
                        content: Text('${translations[t('mobile.error_handler.description')]}\n\n${error.toString()}\n\n${stack.toString()}'),
                        actions: <Widget>[
                            TextButton(
                                child: Text(translations[t('mobile.error_handler.button')]),
                                onPressed: () async {
                                    await dismissAllModals();
                                    await dismissAllOverlays();
                                    Navigator.of(context).pop();
                                },
                            ),
                        ],
                    );
                },
                barrierDismissible: false,
            );
        }
    }
}

final javascriptAndNativeErrorHandler = JavascriptAndNativeErrorHandler();
