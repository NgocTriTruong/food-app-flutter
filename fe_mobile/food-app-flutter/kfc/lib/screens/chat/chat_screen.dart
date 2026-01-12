import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kfc/theme/mau_sac.dart';
import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    // Đánh dấu tin nhắn đã đọc khi mở màn hình
    ChatService.markMessagesAsRead(widget.roomId);
  }

  Future<void> _loadCurrentUserId() async {
    final userData = await AuthService.getCurrentUserData();
    if (userData != null) {
      print('DEBUG: Loaded userId from JWT: ${userData['id']}');
      setState(() {
        _currentUserId = userData['id'];
      });
      print('DEBUG: _currentUserId set to: $_currentUserId');
    } else {
      print('DEBUG: userData is null');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ChatService.sendMessage(widget.roomId, message);
      _messageController.clear();
      
      // Đảm bảo cuộn xuống tin nhắn mới nhất
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi tin nhắn: ${e.toString()}'),
          backgroundColor: MauSac.kfcRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Tải ảnh lên backend
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
      });
      
      final response = await Dio().post(
        'http://10.0.2.2:8080/api/files/upload',
        data: formData,
      );
      
      String imageUrl = '';
      if (response.statusCode == 200) {
        imageUrl = response.data['fileUrl'] ?? '';
      }
      
      // Gửi tin nhắn với ảnh
      await ChatService.sendMessage(widget.roomId, 'Đã gửi một hình ảnh', imageUrl: imageUrl);
      
      // Đảm bảo cuộn xuống tin nhắn mới nhất
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi ảnh: ${e.toString()}'),
          backgroundColor: MauSac.kfcRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<ChatRoom?>(
          stream: ChatService.getChatRoom(widget.roomId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final chatRoom = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hỗ trợ KFC',
                    style: TextStyle(color: MauSac.trang),
                  ),
                  Text(
                    chatRoom.staffName != null
                        ? 'Nhân viên: ${chatRoom.staffName}'
                        : 'Đang chờ nhân viên...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: MauSac.trang,
                    ),
                  ),
                ],
              );
            }
            return const Text(
              'Hỗ trợ KFC',
              style: TextStyle(color: MauSac.trang),
            );
          },
        ),
        backgroundColor: MauSac.kfcRed,
        iconTheme: const IconThemeData(color: MauSac.trang),
      ),
      backgroundColor: MauSac.denNen,
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService.getMessages(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: MauSac.kfcRed),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn nào',
                      style: TextStyle(color: MauSac.xam),
                    ),
                  );
                }

                final messages = snapshot.data!;
                
                // Cuộn xuống tin nhắn mới nhất sau khi danh sách được cập nhật
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSystem = message.senderId == 'system';

                    if (isSystem) {
                      return _buildSystemMessage(message);
                    }

                    // So sánh senderId với currentUserId
                    final isMe = _currentUserId != null && message.senderId == _currentUserId;
                    print('DEBUG: Message from ${message.senderId}, Current user: $_currentUserId, isMe: $isMe');
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Thanh nhập tin nhắn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: MauSac.denNhat,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Nút gửi ảnh
                IconButton(
                  icon: const Icon(Icons.photo, color: MauSac.kfcRed),
                  onPressed: _isLoading ? null : _sendImage,
                ),
                // Ô nhập tin nhắn
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: MauSac.trang),
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: TextStyle(color: MauSac.xam),
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // Nút gửi tin nhắn
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MauSac.kfcRed,
                          ),
                        )
                      : const Icon(Icons.send, color: MauSac.kfcRed),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: MauSac.denNhat,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            message.message,
            style: const TextStyle(
              color: MauSac.xam,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: MauSac.kfcRed,
              child: const Icon(Icons.support_agent, color: MauSac.trang),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MauSac.xam,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isMe ? MauSac.kfcRed : MauSac.denNhat,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null)
                        GestureDetector(
                          onTap: () {
                            // Hiển thị ảnh full màn hình khi nhấn vào
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    iconTheme: const IconThemeData(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.black,
                                  body: Center(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(message.imageUrl!),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              message.imageUrl!,
                              width: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: MauSac.kfcRed,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (message.message.isNotEmpty)
                        Text(
                          message.message,
                          style: TextStyle(
                            color: isMe ? MauSac.trang : MauSac.trang,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? MauSac.trang.withOpacity(0.7) : MauSac.xam,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
