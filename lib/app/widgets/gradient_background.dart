import 'package:flutter/cupertino.dart';
import '../core/theme/app_theme.dart';

/// 渐变背景组件
/// 自动跟随主题切换的优雅渐变背景
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient()),
      child: child,
    );
  }
}
