import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14.5),
              ),
              const SizedBox(height: 4),
              Text('+91 ${widget.phone}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 28),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otp,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 52,
                  fieldWidth: 44,
                  activeColor: AppTheme.primary,
                  selectedColor: AppTheme.primary,
                  inactiveColor: Colors.black12,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                ),
                enableActiveFill: true,
                onChanged: (_) {},
                onCompleted: (value) => auth.verifyOtp(value),
              ),
              const SizedBox(height: 20),
              Obx(() => Row(
                    children: [
                      Text("Didn't receive the code? ", style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5)),
                      GestureDetector(
                        onTap: auth.resendSeconds.value == 0 ? auth.resendOtp : null,
                        child: Text(
                          auth.resendSeconds.value > 0 ? 'Resend in ${auth.resendSeconds.value}s' : 'Resend',
                          style: TextStyle(
                            color: auth.resendSeconds.value > 0 ? AppTheme.textMuted : AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 28),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isVerifying.value ? null : () => auth.verifyOtp(_otp.text.trim()),
                      child: auth.isVerifying.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                            )
                          : const Text('Verify & Continue'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
