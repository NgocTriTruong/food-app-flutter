import 'package:flutter_test/flutter_test.dart';
import 'package:kfc/services_fix/auth_service.dart';

void main() {
  test('Test lay thong tin nguoi dung tu API', () async {
    // Lưu ý: Máy tính chạy test dùng 'localhost' thay vì '10.0.2.2'
    // Bạn có thể cần cấu hình tạm baseUrl là localhost để chạy test này

    final user = await AuthService.getUserData("69350033584b96cd000c8843"); // Giả sử ID là 1

    expect(user, isNotNull);
    print("User name: ${user?.ten}");
  });
}