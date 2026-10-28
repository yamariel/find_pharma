import '../../domain/entities/ai_conversation_message.dart';
import '../models/ai_response_model.dart';

abstract class AiRemoteDataSource {
  Future<AiResponseModel> askAi(List<AiConversationMessage> messages);
}