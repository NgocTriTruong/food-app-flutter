import 'package:kfc/api/chat_api.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:kfc/services/auth_service.dart';
import 'package:kfc/utils/notification_helper.dart';

/// Service để polling tin nhắn cho user ngay cả khi không ở chat screen
/// Chạy trong background và phát thông báo khi có tin nhắn mới từ admin
class UserMessagePollingService {
  static final UserMessagePollingService _instance = UserMessagePollingService._internal();
  
  factory UserMessagePollingService() {
    return _instance;
  }

  UserMessagePollingService._internal();

  final ChatApi _api = ChatApi(DioClient.dio(withAuth: true));
  
  // Track số tin nhắn của mỗi phòng để detect tin nhắn mới
  Map<String, int> _messageCountByRoom = {};
  
  // Biến để kiểm soát polling
  bool _isPolling = false;
  int? _pollingIntervalSeconds = 3;

  /// Bắt đầu polling tin nhắn của user
  /// Được gọi khi app khởi động hoặc user đăng nhập
  void startPolling() {
    if (_isPolling) {
      print('❌ Polling đã chạy rồi');
      return;
    }

    _isPolling = true;
    print('✅ Bắt đầu polling tin nhắn cho user...');
    _pollUserMessages();
  }

  /// Dừng polling tin nhắn
  void stopPolling() {
    _isPolling = false;
    print('⏹️ Dừng polling tin nhắn');
  }

  /// Poll tin nhắn của user - tìm phòng chat có tin nhắn từ admin
  Future<void> _pollUserMessages() async {
    while (_isPolling) {
      try {
        // Lấy phòng chat hiện tại của user
        final userData = await AuthService.getCurrentUserData();
        if (userData == null) {
          print('❌ Không tìm thấy user info');
          await Future.delayed(Duration(seconds: _pollingIntervalSeconds ?? 3));
          continue;
        }

        final customerId = userData['id'];
        print('🔍 Polling tin nhắn cho user: $customerId');

        // Lấy phòng chat của user
        try {
          final room = await _api.getCustomerChatRoom(customerId);
          
          final roomId = room.id;
          
          // Lấy danh sách tin nhắn
          final messages = await _api.getMessages(roomId);
          
          // Kiểm tra xem có tin nhắn mới không
          final currentCount = _messageCountByRoom[roomId] ?? 0;
          if (messages.length > currentCount && currentCount > 0) {
            // Có tin nhắn mới!
            final newMessagesCount = messages.length - currentCount;
            print('🔔 Có $newMessagesCount tin nhắn mới từ admin!');
            
            // Phát thông báo
            await NotificationHelper.notifyNewMessage(
              playSound: true,
              enableVibration: true,
            );
          }
          
          // Cập nhật số lượng tin nhắn
          _messageCountByRoom[roomId] = messages.length;
        } catch (e) {
          // Có thể user chưa tạo phòng chat, không quan trọng
          if (e.toString().contains('404')) {
            print('ℹ️ User chưa có phòng chat');
          } else {
            print('⚠️ Lỗi fetch tin nhắn: $e');
          }
        }
      } catch (e) {
        print('❌ Lỗi polling: $e');
      }

      // Chờ trước khi poll lần tiếp theo
      await Future.delayed(Duration(seconds: _pollingIntervalSeconds ?? 10));
    }
  }

  /// Reset dữ liệu khi user đăng xuất
  void reset() {
    _messageCountByRoom.clear();
    stopPolling();
  }
}
