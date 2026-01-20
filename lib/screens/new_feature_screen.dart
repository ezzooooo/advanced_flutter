import 'package:flutter/material.dart';

/// ========================================
/// 새로운 기능 탭 화면
/// ========================================
///
/// Remote Config의 new_tab_enabled가 true일 때 표시되는 탭입니다.
/// Feature Flag로 새로운 기능의 점진적 출시(Gradual Rollout)를 테스트합니다.
///

class NewFeatureScreen extends StatelessWidget {
  final String title;

  const NewFeatureScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade400,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🎉 새로운 기능이 출시되었습니다!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remote Config Feature Flag를 통해\n이 탭이 활성화되었습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feature Flag 설명 섹션
            _buildInfoSection(
              icon: Icons.flag_rounded,
              title: 'Feature Flags란?',
              content: 'Feature Flags(기능 플래그)는 코드 배포 없이 특정 기능을 '
                  '켜거나 끌 수 있게 해주는 기술입니다. '
                  'A/B 테스트, 점진적 출시, 빠른 롤백 등에 활용됩니다.',
            ),
            const SizedBox(height: 16),

            _buildInfoSection(
              icon: Icons.cloud_sync_rounded,
              title: 'Remote Config 활용',
              content: 'Firebase Remote Config를 사용하면 앱 업데이트 없이 '
                  '서버에서 설정값을 변경할 수 있습니다. '
                  '이 탭도 Remote Config의 new_tab_enabled 값으로 제어됩니다.',
            ),
            const SizedBox(height: 16),

            _buildInfoSection(
              icon: Icons.science_rounded,
              title: '점진적 출시 (Gradual Rollout)',
              content: '새로운 기능을 전체 사용자에게 한 번에 출시하는 대신, '
                  '일부 사용자에게만 먼저 출시하여 테스트할 수 있습니다. '
                  '문제가 발생하면 즉시 롤백이 가능합니다.',
            ),
            const SizedBox(height: 24),

            // 샘플 기능 카드들
            const Text(
              '✨ 새로운 기능 미리보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.dark_mode,
              title: '다크 모드',
              description: '눈의 피로를 줄여주는 다크 모드',
              isComingSoon: true,
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.notifications_active,
              title: '스마트 알림',
              description: 'AI 기반 맞춤형 알림 설정',
              isComingSoon: true,
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.analytics,
              title: '통계 대시보드',
              description: '상세한 사용 통계 확인',
              isComingSoon: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    bool isComingSoon = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.purple.shade700,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: isComingSoon
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
