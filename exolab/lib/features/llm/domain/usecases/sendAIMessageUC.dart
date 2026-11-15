import 'package:dartz/dartz.dart';
import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/features/llm/domain/abstractRepos/aiRepo.dart';
import 'package:exolab/features/llm/domain/entities/chat.dart';

class SendLlmMessageUC {
  final llmRepository repository;

  SendLlmMessageUC(this.repository);

  Future<Either<ServerException, ChatMessage>> execute(String message) {
    return repository.sendMessage(message);
  }
}
