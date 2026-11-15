import 'package:exolab/core/presentation/globalWidgets/custIconButton.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';

class ChatBoxWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSend; // Unified callback that accepts the text

  const ChatBoxWidget({
    super.key,
    required this.controller,
    this.hintText = "Type a message...",
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(25),
        // boxShadow: [
        //   BoxShadow(
        //     color: context.theme.shadowColor,
        //     blurRadius: 10.0,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              // 1. Keyboard submit triggers the callback directly with its text
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  onSend(text);
                }
              },
              style: context.text.bodyMedium!.copyWith(height: 1.3),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: context.text.bodyMedium!.copyWith(
                  color: context.colors.onSurface.withAlpha(150),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CustIconButton(
            icon: Icons.send_rounded,
            color: context.colors.onPrimary,
            bgColor: context.colors.primary,
            // 2. Send button grabs the current controller text and triggers the same callback
            onPressed: () {
              final text = controller.text;
              if (text.trim().isNotEmpty) {
                onSend(text);
              }
            },
          ),
        ],
      ),
    );
  }
}
