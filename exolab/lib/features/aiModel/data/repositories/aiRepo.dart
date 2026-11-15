import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/features/aiModel/data/datasources/aiMlDatasource.dart';
import 'package:exolab/features/aiModel/domain/abstractRepos/aiRepo.dart';

class AIMLRepositoryImpl implements AIMLRepository {
  final AIMLDataSource dataSource;

  AIMLRepositoryImpl({required this.dataSource});

  @override
  Future<Either<ServerException, Unit>> runModel(
    List<dynamic> input,
    List<dynamic> output,
  ) async {
    try {
      await dataSource.runModel(input, output);
      return right(unit);
    } catch (e) {
      return left(ServerException('ML inference error: $e'));
    }
  }
}
