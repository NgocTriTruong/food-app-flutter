import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DioClient{
  static final _storage = FlutterSecureStorage();

  static Dio dio(){
    final dio = Dio(BaseOptions(
      baseUrl: "http://10.0.2.2:8080/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options,handler) async {


          final token = await _storage.read(key: "token");
            if(token != null){
              options.headers['Authorization'] = 'Bearer $token';

            }
            handler.next(options);
          }

      ),
    );
    return dio;
  }
}

