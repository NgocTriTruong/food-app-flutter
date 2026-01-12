import 'package:flutter/material.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/services/chat_service.dart';
import 'package:kfc/services/auth_service.dart';
import 'package:kfc/screens/chat/chat_screen.dart';

class FloatingChatButton extends StatelessWidget {
  
  const FloatingChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hiển thị luôn, check login khi nhấn
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () => _handleChatButtonPressed(context),
        backgroundColor: MauSac.kfcRed,
        heroTag: "chat_button",
        tooltip: 'Trò chuyện với hỗ trợ KFC',
        child: const Icon(
          Icons.chat,
          color: MauSac.trang,
        ),
      ),
    );
  }

  Future<void> _handleChatButtonPressed(BuildContext context) async {
    try {
      print('=== Chat button pressed ===');
      
      final isLoggedIn = await AuthService.isLoggedIn();
      print('isLoggedIn: $isLoggedIn');
      
      if (!isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
            backgroundColor: MauSac.kfcRed,
          ),
        );
        return;
      }

      // Hiển thị dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: MauSac.kfcRed),
        ),
      );

      // Lấy thông tin người dùng
      print('Getting user data...');
      final userData = await AuthService.getCurrentUserData();
      print('userData: $userData');
      
      if (userData == null) {
        print('ERROR: userData is null');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token không hợp lệ. Vui lòng đăng xuất và đăng nhập lại!'),
            backgroundColor: MauSac.kfcRed,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      
      final displayName = userData['ten'] ?? 'Khách hàng';
      print('displayName: $displayName');

      // Tạo hoặc lấy phòng chat hiện có
      print('Creating chat room...');
      final roomId = await ChatService.createChatRoom(displayName);
      print('roomId: $roomId');

      // Đóng dialog loading
      Navigator.pop(context);

      if (roomId == null) {
        print('ERROR: roomId is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo phòng chat')),
        );
        return;
      }

      print('Opening chat screen with roomId: $roomId');
      // Mở màn hình chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(roomId: roomId),
        ),
      );
    } catch (e) {
      print('ERROR in chat button: $e');
      // Đóng dialog loading nếu có lỗi
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: MauSac.kfcRed,
        ),
      );
    }
  }
}
