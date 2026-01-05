// ========================================
// 알림 관련 상수
// ========================================
//
// FCM 및 로컬 알림에 사용되는 상수 정의

/// 알림 채널 설정 (Android)
class NotificationChannel {
  /// 채널 ID (AndroidManifest.xml과 일치해야 함)
  static const String id = 'my_app_channel';

  /// 채널 이름 (설정에서 사용자에게 표시됨)
  static const String name = '중요 알림';

  /// 채널 설명
  static const String description = '이 채널은 중요한 알림에 사용됩니다.';
}

/// 알림 아이콘 설정
class NotificationIcon {
  /// 기본 알림 아이콘
  static const String defaultIcon = '@mipmap/ic_launcher';
}
