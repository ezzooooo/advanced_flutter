// ========================================
// Remote Config 상수 정의
// ========================================
//
// Firebase Remote Config에서 사용할 키 값들을 정의합니다.
// Feature Flags를 통해 앱의 기능을 원격으로 제어할 수 있습니다.

/// Remote Config 키 상수
class RemoteConfigKeys {
  RemoteConfigKeys._();

  /// 임시점검 모드 활성화 여부
  /// - true: 임시점검 화면 표시
  /// - false: 정상 운영
  static const String maintenanceMode = 'maintenance_mode';

  /// 임시점검 메시지
  static const String maintenanceMessage = 'maintenance_message';

  /// 임시점검 종료 예정 시간
  static const String maintenanceEndTime = 'maintenance_end_time';

  /// 새로운 탭 기능 활성화 여부
  /// - true: 새로운 탭 표시
  /// - false: 새로운 탭 숨김
  static const String newTabEnabled = 'new_tab_enabled';

  /// 새로운 탭 제목
  static const String newTabTitle = 'new_tab_title';
}

/// Remote Config 기본값
class RemoteConfigDefaults {
  RemoteConfigDefaults._();

  /// 모든 Remote Config 키의 기본값
  static const Map<String, dynamic> defaults = {
    // 임시점검 관련 기본값
    RemoteConfigKeys.maintenanceMode: false,
    RemoteConfigKeys.maintenanceMessage: '서비스 점검 중입니다.\n잠시 후 다시 시도해 주세요.',
    RemoteConfigKeys.maintenanceEndTime: '',

    // 새로운 탭 관련 기본값
    RemoteConfigKeys.newTabEnabled: false,
    RemoteConfigKeys.newTabTitle: '새로운 기능',
  };
}
