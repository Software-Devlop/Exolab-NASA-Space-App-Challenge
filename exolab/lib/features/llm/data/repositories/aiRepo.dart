import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/features/llm/data/datasources/localDataSource.dart';
import 'package:exolab/features/llm/domain/abstractRepos/aiRepo.dart';
import 'package:exolab/features/llm/domain/entities/chat.dart';

class llmRepositoryImpl implements llmRepository {
  final llmLocalDataSource dataSource;

  llmRepositoryImpl({required this.dataSource});

  @override
  Future<Either<ServerException, ChatMessage>> sendMessage(
    String message,
  ) async {
    try {
      final response = await dataSource.sendMessage(message);

      return right(ChatMessage(message: response, dateTime: DateTime.now()));
    } catch (e) {
      return left(ServerException('llm error: $e'));
    }
  }
}
