import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    final response = await dio.post(
      "https://api.rodiumai.io/v1/chat/completions",
      data: {
        "model": "openai/gpt-4o",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 256,
      },
      options: Options(headers: {"Authorization": "Bearer $apiKey"}),
    );

    final String replyText =
        response.data['choices']?[0]?['message']?['content'] ??
        'Pas de réponse';

    return AiResponseModel.fromJson({'message': replyText});
  }
}
