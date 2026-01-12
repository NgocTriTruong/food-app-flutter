import 'package:flutter/material.dart';
import '../../services_fix/chat_service.dart';
import '../../services_fix/auth_service.dart';
import 'chat_screen.dart';

class ChatSupportButton extends StatelessWidget {
  
  const ChatSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleChatButtonPressed(context),
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.chat,
        color: Colors.white,
      ),
      tooltip: 'Trò chuyện với nhân viên hỗ trợ',
    );
  }

  Future<void> _handleChatButtonPressed(BuildContext context) async {
    try {
      // Lấy UID đã lưu
      final uid = await AuthService.getStoredUid();
      if (uid == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để sử dụng tính năng này')),
          );
        }
        return;
      }

      // Hiển thị dialog loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Lấy thông tin người dùng
      final userData = await AuthService.getUserData(uid);
      final displayName = userData?.ten ?? 'Người dùng';

      // Tạo hoặc lấy phòng chat hiện có
      final roomId = await ChatService.createChatRoom(displayName);

      // Đóng dialog loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Mở màn hình chat
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(roomId: roomId),
          ),
        );
      }
    } catch (e) {
      // Đóng dialog loading nếu có lỗi
      if (context.mounted) {
        Navigator.pop(context);
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
        );
      }
    }
  }
}
