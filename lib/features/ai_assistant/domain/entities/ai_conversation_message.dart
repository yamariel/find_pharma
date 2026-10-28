class AiConversationMessage {
  const AiConversationMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  String get role => isUser ? 'user' : 'assistant';
}
