import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/types/search_ref.dart';

class ModifierItem {
  final int? cursorPosition;
  final String description;
  final String testID;
  final String term;

  ModifierItem({
    this.cursorPosition,
    required this.description,
    required this.testID,
    required this.term,
  });
}

class Modifier extends StatefulWidget {
  final ModifierItem item;
  final ValueChanged<String> setSearchValue;
  final String? searchValue;
  final GlobalKey<SearchRef> searchRef;

  Modifier({
    required this.item,
    required this.setSearchValue,
    this.searchValue,
    required this.searchRef,
  });

  @override
  _ModifierState createState() => _ModifierState();
}

class _ModifierState extends State<Modifier> {
  void handlePress() {
    addModifierTerm(widget.item.term);
  }

  void setNativeCursorPositionProp(int? position) {
    Future.delayed(Duration(milliseconds: 50), () {
      widget.searchRef.currentState?.setNativeProps(
        selection: TextSelection(
          baseOffset: position ?? 0,
          extentOffset: position ?? 0,
        ),
      );
    });
  }

  void addModifierTerm(String modifierTerm) {
    String newValue = '';
    if (widget.searchValue == null) {
      newValue = modifierTerm;
    } else if (widget.searchValue!.endsWith(' ')) {
      newValue = '${widget.searchValue}$modifierTerm';
    } else {
      newValue = '${widget.searchValue} $modifierTerm';
    }

    widget.setSearchValue(newValue);
    if (widget.item.cursorPosition != null) {
      int position = newValue.length + widget.item.cursorPosition!;
      setNativeCursorPositionProp(position);

      if (Theme.of(context).platform == TargetPlatform.android) {
        Future.delayed(Duration(milliseconds: 50), () {
          setNativeCursorPositionProp(null);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      action: handlePress,
      icon: 'plus-box-outline',
      inline: true,
      label: widget.item.term,
      testID: widget.item.testID,
      description: ' ${widget.item.description}',
      type: 'default',
      containerStyle: EdgeInsets.only(left: 20),
    );
  }
}
