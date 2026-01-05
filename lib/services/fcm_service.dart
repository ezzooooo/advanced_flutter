import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ========================================
/// FCM 서비스 클래스
/// ========================================
///
/// 이 클래스는 Firebase Cloud Messaging(FCM)을 관리합니다.
///
/// 주요 기능:
/// 1. FCM 초기화 및 권한 요청
/// 2. FCM 토큰 관리
/// 3. 포그라운드/백그라운드 메시지 핸들링
/// 4. 로컬 알림 표시 (포그라운드에서)
/// 5. 토픽 구독/해제
/// 6. 알림 클릭 시 딥링크 처리
///

/// 백그라운드 메시지 핸들러 (Top-level function이어야 함)
///
/// [중요] 이 함수는 반드시 main.dart나 별도 파일의 최상위에 선언해야 합니다.
/// 클래스 내부나 다른 함수 안에 선언하면 동작하지 않습니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 Firebase를 사용하려면 초기화가 필요합니다
  await Firebase.initializeApp();
  log('📬 백그라운드 메시지 수신: ${message.messageId}');
  log('   제목: ${message.notification?.title}');
  log('   내용: ${message.notification?.body}');
  log('   데이터: ${message.data}');
}

class FcmService {
  // 싱글톤 패턴
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  // Firebase Messaging 인스턴스
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 로컬 알림 플러그인 (포그라운드 알림 표시용)
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 알림 클릭 시 호출될 콜백 (백그라운드/종료 상태)
  Function(RemoteMessage)? onMessageOpenedApp;

  // 알림 메시지 수신 시 호출될 콜백
  Function(RemoteMessage)? onMessage;

  // 로컬 알림 클릭 시 호출될 콜백 (포그라운드)
  // Map에는 title, body, data가 포함됩니다.
  Function(Map<String, dynamic>)? onLocalNotificationTapped;

  /// ========================================
  /// 1. FCM 초기화
  /// ========================================
  Future<void> initialize() async {
    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 알림 권한 요청
    await _requestPermission();

    // 로컬 알림 초기화
    await _initializeLocalNotifications();

    // 알림 채널 생성 (Android)
    await _createNotificationChannel();

    // 포그라운드 메시지 리스너 설정
    _setupMessageListeners();

    // 앱이 종료된 상태에서 알림 클릭으로 실행된 경우 처리
    await _handleInitialMessage();

    // FCM 토큰 가져오기 및 출력
    await getToken();
  }

