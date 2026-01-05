import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/notification_detail_screen.dart';
import '../screens/promo_screen.dart';

/// ========================================
/// 앱 라우터 설정
/// ========================================
///
/// go_router를 사용한 라우팅 설정
/// 딥링크 URL 스킴: advancedflutter://app/[path]
///

class AppRouter {
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouter({GlobalKey<NavigatorState>? navigatorKey})
    : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  /// GoRouter 인스턴스 생성
  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true, // 디버그 로그 활성화
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  /// 라우트 정의
  static final List<RouteBase> _routes = [
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
  ];

  /// 에러 페이지 빌더
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '페이지를 찾을 수 없습니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${state.uri}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
