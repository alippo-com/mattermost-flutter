
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // Assuming some default duration
      curve: Curves.easeInOut, // Assuming some default curve
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: -15),
      child: Container(
        height: 5,
        width: 62.5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
