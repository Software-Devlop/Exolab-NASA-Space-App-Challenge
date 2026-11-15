import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/features/aiModel/domain/abstractRepos/aiRepo.dart';

class RunMLModel {
  final AIMLRepository repository;

  RunMLModel({required this.repository});

  Future<Either<ServerException, Unit>> call({
    required List<dynamic> input,
    required List<dynamic> output,
  }) async {
    return await repository.runModel(input, output);
  }
}
