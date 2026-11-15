import 'package:flutter/material.dart';

class SomethingEntry {
  final String sensing;
  final String reading;
  final String state;
  final String personalRange;
  final String source;
  final String updates;
  final String lastSync;

  const SomethingEntry({
    required this.sensing,
    required this.reading,
    required this.state,
    required this.personalRange,
    required this.source,
    required this.updates,
    required this.lastSync,
  });

  bool get isHigh => state.toUpperCase() == 'HIGH';
  bool get isLow => state.toUpperCase() == 'LOW';

  Color get statusColor {
    if (isHigh || isLow) return const Color(0xFFBE3030);
    return const Color(0xFF137B64);
  }
}
