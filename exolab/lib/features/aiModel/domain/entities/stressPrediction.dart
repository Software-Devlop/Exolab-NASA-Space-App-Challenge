enum StressLabel { baseline, stress }

class StressPrediction {
  final StressLabel label;
  final double stressProbability; // 0..1

  const StressPrediction({
    required this.label,
    required this.stressProbability,
  });
}
