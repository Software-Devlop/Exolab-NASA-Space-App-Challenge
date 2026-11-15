import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  return showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            surface: context.colors.surface,
            primary: context.colors.primary,
            onSurface: context.colors.onSurface,
          ),
        ),
        child: child!,
      );
    },
  );
}
