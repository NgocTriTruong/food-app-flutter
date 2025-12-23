import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:kfc/models/nguoi_dung.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "/api")
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @GET("/users/{uid}")
  Future<NguoiDung> getUserData(@Path("uid") String uid);

  @PUT("/users/{uid}")
  Future<void> updateUserData(
      @Path("uid") String uid,
      @Body() Map<String, dynamic> data,
      );

  @POST("/users")
  Future<void> createUserData(@Body() NguoiDung nguoiDung);

  @POST("/auth/login")
  Future<HttpResponse<dynamic>> login(
      @Body() Map<String, dynamic> credentials,
      );
}
