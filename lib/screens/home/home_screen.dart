import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import '../../constants/topic_constants.dart';
import '../../services/fcm_service.dart';
import '../../services/remote_config_service.dart';
import '../new_feature_screen.dart';
import 'widgets/feature_flags_section.dart';
import 'widgets/token_section.dart';
import 'widgets/topic_section.dart';
import 'widgets/test_guide_section.dart';

/// ========================================
/// 홈 화면
/// ========================================
///
/// FCM 토큰 표시, 토픽 구독/해제, Feature Flags 관리 기능을 제공합니다.
/// Remote Config의 new_tab_enabled 값에 따라 새로운 탭이 표시됩니다.
///

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FcmService _fcmService = FcmService();
  final RemoteConfigService _remoteConfig = RemoteConfigService();

  String? _fcmToken;
  bool _isLoading = true;
  int _currentTabIndex = 0;

  // 토픽 구독 상태 관리
  late Map<String, bool> _topicSubscriptions;

  bool _isMaintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _initializeTopicSubscriptions();
    _loadFcmToken();
    _setupRemoteConfigListener();
  }

  void _initializeTopicSubscriptions() {
    _topicSubscriptions = {for (final topic in Topics.all) topic.id: false};
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

  Future<void> _setupRemoteConfigListener() async {
    await FirebaseRemoteConfig.instance
        .fetchAndActivate(); // 1번만 값을 가져오고 추후 업데이트 되는건 앱을 껐다 키거나 홈화면을 다시 접근했을 때

    // print('maintenanceMode: $maintenanceMode');
    // setState(() {
    //   _isMaintenanceMode = maintenanceMode;
    // });

    // ------------------------------------------------

    FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
      await FirebaseRemoteConfig.instance.activate();
      print('Remote Config 업데이트 감지: ${event.updatedKeys}');

      final maintenanceMode = FirebaseRemoteConfig.instance.getBool(
        'maintenance_mode',
      );
      print('maintenanceMode: $maintenanceMode');

      setState(() {
        _isMaintenanceMode = maintenanceMode;
      });
    });
  }

  Future<void> _refreshRemoteConfig() async {
    await _remoteConfig.fetchAndActivate();
    if (mounted) {
      setState(() {
        // 새로운 탭이 비활성화되면 첫 번째 탭으로 이동
        if (!_remoteConfig.isNewTabEnabled && _currentTabIndex == 1) {
          _currentTabIndex = 0;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remote Config를 새로고침했습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
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
    final maintenanceMode = FirebaseRemoteConfig.instance.getBool(
      'maintenance_mode',
    );

    if (maintenanceMode) {
      return Scaffold(body: Center(child: Text('점검 중입니다')));
    }

    final isNewTabEnabled = FirebaseRemoteConfig.instance.getBool(
      'new_tab_enabled',
    );
    // final isNewTabEnabled = _remoteConfig.isNewTabEnabled;

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // 메인 탭 (FCM & Feature Flags)
          _buildMainTab(),

          // 새로운 기능 탭 (Feature Flag로 제어)
          if (isNewTabEnabled)
            NewFeatureScreen(title: _remoteConfig.newTabTitle),
        ],
      ),
      bottomNavigationBar: isNewTabEnabled
          ? BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.auto_awesome),
                  label: _remoteConfig.newTabTitle,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMainTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM & Remote Config'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature Flags 섹션
            FeatureFlagsSection(onRefresh: _refreshRemoteConfig),
            const SizedBox(height: 24),

            // FCM 토큰 섹션
            TokenSection(fcmToken: _fcmToken, isLoading: _isLoading),
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
