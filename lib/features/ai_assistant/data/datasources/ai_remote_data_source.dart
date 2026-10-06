import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/ai_response_model.dart';

abstract class AiRemoteDataSource {
  Future<AiResponseModel> askAi(String prompt);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio dio;

  AiRemoteDataSourceImpl({required this.dio});

  @override
  Future<AiResponseModel> askAi(String prompt) async {
    final apiKey = dotenv.env["OPENROUTER_API_KEY"] ?? '';
    final String promptIA =
        "Tu es l'assistant Find Pharma AI. "
        "Réponds d'abord à la question exacte de l'utilisateur. "
        "Réponds naturellement et brièvement aux salutations et aux conversations générales. "
        "N'affiche ni ne décris les pharmacies disponibles, sauf si l'utilisateur demande explicitement une pharmacie, "
        "une pharmacie de garde, une adresse, un quartier ou un numéro de téléphone. "
        "Quand le contexte contient des pharmacies, utilise-le uniquement pour répondre à une telle demande et ne liste que les résultats pertinents. "
        "Règles de sécurité absolues : "
        "1. Ne fais JAMAIS de diagnostic médical, n'interprète pas les symptômes et ne prescris aucun traitement. "
        "2. Si un utilisateur te demande un diagnostic ou des conseils médicaux, refuse poliment en lui rappelant que tu es un simple assistant d'orientation et invite-le immédiatement à consulter un professionnel de santé ou une structure d'urgence. "
        "3. Ne mentionne jamais que tu es un modèle d'OpenAI ou de GPT.";

    try {
      final response = await dio.post(
        "https://openrouter.ai/api/v1/chat/completions",
        data: {
          "model": "openai/gpt-4o",
          "messages": [
            {"role": "system", "content": promptIA},
            {"role": "user", "content": prompt},
          ],
          "max_tokens": 256,
          // "max_tokens": 1024,
          // "system": "Tu es l'assistant FindPharma. "
          //   "Ton rôle est exclusivement d'aider les utilisateurs à trouver une pharmacie de garde ouverte, "
          //   "de vérifier les alternatives génériques d'un médicament ou de les orienter vers la structure de"
          //   "santé la plus proche. Règles de sécurité absolues : 1. Ne fais JAMAIS de diagnostic médical,"
          //   "n'interprète pas les symptômes et ne prescris aucun traitement. 2. Si un utilisateur te demande"
          //   "un diagnostic ou des conseils médicaux, refuse poliment en lui rappelant que tu es un simple assistant"
          //   "d'orientation et invite-le immédiatement à consulter un professionnel de santé ou une structure d'urgence."
          //   "3. Ne mentionne jamais que tu es un modèle d'Anthropic ou que tu t'appelles Claude.",
        },
        options: Options(headers: {"Authorization": "Bearer $apiKey"}),
      );

      final String replyText =
          response.data['choices']?[0]?['message']?['content'] ??
          'Pas de réponse';

      return AiResponseModel.fromJson({'message': replyText});
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ServerException(
            "Le serveur met trop de temps à répondre. Vérifiez votre connexion et réessayez.",
          );
        case DioExceptionType.connectionError:
          throw ServerException(
            "Impossible de se connecter. Vérifiez votre accès Internet.",
          );
        default:
          break;
      }
      switch (e.response?.statusCode) {
        case 401:
          throw ServerException(
            "Non autorisé: Clé API manquante ou invalide. Vérifiez l'en-tête Authorization.",
          );
        case 402:
          throw ServerException(
            "Crédits insuffisants: Votre solde RODI est trop bas. Rechargez depuis la facturation.",
          );
        case 429:
          throw ServerException(
            "Limite de débit: Trop de requêtes. Attendez et réessayez avec un backoff exponentiel.",
          );
        case 422:
          throw ServerException(
            "Erreur de validation: Corps de requête invalide. Vérifiez le nom du modèle et le format des messages.",
          );
        case 500:
          throw ServerException(
            "Erreur serveur: Erreur interne. Réessayez une fois, si cela persiste, contactez le support.",
          );
        default:
          throw ServerException("ERREUR, une erreur est survenue: $e");
      }
    }
  }
}
