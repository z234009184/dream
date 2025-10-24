import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 应用主题配置
/// 完全基于 Cupertino 风格设计
class AppTheme {
  // 私有构造函数，禁止实例化
  AppTheme._();

  // ==================== 颜色定义 ====================

  // 浅色模式主色调 - 高级感深紫色系
  static const Color lightPrimary = Color(0xFF6C5CE7); // 优雅深紫
  static const Color lightBackground = Color(0xFFF3F3F3); // 更柔和的背景
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C1C1E); // 深灰色文字，更柔和
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightDivider = Color(0xFFE5E5EA);

  // 深色模式主色调 - 深邃优雅的深色系
  static const Color darkPrimary = Color(0xFF9B8AFF); // 更亮的紫色，深色模式下更显眼
  static const Color darkBackground = Color(0xFF222222); // 纯黑背景，更显高级
  static const Color darkCardBackground = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF98989D); // 稍亮的次要文字
  static const Color darkDivider = Color(0xFF38383A);

  // 强调色 - 更现代的色彩
  static const Color accentColor = Color(0xFFFF375F); // 更鲜艳的粉红
  static const Color successColor = Color(0xFF30D158); // 更亮的绿色
  static const Color warningColor = Color(0xFFFF9F0A); // 更温暖的橙色

  // ==================== 浅色主题 ====================

  static CupertinoThemeData get lightTheme => CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    barBackgroundColor: lightCardBackground.withAlpha(100),
    textTheme: CupertinoTextThemeData(
      primaryColor: lightTextPrimary,
      textStyle: const TextStyle(
        inherit: false,
        fontSize: 17,
        color: lightTextPrimary,
        fontFamily: '.SF Pro Text',
      ),
      navTitleTextStyle: const TextStyle(
        inherit: false,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
        fontFamily: '.SF Pro Text',
      ),
      navLargeTitleTextStyle: const TextStyle(
        inherit: false,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
        fontFamily: '.SF Pro Display',
      ),
    ),
  );

  // ==================== 深色主题 ====================

  static CupertinoThemeData get darkTheme => CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    barBackgroundColor: darkCardBackground.withAlpha(100),
    textTheme: CupertinoTextThemeData(
      primaryColor: darkTextPrimary,
      textStyle: const TextStyle(
        inherit: false,
        fontSize: 17,
        color: darkTextPrimary,
        fontFamily: '.SF Pro Text',
      ),
      navTitleTextStyle: const TextStyle(
        inherit: false,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        fontFamily: '.SF Pro Text',
      ),
      navLargeTitleTextStyle: const TextStyle(
        inherit: false,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
        fontFamily: '.SF Pro Display',
      ),
    ),
  );

  // ==================== 辅助方法 ====================

  /// 获取卡片背景色
  static Color cardBackground() =>
      Get.isDarkMode ? darkCardBackground : lightCardBackground;

  /// 获取文本主色
  static Color textPrimary() =>
      Get.isDarkMode ? darkTextPrimary : lightTextPrimary;

  /// 获取文本次要色
  static Color textSecondary() =>
      Get.isDarkMode ? darkTextSecondary : lightTextSecondary;

  /// 获取分割线颜色
  static Color divider() => Get.isDarkMode ? darkDivider : lightDivider;

  /// 获取背景色
  static Color background() =>
      Get.isDarkMode ? darkBackground : lightBackground;

  /// 获取主色调
  static Color primary() => Get.isDarkMode ? darkPrimary : lightPrimary;

  // ==================== 渐变背景 ====================

  /// 获取页面背景渐变
  /// 优雅的渐变效果，适用于整个页面背景
  static LinearGradient backgroundGradient() {
    if (Get.isDarkMode) {
      // 深色模式：深邃优雅的渐变
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF333366), // 深蓝紫
          Color(0xFF161616), // 深蓝灰
          Color(0xFF0f0f0f), // 深紫黑
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      // 浅色模式：清新淡雅的渐变
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F8CC), // 淡紫白
          Color(0xFFF0F0F0), // 淡灰紫
          Color(0xFFE8E8E8), // 淡紫灰
        ],
        stops: [0.0, 0.5, 1.0],
      );
    }
  }

  /// 获取卡片背景渐变（更微妙）
  /// 适用于卡片或小组件背景
  static LinearGradient cardGradient() {
    if (Get.isDarkMode) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [darkCardBackground, darkCardBackground.withOpacity(0.95)],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightCardBackground, const Color(0xFFFAFAFC)],
      );
    }
  }
}
