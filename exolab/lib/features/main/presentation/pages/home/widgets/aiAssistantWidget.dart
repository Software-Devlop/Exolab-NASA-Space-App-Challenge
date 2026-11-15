import 'package:exolab/core/presentation/globalWidgets/custDivider.dart';
import 'package:exolab/core/presentation/globalWidgets/custIconButton.dart';
import 'package:exolab/core/presentation/globalWidgets/horizontalPageSlider.dart';
import 'package:exolab/core/statics/AppConstants.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/core/utils/copyHelper.dart';
import 'package:exolab/features/llm/presentation/controllers/llmController.dart';
import 'package:exolab/features/llm/domain/entities/chat.dart';
import 'package:exolab/features/llm/presentation/widgets/chatBoxWidget.dart';
import 'package:exolab/features/task/presentation/controllers/taskController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AIAssistantWidget extends ConsumerStatefulWidget {
  final List<Chat> chatWatch;
  final int currentChatPage;
  final List<String> suggestions;
  const AIAssistantWidget({
    super.key,
    required this.chatWatch,
    required this.currentChatPage,
    required this.suggestions,
  });

  @override
  ConsumerState<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends ConsumerState<AIAssistantWidget> {
  final TextEditingController userMessageController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  bool _isCopied = false;
  bool _showCopyButton = true;

  Future<void> _handleCopy(Chat fullChat) async {
    if (_isCopied) return;

    final text =
        "You: ${fullChat.userMessage.message}\n\n$appName AI: ${fullChat.aiMessage?.message ?? "(Still thinking...)"}";

    // Call the core helper
    await ClipboardHelper.copy(text);
    // 2. Update state to show checkmark
    setState(() {
      _isCopied = true;
    });

    // Presentation layer handles the UI notification feedback
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Copied to clipboard!")));
    }

    // 3. Revert back to copy icon after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isCopied = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(llmControllerProvider.notifier).addMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fullChat = widget.chatWatch.isNotEmpty
        ? widget.chatWatch[widget.currentChatPage]
        : null;
    userMessageController.text = widget.chatWatch.isNotEmpty
        ? widget.chatWatch[widget.currentChatPage].userMessage.message
        : "";
    return HorizontalPageSlider(
      height: 503,
      maxNbOfPage: ref.watch(llmControllerProvider).chats.length,
      currentPage: ref.watch(llmControllerProvider).currentChat,
      onPageChange: (value) {
        setState(() {
          ref.read(llmControllerProvider.notifier).currentChat = value;
          print(value);
        });
      },
      pagesPlaceholder: Expanded(child: Center(child: Text("Ask me anything"))),

      onEnterTop: (event) {
        setState(() {
          _showCopyButton = true;
        });
      },

      onExitTop: (event) {
        setState(() {
          _showCopyButton = false;
        });
      },

      // Copy button
      topWidget: Row(
        spacing: 5,
        children: [
          Row(
            spacing: 15,
            children: [
              SvgPicture.asset("assets/icons/leaf.svg"),
              Text(
                "ExoLab Assistant",
                style: context.text.titleMedium!.copyWith(
                  // color: context.colors.primary,
                ),
              ),
            ],
          ),
          // IgnorePointer(
          //   ignoring: !(_showCopyButton && widget.chatWatch.isNotEmpty),
          //   child: AnimatedOpacity(
          //     opacity: (_showCopyButton && widget.chatWatch.isNotEmpty)
          //         ? 1.0
          //         : 0.0,
          //     duration: const Duration(milliseconds: 150),
          //     child:
          CustIconButton(
            padding: const EdgeInsets.all(0),
            onPressed: fullChat != null ? () => _handleCopy(fullChat) : null,
            child: Icon(
              _isCopied ? Icons.check_rounded : Icons.copy_rounded,
              size: 20,
              color: context.colors.primary,
            ),
          ),
          //     ),
          //   ),
        ],
      ),
      pages: widget.chatWatch
          .asMap()
          .entries
          .map(
            (entry) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              reverseDuration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey(entry.key),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User sent text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("You: ", style: context.text.bodyMedium),
                          Flexible(
                            child: TextField(
                              controller: userMessageController,
                              style: context.text.bodyMedium,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelStyle: context.text.bodyMedium,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                isCollapsed: true,
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      CustDivider(axis: CustDividerAxis.horizontal),

                      // AI response
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SelectionArea(
                          child: MarkdownBody(
                            data:
                                entry.value.aiMessage?.message ??
                                ref.watch(llmControllerProvider).aiError ??
                                "Sending...",
                            onTapLink: (text, href, title) async {
                              // print("Text: $text");
                              // print("Href $href");
                              // print("Title: $title");
                              if (href == null) return;

                              final uri = Uri.tryParse(href);
                              if (uri == null) return;

                              // print(uri.scheme);
                              // print(uri.host);
                              // print(uri.path);
                              if (uri.scheme == 'app' &&
                                  uri.host == 'tasks' &&
                                  uri.path.contains('/create')) {
                                await ref
                                    .read(taskControllerProvider.notifier)
                                    .addTaskSuggestion(uri);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),

      fixedWidget: Padding(
        padding: const EdgeInsets.only(right: 17),
        child: ChatBoxWidget(
          suggestions: widget.suggestions,
          controller: controller,
          onSend: (value) async {
            print("UI is sending");
            controller.clear();
            await ref
                .read(llmControllerProvider.notifier)
                .sendMessage(value); // controller.text
          },
        ),
      ),
    );
  }
}
