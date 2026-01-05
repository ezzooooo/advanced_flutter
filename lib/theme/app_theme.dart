import 'package:flutter/material.dart';

/// ========================================
/// 앱 테마 설정
/// ========================================
///
/// 앱 전체에서 사용되는 테마 정의
///

class AppTheme {
  // 기본 시드 색상
  static const Color seedColor = Colors.deepPurple;

  /// 라이트 테마
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    useMaterial3: true,
  );

  /// 다크 테마 (필요시 사용)
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
