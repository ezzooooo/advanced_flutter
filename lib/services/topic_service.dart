import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

/// ========================================
/// 토픽 구독 서비스
/// ========================================
///
/// FCM 토픽 구독/해제를 관리합니다.
///

class TopicService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 토픽 구독
  ///
  /// 토픽(Topic)은 특정 주제에 관심 있는 사용자들에게
  /// 메시지를 보내는 방법입니다.
  ///
  /// 예시:
  /// - 'news': 뉴스 알림 구독자
  /// - 'promo': 프로모션/이벤트 알림 구독자
  /// - 'sports': 스포츠 소식 구독자
  ///
  Future<void> subscribe(String topic) async {
    await _messaging.subscribeToTopic(topic);
    log('✅ 토픽 구독 완료: $topic');
  }

  /// 토픽 구독 해제
  Future<void> unsubscribe(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    log('❌ 토픽 구독 해제: $topic');
  }
}
