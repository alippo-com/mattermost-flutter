
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/post_action_option.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/components/autocomplete_selector.dart';
import 'package:mattermost_flutter/actions/remote/integrations.dart';

class ActionMenu extends StatefulWidget {
  final String? dataSource;
  final String? defaultOption;
  final bool? disabled;
  final String id;
  final String name;
  final List<PostActionOption>? options;
  final String postId;

  ActionMenu({
    this.dataSource,
    this.defaultOption,
    this.disabled,
    required this.id,
    required this.name,
    this.options,
    required this.postId,
  });

  @override
  _ActionMenuState createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selected;
  late String serverUrl;

  @override
  void initState() {
    super.initState();
    serverUrl = useServerUrl();
    if (widget.defaultOption != null && widget.options != null) {
      final isSelected = widget.options!.firstWhere((option) => option.value == widget.defaultOption, orElse: () => null);
      selected = isSelected?.value;
    }
  }

  Future<void> handleSelect(SelectedDialogOption? selectedItem) async {
    if (selectedItem == null || selectedItem is List) {
      return;
    }

    final result = await selectAttachmentMenuAction(serverUrl, widget.postId, widget.id, selectedItem.value);
    if (result.data?.triggerId != null) {
      setState(() {
        selected = selectedItem.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutocompleteSelector(
      placeholder: widget.name,
      dataSource: widget.dataSource,
      isMultiselect: false,
      options: widget.options,
      selected: selected,
      onSelected: handleSelect,
      disabled: widget.disabled,
      testID: 'message_attachment.${widget.name}',
    );
  }
}
