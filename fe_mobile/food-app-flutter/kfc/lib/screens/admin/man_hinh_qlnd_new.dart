import 'package:flutter/material.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:dio/dio.dart';

class ManHinhQLND extends StatefulWidget {
  const ManHinhQLND({Key? key}) : super(key: key);

  @override
  State<ManHinhQLND> createState() => _ManHinhQLNDState();
}

class _ManHinhQLNDState extends State<ManHinhQLND> {
  List<NguoiDung> _users = [];
  bool _isLoading = false;
  final Dio _dio = DioClient.dio();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/users');
      final data = response.data as List<dynamic>;
      setState(() {
        _users = data.map((json) => NguoiDung.fromJson(json as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: MauSac.kfcRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String userId, NguoiDung user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MauSac.denNhat,
        title: const Text('Xác nhận xóa người dùng', style: TextStyle(color: MauSac.trang)),
        content: Text(
          'Bạn có chắc muốn xóa người dùng "${user.ten}" (${user.email})?',
          style: const TextStyle(color: MauSac.xam),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: MauSac.xam)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: MauSac.kfcRed),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _dio.delete('/users/admin/$userId');
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa ${user.ten}'), backgroundColor: MauSac.xanhLa),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: MauSac.kfcRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MauSac.xamDam.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: MauSac.xamDam.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Danh sách người dùng',
                    style: TextStyle(color: MauSac.trang, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.kfcRed,
                    foregroundColor: MauSac.trang,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MauSac.kfcRed))
                : _users.isEmpty
                    ? const Center(child: Text('Không có người dùng', style: TextStyle(color: MauSac.xam)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            color: MauSac.denNen,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: user.isAdmin
                                        ? MauSac.kfcRed.withOpacity(0.1)
                                        : MauSac.xanhLa.withOpacity(0.1),
                                    child: Icon(
                                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                      color: user.isAdmin ? MauSac.kfcRed : MauSac.xanhLa,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.ten,
                                          style: const TextStyle(
                                            color: MauSac.trang,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: TextStyle(color: MauSac.xam, fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: user.isAdmin
                                                ? MauSac.kfcRed.withOpacity(0.1)
                                                : MauSac.xanhLa.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            user.isAdmin ? 'ADMIN' : 'CUSTOMER',
                                            style: TextStyle(
                                              color: user.isAdmin ? MauSac.kfcRed : MauSac.xanhLa,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: MauSac.xam),
                                    color: MauSac.denNhat,
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteUser(user.id, user);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: MauSac.kfcRed, size: 16),
                                            const SizedBox(width: 8),
                                            const Text('Xóa', style: TextStyle(color: MauSac.trang)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
