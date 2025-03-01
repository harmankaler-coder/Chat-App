import 'package:http/http.dart' as http;

class BackendService {
  static Future<String> sendCommand(String command) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/process"), // Update with actual backend URL
      body: {"command": command},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "Error: Unable to process command.";
    }
  }
}
