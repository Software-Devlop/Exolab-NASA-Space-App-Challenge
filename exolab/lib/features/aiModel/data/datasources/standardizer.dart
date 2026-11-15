import 'dart:convert';
import 'package:flutter/services.dart';

class Standardizer {
  final List<double> mean;
  final List<double> scale;

  Standardizer(this.mean, this.scale);

  static Future<Standardizer> load() async {
    final raw = await rootBundle.loadString(
      'assets/models/wesad_scaler_data.json',
    );
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return Standardizer(
      (j['mean'] as List).map((e) => (e as num).toDouble()).toList(),
      (j['scale'] as List).map((e) => (e as num).toDouble()).toList(),
    );
  }

  List<double> transform(List<double> x) =>
      List.generate(x.length, (i) => (x[i] - mean[i]) / scale[i]);
}
