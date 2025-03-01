import 'package:assist/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    final screenSize = await getScreenSize();
    const windowSize = Size(380, 720);

    final position = Offset(
      screenSize.width - windowSize.width,
      screenSize.height - windowSize.height,
    );

    await windowManager.setSize(windowSize);
    await windowManager.setPosition(position);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
  });

  runApp(const MyApp());
}

Future<Size> getScreenSize() async {
  final screen = await screenRetriever.getPrimaryDisplay();
  return Size(screen.size.width.toDouble(), screen.size.height.toDouble());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: isDarkMode,
        toggleTheme: toggleTheme,
      ),
    );
  }
}
