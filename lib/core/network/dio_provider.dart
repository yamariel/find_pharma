import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final dioProvider = Provider<Dio>((ref) => ref.read(dioClientProvider).dio);