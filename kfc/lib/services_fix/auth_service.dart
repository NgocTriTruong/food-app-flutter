import 'package:kfc/network/dio_client.dart'; // File Dio bạn đã gửi
import 'package:kfc/api/auth_api.dart'; // File interface ở bước 2
import 'package:kfc/models/nguoi_dung.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage();
  // Khởi tạo API client thông qua Dio đã cấu hình Interceptor
  static final AuthApi _authApi = AuthApi(DioClient.dio());

  // Lấy thông tin người dùng từ Spring Boot
  static Future<NguoiDung?> getUserData(String uid) async {
    try {
      print('Đang lấy thông tin user từ Spring Boot: $uid');
      final user = await _authApi.getUserData(uid);
      return user;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // Cập nhật thông tin qua API
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _authApi.updateUserData(uid, data);
      print('Cập nhật thông tin user thành công');
    } catch (e) {
      print('Lỗi cập nhật: $e');
      throw Exception('Không thể cập nhật thông tin');
    }
  }

  // Đăng xuất (Xóa token ở local)
  static Future<void> signOut() async {
    try {
      await _storage.delete(key: "token");
      print('Đã xóa token và đăng xuất');
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất');
    }
  }

  // Kiểm tra trạng thái đăng nhập dựa trên Token hiện có
  static Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: "token");
    return token != null;
  }

  // Giữ nguyên logic điều hướng
  static String getNavigationRoute(String? rule) {
    switch (rule?.toLowerCase()) {
      case 'admin': return '/admin';
      default: return '/home';
    }
  }
}