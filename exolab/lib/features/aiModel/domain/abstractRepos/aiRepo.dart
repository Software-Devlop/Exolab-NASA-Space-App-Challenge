import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';

abstract class AIMLRepository {
  Future<Either<ServerException, Unit>> runModel(
    List<dynamic> input,
    List<dynamic> output,
  );
}
