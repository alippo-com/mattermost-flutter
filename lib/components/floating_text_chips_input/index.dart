
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'selected_chip.dart';

const double USER_CHIP_HEIGHT = 40.0; // Adjust as necessary
const double BORDER_DEFAULT_WIDTH = 1.0;
const double BORDER_FOCUSED_WIDTH = 2.0;

class FloatingTextChipsInput extends StatefulWidget {
  final String textInputValue;
  final TextStyle? textInputStyle;
  final ValueChanged<String> onTextInputChange;
  final VoidCallback onTextInputSubmitted;
  final List<String>? chipsValues;
  final ValueChanged<String> onChipRemove;
  final ThemeData theme;
  final TextStyle? labelTextStyle;
  final String label;
  final bool editable;
  final String? error;
  final String errorIcon;
  final bool isKeyboardInput;
  final VoidCallback? onBlur;
  final VoidCallback? onFocus;
  final VoidCallback? onLayout;
  final VoidCallback? onPress;
  final String? placeholder;
  final bool showErrorIcon;
  final String? testID;

  const FloatingTextChipsInput({
    Key? key,
    required this.textInputValue,
    required this.textInputStyle,
    required this.onTextInputChange,
    required this.onTextInputSubmitted,
    required this.chipsValues,
    required this.onChipRemove,
    required this.theme,
    required this.labelTextStyle,
    required this.label,
    required this.editable,
    required this.error,
    required this.errorIcon,
    required this.isKeyboardInput,
    required this.onBlur,
    required this.onFocus,
    required this.onLayout,
    required this.onPress,
    required this.placeholder,
    required this.showErrorIcon,
    required this.testID,
  }) : super(key: key);

  @override
  _FloatingTextChipsInputState createState() => _FloatingTextChipsInputState();
}

class _FloatingTextChipsInputState extends State<FloatingTextChipsInput> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textInputValue);
    _focusNode = FocusNode();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _labelAnimation = Tween<double>(begin: 0.0, end: -16.0).animate(_animationController);

    _focusNode.addListener(() {
      setState(() {
        _focused = _focusNode.hasFocus;
        if (_focused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final inputTextStyle = widget.textInputStyle ?? TextStyle(color: theme.textTheme.bodyText1?.color);

    return GestureDetector(
      onTap: widget.onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: widget.labelTextStyle ?? TextStyle(color: theme.textTheme.caption?.color),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: _focused ? theme.primaryColor : theme.dividerColor),
                  ),
                ),
                style: inputTextStyle,
                onChanged: widget.onTextInputChange,
                onSubmitted: (_) => widget.onTextInputSubmitted(),
              ),
              Positioned(
                top: _labelAnimation.value,
                left: 16.0,
                child: AnimatedBuilder(
                  animation: _labelAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _labelAnimation.value),
                    child: Text(
                      widget.label,
                      style: widget.labelTextStyle ?? inputTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.chipsValues != null && widget.chipsValues!.isNotEmpty)
            Wrap(
              children: widget.chipsValues!.map((chipValue) {
                return SelectedChip(
                  key: ValueKey(chipValue),
                  id: chipValue,
                  text: chipValue,
                  onRemove: widget.onChipRemove,
                );
              }).toList(),
            ),
          if (widget.error != null)
            Row(
              children: [
                if (widget.showErrorIcon)
                  Icon(
                    Icons.error_outline,
                    color: theme.errorColor,
                  ),
                Text(
                  widget.error!,
                  style: TextStyle(color: theme.errorColor),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
