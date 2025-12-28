import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/thong_bao.dart';

part 'notification_api.g.dart';

@RestApi()
abstract class NotificationApi {
  factory NotificationApi(Dio dio, {String baseUrl}) = _NotificationApi;

  @POST("/notifications/token")
  Future<void> saveFcmToken(@Field("fcmToken") String token);

  @GET("/notifications")
  Future<List<ThongBao>> getUserNotifications();

  @PATCH("/notifications/{id}/read")
  Future<void> markAsRead(@Path("id") String id);

  @DELETE("/notifications/{id}")
  Future<void> deleteNotification(@Path("id") String id);

  // Dành cho Admin/Hệ thống gửi thông báo
  @POST("/notifications/send-to-user")
  Future<void> sendNotificationToUser(@Body() Map<String, dynamic> data);
}