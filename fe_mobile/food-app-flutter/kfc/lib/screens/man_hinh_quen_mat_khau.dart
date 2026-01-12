import 'package:flutter/material.dart';
import 'package:kfc/screens/man_hinh_dat_lai_mat_khau.dart';
import 'package:kfc/services_fix/auth_service.dart';
import 'package:kfc/theme/mau_sac.dart';

class ManHinhQuenMatKhau extends StatefulWidget {
  const ManHinhQuenMatKhau({super.key});

  @override
  State<ManHinhQuenMatKhau> createState() => _ManHinhQuenMatKhauState();
}

class _ManHinhQuenMatKhauState extends State<ManHinhQuenMatKhau> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _dangXuLy = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guiYeuCau() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangXuLy = true);
    final email = _emailController.text.trim();

    try {
      await AuthService.forgotPassword(email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ManHinhDatLaiMatKhau(email: email, otp: ''),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      appBar: AppBar(
        backgroundColor: MauSac.denNhat,
        title: const Text('Khôi phục tài khoản'),
        iconTheme: const IconThemeData(color: MauSac.trang),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Nhập email để đặt lại mật khẩu',
                  style: TextStyle(
                    color: MauSac.trang,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                  style: const TextStyle(color: MauSac.trang),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: MauSac.xam.withOpacity(0.8)),
                    prefixIcon: const Icon(Icons.email_outlined, color: MauSac.kfcRed),
                    filled: true,
                    fillColor: MauSac.denNhat,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: MauSac.xam.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: MauSac.xam.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MauSac.kfcRed),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _dangXuLy ? null : _guiYeuCau,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MauSac.kfcRed,
                      foregroundColor: MauSac.trang,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _dangXuLy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MauSac.trang,
                            ),
                          )
                        : const Text(
                            'Gửi yêu cầu',
                            style: TextStyle(
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
}
