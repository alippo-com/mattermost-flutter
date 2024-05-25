// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ErrorSvgComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="46" height="45" viewBox="0 0 46 45" fill="none" xmlns="http://www.w3.org/2000/svg">
        <g clip-path="url(#clip0_1304_35713)">
          <path d="M45.2126 6.63077L38.8691 0.287231L23.0033 16.153L7.13065 0.287231L0.787109 6.63077L16.6529 22.5035L0.787109 38.3692L7.13065 44.7128L23.0033 28.847L38.8691 44.7128L45.2126 38.3692L29.3469 22.5035L45.2126 6.63077Z" fill="#D24B4E"/>
        </g>
        <defs>
          <clipPath id="clip0_1304_35713)">
            <rect width="44.4255" height="44.4255" fill="white" transform="translate(0.787109 0.287231)"></rect>
          </clipPath>
        </defs>
      </svg>
      ''',
      width: 46,
      height: 45,
      allowDrawingOutsideViewBox: true,
    );
  }
}
