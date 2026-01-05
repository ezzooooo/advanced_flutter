import 'package:flutter/material.dart';

/// ========================================
/// 테스트 가이드 섹션 위젯
/// ========================================
///
/// FCM 푸시 알림 테스트 방법을 안내합니다.
///

class TestGuideSection extends StatelessWidget {
  const TestGuideSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '테스트 가이드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._guideItems.map((item) => _buildGuideItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
      ),
    );
  }

  static const List<String> _guideItems = [
    '1. Firebase 콘솔 > Cloud Messaging으로 이동',
    '2. "첫 번째 캠페인 만들기" 또는 "새 캠페인" 클릭',
    '3. "Firebase 알림 메시지" 선택',
    '4. 알림 제목과 텍스트 입력',
    '5. 타겟 설정에서:',
    '   • 특정 기기: FCM 토큰 사용',
    '   • 토픽 구독자: 토픽명 입력 (예: news)',
    '6. 추가 옵션에서 커스텀 데이터 추가 (딥링크용):',
    '   • Key: screen, Value: detail 또는 promo',
    '   • Key: id, Value: 123',
  ];
}

