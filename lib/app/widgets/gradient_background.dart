import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:glasso/app/services/theme_service.dart';
import '../core/theme/app_theme.dart';

/// 渐变背景组件
/// 自动跟随主题切换的优雅渐变背景
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ThemeService.to.themeMode;
      return Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient()),
        child: child,
      );
    });
  }
}
