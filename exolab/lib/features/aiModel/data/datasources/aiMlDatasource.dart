import 'package:flutter/foundation.dart';
import 'package:flutter_litert/flutter_litert.dart';

abstract class AIMLDataSource {
  Future<void> initialize();

  Future<void> runModel(List<dynamic> input, List<dynamic> output);

  void dispose();
}

class AIMLDataSourceImpl implements AIMLDataSource {
  Interpreter? _interpreter;

  @override
  Future<void> initialize() async {
    debugPrint('DATASOURCE initialize: ${identityHashCode(this)}');

    if (_interpreter != null) {
      debugPrint('DATASOURCE: Interpreter already initialized.');
      return;
    }

    try {
      debugPrint('DATASOURCE: Loading TFLite model...');

      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

      _interpreter!.allocateTensors();

      debugPrint('DATASOURCE: Interpreter initialized successfully.');
      debugPrint('DATASOURCE: Interpreter null: ${_interpreter == null}');
    } catch (e) {
      debugPrint('DATASOURCE initialization error: $e');

      _interpreter = null;
      rethrow;
    }
  }

  @override
  Future<void> runModel(List<dynamic> input, List<dynamic> output) async {
    debugPrint('DATASOURCE runModel: ${identityHashCode(this)}');

    debugPrint('INTERPRETER null: ${_interpreter == null}');

    if (_interpreter == null) {
      throw StateError('Model is not initialized.');
    }

    try {
      debugPrint('DATASOURCE: Running inference...');

      _interpreter!.run(input, output);

      debugPrint('DATASOURCE: Inference completed.');
      debugPrint('DATASOURCE: Output: $output');
    } catch (e) {
      debugPrint('DATASOURCE inference error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    debugPrint('DATASOURCE dispose: ${identityHashCode(this)}');

    debugPrint(
      'DATASOURCE: Closing interpreter. Null: ${_interpreter == null}',
    );

    _interpreter?.close();
    _interpreter = null;

    debugPrint('DATASOURCE: Interpreter disposed.');
  }
}
