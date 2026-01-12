import 'package:flutter/material.dart';
import 'package:kfc/services_fix/auth_service.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:provider/provider.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';
import 'package:kfc/screens/man_hinh_dang_ky.dart';
import 'package:kfc/screens/man_hinh_quen_mat_khau.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({Key? key}) : super(key: key);

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  bool _hienMatKhau = false;
  bool _dangXuLy = false;

  late AnimationController _animationController;
  late AnimationController _logoAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _matKhauController.dispose();
    _animationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  // Kiểm tra kết nối internet
  Future<bool> _kiemTraKetNoiInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  Future<void> _dangNhap() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _dangXuLy = true;
        });

        // 1. Kiểm tra kết nối internet
        bool coInternet = await _kiemTraKetNoiInternet();
        if (!coInternet) {
          throw Exception('Không có kết nối internet');
        }

        print('Bắt đầu đăng nhập Spring Boot: ${_emailController.text.trim()}');

        // 2. Gọi hàm signIn từ AuthService (đã xử lý lưu Token/UID bên trong)
        final userData = await AuthService.signIn(
          _emailController.text.trim(),
          _matKhauController.text,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Kết nối server quá chậm, vui lòng thử lại');
          },
        );
        print('hi');
        // 3. Kiểm tra dữ liệu trả về
        if (userData == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        print('Đăng nhập thành công! UID: ${userData.id}');

        // 4. Cập nhật Provider (để các màn hình khác nhận được thông tin user)
        if (mounted) {
          final nguoiDungProvider = Provider.of<NguoiDungProvider>(context, listen: false);
          nguoiDungProvider.dangNhap(userData);

          // Hiển thị thông báo chào mừng
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Chào mừng ${userData.ten} quay lại!'),
                ],
              ),
              backgroundColor: Colors.green, // Dùng Colors nếu MauSac.xanhLa chưa định nghĩa
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          // 5. Kiểm tra quyền Admin và hiển thị thông báo (nếu cần)
          if (userData.rule?.toLowerCase() == 'admin') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Đăng nhập với quyền Admin'),
                  ],
                ),
                backgroundColor: Colors.purple,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // 6. Điều hướng đến trang phù hợp dựa trên Role
          String route = AuthService.getNavigationRoute(userData.rule);
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
                (route) => false,
          );
        }

      } on DioException catch (e) {
        // Xử lý lỗi từ phía Dio/Server
        String message = 'Lỗi kết nối server';
        if (e.response?.statusCode == 401) {
          message = 'Email hoặc mật khẩu không chính xác';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          message = 'Máy chủ không phản hồi';
        }
        _hienThiLoi(message);
      } catch (e) {
        // Xử lý các lỗi khác (Exception tự ném ra)
        print('Lỗi: $e');
        _hienThiLoi(e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (mounted) {
          setState(() {
            _dangXuLy = false;
          });
        }
      }
    }
  }


 Future<void> _dangNhapVoiGoogle() async {
  try {
    setState(() {
      _dangXuLy = true;
    });

    // Kiểm tra kết nối internet trước
    bool coInternet = await _kiemTraKetNoiInternet();
    if (!coInternet) {
      throw Exception('Không có kết nối internet');
    }

    print('Bắt đầu đăng nhập với Google');

    // TODO: Google Sign-In integration with backend API
    // Hiện tại không triển khai, người dùng dùng email/password hoặc đăng ký trước
    throw Exception('Google Sign-In tạm thời chưa hỗ trợ. Vui lòng sử dụng email/password.');

  } catch (e) {
    print('Lỗi: $e');
    _hienThiLoi(e.toString().replaceAll('Exception: ', ''));
  } finally {
    if (mounted) {
      setState(() {
        _dangXuLy = false;
      });
    }
  }
}

  void _hienThiLoi(String thongBao) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(thongBao)),
            ],
          ),
          backgroundColor: MauSac.kfcRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _quenMatKhau() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhQuenMatKhau()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo và tiêu đề
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // Form đăng nhập
                  _buildLoginForm(),
                  
                  const SizedBox(height: 32),
                  
                  // Nút đăng nhập
                  _buildLoginButton(),
                  
                  const SizedBox(height: 16),
                  
                  // Nút đăng nhập với Google
                  _buildGoogleSignInButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Quên mật khẩu
                  _buildForgotPassword(),
                  
                  const SizedBox(height: 40),
                  
                  // Đăng ký
                  _buildSignUpSection(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MauSac.kfcRed,
                      MauSac.kfcRed.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: MauSac.kfcRed.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: MauSac.trang,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'KFC Vietnam',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  color: MauSac.xam.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        style: const TextStyle(color: MauSac.trang, fontSize: 16),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: MauSac.xam.withOpacity(0.8)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MauSac.kfcRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.email_outlined, color: MauSac.kfcRed, size: 20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MauSac.xamDam.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
          fillColor: MauSac.denNhat,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Email không hợp lệ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _matKhauController,
        style: const TextStyle(color: MauSac.trang, fontSize: 16),
        obscureText: !_hienMatKhau,
        decoration: InputDecoration(
          labelText: 'Mật khẩu',
          labelStyle: TextStyle(color: MauSac.xam.withOpacity(0.8)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MauSac.kfcRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_outline, color: MauSac.kfcRed, size: 20),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _hienMatKhau ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: MauSac.xam,
            ),
            onPressed: () {
              setState(() {
                _hienMatKhau = !_hienMatKhau;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MauSac.xamDam.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MauSac.kfcRed, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
          fillColor: MauSac.denNhat,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập mật khẩu';
          }
          if (value.length < 6) {
            return 'Mật khẩu phải có ít nhất 6 ký tự';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MauSac.kfcRed.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _dangXuLy ? null : _dangNhap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.kfcRed,
                  foregroundColor: MauSac.trang,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: MauSac.kfcRed.withOpacity(0.5),
                ),
                child: _dangXuLy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: MauSac.trang,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _dangXuLy ? null : _dangNhapVoiGoogle,
                icon: Image.asset(
                  'assets/images/google_logo.png', // Add Google logo to assets
                  width: 24,
                  height: 24,
                ),
                label: const Text(
                  'Đăng nhập với Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.trang,
                  foregroundColor: MauSac.denNhat,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: MauSac.trang.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: TextButton(
              onPressed: _dangXuLy ? null : _quenMatKhau,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: MauSac.kfcRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MauSac.denNhat,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MauSac.kfcRed.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(
                      color: MauSac.xam.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _dangXuLy ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManHinhDangKy(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: MauSac.kfcRed, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tạo tài khoản mới',
                        style: TextStyle(
                          color: MauSac.kfcRed,
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
        );
      },
    );
  }
}