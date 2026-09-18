import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/module/view/products/product_detail_screen.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Entry point for messages that arrive while the app is terminated or
/// backgrounded. Must be a top-level function and must not touch app state —
/// it runs in a separate isolate with no access to our controllers.
///
/// On both platforms the OS draws the tray notification itself from the
/// `notification` block of the payload, so there is nothing to do here beyond
/// keeping the isolate alive long enough for the handoff.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Intentionally empty. Any Firebase.initializeApp() call belongs in main().
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String _androidChannelId = 'esd_customer_default';
  static const String _androidChannelName = 'General Notifications';
  static const String _androidChannelDescription =
      'Order updates, support replies and offers from Electronics Sales Delhi.';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final _box = GetStorage();

  bool _initialised = false;
  String? _token;

  String? get token => _token;

  /// Wires up permissions, the local-notification channel and every FCM
  /// listener. Safe to call more than once.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await _requestPermission();
    await _initLocalNotifications();

    // iOS only: without this, a message arriving in the foreground is silent.
    // Android foreground messages are drawn by _showLocalNotification below.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _loadToken();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Cold start from a notification tap.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Give the first route time to mount before navigating.
      Future.delayed(const Duration(milliseconds: 800), () => _handleTap(initial));
    }
  }

  Future<void> _requestPermission() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('[push] permission request failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      // FirebaseMessaging.requestPermission already asked; don't ask twice.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _routeFromData(_decodePayload(payload));
        }
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // --- token handling ------------------------------------------------------

  Future<void> _loadToken() async {
    try {
      if (Platform.isIOS) {
        // On iOS the FCM token is only issued once APNs has handed us a device
        // token. Asking too early returns null, so wait for it.
        final apns = await _waitForApnsToken();
        if (apns == null) {
          debugPrint('[push] no APNs token — check the .p8 key in Firebase');
          return;
        }
      }
      _token = await _messaging.getToken();
      debugPrint('[push] fcm token: $_token');
      await syncToken();
    } catch (e) {
      debugPrint('[push] getToken failed: $e');
    }
  }

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null) return apns;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  Future<void> _onTokenRefresh(String newToken) async {
    _token = newToken;
    await syncToken();
  }

  /// Sends the current token to the backend so it can target this device.
  /// Called after init, on refresh, and again right after login (the backend
  /// needs the bearer token to attach the device to a customer).
  Future<void> syncToken() async {
    final fcm = _token;
    if (fcm == null || fcm.isEmpty) return;

    final loggedIn = (_box.read(ApiConstants.storageToken) ?? '').toString().isNotEmpty;
    if (!loggedIn) return;

    try {
      await ApiService.instance.post(ApiConstants.registerDevice, data: {
        'token': fcm,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
      await _box.write(ApiConstants.storageFcmToken, fcm);
    } catch (e) {
      // Never let push registration break the login flow.
      debugPrint('[push] token sync failed: $e');
    }
  }

  /// Detaches this device from the customer so they stop receiving their
  /// notifications after logout or account deletion.
  Future<void> unregisterToken() async {
    final fcm = _token ?? _box.read(ApiConstants.storageFcmToken)?.toString();
    if (fcm == null || fcm.isEmpty) return;
    try {
      await ApiService.instance.post(ApiConstants.unregisterDevice, data: {'token': fcm});
    } catch (e) {
      debugPrint('[push] token unregister failed: $e');
    }
    await _box.remove(ApiConstants.storageFcmToken);
  }

  // --- foreground display --------------------------------------------------

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imageUrl = _imageUrlOf(message);
    final payload = _encodePayload(message.data);

    AndroidNotificationDetails androidDetails;
    if (Platform.isAndroid && imageUrl != null) {
      final path = await _downloadToFile(imageUrl, 'push_image');
      if (path != null) {
        final picture = FilePathAndroidBitmap(path);
        androidDetails = AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: picture,
          styleInformation: BigPictureStyleInformation(
            picture,
            hideExpandedLargeIcon: true,
            contentTitle: notification.title,
            summaryText: notification.body,
          ),
        );
      } else {
        androidDetails = _plainAndroidDetails();
      }
    } else {
      androidDetails = _plainAndroidDetails();
    }

    // iOS rich images need a Notification Service Extension, which this build
    // does not ship — foreground messages show title and body only.
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: darwinDetails),
      payload: payload,
    );
  }

  AndroidNotificationDetails _plainAndroidDetails() => const AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

  String? _imageUrlOf(RemoteMessage message) {
    final fromNotification = Platform.isAndroid
        ? message.notification?.android?.imageUrl
        : message.notification?.apple?.imageUrl;
    if (fromNotification != null && fromNotification.isNotEmpty) return fromNotification;

    // Fallback for data-only messages sent by the CI4 backend.
    final fromData = message.data['image'] ?? message.data['image_url'];
    final url = fromData?.toString() ?? '';
    return url.isEmpty ? null : url;
  }

  Future<String?> _downloadToFile(String url, String name) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) return null;
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name.jpg');
      await file.writeAsBytes(Uint8List.fromList(res.bodyBytes));
      return file.path;
    } catch (e) {
      debugPrint('[push] image download failed: $e');
      return null;
    }
  }

  // --- tap routing ---------------------------------------------------------

  void _handleTap(RemoteMessage message) => _routeFromData(message.data);

  /// Opens the product a notification points at. The CI4 backend sends
  /// `{"type": "product", "product_id": "42"}` in the data block; anything
  /// else just opens the app on whatever screen it was already showing.
  void _routeFromData(Map<String, dynamic> data) {
    final rawId = data['product_id'] ?? data['productId'];
    final productId = int.tryParse('${rawId ?? ''}');
    if (productId == null || productId <= 0) return;

    Get.to(() => ProductDetailScreen(productId: productId));
  }

  // Payload travels through flutter_local_notifications as a plain string,
  // so flatten the data map on the way out and rebuild it on the way back.
  String _encodePayload(Map<String, dynamic> data) =>
      data.entries.map((e) => '${e.key}=${e.value}').join('&');

  Map<String, dynamic> _decodePayload(String payload) {
    final out = <String, dynamic>{};
    for (final pair in payload.split('&')) {
      final i = pair.indexOf('=');
      if (i > 0) out[pair.substring(0, i)] = pair.substring(i + 1);
    }
    return out;
  }
}
