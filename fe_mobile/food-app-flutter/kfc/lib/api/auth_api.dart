import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:kfc/models/nguoi_dung.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "")
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
  
  @POST("/auth/register")
  Future<HttpResponse<dynamic>> register(
      @Body() Map<String, dynamic> data,
      );

  @POST("/auth/forgot-password")
  Future<HttpResponse<dynamic>> forgotPassword(
      @Body() Map<String, dynamic> data,
      );

  @POST("/auth/reset-password")
  Future<HttpResponse<dynamic>> resetPassword(
      @Body() Map<String, dynamic> data,
      );
}
