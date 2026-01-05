import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/notification_constants.dart';

/// ========================================
/// 로컬 알림 서비스
/// ========================================
///
/// 포그라운드에서 알림을 표시하고 클릭 이벤트를 처리합니다.
///

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 로컬 알림 클릭 시 호출될 콜백
  Function(Map<String, dynamic>)? onNotificationTapped;

  /// 로컬 알림 초기화
  Future<void> initialize() async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      NotificationIcon.defaultIcon,
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // FCM에서 이미 요청했으므로 false
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// 알림 채널 생성 (Android 8.0+)
  Future<void> createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      NotificationChannel.id,
      NotificationChannel.name,
      description: NotificationChannel.description,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    log('📢 알림 채널 생성 완료: ${channel.id}');
  }

  /// 로컬 알림 표시 (포그라운드용)
  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      NotificationChannel.id,
      NotificationChannel.name,
      channelDescription: NotificationChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: NotificationIcon.defaultIcon,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 알림 ID 생성 (messageId의 해시값 사용)
    final notificationId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 클릭 시 전달할 데이터를 JSON으로 저장
    final payload = jsonEncode({
      'title': notification.title,
      'body': notification.body,
      'data': message.data,
    });

    await _localNotifications.show(
      notificationId,
      notification.title,
      notification.body,
      details,
      payload: payload,
    );
  }

  /// 로컬 알림 클릭 처리
  void _onNotificationTapped(NotificationResponse response) {
    log('🔔 로컬 알림 클릭! (포그라운드)');
    log('   Payload: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      // JSON 파싱
      final Map<String, dynamic> payloadData = jsonDecode(response.payload!);
      log('   파싱된 데이터: $payloadData');

      // 콜백 호출
      onNotificationTapped?.call(payloadData);
    } catch (e) {
      log('❌ Payload 파싱 실패: $e');
    }
  }

  /// 알림 뱃지 초기화 (iOS)
  Future<void> clearBadge() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(badge: true);
  }
}

