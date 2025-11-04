import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extended_image/extended_image.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/media_viewer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/theme_service.dart';
import '../controllers/favorites_controller.dart';

/// 收藏页视图（双 Tab：壁纸 + 心情）
class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      // 订阅主题变化，确保切换时重建
      ThemeService.to.themeMode;
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.secondarySystemBackground.resolveFrom(
          context,
        ),
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('favorites_title'.tr),
              heroTag: 'favorites_nav_bar',
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            // 顶部分段控制器
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabHeaderDelegate(child: _buildTabFilter(context)),
            ),
            // 内容区域
            Obx(() {
              if (controller.currentTab.value == 0) {
                return _buildWallpapersContent(context);
              } else {
                return _buildMoodsContent(context);
              }
            }),
          ],
        ),
      );
    });
  }

  /// 构建顶部 Tab 过滤器
  Widget _buildTabFilter(BuildContext context) {
    final tabs = [
      {'key': 0, 'label': 'favorites_wallpapers_tab'.tr},
      {'key': 1, 'label': 'favorites_moods_tab'.tr},
    ];

    return Container(
      color: CupertinoColors.transparent,
      child: LiquidGlassLayer(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Obx(() {
            return Row(
              children: tabs.map((tab) {
                final key = tab['key']! as int;
                final label = tab['label']! as String;
                final isSelected = controller.currentTab.value == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.switchTab(key);
                    },
                    child: FakeGlass(
                      shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                      settings: LiquidGlassSettings(
                        glassColor: AppTheme.primary().withAlpha(50),
                        blur: isSelected ? 10 : 6,
                        lightIntensity: 0.8,
                      ),
                      child:
                          AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.primary()
                                        : CupertinoColors.label.resolveFrom(
                                            context,
                                          ),
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              )
                              .animate(target: isSelected ? 1 : 0)
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.05, 1.05),
                                duration: 200.ms,
                              ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  /// 构建壁纸内容
  Widget _buildWallpapersContent(BuildContext context) {
    return Obx(() {
      if (controller.wallpapersLoading.value) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CupertinoActivityIndicator()),
        );
      }

      if (controller.favoriteWallpapers.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(
            context,
            icon: CupertinoIcons.photo,
            title: 'favorites_empty_wallpapers'.tr,
            subtitle: 'favorites_empty_wallpapers_hint'.tr,
          ),
        );
      }

      return _buildWallpaperGrid(context);
    });
  }

  /// 构建壁纸网格
  Widget _buildWallpaperGrid(BuildContext context) {
    const crossAxisCount = 2;
    const spacing = 12.0;
    const padding = 16.0;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        top: padding,
        bottom: padding + MediaQuery.of(context).padding.bottom + 64 + 10,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 3 / 4,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = controller.favoriteWallpapers[index];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _openWallpaperPreview(context, index);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MediaViewer(
                    path: item.path,
                    mediaType: item.mediaType,
                    fit: BoxFit.cover,
                    cacheWidth:
                        (MediaQuery.of(context).size.width *
                                0.5 *
                                MediaQuery.of(context).devicePixelRatio)
                            .round(),
                  ),

                  // 删除按钮
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _showDeleteWallpaperDialog(context, item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context)
                              .withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.delete,
                          size: 18,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms, delay: (index * 40).ms),
          );
        }, childCount: controller.favoriteWallpapers.length),
      ),
    );
  }

  /// 打开壁纸预览
  void _openWallpaperPreview(BuildContext context, int index) {
    final imageList = controller.favoriteWallpapers.map((w) => w.path).toList();
    Get.toNamed(
      Routes.MEDIA_PREVIEW,
      arguments: {'mediaList': imageList, 'initialIndex': index},
    );
  }

  /// 显示删除壁纸确认对话框
  void _showDeleteWallpaperDialog(BuildContext context, dynamic item) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('favorites_delete_wallpaper_title'.tr),
        content: Text('favorites_delete_wallpaper_message'.tr),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              controller.removeWallpaper(item);
              Get.back();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  /// 构建心情内容
  Widget _buildMoodsContent(BuildContext context) {
    return Obx(() {
      final moods = controller.favoriteMoods;

      if (moods.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(
            context,
            icon: CupertinoIcons.heart,
            title: 'favorites_empty_moods'.tr,
            subtitle: 'favorites_empty_moods_hint'.tr,
          ),
        );
      }

      return _buildMoodList(context, moods);
    });
  }

  /// 构建心情列表
  Widget _buildMoodList(BuildContext context, List moods) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom + 64 + 10,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final mood = moods[index];
          return _MoodCard(
            mood: mood,
            index: index,
            onTap: () {
              HapticFeedback.selectionClick();
              _openMoodDetail(mood);
            },
            onDelete: () {
              HapticFeedback.mediumImpact();
              _showDeleteMoodDialog(context, mood);
            },
          );
        }, childCount: moods.length),
      ),
    );
  }

  /// 打开心情详情页
  void _openMoodDetail(dynamic mood) {
    // 将 FavoriteMood 转换为 Mood 对象
    final moodObject = mood.toMood();

    // 跳转到心情详情页
    Get.toNamed(Routes.MOOD_DETAIL, arguments: moodObject);
  }

  /// 显示删除心情确认对话框
  void _showDeleteMoodDialog(BuildContext context, dynamic mood) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('favorites_delete_mood_title'.tr),
        content: Text('favorites_delete_mood_message'.tr),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              controller.removeMood(mood.moodId);
              Get.back();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                icon,
                size: 80,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: CupertinoColors.systemGrey2),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

/// Tab 头部代理
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate({required this.child});
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) {
    return false;
  }
}

/// 心情卡片
class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.mood,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic mood;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mood.color.withOpacity(0.7),
                    mood.bgColor.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: mood.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 背景壁纸
                  if (mood.wallpaperPath.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Opacity(
                          opacity: 0.3,
                          child: ExtendedImage.asset(
                            mood.wallpaperPath,
                            fit: BoxFit.cover,
                            enableLoadState: false,
                          ),
                        ),
                      ),
                    ),

                  // 内容
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 头部：头像 + 分类 + 删除按钮
                        Row(
                          children: [
                            // 头像
                            if (mood.avatarPath != null &&
                                mood.avatarPath!.isNotEmpty)
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: CupertinoColors.white.withOpacity(
                                      0.3,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mood.color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: ExtendedImage.asset(
                                    mood.avatarPath!,
                                    fit: BoxFit.cover,
                                    enableLoadState: false,
                                  ),
                                ),
                              ),

                            // 分类标签
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mood.category,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // 删除按钮
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  size: 16,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 心情文字
                        Text(
                          mood.text,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // 底部：收藏时间
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              size: 14,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(mood.savedAt),
                              style: TextStyle(
                                color: CupertinoColors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
        .moveY(begin: 20, end: 0, duration: 300.ms, delay: (index * 40).ms);
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 30) {
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} 天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} 小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} 分钟前';
    } else {
      return '刚刚';
    }
  }
}
