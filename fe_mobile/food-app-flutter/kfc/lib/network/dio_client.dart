import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DioClient {
  static Dio dio({bool withAuth = true}) {
    final dio = Dio(
      BaseOptions(
        // baseUrl: "http://10.0.2.2:8080/api",
        baseUrl: "http://192.168.1.90:8080//api",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    if (withAuth) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token =
            await const FlutterSecureStorage().read(key: "token");

            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          },
        ),
      );
    }

    return dio;
  }
}
