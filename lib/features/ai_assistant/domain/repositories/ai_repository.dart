import '../entities/ai_conversation_message.dart';
import '../entities/ai_suggestion.dart';

abstract class AiRepository {
  Future<AiSuggestion> askAssistant(List<AiConversationMessage> messages);
}
