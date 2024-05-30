import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/typing_utils.dart';

class Typing extends StatefulWidget {
  final String channelId;
  final String rootId;

  Typing({required this.channelId, required this.rootId});

  @override
  _TypingState createState() => _TypingState();
}

class _TypingState extends State<Typing> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> typing = [];
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  int refresh = 0;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = Theme.of(context);
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _heightAnimation = Tween<double>(begin: 0, end: TYPING_HEIGHT).animate(_controller);
    _controller.addListener(() {
      setState(() {});
    });

    SystemChannels.platform.setMessageHandler((message) async {
      if (message == Events.USER_TYPING) {
        onUserStartTyping(message);
      } else if (message == Events.USER_STOP_TYPING) {
        onUserStopTyping(message);
      }
      return null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onUserStartTyping(Map<String, dynamic> msg) {
    if (widget.channelId != msg['channelId']) return;
    if (widget.rootId != (msg['parentId'] ?? msg['rootId'] ?? '')) return;

    typing.removeWhere((user) => user['id'] == msg['userId']);
    typing.add({'id': msg['userId'], 'now': msg['now'], 'username': msg['username']});
    setState(() {
      refresh = DateTime.now().millisecondsSinceEpoch;
    });
    _controller.forward();
  }

  void onUserStopTyping(Map<String, dynamic> msg) {
    if (widget.channelId != msg['channelId']) return;
    if (widget.rootId != (msg['parentId'] ?? msg['rootId'] ?? '')) return;

    typing.removeWhere((user) => user['id'] == msg['userId']);
    if (typing.isEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          refresh = DateTime.now().millisecondsSinceEpoch;
        });
        _controller.reverse();
      });
    } else {
      setState(() {
        refresh = DateTime.now().millisecondsSinceEpoch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _heightAnimation,
      axisAlignment: -1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        child: renderTyping(),
      ),
    );
  }

  Widget renderTyping() {
    List<String> nextTyping = typing.map((user) => user['username']).toList();
    nextTyping = nextTyping.take(3).toList();
    int numUsers = nextTyping.length;

    switch (numUsers) {
      case 0:
        return Container();
      case 1:
        return FormattedText(
          id: 'msg_typing.isTyping',
          defaultMessage: '{user} is typing...',
          values: {'user': nextTyping[0]},
          style: TextStyle(
            color: changeOpacity(theme.textTheme.bodyLarge!.color!, 0.7),
            paddingHorizontal: 10,
            ...typography('Body', 75),
          ),
          ellipsizeMode: 'tail',
          numberOfLines: 1,
        );
      default:
        String last = nextTyping.removeLast();
        return FormattedText(
          id: 'msg_typing.areTyping',
          defaultMessage: '{users} and {last} are typing...',
          values: {'users': nextTyping.join(', '), 'last': last},
          style: TextStyle(
            color: changeOpacity(theme.textTheme.bodyLarge!.color!, 0.7),
            paddingHorizontal: 10,
            ...typography('Body', 75),
          ),
          ellipsizeMode: 'tail',
          numberOfLines: 1,
        );
    }
  }
}
