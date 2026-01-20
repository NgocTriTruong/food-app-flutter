import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services_fix/phone_auth_service.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  String? verificationId;
  bool loading = false;

  void sendOtp() async {
    setState(() => loading = true);

    await PhoneAuthService.sendOtp(
      phone: phoneCtrl.text,
      onCodeSent: (id) {
        setState(() {
          verificationId = id;
          loading = false;
        });
      },
      onError: (e) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e)));
      },
    );
  }

  void verifyOtp() async {
    try {
      setState(() => loading = true);

      await PhoneAuthService.verifyOtp(
        verificationId: verificationId!,
        otp: otpCtrl.text,
      );

      await PhoneAuthService.confirmToBackend();

      if (mounted) {
        Navigator.pop(context, true); // verified
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("OTP không đúng")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực số điện thoại")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Số điện thoại (+84...)",
              ),
            ),
            const SizedBox(height: 12),
            if (verificationId == null)
              ElevatedButton(
                onPressed: loading ? null : sendOtp,
                child: const Text("Gửi OTP"),
              ),
            if (verificationId != null) ...[
              TextField(
                controller: otpCtrl,
                decoration: const InputDecoration(labelText: "Nhập OTP"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: const Text("Xác nhận"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
