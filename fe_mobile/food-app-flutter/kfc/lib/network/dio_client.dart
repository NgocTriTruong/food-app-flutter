import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DioClient {
  static Dio dio({bool withAuth = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://nonoscine-nonsatiable-ofelia.ngrok-free.dev/api",
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
