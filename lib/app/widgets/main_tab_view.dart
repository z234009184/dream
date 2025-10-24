import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:glasso/app/widgets/bottom_bar.dart';
import '../modules/recommend/views/recommend_view.dart';
import '../modules/mood/views/mood_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../routes/app_routes.dart';
import 'gradient_background.dart';

/// 主标签页视图
/// 包含底部导航栏和四个主要页面
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  // 页面列表
  final List<Widget> _pages = const [
    RecommendView(), // 推荐
    MoodView(), // 心情
    ProfileView(), // 我的
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GradientBackground(
        child: Stack(
          children: [
            // 使用 IndexedStack 保留所有页面状态
            IndexedStack(index: _currentIndex, children: _pages),
            SafeArea(
              bottom: true,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LiquidGlassBottomBar(
                  bottomPadding: 0,
                  extraButton: LiquidGlassBottomBarExtraButton(
                    icon: CupertinoIcons.heart,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      // 打开收藏页
                      Get.toNamed(Routes.FAVORITES);
                    },
                    label: 'tab_favorites'.tr,
                  ),
                  tabs: [
                    LiquidGlassBottomBarTab(
                      label: 'tab_recommend'.tr,
                      icon: _currentIndex == 0
                          ? CupertinoIcons.flame_fill
                          : CupertinoIcons.flame,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'tab_mood'.tr,
                      icon: _currentIndex == 1
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'tab_profile'.tr,
                      icon: _currentIndex == 2
                          ? CupertinoIcons.person_fill
                          : CupertinoIcons.person,
                    ),
                  ],
                  selectedIndex: _currentIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
