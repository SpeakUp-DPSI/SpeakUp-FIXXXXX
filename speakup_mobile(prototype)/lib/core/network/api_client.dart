import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late Dio dio;

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    // Gunakan IP lokal Mac (192.168.1.44) untuk physical device Android 
    // atau gunakan 10.0.2.2 jika menggunakan Emulator Android
    if (Platform.isAndroid) return 'http://192.168.1.44:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
}
