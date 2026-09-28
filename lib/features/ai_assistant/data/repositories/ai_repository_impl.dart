import '../../domain/entities/ai_suggestion.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl extends AiRepository{
  final AiRemoteDataSource remoteDataSource;
  AiRepositoryImpl({required this.remoteDataSource});
  @override
  Future<AiSuggestion> askAssistant(String prompt) async{
    return await remoteDataSource.askAi(prompt);
  }
  
}
