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
  bool _isListening = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _selectedLanguage = "English";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startListeningAnimation() {
    setState(() => _isListening = true);
    _animationController.forward();
    Timer(const Duration(seconds: 3), () {
      setState(() => _isListening = false);
      _animationController.reset();
    });
  }

  void _changeLanguage(String? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Select Language"),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: ["English", "Punjabi", "French", "German", "Hindi"]
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: _changeLanguage,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text("Toggle Theme"),
              onTap: widget.toggleTheme,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("About AI Assistant"),
                    content: const Text("This is an AI-powered chatbot application."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _isListening ? "Listening..." : "Assistant",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, //
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _isListening
              ? Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 8,
              ),
            ),
          )
              : const SizedBox.shrink(),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.black,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: widget.isDarkMode ? Colors.black : Colors.white, //
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                chatHistory: chatProvider.chatHistory,
                isDarkMode: widget.isDarkMode,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Press Enter to Send",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            InputBar(
              onSend: (message) {
                setState(() {
                  chatProvider.addMessage("User: $message");
                  startListeningAnimation();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
