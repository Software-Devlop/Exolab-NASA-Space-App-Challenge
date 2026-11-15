import 'package:exolab/core/presentation/globalPopups/datePickerPopup.dart';
import 'package:exolab/core/presentation/globalPopups/timeOfDayPopup.dart';
import 'package:exolab/core/presentation/globalWidgets/custElevatedButton.dart';
import 'package:exolab/core/presentation/globalWidgets/custTextField.dart';
import 'package:exolab/core/statics/constants.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:exolab/features/task/presentation/widgets/radioButtonSelections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<TaskEntity?> addEditTaskPopup(
  BuildContext context, {
  required String title,
  String? subtitle,
  bool barrierDismissible = true,
  TaskEntity? task,
}) {
  return showGeneralDialog<TaskEntity?>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withAlpha(110),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _AppPopupContent(title: title, subtitle: subtitle, task: task);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppPopupContent extends StatefulWidget {
  final String title;
  final String? subtitle;
  final TaskEntity? task;

  const _AppPopupContent({required this.title, this.subtitle, this.task});

  @override
  State<_AppPopupContent> createState() => _AppPopupContentState();
}

class _AppPopupContentState extends State<_AppPopupContent> {
  late final TextEditingController titleController;
  late final TextEditingController descController;

  bool isImportant = false;
  String dateOption = "Once";
  String timeOption = "No Time";

  List<WeekDays> chosenDays = [];
  List<DateTime> chosenDates = [];
  TimeOfDay? chosenTime;

  bool get isRepeatDate => dateOption == "Repeat";
  bool get isWithTime => timeOption == "At";

  void parseDates(
    List<String> dates, {
    required List<WeekDays> chosenDays,
    required List<DateTime> chosenDates,
  }) {
    if (dates.isEmpty) return;

    final firstDate = DateTime.tryParse(dates.first.trim());

    if (firstDate != null) {
      chosenDates.addAll(dates.map((e) => DateTime.parse(e.trim())));
    } else {
      chosenDays.addAll(
        dates.map(
          (e) => WeekDays.values.firstWhere((day) => day.name == e.trim()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descController = TextEditingController();

    if (widget.task != null) {
      setState(() {
        titleController.text = widget.task!.title;
        descController.text = widget.task!.description ?? "";
        isImportant = widget.task!.isImportant;
        if (!widget.task!.isRepeated) {
          dateOption = "Once";
        } else {
          dateOption = "Repeat";
        }
        parseDates(
          widget.task!.dates,
          chosenDays: chosenDays,
          chosenDates: chosenDates,
        );
        print(widget.task!.time.isNotEmpty);
        if (widget.task!.time.isNotEmpty) {
          timeOption = "At";
          chosenTime = widget.task!.time.first;
        } else {
          timeOption = "No Time";
        }
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkResponse(
                    onTap: () => Navigator.of(context).pop(),
                    radius: 18,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: scheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Content Form
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text
                      CustTextField(
                        textHint: "Title *",
                        controller: titleController,
                      ),
                      const SizedBox(height: 10),

                      // Description
                      CustTextField(
                        textHint: "Description",
                        controller: descController,
                      ),
                      const SizedBox(height: 10),

                      // Is important section
                      CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Set to important',
                          style: context.text.bodyMedium,
                        ),
                        value: isImportant,
                        onChanged: (bool? value) {
                          setState(() {
                            isImportant = value ?? !isImportant;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 10),

                      // Date Section
                      Text(
                        "Date",
                        style: context.text.labelLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustRadioButton(
                                  onOptionClick: () {
                                    setState(() {
                                      dateOption = "Once";
                                    });
                                  },
                                  onOptionChanged: (value) {
                                    setState(() {
                                      dateOption = "Once";
                                    });
                                  },
                                  optionLabel: "Once",
                                  selectedOption: dateOption,
                                  // isDisabled: isRepeatDate,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isRepeatDate
                                          ? context.theme.disabledColor
                                                .withAlpha(100)
                                          : context.colors.secondary,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            chosenDates.isEmpty
                                                ? "Select a date"
                                                : chosenDates
                                                      .map(
                                                        (e) => DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).format(e),
                                                      )
                                                      .join(', '),
                                            overflow: TextOverflow.ellipsis,
                                            style: context.text.bodyMedium!
                                                .copyWith(
                                                  color: isRepeatDate
                                                      ? context
                                                            .theme
                                                            .disabledColor
                                                      : context
                                                            .colors
                                                            .onSurface,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: isRepeatDate
                                              ? null
                                              : () async {
                                                  final List<DateTime>? dates =
                                                      await showMultipleDatePicker(
                                                        context,
                                                        initialSelectedDates:
                                                            chosenDates,
                                                      );

                                                  if (dates != null) {
                                                    setState(() {
                                                      chosenDates = dates;
                                                    });
                                                    print(chosenDates);
                                                  }
                                                },
                                          child: Icon(
                                            Icons.calendar_month_rounded,
                                            color: !isRepeatDate
                                                ? context.colors.primary
                                                : context.theme.disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustRadioButton(
                                  onOptionClick: () {
                                    setState(() {
                                      dateOption = "Repeat";
                                    });
                                  },
                                  onOptionChanged: (value) {
                                    setState(() {
                                      dateOption = "Repeat";
                                    });
                                  },
                                  optionLabel: "Repeat",
                                  selectedOption: dateOption,
                                  // isDisabled: !isRepeatDate,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: WeekDays.values.map((e) {
                                    final isOn = chosenDays.contains(e);
                                    return CustElevatedButton(
                                      width: 35,
                                      height: 35,
                                      padding: const EdgeInsets.all(1),
                                      borderRadius: BorderRadius.circular(12),
                                      bgColor: isOn
                                          ? context.colors.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isRepeatDate
                                            ? isOn
                                                  ? context.colors.primary
                                                  : context.colors.secondary
                                            : context.theme.disabledColor
                                                  .withAlpha(100),
                                      ),
                                      disableColor: Colors.transparent,
                                      isDisabled: !isRepeatDate,
                                      onPressed: () {
                                        setState(() {
                                          if (!chosenDays.contains(e)) {
                                            chosenDays.add(e);
                                          } else {
                                            chosenDays.remove(e);
                                          }
                                        });
                                        print(e);
                                      },
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            e.name,
                                            style: context.text.labelLarge!
                                                .copyWith(
                                                  color: isRepeatDate
                                                      ? isOn
                                                            ? context
                                                                  .colors
                                                                  .onPrimary
                                                            : context
                                                                  .colors
                                                                  .onSurface
                                                      : context
                                                            .theme
                                                            .disabledColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Time Section
                      Text(
                        "Time",
                        style: context.text.labelLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustRadioButton(
                            onOptionClick: () {
                              setState(() {
                                timeOption = "No Time";
                              });
                            },
                            onOptionChanged: (value) {
                              setState(() {
                                timeOption = "No Time";
                              });
                            },
                            optionLabel: "No Time",
                            selectedOption: timeOption,
                            // isDisabled: isWithTime,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 3,
                                child: CustRadioButton(
                                  onOptionClick: () {
                                    setState(() {
                                      timeOption = "At";
                                    });
                                  },
                                  onOptionChanged: (value) {
                                    setState(() {
                                      timeOption = "At";
                                    });
                                  },
                                  optionLabel: "At",
                                  selectedOption: timeOption,
                                  // isDisabled: !isWithTime,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !isWithTime
                                          ? context.theme.disabledColor
                                                .withAlpha(100)
                                          : context.colors.secondary,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          chosenTime == null
                                              ? "Select a time"
                                              : chosenTime!.format(context),
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: !isWithTime
                                                    ? context
                                                          .theme
                                                          .disabledColor
                                                    : context.colors.onSurface,
                                              ),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: !isWithTime
                                              ? null
                                              : () async {
                                                  final time =
                                                      await showCustomTimePicker(
                                                        context,
                                                        initialTime: chosenTime,
                                                      );
                                                  if (time != null) {
                                                    setState(() {
                                                      chosenTime = time;
                                                    });
                                                  }
                                                },
                                          child: Icon(
                                            Icons.access_time_filled_rounded,
                                            color: isWithTime
                                                ? context.colors.primary
                                                : context.theme.disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(color: scheme.onSurface.withAlpha(40)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        print("Is with time: ${isWithTime}");
                        final result = TaskEntity(
                          title: titleController.text.trim(),
                          dateTimeCreated: DateTime.now(),
                          description: descController.text.trim(),
                          dates: !isRepeatDate
                              ? chosenDates.map((e) => e.toString()).toList()
                              : chosenDays.map((e) => e.name).toList(),
                          isImportant: isImportant,
                          isRepeated: isRepeatDate,
                          time: isWithTime
                              ? [chosenTime ?? TimeOfDay(hour: 9, minute: 0)]
                              : [],
                        );
                        print(result.toString());
                        Navigator.of(context).pop(result);
                      },
                      child: const Text("Add"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
