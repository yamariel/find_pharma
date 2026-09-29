import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/usecases/ask_health_assistant_usecase.dart';

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return AiRemoteDataSourceImpl(dio: dio);
});

final aiRepositoryImplProvider = Provider<AiRepositoryImpl>((ref) {
  final dataSource = ref.read(aiRemoteDataSourceProvider);
  return AiRepositoryImpl(remoteDataSource: dataSource);
});

final askHealthAssistantUsecaseProvider = Provider<AskHealthAssistantUsecase>((
  ref,
) {
  final repo = ref.read(aiRepositoryImplProvider);
  return AskHealthAssistantUsecase(repositories: repo);
});

// Réprésente un message
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Répresente l'état de l'IA
class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  AiChatState({required this.messages, required this.isLoading});

  AiChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AskHealthAssistantUsecase useCase;
  AiChatNotifier(this.useCase)
    : super(AiChatState(messages: [], isLoading: false));

  //Envoyez un prompt à l'IA
  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      //appel à l'IA via Rodium
      final suggestion = await useCase(prompt);
      final aiMessage = ChatMessage(
        text: suggestion.responseText,
        isUser: false,
        timestamp: suggestion.timestamp,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        isUser: false,
        text: e.toString(),
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final useCase = ref.read(askHealthAssistantUsecaseProvider);
  return AiChatNotifier(useCase);
});
