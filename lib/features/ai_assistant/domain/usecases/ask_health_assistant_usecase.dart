import '../entities/ai_suggestion.dart';
import '../repositories/ai_repository.dart';

class AskHealthAssistantUsecase {
  final AiRepository repositories;
  AskHealthAssistantUsecase({required this.repositories});
  
    Future<AiSuggestion> call(String prompt) async {
      return await repositories.askAssistant(prompt);
    }

}