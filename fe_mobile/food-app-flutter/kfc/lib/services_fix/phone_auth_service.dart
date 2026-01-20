import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:kfc/api/auth_api.dart';
import 'package:kfc/network/dio_client.dart';

class PhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gửi OTP
  static Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verify (Android)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Lỗi xác thực');
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Xác nhận OTP
  static Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);
  }

  /// Gửi Firebase ID Token lên backend
  static Future<void> confirmToBackend() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập Firebase");

    final idToken = await user.getIdToken(true);

    await Dio().post(
      "http://YOUR_BACKEND/api/auth/verify-phone",
      data: {"idToken": idToken},
    );
  }
}