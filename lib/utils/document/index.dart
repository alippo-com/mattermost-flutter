// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void alertFailedToOpenDocument(BuildContext context, FileInfo file, Intl intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message(
          id: 'mobile.document_preview.failed_title',
          defaultMessage: 'Open Document failed',
        )),
        content: Text(intl.message(
          id: 'mobile.document_preview.failed_description',
          defaultMessage: 'An error occurred while opening the document. Please make sure you have a {fileType} viewer installed and try again.
          ',
          args: {'fileType': file.extension.toUpperCase()},
        )),
        actions: [
          FlatButton(
            child: Text(intl.message(
              id: 'mobile.server_upgrade.button',
              defaultMessage: 'OK',
            )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void alertDownloadDocumentDisabled(BuildContext context, Intl intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message(
          id: 'mobile.downloader.disabled_title',
          defaultMessage: 'Download disabled',
        )),
        content: Text(intl.message(
            id: 'mobile.downloader.disabled_description',
            defaultMessage: 'File downloads are disabled on this server. Please contact your System Admin for more details.
            ',
        )),
        actions: [
          FlatButton(
            child: Text(intl.message(
              id: 'mobile.server_upgrade.button',
              defaultMessage: 'OK',
            )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void alertDownloadFailed(BuildContext context, Intl intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message(
          id: 'mobile.downloader.failed_title',
          defaultMessage: 'Download failed',
        )),
        content: Text(intl.message(
            id: 'mobile.downloader.failed_description',
            defaultMessage: 'An error occurred while downloading the file. Please check your internet connection and try again.
            ',
        )),
        actions: [
          FlatButton(
            child: Text(intl.message(
              id: 'mobile.server_upgrade.button',
              defaultMessage: 'OK',
            )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}