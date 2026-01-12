import 'package:flutter/material.dart';
import 'package:kfc/screens/man_hinh_dang_nhap.dart';
import 'package:kfc/services_fix/auth_service.dart';
import 'package:kfc/theme/mau_sac.dart';

class ManHinhDatLaiMatKhau extends StatefulWidget {
  final String email;
  final String otp;
  const ManHinhDatLaiMatKhau({super.key, required this.email, required this.otp});

  @override
  State<ManHinhDatLaiMatKhau> createState() => _ManHinhDatLaiMatKhauState();
}

class _ManHinhDatLaiMatKhauState extends State<ManHinhDatLaiMatKhau> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _dangXuLy = false;
  bool _anMatKhau = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _datLai() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangXuLy = true);
    final password = _passwordController.text.trim();
    final otp = _otpController.text.trim();

    try {
      final ok = await AuthService.resetPassword(widget.email, password, otp);
      if (!ok) {
        throw Exception('Không thể đặt lại mật khẩu');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
        (route) => false,
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
        title: const Text('Đặt lại mật khẩu'),
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
                Text(
                  'Email: ${widget.email}',
                  style: const TextStyle(
                    color: MauSac.xam,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã OTP';
                    }
                    if (value.trim().length != 6) {
                      return 'Mã OTP phải có 6 chữ số';
                    }
                    return null;
                  },
                  style: const TextStyle(color: MauSac.trang),
                  decoration: InputDecoration(
                    labelText: 'Mã OTP',
                    labelStyle: TextStyle(color: MauSac.xam.withOpacity(0.8)),
                    prefixIcon: const Icon(Icons.password, color: MauSac.kfcRed),
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
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Mật khẩu mới',
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmController,
                  label: 'Xác nhận mật khẩu',
                  isConfirm: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _dangXuLy ? null : _datLai,
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
                            'Đặt lại mật khẩu',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _anMatKhau,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        if (value.trim().length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        if (isConfirm && value.trim() != _passwordController.text.trim()) {
          return 'Mật khẩu xác nhận không khớp';
        }
        return null;
      },
      style: const TextStyle(color: MauSac.trang),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: MauSac.xam.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.lock_outline, color: MauSac.kfcRed),
        suffixIcon: IconButton(
          icon: Icon(_anMatKhau ? Icons.visibility_off : Icons.visibility, color: MauSac.xam),
          onPressed: () => setState(() => _anMatKhau = !_anMatKhau),
        ),
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
    );
  }
}
