import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';

/// ========================================
/// 홈 화면
/// ========================================
///
/// FCM 토큰 표시 및 토픽 구독/해제 기능을 제공합니다.
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FcmService _fcmService = FcmService();

  String? _fcmToken;
  bool _isLoading = true;

  // 토픽 구독 상태 관리
  final Map<String, bool> _topicSubscriptions = {
    'news': false, // 뉴스 알림
    'promo': false, // 프로모션 알림
    'updates': false, // 앱 업데이트 알림
  };

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
  }

  Future<void> _loadFcmToken() async {
    final token = await _fcmService.getToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTopicSubscription(String topic) async {
    final isCurrentlySubscribed = _topicSubscriptions[topic] ?? false;

    if (isCurrentlySubscribed) {
      await _fcmService.unsubscribeFromTopic(topic);
    } else {
      await _fcmService.subscribeToTopic(topic);
    }

    if (mounted) {
      setState(() {
        _topicSubscriptions[topic] = !isCurrentlySubscribed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlySubscribed
                ? '\'$topic\' 토픽 구독을 해제했습니다.'
                : '\'$topic\' 토픽을 구독했습니다.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM 토큰이 클립보드에 복사되었습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM 푸시 알림'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM 토큰 섹션
            _buildTokenSection(),
            const SizedBox(height: 24),

            // 토픽 구독 섹션
            _buildTopicSection(),
            const SizedBox(height: 24),

            // 테스트 가이드 섹션
            _buildTestGuideSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'FCM 토큰',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '이 토큰으로 특정 기기에 푸시 알림을 보낼 수 있습니다.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_fcmToken != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fcmToken!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '토큰을 가져올 수 없습니다',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Platform.isIOS
                          ? 'iOS 시뮬레이터에서는 푸시 알림이 지원되지 않습니다.\n실제 iOS 기기 또는 Android 에뮬레이터에서 테스트해주세요.'
                          : '푸시 알림 권한을 확인해주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fcmToken != null ? _copyToken : null,
                icon: const Icon(Icons.copy),
                label: const Text('토큰 복사하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.topic, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  '토픽 구독 관리',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '원하는 알림 유형을 선택하세요.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTopicTile(
              'news',
              '뉴스 알림',
              '최신 뉴스와 소식을 받아보세요.',
              Icons.newspaper,
            ),
            _buildTopicTile(
              'promo',
              '프로모션 알림',
              '할인 및 이벤트 정보를 받아보세요.',
              Icons.local_offer,
            ),
            _buildTopicTile(
              'updates',
              '업데이트 알림',
              '앱 업데이트 및 새로운 기능 안내',
              Icons.system_update,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(
    String topic,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSubscribed = _topicSubscriptions[topic] ?? false;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isSubscribed
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Icon(
          icon,
          color: isSubscribed
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: isSubscribed,
        onChanged: (_) => _toggleTopicSubscription(topic),
      ),
    );
  }

  Widget _buildTestGuideSection() {
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
            _buildGuideItem('1. Firebase 콘솔 > Cloud Messaging으로 이동'),
            _buildGuideItem('2. "첫 번째 캠페인 만들기" 또는 "새 캠페인" 클릭'),
            _buildGuideItem('3. "Firebase 알림 메시지" 선택'),
            _buildGuideItem('4. 알림 제목과 텍스트 입력'),
            _buildGuideItem('5. 타겟 설정에서:'),
            _buildGuideItem('   • 특정 기기: FCM 토큰 사용'),
            _buildGuideItem('   • 토픽 구독자: 토픽명 입력 (예: news)'),
            _buildGuideItem('6. 추가 옵션에서 커스텀 데이터 추가 (딥링크용):'),
            _buildGuideItem('   • Key: screen, Value: detail 또는 promo'),
            _buildGuideItem('   • Key: id, Value: 123'),
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
}
