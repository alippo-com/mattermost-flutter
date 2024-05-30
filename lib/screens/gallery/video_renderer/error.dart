import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/calculate_dimensions.dart';
import 'package:mattermost_flutter/utils/change_opacity.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class VideoError extends HookWidget {
  final String filename;
  final double height;
  final bool isDownloading;
  final bool isRemote;
  final VoidCallback onShouldHideControls;
  final String? posterUri;
  final ValueNotifier<bool> setDownloading;
  final double width;

  VideoError({
    required this.filename,
    required this.height,
    required this.isDownloading,
    required this.isRemote,
    required this.onShouldHideControls,
    this.posterUri,
    required this.setDownloading,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final hasPoster = useState(false);
    final loadPosterError = useState(false);
    final dimensions = MediaQuery.of(context).size;
    final imageDimensions = calculateDimensions(height, width, dimensions.width);

    void handleDownload() {
      setDownloading.value = true;
    }

    void handlePosterSet() {
      hasPoster.value = true;
    }

    void handlePosterError() {
      loadPosterError.value = true;
    }

    Widget poster;
    if (posterUri != null && !loadPosterError.value) {
      poster = Image.network(
        posterUri!,
        width: hasPoster.value ? imageDimensions.width : null,
        height: hasPoster.value ? imageDimensions.height : null,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CompassIcon(
          color: Color(0xFF338AFF),
          name: 'file-video-outline-large',
          size: 120.0,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    } else {
      poster = CompassIcon(
        color: Color(0xFF338AFF),
        name: 'file-video-outline-large',
        size: 120.0,
      );
    }

    return GestureDetector(
      onTap: onShouldHideControls,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            poster,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
              child: Text(
                filename,
                style: typography('Body', 200, 'SemiBold').copyWith(color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            if (isRemote)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: FormattedText(
                        defaultMessage: 'This video must be downloaded to play it.',
                        id: 'video.download_description',
                        style: typography('Body', 100, 'SemiBold').copyWith(
                          color: Colors.white.withOpacity(0.64),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isDownloading ? null : handleDownload,
                      style: buttonBackgroundStyle(Preferences.THEMES.onyx, 'lg', 'primary', isDownloading ? 'disabled' : 'default'),
                      child: FormattedText(
                        defaultMessage: 'Download',
                        id: 'video.download',
                        style: buttonTextStyle(Preferences.THEMES.onyx, 'lg', 'primary', isDownloading ? 'disabled' : 'default'),
                      ),
                    ),
                  ],
                ),
              )
            else
              FormattedText(
                defaultMessage: 'An error occurred while trying to play the video.',
                id: 'video.failed_description',
                style: typography('Body', 100, 'SemiBold').copyWith(
                  color: Colors.white.withOpacity(0.64),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
