  import 'package:kfc/network/dio_client.dart';
  import 'package:kfc/api/auth_api.dart';
  import 'package:kfc/models/nguoi_dung.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:dio/dio.dart';
  import 'package:retrofit/retrofit.dart';
  import 'package:google_sign_in/google_sign_in.dart';

  class AuthService {
    static final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId: '605693091796-rj3fcrm08ada6fbobd4156cba1cvlgto.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );

    static final _storage = const FlutterSecureStorage();

    // 🔐 Dùng khi CẦN token (app thật)
    static final AuthApi _authApiAuth = AuthApi(DioClient.dio(withAuth: true));

    // 🌐 Dùng khi KHÔNG cần token (cho việc login)
    static final AuthApi _authApiNoAuth = AuthApi(DioClient.dio(withAuth: false));

    // =============================
    // ĐĂNG NHẬP (Thay thế Firebase)
    // =============================
    static Future<NguoiDung?> signIn(String email, String password) async {
      try {
        // Gọi hàm login từ AuthApi
        final response = await _authApiNoAuth.login({
          "email": email,
          "password": password,
        });

        // Lấy data từ HttpResponse
        final data = response.data;

        // Giả sử Spring Boot trả về Map có chứa 'token' và 'user'
        final String? token = data['token'];
        final userData = data['user'];

        if (token != null && userData != null) {
          // Lưu token để DioClient interceptor có thể lấy dùng cho các request sau
          await _storage.write(key: "token", value: token);
          // Lưu UID để dùng cho hàm getUserData(uid)
          await _storage.write(key: "uid", value: userData['id'].toString());

          return NguoiDung.fromJson(userData);
        }
        return null;
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sai email hoặc mật khẩu');
        }
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    }
    // =============================
// ĐĂNG NHẬP GOOGLE
// =============================
    static Future<NguoiDung?> signInWithGoogle() async {
      try {
        // 1. Chọn tài khoản Google
        print("🟡 Start Google Sign In");

        final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

        if (googleUser == null) {
          print("user is null"); // user bấm hủy
          return null;
        }
        print("🟢 Selected account");

        // 2. Lấy ID Token
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final String? idToken = googleAuth.idToken;
        print("🟢 Got token");

        if (idToken == null) {
          throw Exception('Không lấy được Google ID Token');
        }
        print("🟢 Backend response");
        // 3. Gửi token lên backend
        final response = await _authApiNoAuth.loginWithGoogle({
          "idToken": idToken,
        });
        print('get ');
        final data = response.data as Map<String, dynamic>;

        final String token = data['token'];
        final Map<String, dynamic> userJson = data['user'];
        print('save user');
        // 4. Lưu token
        await _storage.write(key: "token", value: token);
        await _storage.write(
            key: "uid", value: userJson['id'].toString());

        // 5. Trả user
        return NguoiDung.fromJson(userJson);

      } on DioException catch (e) {
        final message =
            e.response?.data?.toString() ?? 'Lỗi đăng nhập Google';
        throw Exception(message);
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    // =============================
    // ĐĂNG KÝ (Mới)
    // =============================
    static Future<NguoiDung?> signUp({
      required String ten,
      required String email,
      required String password,
      required String soDienThoai,
    }) async {
      try {
        final response = await _authApiNoAuth.register({
          "ten": ten,
          "email": email,
          "password": password,
          "soDienThoai": soDienThoai,
        });

        final data = response.data;
        final String? token = data['token'];
        final userData = data['user'];

        if (token != null && userData != null) {
          await _storage.write(key: "token", value: token);
          await _storage.write(key: "uid", value: userData['id'].toString());

          return NguoiDung.fromJson(userData);
        }
        return null;
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          throw Exception(e.response?.data ?? 'Email đã được sử dụng');
        }
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    }

    // =============================
    // LẤY THÔNG TIN USER (Giữ nguyên tên hàm của bạn)
    // =============================
    static Future<NguoiDung?> getUserData(
        String uid, {
          bool withAuth = true,
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
    // CẬP NHẬT USER (Giữ nguyên tên hàm của bạn)
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
    // ĐĂNG XUẤT (Giữ nguyên tên hàm của bạn)
    // =============================
    static Future<void> signOut() async {
      try {
        await _storage.delete(key: "token");
        await _storage.delete(key: "uid"); // Xóa luôn uid khi logout
        print('Đã xóa token và đăng xuất');
      } catch (e) {
        throw Exception('Lỗi khi đăng xuất');
      }
    }

    // Lấy UID đã lưu (dùng cho AuthWrapper)
    static Future<String?> getStoredUid() {
      return _storage.read(key: "uid");
    }

    // =============================
    // FACE ID - Register face for current user
    // =============================
    static Future<void> registerFaceFromFile(String filePath) async {
      try {
        final dio = DioClient.dio(withAuth: true);
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(filePath, filename: 'face.jpg'),
        });
        await dio.post('/face/register', data: formData);
      } catch (e) {
        print('Error registerFace: $e');
        throw Exception('Không thể đăng ký khuôn mặt: $e');
      }
    }

    // =============================
    // FACE ID - Login with face image
    // =============================
    static Future<NguoiDung?> loginWithFaceFile(String filePath) async {
      try {
        final dio = DioClient.dio(withAuth: false);
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(filePath, filename: 'face.jpg'),
        });

        final response = await dio.post('/face/login', data: formData);
        final data = response.data as Map<String, dynamic>;
        final String? token = data['token'];
        final userData = data['user'];
        if (token != null && userData != null) {
          await _storage.write(key: "token", value: token);
          await _storage.write(key: "uid", value: userData['id'].toString());
          return NguoiDung.fromJson(userData);
        }
        return null;
      } on DioException catch (e) {
        print('Error loginWithFaceFile - DioException: status=${e.response?.statusCode} body=${e.response?.data}');
        final msg = e.response?.data?.toString() ?? e.message;
        throw Exception('Đăng nhập bằng khuôn mặt thất bại: $msg');
      } catch (e) {
        print('Error loginWithFaceFile: $e');
        throw Exception('Đăng nhập bằng khuôn mặt thất bại');
      }
    }

    // =============================
    // KIỂM TRA LOGIN (Giữ nguyên tên hàm của bạn)
    // =============================
    static Future<bool> isLoggedIn() async {
      final token = await _storage.read(key: "token");
      return token != null && token.isNotEmpty;
    }

    // =============================
    // QUÊN / ĐẶT LẠI MẬT KHẨU (Backend riêng)
    // =============================
    static Future<void> forgotPassword(String email) async {
      try {
        await _authApiNoAuth.forgotPassword({"email": email});
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          throw Exception('Không tìm thấy tài khoản với email này.');
        }
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    }

    static Future<bool> resetPassword(String email, String newPassword, String otp) async {
      try {
        await _authApiNoAuth.resetPassword({
          "email": email,
          "newPassword": newPassword,
          "otp": otp,
        });
        return true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          throw Exception('Không tìm thấy tài khoản với email này.');
        }
        if (e.response?.statusCode == 400) {
          throw Exception('Mã OTP không hợp lệ hoặc đã hết hạn.');
        }
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    }

    // =============================
    // ĐIỀU HƯỚNG (Giữ nguyên tên hàm của bạn)
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