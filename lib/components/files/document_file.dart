import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/document.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/constants/network.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/components/progress_bar.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/client/rest.dart';

class DocumentFile extends HookWidget {
  final Color? backgroundColor;
  final bool canDownloadFiles;
  final FileInfo file;

  const DocumentFile({
    Key? key,
    this.backgroundColor,
    required this.canDownloadFiles,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);
    final serverUrl = Provider.of<ServerNotifier>(context).serverUrl;
    final theme = Provider.of<ThemeNotifier>(context).theme;
    final didCancel = useState(false);
    final downloading = useState(false);
    final preview = useState(false);
    final progress = useState(0.0);
    final client = useMemoized(() => NetworkManager.getClient(serverUrl), [serverUrl]);
    final downloadTask = useRef<ProgressPromise<ClientResponse>>();

    void cancelDownload() {
      didCancel.value = true;
      downloadTask.value?.cancel();
    }

    Future<void> downloadAndPreviewFile() async {
      didCancel.value = false;
      String? path;

      try {
        path = getLocalFilePathFromFile(serverUrl, file);
        final exists = await fileExists(path);
        if (exists) {
          openDocument(path);
        } else {
          downloading.value = true;
          downloadTask.value = client.apiClient.download(
            client.getFileRoute(file.id!),
            path.replaceFirst('file://', ''),
            options: DownloadOptions(timeoutInterval: DOWNLOAD_TIMEOUT),
          );
          downloadTask.value?.progress?.listen((p) => progress.value = p);

          await downloadTask.value;
          progress.value = 1.0;
          openDocument(path);
        }
      } catch (error) {
        if (path != null) {
          FileSystem.unlink(path).catchError((_) {});
        }
        downloading.value = false;
        progress.value = 0.0;

        if (!(error is ErrorWithMessage) || error.message != 'cancelled') {
          logDebug('error on downloadAndPreviewFile', getFullErrorMessage(error));
          alertDownloadFailed(intl);
        }
      }
    }

    Future<void> handlePreviewPress() async {
      if (!canDownloadFiles) {
        alertDownloadDocumentDisabled(intl);
        return;
      }

      if (downloading.value && progress.value < 1.0) {
        cancelDownload();
      } else if (downloading.value) {
        progress.value = 0.0;
        didCancel.value = true;
        downloading.value = false;
      } else {
        await downloadAndPreviewFile();
      }
    }

    void onDonePreviewingFile() {
      progress.value = 0.0;
      downloading.value = false;
      preview.value = false;
      setStatusBarColor();
    }

    Future<void> openDocument(String path) async {
      if (!didCancel.value && !preview.value) {
        preview.value = true;
        setStatusBarColor('dark-content');
        try {
          await FileViewer.open(
            path,
            displayName: file.name,
            onDismiss: onDonePreviewingFile,
            showOpenWithDialog: true,
            showAppsSuggestions: true,
          );
          downloading.value = false;
          progress.value = 0.0;
        } catch (e) {
          alertFailedToOpenDocument(file, intl);
          onDonePreviewingFile();
          FileSystem.unlink(path).catchError((_) {});
        }
      }
    }

    void setStatusBarColor([String style = 'light-content']) {
      if (Platform.isIOS) {
        SystemChrome.setSystemUIOverlayStyle(
          style == 'dark-content'
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
        );
      }
    }

    final icon = FileIcon(
      backgroundColor: colorScheme.background,
      file: file,
    );

    final fileAttachmentComponent = downloading.value
        ? Stack(
            children: [
              icon,
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ProgressBar(
                    progress: progress.value,
                    color: theme.buttonColor,
                  ),
                ),
              ),
            ],
          )
        : icon;

    return GestureDetector(
      onTap: handlePreviewPress,
      child: fileAttachmentComponent,
    );
  }
}
