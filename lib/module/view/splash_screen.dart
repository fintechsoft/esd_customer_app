import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/constants/assets_path.dart';
import 'package:esdcustomer/constants/size.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:esdcustomer/module/view/auth/complete_profile_screen.dart';
import 'package:esdcustomer/module/view/auth/login_screen.dart';
import 'package:esdcustomer/module/view/main_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    final auth = Get.find<AuthController>();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      final c = auth.customer.value;
      // Backend seeds a brand-new OTP signup with name = "Customer" — if it's
      // still that placeholder, they never finished the one-field intro form.
      final profileIncomplete = c == null || c.name.trim().isEmpty || c.name.trim() == 'Customer';
      if (profileIncomplete) {
        Get.offAll(() => const CompleteProfileScreen());
      } else {
        Get.offAll(() => const MainNav());
      }
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return OrientationBuilder(
            builder: (ctx, orientation) {
              ResponsiveSize.init(ctx, orientation);
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(logo, width: getScreeWidth(260)),
                    getVerticalSpace(6),
                    Text(
                      'Your bills, orders & support\nin one place',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(
                        fontSize: getTextSize(14),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: kLightText,
                      ),
                    ),
                    getVerticalSpace(48),
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: kPrimary,
                        strokeWidth: 2.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}