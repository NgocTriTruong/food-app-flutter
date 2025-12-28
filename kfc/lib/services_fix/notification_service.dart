import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kfc/api/notification_api.dart';
import 'package:kfc/models/thong_bao.dart';
import 'package:kfc/network/dio_client.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Sử dụng NotificationApi với Auth
  static final NotificationApi _api = NotificationApi(DioClient.dio(withAuth: true));

  // --- KHỞI TẠO (GIỮ NGUYÊN) ---
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _initializeFirebaseMessaging();
  }

  static Future<void> _initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) _saveTokenToServer(token);

      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToServer);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  // --- THAY THẾ FIRESTORE BẰNG API ---

  // Lưu token lên Server của bạn
  static Future<void> _saveTokenToServer(String token) async {
    try {
      await _api.saveFcmToken(token);
      print('✅ FCM Token đã được cập nhật lên Server');
    } catch (e) {
      print('❌ Lỗi gửi token lên server: $e');
    }
  }

  // Lấy danh sách thông báo (Dùng polling để giả lập stream nếu cần)
  static Future<List<ThongBao>> getUserNotifications() async {
    try {
      final list = await _api.getUserNotifications();
      // Server nên thực hiện sort, nhưng ta giữ sort local cho chắc chắn
      list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      return list;
    } catch (e) {
      print('❌ Lỗi lấy thông báo: $e');
      return [];
    }
  }

  // Giả lập Stream thông báo bằng Polling (Cập nhật mỗi 30 giây)
  static Stream<List<ThongBao>> streamUserNotifications() async* {
    while (true) {
      yield await getUserNotifications();
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await _api.markAsRead(notificationId);
    } catch (e) {
      print('❌ Lỗi mark as read: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.deleteNotification(notificationId);
    } catch (e) {
      print('❌ Lỗi xóa thông báo: $e');
    }
  }

  // Tạo thông báo mới (Gửi request để Backend xử lý gửi FCM)
  static Future<void> createNotificationForUser({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    try {
      final data = {
        'userId': userId,
        'orderId': orderId,
        'status': status,
        'type': 'don_hang',
      };
      await _api.sendNotificationToUser(data);
    } catch (e) {
      print('❌ Lỗi tạo thông báo qua API: $e');
    }
  }

  // --- LOCAL NOTIFICATION LOGIC (GIỮ NGUYÊN) ---

  static void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'KFC Vietnam',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    _handleNotificationAction(message.data);
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('kfc_channel', 'KFC Notifications', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title, body, details, payload: payload,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle tap action
  }

  static void _handleNotificationAction(Map<String, dynamic> data) {
    // Navigate logic
  }
}