// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/components/markdown/markdown.dart';
import 'package:mattermost_flutter/types/database.dart';

class EnhancedMarkdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final enableLatex = observeConfigBooleanValue(database, 'EnableLatex');
    final enableInlineLatex = observeConfigBooleanValue(database, 'EnableInlineLatex');
    final maxNodes = observeConfigIntValue(database, 'MaxMarkdownNodes');

    return StreamBuilder(
      stream: combineLatest3(enableLatex, enableInlineLatex, maxNodes),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final enableLatex = snapshot.data[0];
          final enableInlineLatex = snapshot.data[1];
          final maxNodes = snapshot.data[2];

          return Markdown(
            enableLatex: enableLatex,
            enableInlineLatex: enableInlineLatex,
            maxNodes: maxNodes,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

Widget combineLatest3(Stream<bool> s1, Stream<bool> s2, Stream<int> s3) {
  return Stream.zip3(s1, s2, s3, (a, b, c) => [a, b, c]);
}
