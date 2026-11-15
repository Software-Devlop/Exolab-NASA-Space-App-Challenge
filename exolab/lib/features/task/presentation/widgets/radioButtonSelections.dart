import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';

class RadioButtonSelections extends StatefulWidget {
  final String option1Label;
  final String option2Label;
  final void Function(String?) onOptionChanged;
  final VoidCallback? onOption1Click;
  final VoidCallback? onOption2Click;
  const RadioButtonSelections({
    super.key,
    this.option1Label = "",
    this.option2Label = "",
    required this.onOptionChanged,
    this.onOption1Click,
    this.onOption2Click,
  });

  @override
  State<RadioButtonSelections> createState() => _RadioButtonSelectionsState();
}

class _RadioButtonSelectionsState extends State<RadioButtonSelections> {
  late String selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.option1Label;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: CustRadioButton(
            onOptionClick: widget.onOption1Click,
            onOptionChanged: (value) {
              setState(() {
                selectedOption = value!;
                widget.onOptionChanged(value);
              });
            },
            optionLabel: widget.option1Label,
            selectedOption: selectedOption,
          ),
        ),
        Flexible(
          child: CustRadioButton(
            onOptionClick: widget.onOption2Click,
            onOptionChanged: (value) {
              setState(() {
                selectedOption = value!;
                widget.onOptionChanged(value);
              });
            },
            optionLabel: widget.option2Label,
            selectedOption: selectedOption,
          ),
        ),
      ],
    );
  }
}

class CustRadioButton extends StatelessWidget {
  final String optionLabel;
  final void Function(String?)? onOptionChanged;
  final VoidCallback? onOptionClick;
  final String? selectedOption;
  final bool isDisabled;

  const CustRadioButton({
    super.key,
    this.optionLabel = "",
    this.onOptionChanged,
    this.onOptionClick,
    this.selectedOption,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // Ensures the entire row area registers taps
      onTap: () {
        onOptionChanged?.call(optionLabel);
        onOptionClick?.call();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: optionLabel,
            groupValue: selectedOption,
            onChanged: onOptionChanged,
          ),
          Flexible(
            child: Text(
              optionLabel,
              style: context.text.bodyMedium!.copyWith(
                color: isDisabled
                    ? context.theme.disabledColor
                    : context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
