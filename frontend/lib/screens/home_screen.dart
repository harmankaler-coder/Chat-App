import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final ChatProvider chatProvider = ChatProvider();
  bool _isLoading = false;

  void _sendMessage(String command) async {
    if (command.isNotEmpty) {
      setState(() {
        chatProvider.addMessage("User: $command");
        _isLoading = true;
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
        child: AppBar(
          backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
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
            Switch(
              value: widget.isDarkMode,
              onChanged: (value) => widget.toggleTheme(),
              activeColor: Colors.blueAccent,
              inactiveThumbColor: Colors.orange,
            ),
          ],
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
                padding: const EdgeInsets.only(top: 10.0), // Ensures chat starts below AppBar
                child: ChatList(chatHistory: chatProvider.chatHistory, isDarkMode: widget.isDarkMode),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            InputBar(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
