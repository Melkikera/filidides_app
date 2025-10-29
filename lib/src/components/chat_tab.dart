import 'package:flutter/material.dart';
import 'message_receiver.dart';

class ChatTab extends StatelessWidget {
  final List<String> messages;
  final TextEditingController inputController;
  final void Function(String) onSend;

  const ChatTab({
    Key? key,
    required this.messages,
    required this.inputController,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MessageReceiver(messages: messages),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = inputController.text.trim();
                  if (text.isNotEmpty) {
                    onSend(text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
