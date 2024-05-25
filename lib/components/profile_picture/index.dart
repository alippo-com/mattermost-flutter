
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/image.dart';
import 'package:mattermost_flutter/components/status.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/source.dart';

class ProfilePicture extends StatefulWidget {
  final UserModel? author;
  final GlobalKey? forwardRef;
  final double? iconSize;
  final bool showStatus;
  final double size;
  final double? statusSize;
  final BoxDecoration? containerStyle;
  final BoxDecoration? statusStyle;
  final String? testID;
  final Source? source;
  final String? url;

  ProfilePicture({
    this.author,
    this.forwardRef,
    this.iconSize,
    this.showStatus = true,
    required this.size,
    this.statusSize,
    this.containerStyle,
    this.statusStyle,
    this.testID,
    this.source,
    this.url,
  });

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  late String serverUrl;

  @override
  void initState() {
    super.initState();
    final theme = context.read<ThemeProvider>().theme;
    serverUrl = widget.url ?? context.read<ServerUrlProvider>().serverUrl;

    if (widget.author != null && !(widget.author!.isBot ?? widget.author!.is_bot!) && widget.author!.status == null && widget.showStatus) {
      fetchStatusInBatch(serverUrl, widget.author!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>().theme;
    final style = getStyleSheet(theme);

    final bool isBot = widget.author != null && (widget.author!.isBot ?? widget.author!.is_bot!);

    return Container(
      decoration: widget.containerStyle,
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Image(
            author: widget.author,
            forwardRef: widget.forwardRef,
            iconSize: widget.iconSize,
            size: widget.size,
            source: widget.source,
            url: serverUrl,
          ),
          if (widget.showStatus && !isBot)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: widget.statusStyle,
                child: Status(
                  author: widget.author,
                  statusSize: widget.statusSize,
                  theme: theme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration getStyleSheet(Theme theme) {
    return BoxDecoration(
      color: changeOpacity(theme.centerChannelColor, 0.48),
      border: Border.all(
        color: theme.centerChannelBg,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(50),
    );
  }
}
