import 'package:dio/dio.dart';
import 'package:kfc/network/dio_client.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import 'auth_service.dart';

class ChatService {
  static final Dio _dio = DioClient.dio();

  // ===== CUSTOMER METHODS =====

  // Tạo phòng chat
  static Future<ChatRoom?> createOrGetChatRoom(String customerId, String customerName) async {
    try {
      final response = await _dio.post('/chat/rooms/create', data: {
        'customerId': customerId,
        'customerName': customerName,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return ChatRoom(
          id: data['id'] ?? '',
          customerId: data['customerId'] ?? '',
          customerName: data['customerName'] ?? '',
          createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toString()),
          lastMessageTime: DateTime.parse(data['lastMessageTime'] ?? DateTime.now().toString()),
          lastMessage: data['lastMessage'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Lỗi tạo phòng chat: $e');
      return null;
    }
  }

  // Wrapper cho floating button
  static Future<String?> createChatRoom(String customerName) async {
    try {
      final room = await createOrGetChatRoom(customerName, customerName);
      return room?.id;
    } catch (e) {
      print('Lỗi createChatRoom: $e');
      return null;
    }
  }

  // Gửi tin nhắn - gửi kèm senderId và senderName
  static Future<void> sendMessage(String roomId, String message, {String? imageUrl}) async {
    try {
      // Lấy thông tin người dùng hiện tại
      final userData = await AuthService.getCurrentUserData();
      if (userData == null) {
        print('Lỗi: Không thể lấy thông tin người dùng');
        return;
      }

      final String userId = userData['id'] ?? '';
      final String userName = userData['ten'] ?? 'Unknown';

      final payload = {
        'chatRoomId': roomId,
        'senderId': userId,
        'senderName': userName,
        'message': message,
      };
      if (imageUrl != null && imageUrl.isNotEmpty) {
        payload['imageUrl'] = imageUrl;
      }

      print('DEBUG: Sending message with senderId=$userId, senderName=$userName');
      await _dio.post('/chat/messages/send', data: payload);
    } catch (e) {
      print('Lỗi gửi tin nhắn: $e');
    }
  }

  // Lấy tin nhắn - trả về Stream
  static Stream<List<ChatMessage>> getMessages(String roomId) async* {
    while (true) {
      try {
        final response = await _dio.get('/chat/messages/$roomId');

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data ?? [];
          final messages = data
              .map((item) => ChatMessage(
                id: item['id'] ?? '',
                senderId: item['senderId'] ?? '',
                senderName: item['senderName'] ?? '',
                message: item['message'] ?? '',
                timestamp: DateTime.parse(item['timestamp'] ?? DateTime.now().toString()),
              ))
              .toList();
          yield messages;
        }
      } catch (e) {
        print('Lỗi lấy tin nhắn: $e');
        yield [];
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Lấy info phòng - trả về Stream
  static Stream<ChatRoom?> getChatRoom(String roomId) async* {
    while (true) {
      try {
        final response = await _dio.get('/chat/rooms/customer/$roomId');

        if (response.statusCode == 200) {
          final data = response.data;
          yield ChatRoom(
            id: data['id'] ?? '',
            customerId: data['customerId'] ?? '',
            customerName: data['customerName'] ?? '',
            createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toString()),
            lastMessageTime: DateTime.parse(data['lastMessageTime'] ?? DateTime.now().toString()),
            lastMessage: data['lastMessage'] ?? '',
          );
        }
      } catch (e) {
        print('Lỗi lấy info phòng: $e');
        yield null;
      }

      await Future.delayed(Duration(seconds: 3));
    }
  }

  // Đánh dấu đã đọc
  static Future<void> markMessagesAsRead(String roomId) async {
    try {
      await _dio.post('/chat/rooms/$roomId/mark-read');
    } catch (e) {
      print('Lỗi đánh dấu đã đọc: $e');
    }
  }

  // ===== STAFF METHODS =====

  // Lấy tất cả phòng: unassigned + assigned to this staff
  static Stream<List<ChatRoom>> getAllChatRoomsForStaff(String staffId) async* {
    while (true) {
      try {
        // Lấy các phòng gán cho staff này
        final response = await _dio.get('/chat/rooms/staff/$staffId');
        
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data ?? [];
          final assignedRooms = data
              .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
              .toList();
          
          yield assignedRooms;
        }
      } catch (e) {
        print('Lỗi lấy phòng staff: $e');
        yield [];
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Lấy phòng chưa gán
  static Stream<List<ChatRoom>> getStaffChatRooms() async* {
    while (true) {
      try {
        final response = await _dio.get('/chat/rooms/staff/unassigned');

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data ?? [];
          final rooms = data
              .map((item) => ChatRoom(
                id: item['id'] ?? '',
                customerId: item['customerId'] ?? '',
                customerName: item['customerName'] ?? '',
                createdAt: DateTime.parse(item['createdAt'] ?? DateTime.now().toString()),
                lastMessageTime: DateTime.parse(item['lastMessageTime'] ?? DateTime.now().toString()),
                lastMessage: item['lastMessage'] ?? '',
              ))
              .toList();
          yield rooms;
        }
      } catch (e) {
        print('Lỗi lấy phòng staff: $e');
        yield [];
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Gán nhân viên
  static Future<void> assignStaffToRoom(String roomId, String staffId, String staffName) async {
    try {
      await _dio.post('/chat/rooms/$roomId/assign', data: {
        'staffId': staffId,
        'staffName': staffName,
      });
    } catch (e) {
      print('Lỗi gán nhân viên: $e');
    }
  }

  // Xóa phòng
  static Future<void> deleteChatRoom(String roomId) async {
    try {
      await _dio.post('/chat/rooms/$roomId/close');
    } catch (e) {
      print('Lỗi xóa phòng: $e');
    }
  }

  // Lấy phòng của staff
  static Future<List<ChatRoom>> getStaffRooms(String staffId) async {
    try {
      final response = await _dio.get('/chat/rooms/staff/$staffId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data
            .map((item) => ChatRoom(
              id: item['id'] ?? '',
              customerId: item['customerId'] ?? '',
              customerName: item['customerName'] ?? '',
              createdAt: DateTime.parse(item['createdAt'] ?? DateTime.now().toString()),
              lastMessageTime: DateTime.parse(item['lastMessageTime'] ?? DateTime.now().toString()),
              lastMessage: item['lastMessage'] ?? '',
            ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Lỗi lấy phòng staff: $e');
      return [];
    }
  }
}


