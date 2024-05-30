import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/actions/remote/nps.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/illustrations/review_app.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ReviewApp extends StatefulWidget {
  final bool hasAskedBefore;
  final String componentId;

  ReviewApp({required this.hasAskedBefore, required this.componentId});

  @override
  _ReviewAppState createState() => _ReviewAppState();
}

class _ReviewAppState extends State<ReviewApp> with SingleTickerProviderStateMixin {
  late ThemeData theme;
  late String serverUrl;
  bool show = true;
  late VoidCallback executeAfterDone;

  @override
  void initState() {
    super.initState();
    executeAfterDone = () => dismissOverlay(widget.componentId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of<ThemeContext>(context).theme;
    serverUrl = Provider.of<ServerContext>(context).serverUrl;
  }

  void close(VoidCallback afterDone) {
    setState(() {
      executeAfterDone = afterDone;
      storeLastAskForReview();
      show = false;
    });
  }

  Future<void> onPressYes() async {
    close(() async {
      await dismissOverlay(widget.componentId);
      try {
        await InAppReview.RequestInAppReview();
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('There has been an error while opening the review modal.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> onPressNeedsWork() async {
    close(() async {
      await dismissOverlay(widget.componentId);
      if (await isNPSEnabled(serverUrl)) {
        showShareFeedbackOverlay();
      }
    });
  }

  void onPressDontAsk() {
    storeDontAskForReview();
    close(() async {
      await dismissOverlay(widget.componentId);
    });
  }

  void onPressClose() {
    close(() async {
      await dismissOverlay(widget.componentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            onEnd: executeAfterDone,
            child: Container(
              constraints: BoxConstraints(maxWidth: 680),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.16)),
              ),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: CompassIcon(name: 'close', size: 24, color: theme.dividerColor.withOpacity(0.56)),
                      onPressed: onPressClose,
                    ),
                  ),
                  ReviewAppIllustration(theme: theme),
                  SizedBox(height: 8),
                  Text(
                    'Enjoying Mattermost?',
                    style: typography(theme, 'Heading', 600, FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Let us know what you think.',
                    style: typography(theme, 'Body', 200, FontWeight.normal).copyWith(
                      color: theme.dividerColor.withOpacity(0.72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          theme: theme,
                          size: 'lg',
                          emphasis: 'tertiary',
                          onPressed: onPressNeedsWork,
                          text: 'Needs work',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Button(
                          theme: theme,
                          size: 'lg',
                          onPressed: onPressYes,
                          text: 'Love it!',
                        ),
                      ),
                    ],
                  ),
                  if (widget.hasAskedBefore)
                    GestureDetector(
                      onTap: onPressDontAsk,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'Don't ask me again',
                          style: typography(theme, 'Body', 75, FontWeight.w600).copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
