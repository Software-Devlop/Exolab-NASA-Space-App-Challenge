import 'package:exolab/features/aiModel/data/datasources/aiMlDatasource.dart';
import 'package:exolab/features/aiModel/data/repositories/aiRepo.dart';
import 'package:exolab/features/aiModel/domain/abstractRepos/aiRepo.dart';
import 'package:exolab/features/aiModel/domain/usecases/runMLModel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controller State
class AIMLController {
  final bool mlLoading;
  final String? mlError;
  final bool isInitialized;
  final List<dynamic> output;

  const AIMLController({
    this.mlLoading = false,
    this.mlError,
    this.isInitialized = false,
    this.output = const [],
  });

  AIMLController copyWith({
    bool? mlLoading,
    String? Function()? mlError,
    bool? isInitialized,
    List<dynamic>? output,
  }) {
    return AIMLController(
      mlLoading: mlLoading ?? this.mlLoading,
      mlError: mlError != null ? mlError() : this.mlError,
      isInitialized: isInitialized ?? this.isInitialized,
      output: output ?? this.output,
    );
  }
}

// Controller Manager
class AIMLControllerManager extends Notifier<AIMLController> {
  @override
  AIMLController build() {
    return const AIMLController();
  }

  Future<void> initialize() async {
    if (state.isInitialized || state.mlLoading) return;

    debugPrint('ML: Starting initialization');

    state = state.copyWith(mlLoading: true, mlError: () => null, output: []);

    try {
      await ref.read(aiMLDataSourceProvider).initialize();

      debugPrint('ML: Initialization successful');

      state = state.copyWith(
        mlLoading: false,
        mlError: () => null,
        isInitialized: true,
      );
    } catch (e) {
      debugPrint('ML: Initialization failed: $e');

      state = state.copyWith(
        mlLoading: false,
        mlError: () => e.toString(),
        isInitialized: false,
      );
    }
  }

  Future<void> runModel({
    required List<dynamic> input,
    required List<dynamic> output,
  }) async {
    debugPrint('ML: runModel called');
    debugPrint('ML initialized: ${state.isInitialized}');

    if (!state.isInitialized) {
      state = state.copyWith(
        mlError: () => 'ML model is not initialized.',
        output: [],
      );
      return;
    }

    state = state.copyWith(mlLoading: true, mlError: () => null, output: []);

    try {
      debugPrint('ML: Starting inference');

      final result = await ref.read(runMLModelProvider)(
        input: input,
        output: output,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            mlLoading: false,
            mlError: () => failure.message,
            output: [],
          );
        },
        (_) {
          final modelOutput = output.map((row) {
            return row is List ? List<dynamic>.from(row) : row;
          }).toList();

          state = state.copyWith(
            mlLoading: false,
            mlError: () => null,
            output: modelOutput,
          );
        },
      );

      debugPrint('ML: Loading state: ${state.mlLoading}');
      debugPrint('ML: Final output: ${state.output}');
    } catch (e) {
      state = state.copyWith(
        mlLoading: false,
        mlError: () => e.toString(),
        output: [],
      );

      debugPrint('ML: Inference exception: $e');
    }
  }
}

final aiMLControllerProvider =
    NotifierProvider<AIMLControllerManager, AIMLController>(
      AIMLControllerManager.new,
    );

final aiMLDataSourceProvider = Provider<AIMLDataSource>((ref) {
  final dataSource = AIMLDataSourceImpl();

  ref.onDispose(() {
    dataSource.dispose();
  });

  return dataSource;
});

final aiMLRepositoryProvider = Provider<AIMLRepository>(
  (ref) => AIMLRepositoryImpl(dataSource: ref.watch(aiMLDataSourceProvider)),
);

final runMLModelProvider = Provider<RunMLModel>(
  (ref) => RunMLModel(repository: ref.watch(aiMLRepositoryProvider)),
);
