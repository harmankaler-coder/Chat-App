class ChatProvider {
  static final ChatProvider _instance = ChatProvider._internal();

  factory ChatProvider() {
    return _instance;
  }

  ChatProvider._internal();

  final List<String> _chatHistory = [];

  List<String> get chatHistory => _chatHistory;

  void addMessage(String message) {
    _chatHistory.add(message);
  }

  void clearChat() {
    _chatHistory.clear();
  }
}
