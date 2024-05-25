import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:mattermost_flutter/actions/local/file.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/screens/gallery/footer/download_with_action.dart';
import 'package:mattermost_flutter/screens/gallery/video_renderer/error.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/captions_enabled.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/transcription.dart';

class VideoRenderer extends HookWidget {
  final int index;
  final int initialIndex;
  final GalleryItem item;
  final bool isPageActive;
  final Function(bool) onShouldHideControls;
  final double height;
  final double width;

  VideoRenderer({
    required this.index,
    required this.initialIndex,
    required this.item,
    required this.isPageActive,
    required this.onShouldHideControls,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = useWindowDimensions();
    final fullscreen = useState(false);
    final bottom = MediaQuery.of(context).padding.bottom;
    final serverUrl = Provider.of<ServerUrl>(context);
    final videoController = useVideoPlayerController(item.uri);
    final showControls = useRef(!(initialIndex == index));
    final captionsEnabled = useContext<CaptionsEnabledContext>(context);
    final paused = useState(!(initialIndex == index));
    final videoReady = useState(false);
    final videoUri = useState(item.uri);
    final downloading = useState(false);
    final hasError = useState(false);
    final source = useMemo(() => VideoPlayerController.network(videoUri.value), [videoUri]);

    void setFullscreen(bool value) {
      fullscreen.value = value;
    }

    void onDownloadSuccess(String path) {
      videoUri.value = path;
      hasError.value = false;
      updateLocalFilePath(serverUrl, item.id, path);
    }

    void onEnd() {
      setFullscreen(false);
      onShouldHideControls(true);
      showControls.current = true;
      paused.value = true;
      videoController.value?.pause();
    }

    void onError() {
      hasError.value = true;
    }

    void onFullscreenPlayerWillDismiss() {
      setFullscreen(false);
      showControls.current = !paused.value;
      onShouldHideControls(showControls.current);
    }

    void onFullscreenPlayerWillPresent() {
      setFullscreen(true);
      onShouldHideControls(true);
      showControls.current = true;
    }

    void onPlay() {
      paused.value = false;
      videoController.value?.play();
    }

    void onPlaybackRateChange(VideoPlayerController controller) {
      if (isPageActive) {
        final isPlaying = controller.value.isPlaying;
        showControls.current = isPlaying;
        onShouldHideControls(isPlaying);
        paused.value = !isPlaying;
      }
    }

    void onReadyForDisplay() {
      videoReady.value = true;
      hasError.value = false;
    }

    void handleTouchStart() {
      showControls.current = !showControls.current;
      onShouldHideControls(showControls.current);
    }

    void setGalleryAction(String action) {
      DeviceEventEmitter.emit(Events.GALLERY_ACTIONS, action);
      if (action == 'none') {
        downloading.value = false;
      }
    }

    useEffect(() {
      if (initialIndex == index && videoReady.value) {
        paused.value = false;
      } else if (videoReady.value) {
        videoController.value?.seekTo(Duration(milliseconds: 400));
      }
    }, [index, initialIndex, videoReady]);

    useEffect(() {
      if (!isPageActive && !paused.value) {
        paused.value = true;
        videoController.value?.pause();
      }
    }, [isPageActive, paused]);

    return Column(
      children: [
        VideoPlayer(
          controller: source,
          onError: onError,
          onReady: onReadyForDisplay,
          onEnd: onEnd,
          onTouchStart: handleTouchStart,
          textTracks: tracks,
          selectedTextTrack: captionsEnabled[index] ? selected : null,
          width: fullscreen.value ? dimensions.width : width,
          height: fullscreen.value
              ? dimensions.height
              : height - (VIDEO_INSET + GALLERY_FOOTER_HEIGHT + bottom),
        ),
        if (paused.value && videoReady.value)
          Positioned.fill(
            child: Center(
              child: CompassIcon(
                color: changeOpacity('#fff', 0.8),
                name: 'play',
                onPress: onPlay,
                size: 80,
              ),
            ),
          ),
        if (hasError.value)
          VideoError(
            filename: item.name,
            isDownloading: downloading.value,
            isRemote: videoUri.value.startsWith('http'),
            onShouldHideControls: handleTouchStart,
            posterUri: item.posterUri,
            setDownloading: (value) => downloading.value = value,
            height: item.height,
            width: item.width,
          ),
        if (downloading.value)
          DownloadWithAction(
            action: 'external',
            setAction: setGalleryAction,
            onDownloadSuccess: onDownloadSuccess,
            item: item,
          ),
      ],
    );
  }
}
