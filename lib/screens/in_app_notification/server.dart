import 'package:flutter/material.dart';

final TextStyle textStyle = TextStyle(
  color: Color.fromRGBO(255, 255, 255, 0.64),
  fontFamily: 'OpenSans',
  fontSize: 10,
);

final BoxDecoration containerDecoration = BoxDecoration(
  alignItems: Alignment.topLeft,
  margin: EdgeInsets.only(top: 5),
);

class NotificationServerProps {
  final String serverName;

  NotificationServerProps({required this.serverName});
}

class Server extends StatelessWidget {
  final NotificationServerProps props;

  Server({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: containerDecoration,
      child: Text(
        props.serverName,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
