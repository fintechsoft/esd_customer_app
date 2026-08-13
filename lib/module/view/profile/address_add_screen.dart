import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/models/address_model.dart';
import 'package:esdcustomer/module/controller/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddressAddScreen extends StatefulWidget {
  final AddressModel? existing; // null = adding new
  const AddressAddScreen({Key? key, this.existing}) : super(key: key);

  @override
  State<AddressAddScreen> createState() => _AddressAddScreenState();
}

class _AddressAddScreenState extends State<AddressAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;

  // Editing: exactly one type selected (maps 1:1 to the existing row).
  late final RxString _editType;
  // Adding: one or more types selected — saves one row per type so the
  // customer doesn't have to retype the same address for each purpose.
  late final RxSet<String> _newTypes;

  final ctrl = Get.find<AddressController>();

  final _types = const [
    {'value': 'shipping', 'label': 'Shipping'},
    {'value': 'billing', 'label': 'Billing'},
    {'value': 'installation', 'label': 'Installation'},
  ];

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _stateCtrl = TextEditingController(text: e?.state ?? '');
    _pincodeCtrl = TextEditingController(text: e?.pincode ?? '');
    _editType = (e?.addressType ?? 'shipping').obs;
    _newTypes = <String>{'shipping'}.obs;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBgColor,
      appBar: AppBar(title: Text(isEditing ? 'Edit Address' : 'Add Address')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Address Type', style: TextStyle(fontWeight: FontWeight.w600)),
            if (!isEditing) ...[
              const SizedBox(height: 4),
              Text(
                'Select all that apply — same address can be used for more than one purpose.',
                style: TextStyle(color: kLightText, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            isEditing ? _singleTypePicker() : _multiTypePicker(),
            const SizedBox(height: 18),
            _field('Address', _addressCtrl, maxLines: 3),
            Row(
              children: [
                Expanded(child: _field('City', _cityCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('State', _stateCtrl)),
              ],
            ),
            _field(
              'Pincode',
              _pincodeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Pincode is required';
                if (v.trim().length != 6) return 'Enter a valid 6 digit pincode';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isSaving.value ? null : _submit,
                child: ctrl.isSaving.value
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                    : Text(isEditing ? 'Update Address' : 'Save Address'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _singleTypePicker() {
    return Obx(() => Wrap(
      spacing: 8,
      children: _types.map((t) {
        final selected = _editType.value == t['value'];
        return ChoiceChip(
          label: Text(t['label']!, style: TextStyle(fontSize: 12.5, color: selected ? Colors.white : kDark)),
          selected: selected,
          selectedColor: kPrimary,
          backgroundColor: Colors.white,
          onSelected: (_) => _editType.value = t['value']!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: selected ? kPrimary : Colors.black12),
          ),
        );
      }).toList(),
    ));
  }

  Widget _multiTypePicker() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final value = t['value']!;
        final selected = _newTypes.contains(value);
        return FilterChip(
          label: Text(t['label']!, style: TextStyle(fontSize: 12.5, color: selected ? Colors.white : kDark)),
          selected: selected,
          selectedColor: kPrimary,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.white,
          onSelected: (checked) {
            if (checked) {
              _newTypes.add(value);
            } else {
              // Keep at least one type selected — can't save an
              // address with no purpose attached.
              if (_newTypes.length > 1) _newTypes.remove(value);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: selected ? kPrimary : Colors.black12),
          ),
        );
      }).toList(),
    ));
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType? keyboardType,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(counterText: ''),
            validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bool ok;
    if (isEditing) {
      ok = await ctrl.updateAddress(
        id: widget.existing!.id,
        addressType: _editType.value,
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
      );
    } else {
      ok = await ctrl.createAddress(
        addressTypes: _newTypes.toList(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
      );
    }
    if (ok && mounted) Get.back();
  }
}