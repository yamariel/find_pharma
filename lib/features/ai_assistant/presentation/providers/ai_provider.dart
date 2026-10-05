import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../pharmacies/data/datasources/pharmacy_local_mock_datasource.dart';
import '../../../pharmacies/domain/entities/pharmacy.dart'; //
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

final _mockDatasource = Provider<PharmacyLocalMockDatasource>((ref) {
  return PharmacyLocalMockDatasource();
});

// Représente un message
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isDelete;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isDelete = false,
  });
}

// Représente l'état de l'IA
class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final List<Pharmacy> pharmacies;

  AiChatState({
    required this.messages,
    required this.isLoading,
    this.pharmacies = const [],
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    List<Pharmacy>? pharmacies,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      pharmacies: pharmacies ?? this.pharmacies,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AskHealthAssistantUsecase useCase;
  final PharmacyLocalMockDatasource pharmacyDatasource;

  AiChatNotifier(this.useCase, this.pharmacyDatasource)
    : super(
        AiChatState(
          messages: [
            ChatMessage(
              text: "Bonjour ! Je suis l'assistant FindPharma. Je peux vous aider à trouver une pharmacie de garde ouverte, vérifier les alternatives génériques d'un médicament ou vous orienter vers la structure de santé la plus proche. Comment puis-je vous aider aujourd'hui ?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isLoading: false,
        ),
      );

  // Envoyer un prompt à l'IA avec le contexte des pharmacies
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
      // on récupère les pharmacies via le mock injecté
      final pharmacies = await pharmacyDatasource.getPharmacies();
      final pharmaciesContext = pharmacies.map(
        (p) => "- Nom : ${p.name} | Quartier : ${p.district} | Adresse : ${p.address ?? 'Non spécifiée'} | Téléphone : ${p.phone}",
      ).join('\n');

      final enrichedPrompt = """
Voici la liste des pharmacies actuellement enregistrées dans le système :
$pharmaciesContext

Question de l'utilisateur : $prompt
""";

      final suggestion = await useCase(enrichedPrompt);
      
      final aiMessage = ChatMessage(
        text: suggestion.responseText,
        isUser: false,
        timestamp: suggestion.timestamp,
      );
      
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        pharmacies: pharmacies,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        isUser: false,
        text: e is ServerFailure ? e.message : e.toString(),
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < state.messages.length) {
      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..removeAt(index);
      state = state.copyWith(messages: updatedMessages);
    }
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final useCase = ref.read(askHealthAssistantUsecaseProvider);
  final mockDatasource = ref.read(_mockDatasource);
  return AiChatNotifier(useCase, mockDatasource);
});
