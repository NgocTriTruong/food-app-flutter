import 'package:kfc/api/chat_api.dart';
import 'package:kfc/models/chat_message.dart';
import 'package:kfc/models/chat_room.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:kfc/utils/notification_helper.dart';
import 'package:kfc/services_fix/auth_service.dart';

class ChatService {
  // Chat luôn cần Auth để xác định người gửi
  static final ChatApi _api = ChatApi(DioClient.dio(withAuth: true));
  
  // Track last message count để detect tin nhắn mới
  static int _lastMessageCount = 0;

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
      // Lấy senderId để backend biết ai đang gửi
      final senderId = await AuthService.getStoredUid();
      
      final messageData = {
        'message': message,
        'imageUrl': imageUrl,
        'senderId': senderId, // Thêm senderId
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
    _lastMessageCount = 0;
    while (true) {
      try {
        final messages = await _api.getMessages(roomId);
        
        // Detect tin nhắn mới và phát thông báo
        if (messages.length > _lastMessageCount && _lastMessageCount > 0) {
          print('🔔 Có ${messages.length - _lastMessageCount} tin nhắn mới!');
          await NotificationHelper.notifyNewMessage();
        }
        
        _lastMessageCount = messages.length;
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

  // Đánh dấu room đã đọc (reset unreadCount)
  static Future<void> markRoomAsRead(String roomId) async {
    try {
      print('🔵 [ChatService] Marking room as read: $roomId');
      await _api.markRoomAsRead(roomId);
      print('✅ [ChatService] Room marked as read');
    } catch (e) {
      print('❌ [ChatService] Lỗi mark room as read: $e');
    }
  }

  // Admin lấy danh sách phòng chat
  static Stream<List<ChatRoom>> getStaffChatRooms() async* {
    List<String> _seenRoomIds = [];
    while (true) {
      try {
        final rooms = await _api.getStaffChatRooms();
        
        // Detect phòng mới và phát thông báo
        for (var room in rooms) {
          if (!_seenRoomIds.contains(room.id) && room.lastMessage.isNotEmpty) {
            print('🔔 Phòng chat mới từ ${room.customerName}: "${room.lastMessage}"');
            await NotificationHelper.notifyNewMessage();
            _seenRoomIds.add(room.id);
          }
        }
        
        yield rooms;
      } catch (e) {
        print('❌ Lỗi getStaffChatRooms stream: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // Admin lấy danh sách phòng chat (Future version for easier testing)
  static Future<List<ChatRoom>> getStaffChatRoomsAsFuture() async {
    try {
      print('[ChatService] Fetching staff chat rooms...');
      // Get current staff id from storage
      final staffId = await AuthService.getStoredUid();
      if (staffId == null) {
        // Fallback: return only unassigned rooms
        return await _api.getUnassignedRooms();
      }
      final assigned = await _api.getStaffRoomsByStaffId(staffId);
      final unassigned = await _api.getUnassignedRooms();
      // Combine: unassigned first, then assigned
      return [...unassigned, ...assigned];
    } catch (e) {
      print('❌ Lỗi getStaffChatRooms: $e');
      rethrow;
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