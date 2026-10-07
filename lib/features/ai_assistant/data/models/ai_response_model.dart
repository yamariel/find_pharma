import '../../domain/entities/ai_suggestion.dart';

class AiResponseModel extends AiSuggestion {
  AiResponseModel({
    required super.responseText,
    required super.timestamp,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      responseText: json['message'] ?? 'Pas de réponse',
      timestamp: DateTime.now(),
    );
  }
}