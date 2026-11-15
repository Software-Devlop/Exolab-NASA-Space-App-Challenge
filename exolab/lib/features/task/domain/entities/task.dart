import 'package:flutter/material.dart';

class TaskEntity {
  final int? id; // null until persisted
  final String title;
  final String? description;
  final DateTime dateTimeCreated;
  final bool isImportant;
  final bool isRepeated;
  final List<String> dates;
  final List<TimeOfDay> time;
  final bool isDone;

  TaskEntity({
    this.id,
    required this.title,
    this.description,
    required this.dateTimeCreated,
    this.isImportant = false,
    this.isRepeated = false,
    this.dates = const [],
    this.time = const [],
    this.isDone = false,
  });

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTimeCreated,
    bool? isImportant,
    bool? isRepeated,
    List<String>? dates,
    List<TimeOfDay>? time,
    bool? isDone,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      isImportant: isImportant ?? this.isImportant,
      isRepeated: isRepeated ?? this.isRepeated,
      dates: dates ?? this.dates,
      time: time ?? this.time,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  String toString() {
    return '''
TaskEntity(
  id: $id,
  title: $title,
  description: $description,
  dateTimeCreated: $dateTimeCreated,
  isImportant: $isImportant,
  isRepeated: $isRepeated,
  isDone: $isDone,
  dates: ${dates.join(', ')},
  time: ${time.map((e) => '${e.hourOfPeriod.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')} ${e.period.name.toUpperCase()}').join(', ')}
)
''';
  }
}
