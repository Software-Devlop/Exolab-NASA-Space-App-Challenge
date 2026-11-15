import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/features/llm/domain/entities/chat.dart';

abstract class llmRepository {
  Future<Either<ServerException, ChatMessage>> sendMessage(String message);
}
