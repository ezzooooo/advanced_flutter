import 'package:flutter/material.dart';
import '../../constants/topic_constants.dart';
import '../../services/fcm_service.dart';
import 'widgets/token_section.dart';
import 'widgets/topic_section.dart';
import 'widgets/test_guide_section.dart';

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
  late Map<String, bool> _topicSubscriptions;

  @override
  void initState() {
    super.initState();
    _initializeTopicSubscriptions();
    _loadFcmToken();
  }

  void _initializeTopicSubscriptions() {
    _topicSubscriptions = {
      for (final topic in Topics.all) topic.id: false,
    };
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
            TokenSection(
              fcmToken: _fcmToken,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // 토픽 구독 섹션
            TopicSection(
              topicSubscriptions: _topicSubscriptions,
              onToggleSubscription: _toggleTopicSubscription,
            ),
            const SizedBox(height: 24),

            // 테스트 가이드 섹션
            const TestGuideSection(),
          ],
        ),
      ),
    );
  }
}

