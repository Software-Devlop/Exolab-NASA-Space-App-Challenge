import 'dart:convert';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:flutter/material.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    super.id,
    required super.title,
    super.description,
    required super.dateTimeCreated,
    super.isImportant,
    super.isRepeated,
    super.dates,
    super.time,
    super.isDone,
  });

  factory TaskModel.fromEntity(TaskEntity e) => TaskModel(
    id: e.id,
    title: e.title,
    description: e.description,
    dateTimeCreated: e.dateTimeCreated,
    isImportant: e.isImportant,
    isRepeated: e.isRepeated,
    dates: e.dates,
    time: e.time,
    isDone: e.isDone,
  );

  factory TaskModel.fromMap(Map<String, Object?> map) {
    final rawDates = jsonDecode(map['dates'] as String) as List<dynamic>;
    final rawTimes = jsonDecode(map['times'] as String) as List<dynamic>;

    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateTimeCreated: DateTime.parse(map['date_time_created'] as String),
      isImportant: (map['is_important'] as int) == 1,
      isRepeated: (map['is_repeated'] as int) == 1,
      dates: rawDates.map((e) => e as String).toList(),
      time: rawTimes.map((e) {
        final parts = (e as String).split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList(),
      isDone: (map['is_done'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    String two(int n) => n.toString().padLeft(2, '0');
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date_time_created': dateTimeCreated.toIso8601String(),
      'is_important': isImportant ? 1 : 0,
      'is_repeated': isRepeated ? 1 : 0,
      'dates': jsonEncode(dates),
      'times': jsonEncode(
        time.map((t) => '${two(t.hour)}:${two(t.minute)}').toList(),
      ),
      'is_done': isDone ? 1 : 0,
    };
  }
}
