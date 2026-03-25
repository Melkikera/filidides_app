import 'package:flutter/material.dart';

class MessageReceiver extends StatefulWidget {
  final List<String> messages;
  const MessageReceiver({super.key, required this.messages});

  @override
  State<MessageReceiver> createState() => _MessageReceiverState();
}

class _MessageReceiverState extends State<MessageReceiver> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.message),
          title: Text(widget.messages[index]),
        );
      },
    );
  }
}
