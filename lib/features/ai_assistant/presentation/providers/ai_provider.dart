import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../pharmacies/domain/repositories/pharmacy_repository.dart';
import '../../../pharmacies/presentation/providers/pharmacy_provider.dart';
import '../../../pharmacies/domain/entities/pharmacy.dart';
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

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
  );
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingHistory;
  final List<Pharmacy> pharmacies;
  final String? errorMessage;

  AiChatState({
    required this.messages,
    required this.isLoading,
    this.isLoadingHistory = false,
    this.pharmacies = const [],
    this.errorMessage,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingHistory,
    List<Pharmacy>? pharmacies,
    String? errorMessage,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      pharmacies: pharmacies ?? this.pharmacies,
      errorMessage: errorMessage,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AskHealthAssistantUsecase useCase;
  final PharmacyRepository pharmacyDatasource;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  AiChatNotifier(this.useCase, this.pharmacyDatasource)
    : super(
        AiChatState(
          messages: [
            ChatMessage(
              text: "Bonjour ! Je suis l'assistant Find Pharma AI. Je peux vous aider à trouver une pharmacie de garde ouverte, vérifier les alternatives génériques d'un médicament ou vous orienter vers la structure de santé la plus proche. Comment puis-je vous aider aujourd'hui ?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isLoading: false,
        ),
      ) {
    loadUserHistory();
  }

  //charger l'historique Firestore
  Future<void> loadUserHistory() async {
    final currentUserId = userId;
    if (currentUserId == null) return;
    try {
      state = state.copyWith(isLoadingHistory: true, errorMessage: null);
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chat_history')
          .orderBy('timestamp')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final loadedMessages = snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .toList();

        state = state.copyWith(
          messages: loadedMessages,
          isLoadingHistory: false,
        );
      } else {
        state = state.copyWith(isLoadingHistory: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: "Erreur lors du chargement de l'historique : $e",
      );
    }
  }

  //sauvegarder un message dans Firestore
  Future<bool> _saveMessageToFirestore(ChatMessage message) async {
    final currentUserId = userId;
    if (currentUserId == null) {
      state = state.copyWith(
        errorMessage: "Connectez-vous pour sauvegarder vos messages.",
      );
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chat_history')
          .add(message.toJson());
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Impossible de sauvegarder le message : $e",
      );
      return false;
    }
  }

  //supprimer un message de la liste et de Firestore
  Future<void> deleteMessage(int index) async {
    if (index < 0 || index >= state.messages.length) return;

    final messageToDelete = state.messages[index];

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..removeAt(index);
    state = state.copyWith(messages: updatedMessages);

    //suppression dans Firestore
    final currentUserId = userId;
    if (currentUserId != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('chat_history')
            .where('text', isEqualTo: messageToDelete.text)
            .where(
              'timestamp',
              isEqualTo: messageToDelete.timestamp.toIso8601String(),
            )
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        state = state.copyWith(
          errorMessage:
              "Erreur lors de la suppression du message en ligne : $e",
        );
      }
    }
  }

  //envoyer un message
  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    state = state.copyWith(errorMessage: null);

    final userMessage = ChatMessage(
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    await _saveMessageToFirestore(userMessage);
    final userMessageSaveError = state.errorMessage;

    try {
      // Même catalogue métier que la carte et les autres parcours.
      final pharmacies = await pharmacyDatasource.getPharmacies();
      final pharmaciesContext = pharmacies
          .map(
            (p) =>
                "- Nom : ${p.name} | Quartier : ${p.district} | Adresse : ${p.address ?? 'Non spécifiée'} | Téléphone : ${p.phone}",
          )
          .join('\n');

      final enrichedPrompt =
          """
Contexte des pharmacies (à utiliser uniquement si la question porte sur une recherche de pharmacie) :
$pharmaciesContext

Question exacte de l'utilisateur :
$prompt
""";

      final suggestion = await useCase(enrichedPrompt);

      final aiMessage = ChatMessage(
        text: suggestion.responseText,
        isUser: false,
        timestamp: suggestion.timestamp,
      );

      await _saveMessageToFirestore(aiMessage);
      final persistenceError = state.errorMessage ?? userMessageSaveError;

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        pharmacies: pharmacies,
        errorMessage: persistenceError,
      );
    } catch (e) {
      final errorText = e is ServerFailure ? e.message : e.toString();
      final errorMessage = ChatMessage(
        isUser: false,
        text: "Erreur : $errorText",
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        errorMessage: errorText,
      );
    }
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final useCase = ref.read(askHealthAssistantUsecaseProvider);
  final repository = ref.watch(pharmacyRepositoryProvider);
  return AiChatNotifier(useCase, repository);
});
