import 'package:flutter/material.dart';

class MarkdownList extends StatelessWidget {
  final List<Widget> children;
  final bool ordered;
  final int start;
  final bool tight;

  MarkdownList({
    Key? key,
    this.children = const <Widget>[],
    this.ordered = false,
    this.start = 1,
    this.tight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int bulletWidth = 15;
    if (ordered) {
      final lastNumber = (start + children.length) - 1;
      bulletWidth = (9 * lastNumber.toString().length) + 7;
    }

    List<Widget> childrenElements = children.map((child) {
      return Container(
        margin: EdgeInsets.only(left: bulletWidth.toDouble()),
        child: child,
      );
    }).toList();

    return Column(
      children: childrenElements,
    );
  }
}