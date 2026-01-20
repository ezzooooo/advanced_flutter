import 'package:flutter/material.dart';

import '../../../services/remote_config_service.dart';

/// ========================================
/// Feature Flags 상태 섹션
/// ========================================
///
/// Remote Config의 Feature Flags 상태를 표시하고
/// 수동으로 새로고침할 수 있는 위젯입니다.
///

class FeatureFlagsSection extends StatelessWidget {
  final VoidCallback onRefresh;

  const FeatureFlagsSection({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final remoteConfig = RemoteConfigService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🚩 Feature Flags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('새로고침'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 설명 카드
        Card(
          color: Colors.blue.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Firebase Console에서 Remote Config 값을 변경한 후 새로고침을 누르세요.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Feature Flags 목록
        _buildFlagItem(
          context,
          icon: Icons.construction,
          title: '임시점검 모드',
          key: 'maintenance_mode',
          value: remoteConfig.isMaintenanceMode,
          description: remoteConfig.isMaintenanceMode
              ? '점검 중 - ${remoteConfig.maintenanceMessage}'
              : '정상 운영 중',
        ),
        const SizedBox(height: 12),

        _buildFlagItem(
          context,
          icon: Icons.tab,
          title: '새로운 탭',
          key: 'new_tab_enabled',
          value: remoteConfig.isNewTabEnabled,
          description: remoteConfig.isNewTabEnabled
              ? '활성화됨 - "${remoteConfig.newTabTitle}"'
              : '비활성화됨',
        ),
        const SizedBox(height: 16),

        // Firebase Console 안내
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Remote Config 설정 방법',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStep('1', 'Firebase Console 접속'),
                _buildStep('2', 'Remote Config 메뉴 선택'),
                _buildStep('3', '파라미터 추가/수정'),
                const SizedBox(height: 8),
                _buildConfigExample(
                  'maintenance_mode',
                  'Boolean',
                  'true/false',
                ),
                _buildConfigExample('maintenance_message', 'String', '점검 메시지'),
                _buildConfigExample(
                  'maintenance_end_time',
                  'String',
                  '예: 2024-01-15 18:00',
                ),
                _buildConfigExample('new_tab_enabled', 'Boolean', 'true/false'),
                _buildConfigExample('new_tab_title', 'String', '탭 제목'),
                const SizedBox(height: 8),
                _buildStep('4', '변경사항 게시 (Publish)'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlagItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String key,
    required bool value,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: value ? Colors.green.shade700 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: value
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          value ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: value
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: $key',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigExample(String key, String type, String example) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($type)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              example,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
