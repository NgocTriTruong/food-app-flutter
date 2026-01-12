import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';

class ManHinhChinhSuaThongTin extends StatefulWidget {
  const ManHinhChinhSuaThongTin({super.key});

  @override
  State<ManHinhChinhSuaThongTin> createState() => _ManHinhChinhSuaThongTinState();
}

class _ManHinhChinhSuaThongTinState extends State<ManHinhChinhSuaThongTin> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenController;
  late TextEditingController _emailController;
  late TextEditingController _soDienThoaiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final nguoiDung = context.read<NguoiDungProvider>().nguoiDung;
    _tenController = TextEditingController(text: nguoiDung?.ten ?? '');
    _emailController = TextEditingController(text: nguoiDung?.email ?? '');
    _soDienThoaiController = TextEditingController(text: nguoiDung?.soDienThoai ?? '');
  }

  @override
  void dispose() {
    _tenController.dispose();
    _emailController.dispose();
    _soDienThoaiController.dispose();
    super.dispose();
  }

  Future<void> _luuThongTin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nguoiDungProvider = context.read<NguoiDungProvider>();
      final currentUser = nguoiDungProvider.nguoiDung;
      
      if (currentUser == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      // Tạo user mới với thông tin đã cập nhật
      final updatedUser = NguoiDung(
        id: currentUser.id,
        ten: _tenController.text.trim(),
        email: _emailController.text.trim(),
        soDienThoai: _soDienThoaiController.text.trim(),
        rule: currentUser.rule,
      );

      // Gọi API update (bạn cần implement hàm này trong provider)
      await nguoiDungProvider.capNhatThongTin(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      appBar: AppBar(
        backgroundColor: MauSac.denNhat,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.trang),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: MauSac.trang, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _tenController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _soDienThoaiController,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                      return 'Số điện thoại phải có 10 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _luuThongTin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MauSac.kfcRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: MauSac.trang,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              color: MauSac.trang,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: MauSac.trang),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: MauSac.xam.withValues(alpha: 0.8)),
        prefixIcon: Icon(icon, color: MauSac.kfcRed),
        filled: true,
        fillColor: MauSac.denNhat,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MauSac.xam.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MauSac.xam.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MauSac.kfcRed),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
