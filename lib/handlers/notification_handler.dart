import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

/// ========================================
/// 알림 핸들러
/// ========================================
///
/// FCM 푸시 알림 및 로컬 알림 클릭 시
/// 딥링크 처리를 담당하는 핸들러
///

class NotificationHandler {
  final GoRouter router;

  NotificationHandler({required this.router});

  /// ========================================
  /// 알림 클릭 처리 (백그라운드/종료 상태)
  /// ========================================
  ///
  /// FCM 알림을 클릭하여 앱이 열렸을 때 호출됩니다.
  /// RemoteMessage에서 데이터를 추출하여 적절한 화면으로 라우팅합니다.
  ///
  void handleNotificationClick(RemoteMessage message) {
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
    _navigateToScreen(screen: screen, id: id, extra: extra);
  }

  /// ========================================
  /// 로컬 알림 클릭 처리 (포그라운드)
  /// ========================================
  ///
  /// 포그라운드에서 표시된 로컬 알림을 클릭했을 때 호출됩니다.
  /// payload에서 데이터를 추출하여 적절한 화면으로 라우팅합니다.
  ///
  void handleLocalNotificationClick(Map<String, dynamic> payload) {
    log('🎯 로컬 알림 클릭 처리 시작 (포그라운드)');
    log('   Payload: $payload');

    // payload에서 data 추출
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    final screen = data['screen'];
    final id = data['id'];

    // 딥링크 데이터 구성
    final extra = {
      'title': payload['title'],
      'body': payload['body'],
      ...data,
    };

    // 화면별 라우팅
    _navigateToScreen(screen: screen, id: id, extra: extra);
  }

  /// ========================================
  /// 포그라운드 메시지 처리
  /// ========================================
  ///
  /// 앱이 포그라운드 상태일 때 FCM 메시지를 수신했을 때 호출됩니다.
  /// 필요시 UI 업데이트 등 추가 처리를 수행합니다.
  ///
  void handleForegroundMessage(RemoteMessage message) {
    log('📱 포그라운드 메시지 처리');
    log('   제목: ${message.notification?.title}');
    log('   내용: ${message.notification?.body}');
    log('   데이터: ${message.data}');

    // 필요시 UI 업데이트 등 추가 처리
    // 예: 앱 내 배지 업데이트, 스낵바 표시 등
  }

  /// ========================================
  /// 화면별 라우팅 (공통 로직)
  /// ========================================
  void _navigateToScreen({
    required String? screen,
    required String? id,
    required Map<String, dynamic> extra,
  }) {
    switch (screen) {
      case 'detail':
        log('   ➡️ 상세 화면으로 이동: id=$id');
        router.push('/detail?id=$id', extra: extra);
        break;

      case 'promo':
        log('   ➡️ 프로모션 화면으로 이동: id=$id');
        router.push('/promo?id=$id', extra: extra);
        break;

      default:
        // 기본: 상세 화면으로 이동
        log('   ➡️ 기본 상세 화면으로 이동');
        router.push('/detail', extra: extra);
    }
  }
}

