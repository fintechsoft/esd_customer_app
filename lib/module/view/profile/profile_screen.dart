import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/constants/size.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:esdcustomer/module/view/my_enquires_screen.dart';
import 'package:esdcustomer/module/view/orders/orders_screen.dart';
import 'package:esdcustomer/module/view/profile/addresses_screen.dart';
import 'package:esdcustomer/module/view/support/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kAppBgColor,
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final c = auth.customer.value;
        final initials = _getInitials(c?.name ?? 'Customer');
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile header card, maroon gradient — matches brand identity
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    child: Text(
                      initials,
                      style: GoogleFonts.jost(color: Colors.white, fontSize: getTextSize(22), fontWeight: FontWeight.w800),
                    ),
                  ),
                  getHorizontalSpace(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c?.name ?? 'Customer',
                            style: GoogleFonts.jost(color: Colors.white, fontSize: getTextSize(17), fontWeight: FontWeight.w700)),
                        getVerticalSpace(4),
                        Text('+91 ${c?.phone ?? ''}',
                            style: GoogleFonts.jost(color: Colors.white.withOpacity(0.8), fontSize: getTextSize(13))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            getVerticalSpace(22),
            _groupLabel('Account'),
            getVerticalSpace(8),
            _tileGroup([
              _TileData(Icons.location_on_outlined, 'Saved Addresses', () => Get.to(() => const AddressesScreen())),
              _TileData(Icons.receipt_long_outlined, 'My Bills', () => Get.to(() => const OrdersScreen())),
              _TileData(Icons.support_agent_outlined, 'My Enquires', () => Get.to(() => const MyEnquiresScreen())),
              _TileData(Icons.support_agent_outlined, 'Support Requests', () => Get.to(() => const SupportScreen())),
            ]),
            getVerticalSpace(20),
            _groupLabel('About'),
            getVerticalSpace(8),
            _tileGroup([
              _TileData(Icons.privacy_tip_outlined, 'Privacy Policy', () => _openUrl(ApiConstants.privacyPolicyUrl)),
              _TileData(Icons.description_outlined, 'Terms & Conditions', () => _openUrl(ApiConstants.termsUrl)),
              _TileData(Icons.headset_mic_outlined, 'Contact Us', () => _openUrl(ApiConstants.contactUsUrl)),
            ]),
            getVerticalSpace(24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, auth),
                icon: const Icon(Icons.logout_rounded, size: 18, color: kDanger),
                label: Text('Logout', style: GoogleFonts.jost(color: kDanger, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: kDanger)),
              ),
            ),
            getVerticalSpace(12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _confirmDeleteAccount(context, auth),
                icon: const Icon(Icons.delete_forever_outlined, size: 18, color: kDanger),
                label: Text('Delete Account',
                    style: GoogleFonts.jost(color: kDanger, fontWeight: FontWeight.w600)),
              ),
            ),
            getVerticalSpace(4),
            Text(
              'Deleting your account permanently removes your profile, saved addresses, enquiries and support requests. This cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(fontSize: getTextSize(11.5), color: kLightText),
            ),
            getVerticalSpace(8),
          ],
        );
      }),
    );
  }

  Widget _groupLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.jost(fontSize: getTextSize(11), fontWeight: FontWeight.w600, color: kLightText, letterSpacing: 0.8),
    );
  }

  Widget _tileGroup(List<_TileData> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: kPrimaryTint, borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.icon, color: kPrimary, size: 18),
                ),
                title: Text(t.label, style: GoogleFonts.jost(fontSize: getTextSize(13.5), fontWeight: FontWeight.w500, color: kDark)),
                trailing: Icon(Icons.chevron_right_rounded, size: 20, color: kGreyIcon),
                onTap: t.onTap,
              ),
              if (i < tiles.length - 1) Divider(height: 1, indent: 62, color: kBorder),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Unable to open', 'Could not open this page right now', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.jost()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.jost())),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: Text('Logout', style: GoogleFonts.jost(color: kDanger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account?', style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text(
          'This permanently deletes your ESD account and all data linked to it — '
          'profile, saved addresses, enquiries and support requests.\n\n'
          'This action cannot be undone.',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.jost())),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.deleteAccount();
            },
            child: Text('Delete', style: GoogleFonts.jost(color: kDanger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'C';
  }
}

class _TileData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _TileData(this.icon, this.label, this.onTap);
}