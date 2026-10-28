import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ai_conversation_message.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl extends AiRepository {
  final AiRemoteDataSource remoteDataSource;
  AiRepositoryImpl({required this.remoteDataSource});
  @override
  Future<AiSuggestion> askAssistant(
    List<AiConversationMessage> messages,
  ) async {
    try {
      return await remoteDataSource.askAi(messages);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure("Erreur inattendue : $e");
    }
  }
}
