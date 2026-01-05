import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';
import 'topic_service.dart';

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

  // 분리된 서비스들
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  final TopicService _topicService = TopicService();

  // 알림 클릭 시 호출될 콜백 (백그라운드/종료 상태)
  Function(RemoteMessage)? onMessageOpenedApp;

  // 알림 메시지 수신 시 호출될 콜백
  Function(RemoteMessage)? onMessage;

  // 로컬 알림 클릭 시 호출될 콜백 (포그라운드)
  // Map에는 title, body, data가 포함됩니다.
  Function(Map<String, dynamic>)? get onLocalNotificationTapped =>
      _localNotificationService.onNotificationTapped;
  set onLocalNotificationTapped(Function(Map<String, dynamic>)? callback) {
    _localNotificationService.onNotificationTapped = callback;
  }

  /// ========================================
  /// 1. FCM 초기화
  /// ========================================
  Future<void> initialize() async {
    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 알림 권한 요청
    await _requestPermission();

    // 로컬 알림 초기화
    await _localNotificationService.initialize();

    // 알림 채널 생성 (Android)
    await _localNotificationService.createNotificationChannel();

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
  /// 3. 메시지 리스너 설정
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
      _localNotificationService.showNotification(message);
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
  /// 4. 앱 종료 상태에서 알림 클릭 처리
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
  /// 5. FCM 토큰 가져오기
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
  /// 6. 토픽 구독
  /// ========================================
  Future<void> subscribeToTopic(String topic) async {
    await _topicService.subscribe(topic);
  }

  /// ========================================
  /// 7. 토픽 구독 해제
  /// ========================================
  Future<void> unsubscribeFromTopic(String topic) async {
    await _topicService.unsubscribe(topic);
  }

  /// ========================================
  /// 8. 알림 뱃지 초기화 (iOS)
  /// ========================================
  Future<void> clearBadge() async {
    await _localNotificationService.clearBadge();
  }
}
