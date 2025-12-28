class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  // --- HÀM FROMJSON MỚI CHO RETROFIT ---
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  // --- HÀM TOJSON CHO RETROFIT ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  // Helper xử lý DateTime linh hoạt (String, int, hoặc legacy Timestamp)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    // Hỗ trợ nếu vẫn còn dữ liệu kiểu Timestamp từ Firebase
    try {
      return value.toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  // --- GIỮ NGUYÊN CÁC HÀM CŨ CỦA BẠN ---
  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp, // Tùy vào việc bạn dùng Firebase hay API mà để nguyên hoặc convert
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }
}