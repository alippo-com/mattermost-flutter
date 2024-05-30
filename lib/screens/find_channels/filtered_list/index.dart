import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class VideoError extends StatefulWidget {
  final String filename;
  final double height;
  final bool isDownloading;
  final bool isRemote;
  final VoidCallback onShouldHideControls;
  final String? posterUri;
  final Function(bool) setDownloading;
  final double width;

  const VideoError({
    required this.filename,
    required this.height,
    required this.isDownloading,
    required this.isRemote,
    required this.onShouldHideControls,
    this.posterUri,
    required this.setDownloading,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  _VideoErrorState createState() => _VideoErrorState();
}

class _VideoErrorState extends State<VideoError> {
  bool hasPoster = false;
  bool loadPosterError = false;

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final imageDimensions = calculateDimensions(widget.height, widget.width, dimensions.width);

    Widget poster;
    if (widget.posterUri != null && !loadPosterError) {
      poster = Image.network(
        widget.posterUri!,
        fit: hasPoster ? BoxFit.cover : BoxFit.contain,
        width: imageDimensions.width,
        height: imageDimensions.height,
        loadingBuilder: (_, child, progress) {
          if (progress == null) {
            setState(() {
              hasPoster = true;
            });
            return child;
          } else {
            return CircularProgressIndicator();
          }
        },
        errorBuilder: (_, __, ___) {
          setState(() {
            loadPosterError = true;
          });
          return CompassIcon(
            color: Color(0xFF338AFF),
            name: 'file-video-outline-large',
            size: 120,
          );
        },
      );
    } else {
      poster = CompassIcon(
        color: Color(0xFF338AFF),
        name: 'file-video-outline-large',
        size: 120,
      );
    }

    return GestureDetector(
      onTap: widget.onShouldHideControls,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            poster,
            Text(
              widget.filename,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (widget.isRemote) ...[
              SizedBox(height: 16),
              FormattedText(
                defaultMessage: 'This video must be downloaded to play it.',
                id: 'video.download_description',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.64),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.isDownloading ? null : () => widget.setDownloading(true),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Preferences.themes['onyx']?.backgroundColor ?? Colors.black,
                ),
                child: FormattedText(
                  defaultMessage: 'Download',
                  id: 'video.download',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            if (!widget.isRemote)
              FormattedText(
                defaultMessage: 'An error occurred while trying to play the video.',
                id: 'video.failed_description',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.64),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
