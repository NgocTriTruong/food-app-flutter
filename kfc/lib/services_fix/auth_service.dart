import 'package:kfc/network/dio_client.dart';
import 'package:kfc/api/auth_api.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage();

  // 🔐 Dùng khi CẦN token (app thật)
  static final AuthApi _authApiAuth =
  AuthApi(DioClient.dio(withAuth: true));

  // 🌐 Dùng khi KHÔNG cần token (test / API public)
  static final AuthApi _authApiNoAuth =
  AuthApi(DioClient.dio(withAuth: false));

  // =============================
  // LẤY THÔNG TIN USER
  // =============================
  static Future<NguoiDung?> getUserData(
      String uid, {
        bool withAuth = true, // 👈 mặc định KHÔNG auth cho test
      }) async {
    try {
      print('Đang lấy thông tin user từ Spring Boot: $uid');

      final api = withAuth ? _authApiAuth : _authApiNoAuth;
      return await api.getUserData(uid);
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // =============================
  // CẬP NHẬT USER (CẦN AUTH)
  // =============================
  static Future<void> updateUserData(
      String uid,
      Map<String, dynamic> data,
      ) async {
    try {
      await _authApiAuth.updateUserData(uid, data);
      print('Cập nhật thông tin user thành công');
    } catch (e) {
      print('Lỗi cập nhật: $e');
      throw Exception('Không thể cập nhật thông tin');
    }
  }

  // =============================
  // ĐĂNG XUẤT
  // =============================
  static Future<void> signOut() async {
    try {
      await _storage.delete(key: "token");
      print('Đã xóa token và đăng xuất');
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất');
    }
  }

  // =============================
  // KIỂM TRA LOGIN
  // =============================
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: "token");
    return token != null && token.isNotEmpty;
  }

  // =============================
  // ĐIỀU HƯỚNG
  // =============================
  static String getNavigationRoute(String? rule) {
    switch (rule?.toLowerCase()) {
      case 'admin':
        return '/admin';
      default:
        return '/home';
    }
  }
}
