import 'package:exolab/core/presentation/globalPopups/questionPopup.dart';
import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
import 'package:exolab/core/presentation/globalWidgets/custIconButton.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:exolab/features/task/presentation/controllers/taskController.dart';
import 'package:exolab/features/task/presentation/widgets/taskManagementPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HealthTasksWidget extends ConsumerStatefulWidget {
  final String note;
  final String bigNote;
  final double percentage;
  final List<TaskEntity> task;
  const HealthTasksWidget({
    super.key,
    this.note = "",
    this.percentage = 0,
    required this.bigNote,
    required this.task,
  });

  @override
  ConsumerState<HealthTasksWidget> createState() => _HealthTasksWidgetState();
}

class _HealthTasksWidgetState extends ConsumerState<HealthTasksWidget> {
  bool isChecked = false;
  String dateOption = "";
  String timeOption = "";

  @override
  Widget build(BuildContext context) {
    return CustContainer(
      height: 422,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/icons/leaf.svg"),
                  const SizedBox(width: 10),
                  Text(
                    "Health Habits",
                    style: context.text.titleMedium!.copyWith(
                      // color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 15),
                  CustIconButton(
                    padding: EdgeInsets.all(1),
                    bgColor: context.colors.secondary,
                    child: Icon(
                      Icons.add_rounded,
                      color: context.colors.primary,
                    ),
                    onPressed: () async {
                      final newTask = await addEditTaskPopup(
                        context,
                        title: "Add task",
                        subtitle: "Select the details that suits you",
                      );

                      if (newTask != null) {
                        print(newTask.toString());
                        await ref
                            .read(taskControllerProvider.notifier)
                            .addTask(newTask);
                      } else {
                        print("New task is null");
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(widget.note, style: context.text.labelSmall),
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: context.colors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 140 * widget.percentage,
                          height: 14,
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Center(
                          child: Text(
                            "${(widget.percentage * 100).round()}%",
                            style: context.text.labelSmall!.copyWith(
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),
          // Big Note
          Text(
            widget.bigNote,
            style: context.text.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Column(
            children: widget.task
                .map(
                  (task) => TaskWidget(
                    task: task,
                    onPressed: () {
                      ref
                          .read(taskControllerProvider.notifier)
                          .toggleDone(task);
                    },
                    onDelete: () async {
                      final bool allowDelete =
                          await showQuestionPopup(
                            context,
                            title: "Delete task",
                            subtitle:
                                "Are you sure you want to delete this task?",
                            confirmColor: context.colors.error,
                          ) ??
                          false;

                      if (task.id != null && allowDelete) {
                        ref
                            .read(taskControllerProvider.notifier)
                            .deleteTask(task.id!);
                      }
                    },
                    onMoreSettings: () async {
                      final bool allowEdit =
                          await showQuestionPopup(
                            context,
                            title: "More Info",
                            subtitle: [
                              if (task.description?.isNotEmpty == true)
                                "Description: ${task.description}",
                              "Dates: ${task.dates.join(', ')}",
                              'To be done at: ${task.time.isEmpty ? '(No time)' : task.time.first.format(context)}',
                            ].join('\n'),
                            confirmColor: context.colors.tertiary,
                            confirmText: "Edit",
                          ) ??
                          false;

                      if (allowEdit) {
                        final result = await addEditTaskPopup(
                          context,
                          title: "Add task",
                          subtitle: "Update your task",
                          task: task,
                        );
                        if (result != null) {
                          final updatedTask = task.copyWith(
                            title: result.title,
                            description: result.description,
                            dates: result.dates,
                            isImportant: result.isImportant,
                            isRepeated: result.isRepeated,
                            time: result.time,
                          );
                          await ref
                              .read(taskControllerProvider.notifier)
                              .updateTask(updatedTask);
                        }
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TaskWidget extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onPressed;
  final VoidCallback? onDelete;
  final VoidCallback? onMoreSettings;
  const TaskWidget({
    super.key,
    required this.task,
    required this.onPressed,
    this.onDelete,
    this.onMoreSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onDelete,
      onDoubleTap: onMoreSettings,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        color: context.colors.surface,
        child: Row(
          children: [
            Icon(
              task.isDone
                  ? Icons.check_circle_outline_rounded
                  : Icons.circle_outlined,
              color: task.isDone
                  ? context.colors.primary.withAlpha(150)
                  : context.colors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.title.toFirstCapital(),
                style: context.text.bodyMedium!.copyWith(
                  color: task.isDone
                      ? context.colors.onSurface.withAlpha(150)
                      : context.colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 15),
            if (task.isImportant)
              Icon(
                Icons.error_outline_rounded,
                color: task.isDone
                    ? context.colors.primary.withAlpha(150)
                    : context.colors.primary.withAlpha(200),
              ),
            const SizedBox(width: 10),
            Text(
              task.time.isEmpty ? '' : task.time.first.format(context),
              style: context.text.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
