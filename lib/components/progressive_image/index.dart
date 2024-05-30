import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/components/thumbnail.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/types/global_styles.dart';

class ProgressiveImage extends StatefulWidget {
  final String id;
  final String? imageUri;
  final String? thumbnailUri;
  final bool inViewPort;
  final ImageProvider? defaultSource;
  final bool isBackgroundImage;
  final BoxFit resizeMode;
  final bool tintDefaultSource;
  final Function onError;
  final Widget? children;
  final EdgeInsetsGeometry? style;
  final ImageStyle? imageStyle;

  const ProgressiveImage({
    required this.id,
    this.imageUri,
    this.thumbnailUri,
    required this.inViewPort,
    this.defaultSource,
    this.isBackgroundImage = false,
    this.resizeMode = BoxFit.contain,
    this.tintDefaultSource = false,
    required this.onError,
    this.children,
    this.style,
    this.imageStyle,
  });

  @override
  _ProgressiveImageState createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<ProgressiveImage> {
  bool showHighResImage = false;
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(_controller);
    if (widget.inViewPort) {
      setState(() {
        showHighResImage = true;
      });
    }
  }

  @override
  void didUpdateWidget(ProgressiveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inViewPort && !oldWidget.inViewPort) {
      setState(() {
        showHighResImage = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeData>(context);
    final styles = getStyleSheet(theme);

    if (widget.isBackgroundImage && widget.imageUri != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.imageUri!),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.children,
      );
    }

    if (widget.defaultSource != null) {
      return Container(
        decoration: BoxDecoration(
          color: changeOpacity(theme.centerChannelColor, 0.08),
        ),
        child: Image(
          image: widget.defaultSource!,
          fit: widget.resizeMode,
          color: widget.tintDefaultSource ? changeOpacity(theme.centerChannelColor, 0.2) : null,
          errorBuilder: (context, error, stackTrace) {
            widget.onError();
            return Container();
          },
        ),
      );
    }

    final containerStyle = BoxDecoration(
      color: changeOpacity(theme.centerChannelColor, _opacity.value),
    );

    Widget? image;
    if (widget.thumbnailUri != null) {
      if (showHighResImage && widget.imageUri != null) {
        image = Image.network(
          widget.imageUri!,
          fit: widget.resizeMode,
          errorBuilder: (context, error, stackTrace) {
            widget.onError();
            return Container();
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            } else {
              return AnimatedOpacity(
                opacity: frame == null ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            }
          },
        );
      }
    } else if (widget.imageUri != null) {
      image = Image.network(
        widget.imageUri!,
        fit: widget.resizeMode,
        errorBuilder: (context, error, stackTrace) {
          widget.onError();
          return Container();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          } else {
            return AnimatedOpacity(
              opacity: frame == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: child,
            );
          }
        },
      );
    }

    return Container(
      decoration: containerStyle,
      child: Stack(
        children: [
          if (widget.thumbnailUri != null)
            Thumbnail(
              onError: emptyFunction,
              opacity: _opacity,
              imageUri: widget.thumbnailUri!,
              imageStyle: widget.imageStyle,
              tintColor: widget.thumbnailUri == null ? theme.centerChannelColor : null,
            ),
          if (image != null) image,
        ],
      ),
    );
  }
}

TextStyle getStyleSheet(ThemeData theme) {
  return TextStyle(
    color: theme.centerChannelColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
