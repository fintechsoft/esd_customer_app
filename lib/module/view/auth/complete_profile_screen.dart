import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  // final _emailCtrl = TextEditingController();
  // final _addressCtrl = TextEditingController();
  // final _cityCtrl = TextEditingController();
  // final _stateCtrl = TextEditingController();
  // final _pincodeCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // mandatory step — block back button/gesture, not just the app bar arrow
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          automaticallyImplyLeading: false, // no going back — this step is mandatory
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Just a few details before you get started',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                _field('Full Name', _nameCtrl, required: true),
                // _field('Email', _emailCtrl, required: true, keyboardType: TextInputType.emailAddress),
                // _field('Address', _addressCtrl, required: true, maxLines: 2),
                // Row(
                //   children: [
                //     Expanded(child: _field('City', _cityCtrl, required: true)),
                //     const SizedBox(width: 12),
                //     Expanded(child: _field('State', _stateCtrl, required: true)),
                //   ],
                // ),
                // _field(
                //   'Pincode',
                //   _pincodeCtrl,
                //   required: true,
                //   keyboardType: TextInputType.number,
                //   maxLength: 6,
                //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //   validator: (v) {
                //     if (v == null || v.trim().isEmpty) return 'Pincode is required';
                //     if (v.trim().length != 6) return 'Enter a valid 6 digit pincode';
                //     return null;
                //   },
                // ),
                _field('GST Number (optional, for business customers)', _gstCtrl, required: false),
                const SizedBox(height: 12),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isVerifying.value ? null : _submit,
                    child: auth.isVerifying.value
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                        : const Text('Continue'),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        required bool required,
        TextInputType? keyboardType,
        int maxLines = 1,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(counterText: ''),
            validator: validator ??
                (required
                    ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
                    : null),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // if (_emailCtrl.text.trim().isNotEmpty &&
    //     !RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(_emailCtrl.text.trim())) {
    //   Get.snackbar('Invalid email', 'Please enter a valid email address', snackPosition: SnackPosition.BOTTOM);
    //   return;
    // }
    // email: _emailCtrl.text.trim(),
    // address: _addressCtrl.text.trim(),
    // city: _cityCtrl.text.trim(),
    // state: _stateCtrl.text.trim(),
    // pincode: _pincodeCtrl.text.trim(),
    await auth.completeProfile(
      name: _nameCtrl.text.trim(),
      gst: _gstCtrl.text.trim(),
    );
  }
}