import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<String> chatHistory;
  final bool isDarkMode;

  const ChatList({super.key, required this.chatHistory, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        bool isUser = chatHistory[index].startsWith("User:");

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(colors: [Colors.blue, Colors.blueAccent])
                      : LinearGradient(
                      colors: isDarkMode
                          ? [Colors.grey[850]!, Colors.grey[800]!]
                          : [Colors.lightBlue[50]!, Colors.white]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Text(
                  chatHistory[index].replaceFirst("User: ", "").replaceFirst("Assistant: ", ""),
                  style: TextStyle(
                    color: isUser ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
