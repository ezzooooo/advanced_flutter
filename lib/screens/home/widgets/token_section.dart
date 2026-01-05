import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ========================================
/// FCM 토큰 섹션 위젯
/// ========================================
///
/// FCM 토큰을 표시하고 복사하는 기능을 제공합니다.
///

class TokenSection extends StatelessWidget {
  final String? fcmToken;
  final bool isLoading;
  final VoidCallback? onCopyToken;

  const TokenSection({
    super.key,
    required this.fcmToken,
    required this.isLoading,
    this.onCopyToken,
  });

  void _copyToken(BuildContext context) {
    if (fcmToken != null) {
      Clipboard.setData(ClipboardData(text: fcmToken!));
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (fcmToken != null)
              _buildTokenDisplay()
            else
              _buildTokenError(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: fcmToken != null ? () => _copyToken(context) : null,
                icon: const Icon(Icons.copy),
                label: const Text('토큰 복사하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        fcmToken!,
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildTokenError() {
    return Container(
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
    );
  }
}

