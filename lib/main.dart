import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'screens/home_screen.dart';
import 'screens/notification_detail_screen.dart';
import 'screens/promo_screen.dart';

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
  late final GoRouter _router;

  // 딥링크 처리를 위한 키
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeRouter();
    _initializeFcm();
  }

  /// ========================================
  /// 라우터 초기화
  /// ========================================
  void _initializeRouter() {
    _router = GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true, // 디버그 로그 활성화

      routes: [
        // 홈 화면
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // 알림 상세 화면 (딥링크 대상)
        // URL: advancedflutter://app/detail?id=123
        GoRoute(
          path: '/detail',
          name: 'detail',
          builder: (context, state) {
            // 쿼리 파라미터에서 데이터 추출
            final id = state.uri.queryParameters['id'];
            final title = state.uri.queryParameters['title'];
            final body = state.uri.queryParameters['body'];

            // extra로 전달된 데이터가 있으면 사용
            final extra = state.extra as Map<String, dynamic>?;

            return NotificationDetailScreen(
              notificationId: id,
              title: title ?? extra?['title'],
              body: body ?? extra?['body'],
              data: extra,
            );
          },
        ),

        // 프로모션 화면 (딥링크 대상)
        // URL: advancedflutter://app/promo?id=PROMO123
        GoRoute(
          path: '/promo',
          name: 'promo',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            final title = state.uri.queryParameters['title'];
            final extra = state.extra as Map<String, dynamic>?;

            return PromoScreen(
              promoId: id,
              title: title ?? extra?['title'],
              data: extra,
            );
          },
        ),
      ],

      // 에러 페이지
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(child: Text('페이지를 찾을 수 없습니다.\n${state.uri}')),
      ),
    );
  }

  /// ========================================
  /// FCM 초기화
  /// ========================================
  Future<void> _initializeFcm() async {
    // FCM 서비스 초기화
    await _fcmService.initialize();

    // 알림 클릭 시 딥링크 처리 콜백 설정 (백그라운드/종료 상태)
    _fcmService.onMessageOpenedApp = _handleNotificationClick;

    // 포그라운드 메시지 수신 콜백 설정
    _fcmService.onMessage = _handleForegroundMessage;

    // 로컬 알림 클릭 시 딥링크 처리 콜백 설정 (포그라운드)
    _fcmService.onLocalNotificationTapped = _handleLocalNotificationClick;
  }

  /// ========================================
  /// 알림 클릭 처리 (딥링크)
  /// ========================================
  void _handleNotificationClick(RemoteMessage message) {
    log('🎯 알림 클릭 처리 시작');
    log('   데이터: ${message.data}');

    // 데이터에서 화면 정보 추출
    final screen = message.data['screen'];
    final id = message.data['id'];

    // 딥링크 데이터 구성
    final extra = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      ...message.data,
    };

    // 화면별 라우팅
    switch (screen) {
      case 'detail':
        log('   ➡️ 상세 화면으로 이동: id=$id');
        _router.push('/detail?id=$id', extra: extra);
        break;

      case 'promo':
        log('   ➡️ 프로모션 화면으로 이동: id=$id');
        _router.push('/promo?id=$id', extra: extra);
        break;

      default:
        // 기본: 상세 화면으로 이동
        log('   ➡️ 기본 상세 화면으로 이동');
        _router.push('/detail', extra: extra);
    }
  }

  /// ========================================
  /// 로컬 알림 클릭 처리 (포그라운드)
  /// ========================================
  void _handleLocalNotificationClick(Map<String, dynamic> payload) {
    log('🎯 로컬 알림 클릭 처리 시작 (포그라운드)');
    log('   Payload: $payload');

    // payload에서 data 추출
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    final screen = data['screen'];
    final id = data['id'];

    // 딥링크 데이터 구성
    final extra = {'title': payload['title'], 'body': payload['body'], ...data};

    // 화면별 라우팅
    switch (screen) {
      case 'detail':
        log('   ➡️ 상세 화면으로 이동: id=$id');
        _router.push('/detail?id=$id', extra: extra);
        break;

      case 'promo':
        log('   ➡️ 프로모션 화면으로 이동: id=$id');
        _router.push('/promo?id=$id', extra: extra);
        break;

      default:
        // 기본: 상세 화면으로 이동
        log('   ➡️ 기본 상세 화면으로 이동');
        _router.push('/detail', extra: extra);
    }
  }

  /// ========================================
  /// 포그라운드 메시지 처리
  /// ========================================
  void _handleForegroundMessage(RemoteMessage message) {
    log('📱 포그라운드 메시지 처리');
    // 필요시 UI 업데이트 등 추가 처리
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FCM 푸시 알림',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
