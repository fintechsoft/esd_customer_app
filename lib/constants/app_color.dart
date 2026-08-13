import 'package:flutter/material.dart';

/// Brand palette — sampled directly from the ESD logo (deep maroon/crimson)
/// plus a warm gold accent for CTAs/highlights. Kept as top-level `k`-prefixed
/// constants to match the naming convention used in the employee (ESD ERP) app.

const Color kPrimary = Color(0xFFA81A3D); // logo maroon
const Color kPrimaryDark = Color(0xFF7A1230); // for gradients / pressed states
const Color kPrimaryLight = Color(0xFFD65C7C); // tints, soft badges
const Color kPrimaryTint = Color(0xFFFBEAEE); // very light maroon wash (icon bg chips)

const Color kAccent = Color(0xFFF2A93B); // warm gold — CTAs, ratings, highlights
const Color kAccentTint = Color(0xFFFDF1DD);

const Color kAppBgColor = Color(0xFFFAF6F7); // warm off-white app background
const Color kCardBg = Colors.white;
const Color kBorder = Color(0xFFF0E2E5);

const Color kDark = Color(0xFF241016); // near-black, maroon-tinted text
const Color kLightText = Color(0xFF8C6570); // muted mauve-grey secondary text
const Color kGreyIcon = Color(0xFF9AA0A6);

const Color kSuccess = Color(0xFF1E8E3E);
const Color kSuccessTint = Color(0xFFE7F5EB);
const Color kWarning = Color(0xFFB4770A);
const Color kWarningTint = Color(0xFFFCF0DD);
const Color kDanger = Color(0xFFD93025);
const Color kDangerTint = Color(0xFFFCEAE9);

Map<String, Color> statusColors(String status) {
  switch (status.toLowerCase()) {
    case 'done':
    case 'resolved':
    case 'closed':
      return {'bg': kSuccessTint, 'text': kSuccess};
    case 'pending':
    case 'open':
      return {'bg': kWarningTint, 'text': kWarning};
    case 'in_progress':
      return {'bg': kPrimaryTint, 'text': kPrimary};
    default:
      return {'bg': const Color(0xFFF1F1F3), 'text': kLightText};
  }
}
