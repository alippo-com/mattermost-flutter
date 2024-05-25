
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/theme.dart'; // Assuming 'Theme' comes from 'types' directory

class SvgComponent extends StatelessWidget {
  final Theme theme;

  SvgComponent({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="200" height="201" fill="none" viewBox="0 0 210 170">
        <path d="M20.215 68.747h41.93a5.84 5.84 0 0 1 4.143 1.704 5.864 5.864 0 0 1 1.727 4.14v26.71a5.879 5.879 0 0 1-1.727 4.141 5.842 5.842 0 0 1-4.144 1.704h-6.188v9.998l-9.281-9.998H20.23a5.857 5.857 0 0 1-4.143-1.704 5.871 5.871 0 0 1-1.728-4.141v-26.71a5.871 5.871 0 0 1 1.722-4.135 5.844 5.844 0 0 1 4.134-1.709Z" fill="${theme.buttonBg}" />
        <!-- Additional paths omitted for brevity -->
      </svg>
      ''',
      allowDrawingOutsideViewBox: true,
    );
  }
}
