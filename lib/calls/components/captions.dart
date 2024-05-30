
import 'package:flutter/material.dart';
// Assuming a corresponding file exists
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Captions extends StatefulWidget {
  final Map<String, LiveCaptionMobile> captionsDict;
  final Map<String, CallSession> sessionsDict;
  final String teammateNameDisplay;

  Captions({required this.captionsDict, required this.sessionsDict, required this.teammateNameDisplay});

  @override
  _CaptionsState createState() => _CaptionsState();
}

class _CaptionsState extends State<Captions> {
  bool showCCNotice = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showCCNotice = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final captionsArr = widget.captionsDict.values.toList().reversed.toList();

    if (showCCNotice && captionsArr.isNotEmpty) {
      setState(() {
        showCCNotice = false;
      });
    }

    if (showCCNotice) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.90,
        height: 48,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: changeOpacity(Colors.black, 0.64),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CompassIcon(
                    name: 'closed-caption-outline',
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  FormattedText(
                    id: 'mobile.calls_captions_turned_on',
                    defaultMessage: 'Live captions turned on',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.375,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      height: 48,
      child: ListView(
        reverse: true,
        children: captionsArr.map((cap) => Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: changeOpacity(Colors.black, 0.64),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '(${displayUsername(widget.sessionsDict[cap.sessionId]?.userModel, context.locale.toString(), widget.teammateNameDisplay)}) ${cap.text}',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.375,
            ),
          ),
        )).toList(),
      ),
    );
  }
}
