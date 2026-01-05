import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'handlers/notification_handler.dart';
import 'routes/app_router.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';

/// ========================================
/// FCM 푸시 알림 실습 앱
/// ========================================
///
/// 이 앱은 Firebase Cloud Messaging(FCM)을 사용하여
/// 푸시 알림을 구현하는 방법을 학습합니다.
///
/// 주요 학습 내용:
/// 1. FCM 초기화 및 권한 요청
/// 2. FCM 토큰 관리
/// 3. 포그라운드/백그라운드 메시지 처리
/// 4. 토픽 구독/해제
/// 5. 알림 클릭 시 딥링크 처리
///

void main() async {
  // Flutter 바인딩 초기화 (Firebase 초기화 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (flutterfire configure로 생성된 옵션 사용)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 앱 실행
  runApp(const MyApp());
}

/// 앱의 루트 위젯
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FcmService _fcmService = FcmService();
  late final AppRouter _appRouter;
  late final NotificationHandler _notificationHandler;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    _notificationHandler = NotificationHandler(router: _appRouter.router);
    _initializeFcm();
  }

  /// ========================================
  /// FCM 초기화
  /// ========================================
  Future<void> _initializeFcm() async {
    // FCM 서비스 초기화
    await _fcmService.initialize();

    // 알림 클릭 시 딥링크 처리 콜백 설정 (백그라운드/종료 상태)
    _fcmService.onMessageOpenedApp =
        _notificationHandler.handleNotificationClick;

    // 포그라운드 메시지 수신 콜백 설정
    _fcmService.onMessage = _notificationHandler.handleForegroundMessage;

    // 로컬 알림 클릭 시 딥링크 처리 콜백 설정 (포그라운드)
    _fcmService.onLocalNotificationTapped =
        _notificationHandler.handleLocalNotificationClick;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FCM 푸시 알림',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _appRouter.router,
    );
  }
}
