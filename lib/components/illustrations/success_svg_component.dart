// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessSvgComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="46" height="47" viewBox="0 0 46 47" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M41.1767 0.776611L13.0005 31.7625L4.82284 25.5642H0.276367L13.0005 46.2234L45.7232 0.776611H41.1767Z" fill="#3DB887"/>
      </svg>
      ''',
      allowDrawingOutsideViewBox: true,
    );
  }
}
