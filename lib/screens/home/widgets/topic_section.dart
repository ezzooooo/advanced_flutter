import 'package:flutter/material.dart';
import '../../../constants/topic_constants.dart';

/// ========================================
/// 토픽 구독 섹션 위젯
/// ========================================
///
/// FCM 토픽 구독/해제 기능을 제공합니다.
///

class TopicSection extends StatelessWidget {
  final Map<String, bool> topicSubscriptions;
  final Function(String topic) onToggleSubscription;

  const TopicSection({
    super.key,
    required this.topicSubscriptions,
    required this.onToggleSubscription,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildTopicTile(context, Topics.news, Icons.newspaper),
            _buildTopicTile(context, Topics.promo, Icons.local_offer),
            _buildTopicTile(context, Topics.updates, Icons.system_update),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(
    BuildContext context,
    TopicInfo topic,
    IconData icon,
  ) {
    final isSubscribed = topicSubscriptions[topic.id] ?? false;

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
      title: Text(topic.name),
      subtitle: Text(topic.description, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: isSubscribed,
        onChanged: (_) => onToggleSubscription(topic.id),
      ),
    );
  }
}