  /// ========================================
  /// 2. 알림 권한 요청
  /// ========================================
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true, // 알림 표시
      announcement: false, // Siri 음성 읽기 (iOS)
      badge: true, // 앱 아이콘 뱃지
      carPlay: false, // CarPlay 알림
      criticalAlert: false, // 중요 알림 (방해금지 모드에서도 표시)
      provisional: false, // 임시 권한 (iOS 12+, 조용히 알림)
      sound: true, // 알림음
    );

    log('🔔 알림 권한 상태: ${settings.authorizationStatus}');

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        log('   ✅ 알림 권한이 허용되었습니다.');
        break;
      case AuthorizationStatus.denied:
        log('   ❌ 알림 권한이 거부되었습니다.');
        break;
      case AuthorizationStatus.notDetermined:
        log('   ⏳ 알림 권한이 아직 결정되지 않았습니다.');
        break;
      case AuthorizationStatus.provisional:
        log('   📋 임시 알림 권한이 허용되었습니다.');
        break;
    }
  }

  /// ========================================
  /// 3. 로컬 알림 초기화
  /// ========================================
  Future<void> _initializeLocalNotifications() async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
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

  /// ========================================
  /// 4. 알림 채널 생성 (Android 8.0+)
  /// ========================================
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'my_app_channel', // ID (AndroidManifest.xml과 일치해야 함)
      '중요 알림', // 이름 (설정에서 사용자에게 표시됨)
      description: '이 채널은 중요한 알림에 사용됩니다.',
      importance: Importance.high, // 중요도 (헤드업 알림 표시)
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    log('📢 알림 채널 생성 완료: ${channel.id}');
  }

  /// ========================================
  /// 5. 메시지 리스너 설정
  /// ========================================
  void _setupMessageListeners() {
    // 포그라운드에서 메시지 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📱 포그라운드 메시지 수신!');
      log('   제목: ${message.notification?.title}');
      log('   내용: ${message.notification?.body}');
      log('   데이터: ${message.data}');

      // 콜백 호출
      onMessage?.call(message);

      // 포그라운드에서는 알림이 자동으로 표시되지 않으므로
      // 로컬 알림으로 직접 표시합니다.
      _showLocalNotification(message);
    });

    // 백그라운드에서 알림 클릭으로 앱이 열린 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('🚀 알림 클릭으로 앱 열림!');
      log('   데이터: ${message.data}');

      // 콜백 호출 - 딥링크 처리
      onMessageOpenedApp?.call(message);
    });
  }

  /// ========================================
  /// 6. 앱 종료 상태에서 알림 클릭 처리
  /// ========================================
  Future<void> _handleInitialMessage() async {
    // 앱이 완전히 종료된 상태에서 알림을 클릭하여 앱이 실행된 경우
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      log('🎯 앱 시작 시 초기 메시지 감지!');
      log('   데이터: ${initialMessage.data}');

      // 약간의 지연 후 콜백 호출 (앱 초기화 완료 대기)
      Future.delayed(const Duration(milliseconds: 500), () {
        onMessageOpenedApp?.call(initialMessage);
      });
    }
  }

  /// ========================================
  /// 7. 로컬 알림 표시 (포그라운드용)
  /// ========================================
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'my_app_channel',
      '중요 알림',
      channelDescription: '이 채널은 중요한 알림에 사용됩니다.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
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
    final notificationId =
        message.messageId?.hashCode ??
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

  /// ========================================
  /// 8. 로컬 알림 클릭 처리 (포그라운드)
  /// ========================================
  void _onNotificationTapped(NotificationResponse response) {
    log('🔔 로컬 알림 클릭! (포그라운드)');
    log('   Payload: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      // JSON 파싱
      final Map<String, dynamic> payloadData = jsonDecode(response.payload!);
      log('   파싱된 데이터: $payloadData');

      // 콜백 호출
      onLocalNotificationTapped?.call(payloadData);
    } catch (e) {
      log('❌ Payload 파싱 실패: $e');
    }
  }

  /// ========================================
  /// 9. FCM 토큰 가져오기
  /// ========================================
  ///
  /// [주의] iOS 시뮬레이터에서는 APNS 토큰을 받을 수 없어서
  /// FCM 토큰도 가져올 수 없습니다. 실제 기기에서 테스트하세요.
  ///
  Future<String?> getToken() async {
    try {
      // iOS에서는 APNS 토큰이 먼저 설정되어야 FCM 토큰을 받을 수 있습니다.
      if (Platform.isIOS) {
        // APNS 토큰 확인 (시뮬레이터에서는 null)
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          log('⚠️ APNS 토큰을 받을 수 없습니다.');
          log('   iOS 시뮬레이터에서는 푸시 알림이 지원되지 않습니다.');
          log('   실제 iOS 기기에서 테스트해주세요.');
          return null;
        }
        log('🍎 APNS 토큰: $apnsToken');
      }

      String? token = await _messaging.getToken();
      log('🔑 FCM 토큰: $token');

      // 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) {
        log('🔄 FCM 토큰 갱신됨: $newToken');
        // TODO: 서버에 새 토큰 업데이트
      });

      return token;
    } catch (e) {
      log('❌ FCM 토큰 가져오기 실패: $e');
      if (Platform.isIOS) {
        log('   iOS 시뮬레이터에서는 푸시 알림이 지원되지 않습니다.');
        log('   실제 iOS 기기 또는 Android에서 테스트해주세요.');
      }
      return null;
    }
  }

  /// ========================================
  /// 10. 토픽 구독
  /// ========================================
  ///
  /// 토픽(Topic)은 특정 주제에 관심 있는 사용자들에게
  /// 메시지를 보내는 방법입니다.
  ///
  /// 예시:
  /// - 'news': 뉴스 알림 구독자
  /// - 'promo': 프로모션/이벤트 알림 구독자
  /// - 'sports': 스포츠 소식 구독자
  ///
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    log('✅ 토픽 구독 완료: $topic');
  }

  /// ========================================
  /// 11. 토픽 구독 해제
  /// ========================================
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    log('❌ 토픽 구독 해제: $topic');
  }

  /// ========================================
  /// 12. 알림 뱃지 초기화 (iOS)
  /// ========================================
  Future<void> clearBadge() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(badge: true);
  }
}
