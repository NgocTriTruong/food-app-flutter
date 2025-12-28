import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kfc/services_fix/auth_service.dart';

void main() {
  // ⚠️ BẮT BUỘC cho integration_test
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Gọi API Spring Boot lấy user (no auth)',
        (tester) async {
      // 👉 gọi API thật (KHÔNG auth)
      final user = await AuthService.getUserData(
        '69350033584b96cd000c8843',
        withAuth: false, // 👈 QUAN TRỌNG
      );

      // 👉 kiểm tra kết quả
      expect(user, isNotNull);
      expect(user!.email, isNotEmpty);

      print('✅ Email user: ${user.email}');
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );
}
