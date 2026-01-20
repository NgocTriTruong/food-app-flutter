import 'package:flutter/material.dart';
import 'package:kfc/screens/man_hinh_dang_ky.dart';
import 'package:kfc/screens/man_hinh_dang_nhap.dart';
import 'package:kfc/screens/man_hinh_don_hang.dart';
import 'package:kfc/screens/man_hinh_quen_mat_khau.dart';
import 'package:kfc/screens/man_hinh_chinh_sua_thong_tin.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';
import 'package:kfc/services_fix/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ManHinhTaiKhoan extends StatefulWidget {
  const ManHinhTaiKhoan({Key? key}) : super(key: key);

  @override
  State<ManHinhTaiKhoan> createState() => _ManHinhTaiKhoanState();
}

class _ManHinhTaiKhoanState extends State<ManHinhTaiKhoan>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _headerAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nguoiDung = context.watch<NguoiDungProvider>().nguoiDung;
    if (nguoiDung != null) {
      return _buildLoggedInViewLocal(nguoiDung);
    }

    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: SafeArea(
        child: _buildLoggedOutView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: MauSac.kfcRed,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildLoggedInViewLocal(NguoiDung user) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: MauSac.kfcRed.withOpacity(0.1),
                child: Text(
                  user.ten.isNotEmpty ? user.ten[0].toUpperCase() : 'U',
                  style: const TextStyle(color: MauSac.kfcRed, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.ten,
                style: const TextStyle(color: MauSac.trang, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                style: const TextStyle(color: MauSac.xam, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                      _buildSimpleTile(Icons.edit_outlined, 'Chỉnh sửa thông tin', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhChinhSuaThongTin()));
                    }),
                      _buildSimpleTile(Icons.face, 'Đăng ký Face ID', () async {
                        try {
                          final picker = ImagePicker();
                          final XFile? picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 80);
                          if (picked == null) return;
                          await AuthService.registerFaceFromFile(picked.path);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký Face ID thành công')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      }),
                    _buildSimpleTile(Icons.receipt_long, 'Đơn hàng của tôi', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhDonHang()));
                    }),
                    _buildSimpleTile(Icons.logout, 'Đăng xuất', () async {
                      await AuthService.signOut();
                      context.read<NguoiDungProvider>().dangXuat();
                    }, danger: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, VoidCallback onTap, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: danger ? MauSac.kfcRed : MauSac.trang),
        title: Text(
          title,
          style: TextStyle(color: danger ? MauSac.kfcRed : MauSac.trang, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.chevron_right, color: danger ? MauSac.kfcRed : MauSac.trang),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MauSac.kfcRed.withOpacity(0.1),
                          MauSac.kfcRed.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                        color: MauSac.kfcRed.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 70,
                      color: MauSac.kfcRed,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Chào mừng đến với KFC!',
              style: TextStyle(
                color: MauSac.trang,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Đăng nhập để đặt hàng và nhận những\nưu đãi đặc biệt từ KFC',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MauSac.xam.withOpacity(0.8),
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            _buildAuthButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: MauSac.kfcRed,
              foregroundColor: MauSac.trang,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: MauSac.kfcRed.withOpacity(0.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 22),
                SizedBox(width: 12),
                Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Forgot Password Link
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _navigateToForgotPassword,
            child: Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _navigateToRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: MauSac.trang,
              side: BorderSide(color: MauSac.kfcRed.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 22),
                SizedBox(width: 12),
                Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangKy()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhQuenMatKhau()),
    );
  }

  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManHinhDonHang(),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final AnimationController contentAnimationController = AnimationController(
          duration: const Duration(milliseconds: 800),
          vsync: Navigator.of(context),
        );
        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: contentAnimationController,
          curve: Curves.easeOut,
        ));
        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: contentAnimationController,
          curve: Curves.easeOutBack,
        ));

        contentAnimationController.forward();

        return AlertDialog(
          backgroundColor: MauSac.denNhat,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MauSac.kfcRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info, color: MauSac.kfcRed, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Về KFC Việt Nam',
                style: TextStyle(
                  color: MauSac.trang,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo or Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MauSac.kfcRed.withOpacity(0.1),
                          border: Border.all(
                            color: MauSac.kfcRed.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.fastfood,
                          color: MauSac.kfcRed,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Info
                    const Text(
                      'KFC Vietnam App',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phiên bản: 1.0.0',
                      style: TextStyle(
                        color: MauSac.xam.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Ngày phát hành: 09/06/2025',
                      style: TextStyle(
                        color: MauSac.xam.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // About KFC
                    const Text(
                      'Giới thiệu về KFC',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KFC (Kentucky Fried Chicken) là thương hiệu gà rán nổi tiếng toàn cầu, được thành lập bởi Đại tá Harland Sanders vào năm 1930 tại Kentucky, Hoa Kỳ. KFC Việt Nam bắt đầu hoạt động từ năm 1997 và hiện có hơn 140 nhà hàng trên toàn quốc.',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mission
                    const Text(
                      'Sứ mệnh',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mang đến những bữa ăn ngon, chất lượng cao với công thức 11 loại thảo mộc và gia vị bí mật, cùng dịch vụ thân thiện và nhanh chóng.',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Info
                    const Text(
                      'Liên hệ',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hotline: 1900 6886\nEmail: support@kfcvietnam.com.vn\nWebsite: www.kfcvietnam.com.vn',
                      style: TextStyle(
                        color: MauSac.trang,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                contentAnimationController.dispose();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.kfcRed,
                foregroundColor: MauSac.trang,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MauSac.denNhat,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MauSac.kfcRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: MauSac.kfcRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Đăng xuất',
              style: TextStyle(
                color: MauSac.trang,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(
            color: MauSac.trang,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: MauSac.xam,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              context.read<NguoiDungProvider>().dangXuat();
              Navigator.pop(context);
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManHinhDangNhap(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MauSac.kfcRed,
              foregroundColor: MauSac.trang,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}