import 'package:kfc/api/chat_api.dart';
import 'package:kfc/models/chat_message.dart';
import 'package:kfc/models/chat_room.dart';
import 'package:kfc/network/dio_client.dart';

class ChatService {
  // Chat luôn cần Auth để xác định người gửi
  static final ChatApi _api = ChatApi(DioClient.dio(withAuth: true));

  // Tạo phòng chat mới
  static Future<String> createChatRoom(String customerName) async {
    try {
      return await _api.createChatRoom(customerName);
    } catch (e) {
      print('❌ Lỗi khi tạo phòng chat: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn
  static Future<void> sendMessage(String roomId, String message, {String? imageUrl}) async {
    try {
      final messageData = {
        'message': message,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _api.sendMessage(roomId, messageData);
    } catch (e) {
      print('❌ Lỗi khi gửi tin nhắn: $e');
      rethrow;
    }
  }

  // Lấy danh sách tin nhắn (Polling để giả lập Real-time)
  static Stream<List<ChatMessage>> getMessages(String roomId) async* {
    while (true) {
      try {
        final messages = await _api.getMessages(roomId);
        yield messages;
      } catch (e) {
        print('⚠️ Lỗi cập nhật tin nhắn: $e');
      }
      await Future.delayed(const Duration(seconds: 2)); // Cập nhật mỗi 2 giây
    }
  }

  // Lấy thông tin phòng chat
  static Stream<ChatRoom?> getChatRoom(String roomId) async* {
    while (true) {
      try {
        final room = await _api.getChatRoom(roomId);
        yield room;
      } catch (e) {
        yield null;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // Đánh dấu đã đọc
  static Future<void> markMessagesAsRead(String roomId) async {
    try {
      await _api.markMessagesAsRead(roomId);
    } catch (e) {
      print('❌ Lỗi mark as read: $e');
    }
  }

  // Admin lấy danh sách phòng chat
  static Stream<List<ChatRoom>> getStaffChatRooms() async* {
    while (true) {
      try {
        yield await _api.getStaffChatRooms();
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  // Gán admin vào phòng
  static Future<void> assignStaffToRoom(String roomId) async {
    try {
      await _api.assignStaff(roomId);
    } catch (e) {
      rethrow;
    }
  }

  // Đóng phòng chat
  static Future<void> closeChatRoom(String roomId) async {
    try {
      await _api.closeChatRoom(roomId);
    } catch (e) {
      rethrow;
    }
  }

  // Xóa tin nhắn
  static Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await _api.deleteMessage(roomId, messageId);
    } catch (e) {
      print('❌ Lỗi xóa tin nhắn: $e');
      rethrow;
    }
  }

  // Xóa toàn bộ cuộc hội thoại (Admin)
  static Future<void> deleteChatRoom(String roomId) async {
    try {
      await _api.deleteChatRoom(roomId);
    } catch (e) {
      print('❌ Lỗi xóa phòng chat: $e');
      rethrow;
    }
  }
}