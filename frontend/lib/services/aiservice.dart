import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyCZ4BPcloMEUFSlAUBoNgFKKkMkEOKRvYk"; // Replace with your actual key
  static const String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey";

  static Future<String> getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Failed to connect to Gemini AI service.";
    }
  }
}
