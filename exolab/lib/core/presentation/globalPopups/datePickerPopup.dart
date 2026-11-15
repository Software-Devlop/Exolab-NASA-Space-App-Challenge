import 'package:exolab/core/presentation/globalWidgets/custElevatedButton.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<List<DateTime>?> showMultipleDatePicker(
  BuildContext context, {
  List<DateTime>? initialSelectedDates,
}) async {
  List<DateTime> selectedDates = List.from(initialSelectedDates ?? []);

  return showDialog<List<DateTime>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Dates'),
        content: SizedBox(
          width: 350,
          height: 350,
          child: SfDateRangePicker(
            backgroundColor: context.colors.surface,
            headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: context.colors.surface,
              textStyle: TextStyle(
                color: context.colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            selectionMode: DateRangePickerSelectionMode.multiple,
            initialSelectedDates: selectedDates,
            selectionColor: context.colors.primary,
            onSelectionChanged: (args) {
              selectedDates = List<DateTime>.from(args.value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.text.labelLarge!.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
          CustElevatedButton(
            onPressed: () {
              selectedDates.sort();
              Navigator.pop(context, selectedDates);
            },
            child: Text(
              'Set Dates',
              style: context.text.labelLarge!.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}
