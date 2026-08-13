import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/constants/assets_path.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Image.asset(logo, width: 120),
              const SizedBox(height: 24),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Login with your mobile number to view bills,\ntrack orders and raise support requests.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14.5, height: 1.4),
              ),
              const SizedBox(height: 36),
              Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Center(widthFactor: 1, child: Text('+91', style: TextStyle(fontWeight: FontWeight.w600))),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '98765 43210',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isSendingOtp.value ? null : () => auth.sendOtp(_controller.text.trim()),
                      child: auth.isSendingOtp.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                            )
                          : const Text('Send OTP'),
                    ),
                  )),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
