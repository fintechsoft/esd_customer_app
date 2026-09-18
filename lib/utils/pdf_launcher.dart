import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Downloads a PDF from [url] and opens the native share/open sheet
/// (lets the user view, download, print, or share it).
/// Handles null, empty, and failed-download cases gracefully.
Future<void> openPdf(String url, {String label = 'document'}) async {
  if (url.trim().isEmpty) {
    Get.snackbar(
      'Not Available',
      'No $label link found for this order.',
      backgroundColor: const Color(0xFFFAEEDA),
      colorText: const Color(0xFF854F0B),
    );
    return;
  }

  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    Get.snackbar(
      'Invalid Link',
      'The $label link looks invalid.',
      backgroundColor: const Color(0xFFFCEBEB),
      colorText: const Color(0xFFA32D2D),
    );
    return;
  }

  // Show a lightweight loading indicator while downloading
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      Get.back(); // close loading dialog
      Get.snackbar(
        'Error',
        'Could not download $label.',
        backgroundColor: const Color(0xFFFCEBEB),
        colorText: const Color(0xFFA32D2D),
      );
      return;
    }

    // Save to temp directory
    final dir = await getTemporaryDirectory();
    final fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : '$label.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);

    Get.back(); // close loading dialog

    // Open native share sheet — lets user view/print/save/share the PDF
    // sharePositionOrigin anchors the share popover. iPhone ignores it, but
    // without it the sheet throws on any popover-based presentation.
    final ctx = Get.context;
    final size = ctx == null ? const Size(390, 844) : MediaQuery.of(ctx).size;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      text: label,
      sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
    );
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    Get.snackbar(
      'Error',
      'Could not open $label.',
      backgroundColor: const Color(0xFFFCEBEB),
      colorText: const Color(0xFFA32D2D),
    );
  }
}