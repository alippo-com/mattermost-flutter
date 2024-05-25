// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

void useWhyDidYouUpdate(String name, Map props) {
  final previousProps = ValueNotifier<Map?>(null);

  useEffect(() {
    if (previousProps.value != null) {
      final allKeys = {...previousProps.value!.keys, ...props.keys};
      final changesObj = <String, dynamic>{};

      for (var key in allKeys) {
        if (previousProps.value![key] != props[key]) {
          changesObj[key] = {
            'from': previousProps.value![key],
            'to': props[key],
          };
        }
      }

      if (changesObj.isNotEmpty) {
        debugPrint('[why-did-you-update] $name $changesObj');
      }
    }
    previousProps.value = props;
  });
}

void useEffect(void Function() effect) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    effect();
  });
}
