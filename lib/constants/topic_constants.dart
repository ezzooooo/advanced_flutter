// ========================================
// 토픽 관련 상수
// ========================================
//
// FCM 토픽 구독에 사용되는 상수 정의
//

/// 토픽 정보를 담는 클래스
class TopicInfo {
  final String id;
  final String name;
  final String description;

  const TopicInfo({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// 사용 가능한 토픽 목록
class Topics {
  /// 뉴스 알림 토픽
  static const TopicInfo news = TopicInfo(
    id: 'news',
    name: '뉴스 알림',
    description: '최신 뉴스와 소식을 받아보세요.',
  );

  /// 프로모션 알림 토픽
  static const TopicInfo promo = TopicInfo(
    id: 'promo',
    name: '프로모션 알림',
    description: '할인 및 이벤트 정보를 받아보세요.',
  );

  /// 업데이트 알림 토픽
  static const TopicInfo updates = TopicInfo(
    id: 'updates',
    name: '업데이트 알림',
    description: '앱 업데이트 및 새로운 기능 안내',
  );

  /// 모든 토픽 목록
  static const List<TopicInfo> all = [news, promo, updates];
}
