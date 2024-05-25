// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

class AttachmentThumbnail extends StatelessWidget {
  final String uri;

  const AttachmentThumbnail({Key? key, required this.uri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      top: 10,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(uri),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
