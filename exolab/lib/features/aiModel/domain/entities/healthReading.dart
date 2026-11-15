class HealthReading {
  final double heartRate;
  final double spo2;
  final double skinTemp;
  final double hrvRmssd;
  final double sleepHours;
  final double eda;

  const HealthReading({
    required this.heartRate,
    required this.spo2,
    required this.skinTemp,
    required this.hrvRmssd,
    required this.sleepHours,
    required this.eda,
  });
}
