import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class NotificationHelper {
  // Android MethodChannel cho notification sound
  static const platform = MethodChannel('com.example.kfc/notification');

  // Phát âm thanh thông báo
  static Future<void> playNotificationSound() async {
    try {
      await platform.invokeMethod('playSound');
    } catch (e) {
      print('❌ Lỗi phát âm thanh thông báo: $e');
    }
  }

  // Rung điện thoại
  static Future<void> vibrate({int duration = 200}) async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      print('❌ Lỗi rung điện thoại: $e');
    }
  }

  // Flash màn hình (chỉ dành cho Android)
  static Future<void> flashScreen() async {
    try {
      await platform.invokeMethod('flashScreen');
    } catch (e) {
      print('❌ Lỗi flash màn hình: $e');
    }
  }

  // Thông báo toàn bộ hiệu ứng (âm thanh + rung + flash)
  static Future<void> notifyNewMessage({
    bool playSound = true,
    bool enableVibration = true,
    bool flashScreenEffect = true,
  }) async {
    print('🔔 Thông báo tin nhắn mới...');
    
    // Phát âm thanh
    if (playSound) {
      await playNotificationSound();
    }

    // Rung
    if (enableVibration) {
      // Mô hình rung: ngắn - tạm dừng - dài
      await vibrate(duration: 150);
      await Future.delayed(Duration(milliseconds: 100));
      await vibrate(duration: 300);
    }

    // Flash màn hình
    if (flashScreenEffect) {
      await NotificationHelper.flashScreen();
    }
  }

  // Thông báo phòng chat mới (nhẹ hơn)
  static Future<void> notifyNewChatRoom({
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    print('🔔 Có phòng chat mới...');
    
    if (playSound) {
      await playNotificationSound();
    }

    if (enableVibration) {
      // Rung nhẹ - 2 lần
      await vibrate(duration: 100);
      await Future.delayed(Duration(milliseconds: 100));
      await vibrate(duration: 100);
    }
  }

  // Thông báo lỗi (khác hẳn)
  static Future<void> notifyError() async {
    print('❌ Thông báo lỗi');
    
    // Rung liên tục 3 lần để báo lỗi
    for (int i = 0; i < 3; i++) {
      await vibrate(duration: 100);
      await Future.delayed(Duration(milliseconds: 150));
    }
  }
}
