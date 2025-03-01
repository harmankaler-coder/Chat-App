import 'package:flutter/material.dart';
import 'dart:async';

import '../providers/chat_provider.dart';
import '../widgets/chat_list.dart';
import '../widgets/input_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ChatProvider chatProvider = ChatProvider();
  bool _isLoading = false;
  bool _isListening = false;

  late AnimationController _waveController;
  late Animation<Color?> _waveColorAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _waveColorAnimation = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.cyanAccent,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _sendMessage(String command) async {
    if (command.isNotEmpty) {
      setState(() {
        chatProvider.addMessage("User: $command");
        _isLoading = true;
        _isListening = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isListening = false;
      });

      String response = await Future.delayed(
          const Duration(seconds: 2), () => "Processing: $command");

      setState(() {
        chatProvider.addMessage("Assistant: $response");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: _isListening
                    ? LinearGradient(
                  colors: [
                    _waveColorAnimation.value!,
                    _waveColorAnimation.value!.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null,
              ),
              child: AppBar(
                backgroundColor: _isListening ? Colors.transparent : (widget.isDarkMode ? Colors.black : Colors.white),
                elevation: 5,
                title: Text(
                  "AI Assistant",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: widget.isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {},
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: widget.isDarkMode ? Colors.yellow : Colors.blue,
                    ),
                    onPressed: widget.toggleTheme,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.white, Colors.grey[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ChatList(chatHistory: chatProvider.chatHistory, isDarkMode: widget.isDarkMode),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("AI is typing...", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            InputBar(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
