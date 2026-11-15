import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/llm/data/datasources/localDataSource.dart';
import 'package:exolab/features/llm/data/repositories/aiRepo.dart';
import 'package:exolab/features/llm/domain/abstractRepos/aiRepo.dart';
import 'package:exolab/features/llm/domain/entities/chat.dart';
import 'package:exolab/features/llm/domain/usecases/sendAIMessageUC.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LlmController {
  final bool aiLoading;
  final String? aiError;
  final List<Chat> chats;
  final int currentChat;
  const LlmController({
    this.aiError,
    this.aiLoading = false,
    this.chats = const [],
    this.currentChat = 0,
  });

  LlmController copyWith({
    bool? aiLoading,
    List<Chat>? chats,
    String? Function()? aiError,
    int? currentChat,
  }) {
    return LlmController(
      aiLoading: aiLoading ?? this.aiLoading,
      aiError: aiError != null ? aiError() : this.aiError,
      chats: chats ?? this.chats,
      currentChat: currentChat ?? this.currentChat,
    );
  }
}

class LlmControllerManager extends Notifier<LlmController> {
  @override
  LlmController build() {
    // 5. Mandatory build method required by Riverpod Notifier
    return const LlmController();
  }

  set currentChat(int newChatIndex) {
    state = state.copyWith(currentChat: newChatIndex);
  }

  void addMessage() {
    state = state.copyWith(
      chats: [
        //         Chat(
        //           userMessage: ChatMessage(
        //             message: "nothing",
        //             dateTime: DateTime.now(),
        //           ),
        //           aiMessage: ChatMessage(
        //             message:
        //                 """* [30-minute walk](app://tasks/create%3Ftitle%3D30-minute%2520walk%26description%3DGo%2520for%2520a%252030-minute%2520walk%2520to%2520improve%2520cardiovascular%2520fitness%26isImportant%3Dfalse%26isRepeated%3Dtrue%26dates%3D2026-11-13%26time%3D07:30%26time%3D17:00)
        // * [Drink water](app://tasks/create%3Ftitle%3DDrink%2520water%26description%3DDrink%2520a%2520glass%2520of%2520water%2520and%2520stay%2520hydrated%2520throughout%2520the%2520day%26isImportant%3Dtrue%26isRepeated%3Dtrue%26dates%3D2026-11-13%26time%3D09:00%26time%3D12:00%26time%3D15:00%26time%3D18:00)
        // * [Take prescribed medication](app://tasks/create%3Ftitle%3DTake%2520prescribed%2520medication%26description%3DTake%2520your%2520medication%2520according%2520to%2520your%2520prescription%26isImportant%3Dtrue%26isRepeated%3Dtrue%26dates%3D2026-11-13%26time%3D08:00)
        // * [Stretching exercises](app://tasks/create%3Ftitle%3DStretching%2520exercises%26description%3DPerform%252010%2520minutes%2520of%2520gentle%2520stretching%2520to%2520reduce%2520muscle%2520stiffness%26isImportant%3Dfalse%26isRepeated%3Dtrue%26dates%3D2026-11-13%26time%3D10:00%26time%3D16:00)
        // * [Eat a healthy breakfast](app://tasks/create%3Ftitle%3DEat%2520a%2520healthy%2520breakfast%26description%3DHave%2520a%2520balanced%2520breakfast%2520containing%2520protein%252C%2520fiber%252C%2520and%2520healthy%2520fats%26isImportant%3Dtrue%26isRepeated%3Dtrue%26dates%3D2026-11-13%26time%3D08:30)
        // * [Attend medical checkup](app://tasks/create%3Ftitle%3DAttend%2520medical%2520checkup%26description%3DAttend%2520your%2520scheduled%2520medical%2520appointment%26isImportant%3Dtrue%26isRepeated%3Dfalse%26dates%3D2026-11-16%26time%3D11:30)""",
        //             dateTime: DateTime.now(),
        //           ),
        //         ),
      ],
    );
  }

  Future<String> analyzeData(String text) async {
    final result = await ref.read(llmSenderUCProvider).execute(text);
    if (result.isLeft()) {
      return "Error: ${result.getLeft()}";
    }
    return result.getRight().message;
  }

  Future<void> sendMessage(String text, {bool isAutoUpdatePage = true}) async {
    print("I have received order form UI (Control Manager)");

    final newChat = Chat(
      userMessage: ChatMessage(message: text, dateTime: DateTime.now()),
    );

    final updatedChats = [...state.chats, newChat];
    final newIndex = updatedChats.length - 1; // 0-based index

    // 1. Update state atomically
    state = state.copyWith(
      aiLoading: true,
      aiError: () => null,
      chats: updatedChats,
      currentChat: isAutoUpdatePage ? newIndex : state.currentChat,
    );

    final result = await ref.read(llmSenderUCProvider).execute(text);

    // Create a mutable copy of the current list for updating the response
    final currentChatsList = [...state.chats];

    if (result.isLeft()) {
      state = state.copyWith(
        aiLoading: false,
        aiError: () => result.getLeft().message,
      );
    } else {
      final updatedChatWithResponse = newChat.addResponse(
        ChatMessage(
          message: result.getRight().message,
          dateTime: result.getRight().dateTime,
        ),
      );

      if (newIndex < currentChatsList.length) {
        currentChatsList[newIndex] = updatedChatWithResponse;
      }

      state = state.copyWith(
        aiLoading: false,
        aiError: () => null,
        chats: currentChatsList,
      );
    }
  }
}

// 6. Don't forget to expose your Notifier via a Provider:
final llmControllerProvider =
    NotifierProvider<LlmControllerManager, LlmController>(
      LlmControllerManager.new,
    );

// Local data source
final llmLocalDataSourceProvider = Provider<llmLocalDataSource>(
  (ref) => AILocalDataSourceImpl(
    linuxModelPath: "/home/user/Models/Qwen3-4B-Q4_K_M.gguf",
    windowsModelPath: r'C:\Users\Lenovo\Desktop\Qwen3-4B-Q4_K_M.gguf',
  ),
  isAutoDispose: true,
);

// Repository: Select implementation according to platform
// Repository
final llmRepositoryProvider = Provider<llmRepository>(
  (ref) => llmRepositoryImpl(dataSource: ref.watch(llmLocalDataSourceProvider)),
);

// Use cases
final llmSenderUCProvider = Provider<SendLlmMessageUC>(
  (ref) => SendLlmMessageUC(ref.watch(llmRepositoryProvider)),
  isAutoDispose: true,
);

final aiInitializationProvider = FutureProvider<void>((ref) async {
  final dataSource = ref.watch(llmLocalDataSourceProvider);

  await dataSource.initialize();

  ref.onDispose(() {
    dataSource.dispose();
  });
});
