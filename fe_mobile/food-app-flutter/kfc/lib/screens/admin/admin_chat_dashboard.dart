import 'package:flutter/material.dart';
import '../../models/chat_room.dart';
import '../../services_fix/chat_service.dart';
import '../../services_fix/auth_service.dart';
import '../chat/chat_screen.dart';
import '../../theme/mau_sac.dart';

class AdminChatDashboard extends StatefulWidget {
  const AdminChatDashboard({super.key});

  @override
  _AdminChatDashboardState createState() => _AdminChatDashboardState();
}

class _AdminChatDashboardState extends State<AdminChatDashboard> {
  String _adminName = '';
  String? _adminId;
  bool _isDeleting = false;
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🔴 [AdminChatDashboard] initState called');
    _loadAdminInfo();
    // Auto refresh every 1 second for realtime update
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _adminId != null) {
        print('🔄 [AdminChatDashboard] Auto-refreshing chat rooms...');
        _loadChatRooms();
        return true;
      }
      return false;
    });
  }

  Future<void> _loadAdminInfo() async {
    print('🔴 [AdminChatDashboard] _loadAdminInfo called');
    try {
      final uid = await AuthService.getStoredUid();
      print('🔴 [AdminChatDashboard] Stored UID: $uid');
      if (uid != null) {
        final userData = await AuthService.getUserData(uid);
        print('🔴 [AdminChatDashboard] User data: ${userData?.ten}');
        if (userData != null) {
          setState(() {
            _adminName = userData.ten;
            _adminId = uid;
          });
          print('✅ [AdminChatDashboard] Admin loaded: $_adminName (ID: $_adminId)');
          // Load chat rooms after getting admin ID
          _loadChatRooms();
        }
      } else {
        print('❌ [AdminChatDashboard] No stored UID found!');
      }
    } catch (e) {
      print('❌ [AdminChatDashboard] Lỗi load admin info: $e');
    }
  }

  Future<void> _loadChatRooms() async {
    if (_adminId == null) {
      print('⚠️ [AdminChatDashboard] Cannot load - _adminId is null');
      return;
    }
    
    print('🔵 [AdminChatDashboard] Loading chat rooms for admin: $_adminId');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔵 [AdminChatDashboard] Calling ChatService.getStaffChatRoomsAsFuture()...');
      final rooms = await ChatService.getStaffChatRoomsAsFuture();
      print('✅ [AdminChatDashboard] Received ${rooms.length} chat rooms');
      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [AdminChatDashboard] Lỗi load chat rooms: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
        backgroundColor: MauSac.kfcRed,
      ),
      body: Column(
        children: [
          // Header thông tin admin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: MauSac.kfcRed.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: MauSac.kfcRed,
                      child: Icon(Icons.admin_panel_settings, color: MauSac.trang),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, $_adminName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Quản trị viên hệ thống'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MauSac.denNhat.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: MauSac.trang,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kéo sang trái để xóa cuộc trò chuyện',
                        style: TextStyle(
                          fontSize: 12,
                          color: MauSac.trang,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Danh sách phòng chat
          Expanded(
            child: _adminId == null
                ? const Center(child: CircularProgressIndicator(color: MauSac.kfcRed))
                : _buildChatRoomList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomList() {
    if (_isLoading && _chatRooms.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: MauSac.kfcRed));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: MauSac.xam),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: const TextStyle(fontSize: 16, color: MauSac.xam),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: MauSac.xam),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChatRooms,
              style: ElevatedButton.styleFrom(backgroundColor: MauSac.kfcRed),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_chatRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: MauSac.xam),
            SizedBox(height: 16),
            Text(
              'Chưa có tin nhắn hỗ trợ nào',
              style: TextStyle(fontSize: 16, color: MauSac.xam),
            ),
          ],
        ),
      );
    }

    final activeChatRooms = _chatRooms.where((room) => room.isActive).toList();

    if (activeChatRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: MauSac.xam),
            SizedBox(height: 16),
            Text(
              'Không có cuộc trò chuyện đang hoạt động',
              style: TextStyle(fontSize: 16, color: MauSac.xam),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: activeChatRooms.length,
      itemBuilder: (context, index) {
        final room = activeChatRooms[index];
        return _buildDismissibleChatRoom(room);
      },
    );
  }

  Widget _buildDismissibleChatRoom(ChatRoom room) {
    return Dismissible(
      key: Key(room.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: MauSac.denNhat,
              title: const Text(
                'Xóa cuộc trò chuyện',
                style: TextStyle(color: MauSac.trang),
              ),
              content: Text(
                'Bạn có chắc chắn muốn xóa cuộc trò chuyện với ${room.customerName}? Hành động này không thể hoàn tác.',
                style: const TextStyle(color: MauSac.trang),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: MauSac.xam),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: MauSac.kfcRed),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteChatRoom(room);
      },
      child: _buildChatRoomItem(room),
    );
  }

  Widget _buildChatRoomItem(ChatRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      color: MauSac.denNhat,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: MauSac.kfcRed,
              child: Text(
                room.customerName.isNotEmpty ? room.customerName[0].toUpperCase() : '?',
                style: const TextStyle(color: MauSac.trang, fontWeight: FontWeight.bold),
              ),
            ),
            if (room.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    room.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          room.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: MauSac.trang),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: room.unreadCount > 0 ? MauSac.trang : MauSac.xam,
                fontWeight: room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: MauSac.xam),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(room.lastMessageTime),
                  style: TextStyle(fontSize: 12, color: MauSac.xam),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: MauSac.xam,
            ),
            if (room.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MauSac.kfcRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Mới',
                  style: const TextStyle(
                    color: MauSac.trang,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChatRoom(room),
      ),
    );
  }

  Future<void> _deleteChatRoom(ChatRoom room) async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await ChatService.deleteChatRoom(room.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa cuộc trò chuyện với ${room.customerName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa cuộc trò chuyện: ${e.toString()}'),
          backgroundColor: MauSac.kfcRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _openChatRoom(ChatRoom room) async {
    // Nếu admin chưa được gán vào phòng chat, tự động gán
    if (room.staffId == null && _adminId != null) {
      try {
        await ChatService.assignStaffToRoom(room.id);
      } catch (e) {
        print('Lỗi gán admin: $e');
      }
    }

    // Đánh dấu room đã đọc (reset unreadCount)
    try {
      await ChatService.markRoomAsRead(room.id);
    } catch (e) {
      print('Lỗi mark room as read: $e');
    }

    // Mở màn hình chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(roomId: room.id),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
