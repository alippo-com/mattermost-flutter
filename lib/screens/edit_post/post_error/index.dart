
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/error_text.dart';

class PostError extends StatelessWidget {
  final String? errorLine;
  final String? errorExtra;

  const PostError({Key? key, this.errorLine, this.errorExtra}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: errorExtra != null ? 15.0 : 10.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorLine != null)
            ErrorText(
              testID: 'edit_post.message.input.error',
              error: errorLine!,
              textStyle: errorWrapStyle,
            ),
          if (errorExtra != null)
            ErrorText(
              testID: 'edit_post.message.input.error.extra',
              error: errorExtra!,
              textStyle: errorLine == null ? errorWrapperStyle : null,
            ),
        ],
      ),
    );
  }
}

final errorWrapStyle = TextStyle(
  // Equivalent styles for flexShrink and paddingRight
  fontSize: 14.0,  // Default font size
  fontWeight: FontWeight.normal,  // Default font weight
  paddingRight: 20.0,
);

final errorWrapperStyle = BoxDecoration(
  // Equivalent styles for alignItems
  alignment: Alignment.center,
);
