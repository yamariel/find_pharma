import '../entities/ai_conversation_message.dart';
import '../entities/ai_suggestion.dart';
import '../repositories/ai_repository.dart';

class AskHealthAssistantUsecase {
  final AiRepository repositories;
  AskHealthAssistantUsecase({required this.repositories});

  Future<AiSuggestion> call(List<AiConversationMessage> messages) async {
    return await repositories.askAssistant(messages);
  }
}
