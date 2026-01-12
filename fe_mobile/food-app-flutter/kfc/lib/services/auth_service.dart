import 'package:dio/dio.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:kfc/models/nguoi_dung.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static final Dio _dio = DioClient.dio();
  static const storage = FlutterSecureStorage();

  // Đăng nhập bằng email/password
  static Future<NguoiDung?> loginWithEmail(String email, String password) async {
    try {
      print('Đang đăng nhập với email: $email');

      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      print('Login response statusCode: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];
        
        print('Đăng nhập thành công: ${userData['ten']}');
        print('Token nhận được: $token');
        print('Token length: ${token?.length}');
        
        // Lưu token
        await storage.write(key: 'token', value: token ?? '');
        print('Token đã lưu vào storage');
        
        // Verify token đã lưu
        final savedToken = await storage.read(key: 'token');
        print('Token sau khi lưu: $savedToken');
        
        return NguoiDung.fromMap(userData);
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      rethrow;
    }
  }

  // Đăng ký người dùng mới
  static Future<NguoiDung?> registerUser(String ten, String email, String password, String soDienThoai) async {
    try {
      print('Đang đăng ký: $email');

      final response = await _dio.post('/auth/register', data: {
        'ten': ten,
        'email': email,
        'password': password,
        'soDienThoai': soDienThoai,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'];
        print('Đăng ký thành công: ${userData['ten']}');
        
        return NguoiDung.fromMap(userData);
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      print('Lỗi khi đăng ký: $e');
      rethrow;
    }
  }

  // Lấy thông tin người dùng hiện tại (từ token)
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      print('getCurrentUserData: Getting token...');
      final token = await getToken();
      print('getCurrentUserData: token = ${token?.substring(0, 20)}...');
      if (token == null) {
        print('getCurrentUserData: token is null');
        return null;
      }

      // Decode JWT để lấy uid
      print('getCurrentUserData: Decoding JWT...');
      final parts = token.split('.');
      if (parts.length != 3) {
        print('getCurrentUserData: Invalid JWT format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      print('getCurrentUserData: JWT payload = $payloadMap');
      
      final uid = payloadMap['sub'] ?? payloadMap['userId'];
      print('getCurrentUserData: uid = $uid');
      if (uid == null) {
        print('getCurrentUserData: uid not found in token');
        return null;
      }

      print('getCurrentUserData: Calling API /auth/user/$uid');
      final response = await _dio.get('/auth/user/$uid');
      print('getCurrentUserData: Response status = ${response.statusCode}');
      print('getCurrentUserData: Response data = ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e, stackTrace) {
      print('getCurrentUserData ERROR: $e');
      print('getCurrentUserData STACK: $stackTrace');
      return null;
    }
  }

  // Lấy thông tin người dùng từ backend
  static Future<NguoiDung?> getUserData(String uid) async {
    try {
      print('Đang lấy thông tin user từ backend: $uid');

      final response = await _dio.get('/auth/user/$uid');

      if (response.statusCode == 200 && response.data != null) {
        print('Dữ liệu user từ backend: ${response.data}');
        return NguoiDung.fromMap(response.data);
      } else {
        print('Không tìm thấy user');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // Quên mật khẩu - gửi OTP
  static Future<bool> forgotPassword(String email) async {
    try {
      print('Đang gửi OTP cho email: $email');

      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        print('OTP đã được gửi');
        return true;
      } else {
        throw Exception('Gửi OTP thất bại');
      }
    } catch (e) {
      print('Lỗi khi gửi OTP: $e');
      rethrow;
    }
  }

  // Đặt lại mật khẩu
  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      print('Đang đặt lại mật khẩu cho: $email');

      final response = await _dio.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200) {
        print('Đặt lại mật khẩu thành công');
        return true;
      } else {
        throw Exception('Đặt lại mật khẩu thất bại');
      }
    } catch (e) {
      print('Lỗi khi đặt lại mật khẩu: $e');
      rethrow;
    }
  }

  // Kiểm tra quyền và điều hướng
  static String getNavigationRoute(String? rule) {
    print('Xác định route dựa trên quyền: $rule');

    switch (rule?.toLowerCase()) {
      case 'admin':
        print('Điều hướng đến trang admin');
        return '/admin';
      case 'user':
      default:
        print('Điều hướng đến trang home');
        return '/home';
    }
  }

  // Cập nhật thông tin người dùng
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      print('Đang cập nhật thông tin user: $uid');
      
      final response = await _dio.put('/users/$uid', data: data);
      
      if (response.statusCode == 200) {
        print('Cập nhật thông tin user thành công');
      } else {
        throw Exception('Cập nhật thất bại');
      }
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      throw Exception('Không thể cập nhật thông tin người dùng');
    }
  }

  // Đăng xuất
  static Future<void> signOut() async {
    try {
      await storage.delete(key: 'token');
      print('Đăng xuất thành công');
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      throw Exception('Không thể đăng xuất');
    }
  }

  // Lấy token
  static Future<String?> getToken() async {
    try {
      return await storage.read(key: 'token');
    } catch (e) {
      print('Lỗi khi lấy token: $e');
      return null;
    }
  }

  // Kiểm tra đăng nhập
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
