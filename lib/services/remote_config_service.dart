import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../constants/remote_config_constants.dart';

/// ========================================
/// Remote Config 서비스
/// ========================================
///
/// Firebase Remote Config를 사용하여 Feature Flags를 관리합니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 동일한 인스턴스를 사용합니다.
///

class RemoteConfigService {
  // 싱글톤 인스턴스
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  // Firebase Remote Config 인스턴스
  late final FirebaseRemoteConfig _remoteConfig;

  // 초기화 완료 여부
  bool _isInitialized = false;

  /// Remote Config 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _remoteConfig = FirebaseRemoteConfig.instance;

    // Remote Config 설정
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        // 개발 중에는 짧은 간격으로 설정 (1분)
        // 프로덕션에서는 더 긴 간격 권장 (1시간 이상)
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 1)
            : const Duration(hours: 1),
      ),
    );

    // 기본값 설정
    await _remoteConfig.setDefaults(RemoteConfigDefaults.defaults);

    // 서버에서 값 가져오기 및 활성화
    await fetchAndActivate();

    _isInitialized = true;

    debugPrint('[RemoteConfig] 초기화 완료');
    _printCurrentValues();
  }

  /// 서버에서 최신 설정 가져오기 및 활성화
  Future<bool> fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      debugPrint('[RemoteConfig] fetchAndActivate: updated=$updated');
      _printCurrentValues();
      return updated;
    } catch (e) {
      debugPrint('[RemoteConfig] fetchAndActivate 실패: $e');
      return false;
    }
  }

  /// 실시간 Remote Config 리스너 설정
  /// Remote Config 값이 변경되면 콜백이 호출됩니다.
  void addOnConfigUpdatedListener(Function(Set<String>) onUpdate) {
    _remoteConfig.onConfigUpdated.listen((event) async {
      debugPrint('[RemoteConfig] 설정 변경 감지: ${event.updatedKeys}');

      await _remoteConfig.activate();
      onUpdate(event.updatedKeys);
      _printCurrentValues();
    });
  }

  // ========================================
  // Feature Flags 접근자
  // ========================================

  /// 임시점검 모드 활성화 여부
  bool get isMaintenanceMode {
    return _remoteConfig.getBool(
      'maintenance_mode',
    ); // 이게 항상 서버쪽에서 데이터를 가져오는 건 X ->
  }

  /// 임시점검 메시지
  String get maintenanceMessage {
    return FirebaseRemoteConfig.instance.getString('maintenance_message');
  }

  /// 임시점검 종료 예정 시간
  String get maintenanceEndTime {
    return _remoteConfig.getString('maintenance_end_time');
  }

  /// 새로운 탭 기능 활성화 여부
  bool get isNewTabEnabled {
    return _remoteConfig.getBool('new_tab_enabled');
  }

  /// 새로운 탭 제목
  String get newTabTitle {
    return _remoteConfig.getString('new_tab_title');
  }

  // ========================================
  // 유틸리티 메서드
  // ========================================

  /// 특정 키의 값 소스 확인 (디버깅용)
  ValueSource getValueSource(String key) {
    return _remoteConfig.getValue(key).source;
  }

  /// 모든 Feature Flags 상태를 Map으로 반환
  Map<String, dynamic> getAllFeatureFlags() {
    return {
      'maintenanceMode': isMaintenanceMode,
      'maintenanceMessage': maintenanceMessage,
      'maintenanceEndTime': maintenanceEndTime,
      'newTabEnabled': isNewTabEnabled,
      'newTabTitle': newTabTitle,
    };
  }

  /// 현재 값들 출력 (디버깅용)
  void _printCurrentValues() {
    debugPrint('[RemoteConfig] 현재 값:');
    debugPrint(
      '  - maintenanceMode: $isMaintenanceMode (source: ${getValueSource(RemoteConfigKeys.maintenanceMode)})',
    );
    debugPrint('  - maintenanceMessage: $maintenanceMessage');
    debugPrint('  - maintenanceEndTime: $maintenanceEndTime');
    debugPrint(
      '  - newTabEnabled: $isNewTabEnabled (source: ${getValueSource(RemoteConfigKeys.newTabEnabled)})',
    );
    debugPrint('  - newTabTitle: $newTabTitle');
  }
}
