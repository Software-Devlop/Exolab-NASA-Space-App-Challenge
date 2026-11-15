import 'package:flutter_litert/flutter_litert.dart';

class StressModelSource {
  final Interpreter _interpreter;
  StressModelSource._(this._interpreter);

  static Future<StressModelSource> load() async {
    final interpreter = await Interpreter.fromAsset(
      'assets/models/wesad_stress_mlp.tflite',
    );
    return StressModelSource._(interpreter);
  }

  /// Returns P(stress). Handles both [1,1] sigmoid and [1,2] softmax outputs.
  double run(List<double> input) {
    final outLen = _interpreter.getOutputTensor(0).shape.last;
    final output = [List<double>.filled(outLen, 0.0)];
    _interpreter.run([input], output);
    return outLen == 1 ? output[0][0] : output[0][1];
  }

  void close() => _interpreter.close();
}
