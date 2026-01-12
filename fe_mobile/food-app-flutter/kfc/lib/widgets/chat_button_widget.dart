import 'package:flutter/material.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/services_fix/chat_service.dart';
import 'package:kfc/services/auth_service.dart';
import 'package:kfc/screens/chat/chat_screen.dart';

class ChatButtonWidget extends StatelessWidget {
  const ChatButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService.getCurrentUserData(),
      builder: (context, snapshot) {
        // Chỉ hiển thị khi user đã đăng nhập và không phải admin
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        
        final userData = snapshot.data!;
        final userRole = userData['vaiTro'] ?? userData['rule'] ?? 'user';
        
        // Không hiển thị cho admin
        if (userRole == 'admin') return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _handleChatButtonPressed(context, userData),
            style: ElevatedButton.styleFrom(
              backgroundColor: MauSac.kfcRed,
              foregroundColor: MauSac.trang,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.support_agent),
            label: const Text(
              'Hỗ trợ trực tuyến',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleChatButtonPressed(
    BuildContext context,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Hiển thị dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: MauSac.kfcRed),
              SizedBox(width: 20),
              Text('Đang kết nối...'),
            ],
          ),
        ),
      );

      // Lấy displayName
      final displayName = userData['displayName'] ?? userData['ten'] ?? 'Khách hàng';

      // Tạo hoặc lấy phòng chat hiện có
      final roomId = await ChatService.createChatRoom(displayName);

      // Đóng dialog loading
      if (context.mounted) Navigator.pop(context);

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
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: MauSac.kfcRed,
          ),
        );
      }
    }
  }
}
