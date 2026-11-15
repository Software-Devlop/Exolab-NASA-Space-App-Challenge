class StressFeatures {
  final double bvpMean, bvpStd, edaMean, edaStd, edaScrCount;
  final double tempMean, tempStd, tempTrend, accSma, accVmStd;

  const StressFeatures({
    required this.bvpMean,
    required this.bvpStd,
    required this.edaMean,
    required this.edaStd,
    required this.edaScrCount,
    required this.tempMean,
    required this.tempStd,
    required this.tempTrend,
    required this.accSma,
    required this.accVmStd,
  });

  // Order MUST match the training "features" list.
  List<double> toList() => [
    bvpMean,
    bvpStd,
    edaMean,
    edaStd,
    edaScrCount,
    tempMean,
    tempStd,
    tempTrend,
    accSma,
    accVmStd,
  ];
}
