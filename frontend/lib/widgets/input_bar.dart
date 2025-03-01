import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;

  const InputBar({super.key, required this.onSend});

  @override
  _InputBarState createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSend(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedScale(
              scale: 1.2,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.send_rounded, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
