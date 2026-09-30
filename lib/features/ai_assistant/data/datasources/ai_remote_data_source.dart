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
    final apiKey = dotenv.env["RODIUMAI_API_KEY"] ?? '';

    try {
      final response = await dio.post(
        "https://api.rodiumai.io/v1/messages",
        data: {
          "model": "anthropic/claude-sonnet-4-6",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          "max_tokens": 1024,
        },
        options: Options(
          headers: {"x-api-key": apiKey, "anthropic-version": "2023-06-01"},
        ),
      );

      final String replyText =
          response.data['content']?[0]?['text'] ?? 'Mauvais chemin de réponse JSON';

      return AiResponseModel.fromJson({'message': replyText});
    } on DioException catch (e) {
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
