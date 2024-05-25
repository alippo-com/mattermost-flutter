
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BooleanListProvider with ChangeNotifier {
  List<bool> _items = [];

  List<bool> get items => _items;

  void addItem(bool item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(bool item) {
    _items.remove(item);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BooleanListProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var booleanList = Provider.of<BooleanListProvider>(context);
    return ListView.builder(
      itemCount: booleanList.items.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          value: booleanList.items[index],
          onChanged: (bool? newValue) {
            // Update the item
            booleanList.items[index] = newValue ?? false;
            booleanList.notifyListeners();
          },
        );
      },
    );
  }
}
