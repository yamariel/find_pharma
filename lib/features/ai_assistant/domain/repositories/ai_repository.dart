import '../entities/ai_suggestion.dart';

abstract class AiRepository {
  Future<AiSuggestion> askAssistant(String prompt);
}
