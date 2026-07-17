import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../../core/network/token_manager.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await _firebaseMessaging.getToken();
      
      if (fcmToken != null) {
        await _sendFcmTokenToBackend(fcmToken);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _sendFcmTokenToBackend(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message: ${message.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification opened: ${message.data}');
      });
    }
  }

  Future<void> _sendFcmTokenToBackend(String token) async {
    try {
      final tokenManager = TokenManager();
      final authToken = await tokenManager.getToken();
      if (authToken == null) return;

      final dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ));

      await dio.post('/profile/fcm-token', data: {'fcm_token': token});
    } catch (e) {
      print('Failed to send FCM token: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}
