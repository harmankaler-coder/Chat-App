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
    )..repeat(reverse: true);

    _scaleAnimation = _animationController.drive(
      Tween<double>(begin: 0.9, end: 1.0).chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );

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
    setState(() {
      _isListening = true;
    });
    _animationController.forward();

    // Stop listening animation after a few seconds
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isListening = false;
      });
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

  void _sendMessage(String message) {
    if (message.isEmpty) return;

    setState(() {
      chatProvider.addMessage("User: $message");
    });

    startListeningAnimation();

    // Simulating AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chatProvider.addMessage("Assistant: I received your message!");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Drawer(
          child: Column(
            children: [
              // Gradient Drawer Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent], // Same as chat bubbles
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "VOX",
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                ),
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
                      title: const Text("VOX",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
                      content: const Text("This is an AI-powered Assistant Application."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK",style: TextStyle(color: Colors.blueAccent),))
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "VOX",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 25, color: Colors.lightBlue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.menu, color: Colors.black),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _isListening
              ? Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const CircleAvatar(
                  backgroundColor: Colors.blue, // Alexa-style pulsing dot
                  radius: 8,
                ),
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
        color: widget.isDarkMode ? Colors.black : Colors.white, // Solid background
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
              onSend: (message) => _sendMessage(message),
            ),
          ],
        ),
      ),
    );
  }
}
