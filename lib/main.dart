import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'handlers/notification_handler.dart';
import 'routes/app_router.dart';
import 'screens/maintenance_screen.dart';
import 'services/fcm_service.dart';
import 'services/remote_config_service.dart';
import 'theme/app_theme.dart';

/// ========================================
/// FCM 푸시 알림 & Remote Config 실습 앱
/// ========================================
///
/// 이 앱은 Firebase Cloud Messaging(FCM)과 Remote Config를 사용하여
/// 푸시 알림과 Feature Flags를 구현하는 방법을 학습합니다.
///
/// 주요 학습 내용:
/// 1. FCM 초기화 및 권한 요청
/// 2. FCM 토큰 관리
/// 3. 포그라운드/백그라운드 메시지 처리
/// 4. 토픽 구독/해제
/// 5. 알림 클릭 시 딥링크 처리
/// 6. Remote Config를 통한 Feature Flags 관리
/// 7. 임시점검 모드 (Maintenance Mode)
/// 8. 새로운 탭 기능 (점진적 출시)
//

void main() async {
  // Flutter 바인딩 초기화 (Firebase 초기화 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (flutterfire configure로 생성된 옵션 사용)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Remote Config 초기화
  await RemoteConfigService().initialize();

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
  final RemoteConfigService _remoteConfig = RemoteConfigService();
  late final AppRouter _appRouter;
  late final NotificationHandler _notificationHandler;

  // 임시점검 모드 상태
  bool _isMaintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    _notificationHandler = NotificationHandler(router: _appRouter.router);
    _initializeFcm();
    _initializeRemoteConfig();
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

  /// ========================================
  /// Remote Config 초기화 및 리스너 설정
  /// ========================================
  void _initializeRemoteConfig() {
    // 초기 임시점검 상태 확인
    _checkMaintenanceMode();

    // Remote Config 실시간 업데이트 리스너 설정
    _remoteConfig.addOnConfigUpdatedListener((updatedKeys) {
      debugPrint('[Main] Remote Config 업데이트 감지: $updatedKeys');
      _checkMaintenanceMode();
    });
  }

  /// 임시점검 모드 확인 및 상태 업데이트
  void _checkMaintenanceMode() {
    if (mounted) {
      setState(() {
        _isMaintenanceMode = _remoteConfig.isMaintenanceMode;
      });
    }
  }

  /// 임시점검 모드에서 다시 시도
  Future<void> _retryFromMaintenance() async {
    await _remoteConfig.fetchAndActivate();
    _checkMaintenanceMode();
  }

  @override
  Widget build(BuildContext context) {
    // // 임시점검 모드일 경우 점검 화면 표시
    // if (_isMaintenanceMode) {
    //   return MaterialApp(
    //     title: 'FCM & Remote Config',
    //     debugShowCheckedModeBanner: false,
    //     theme: AppTheme.light,
    //     home: MaintenanceScreen(
    //       message: _remoteConfig.maintenanceMessage,
    //       endTime: _remoteConfig.maintenanceEndTime,
    //       onRetry: _retryFromMaintenance,
    //     ),
    //   );
    // }

    // 정상 운영 시 메인 앱 표시
    return MaterialApp.router(
      title: 'FCM & Remote Config',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _appRouter.router,
    );
  }
}
