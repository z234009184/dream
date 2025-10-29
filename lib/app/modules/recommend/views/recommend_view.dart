import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/recommend_controller.dart';
import '../../../widgets/wallpaper_masonry.dart';
import '../../../widgets/media_viewer.dart';
import '../../../data/models/wallpaper.dart';
import '../../../services/theme_service.dart';
import '../../../routes/app_routes.dart';

/// 推荐页视图
class RecommendView extends GetView<RecommendController> {
  const RecommendView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent, // 透明背景，显示渐变
      child: Obx(() {
        // 监听主题变化以自动重建
        final isDark = ThemeService.to.isDarkMode;
        ThemeService.to.themeMode; // 触发响应式更新

        return Listener(
          // 监听用户手势，任何触摸都算交互
          onPointerDown: (_) => controller.onUserInteraction(),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            controller: controller.scrollController,
            cacheExtent: 600.0,
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text('tab_recommend'.tr),
                heroTag: 'recommend_nav_bar', // 唯一的 Hero tag
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              if (controller.loading.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (controller.wallpapers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(context),
                )
              else
                SliverWallpaperMasonry(
                  itemCount: controller.wallpapers.length,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 64 + 10,
                  ),
                  tileBuilder: (c, i) {
                    final item = controller.wallpapers[i];
                    final tag = 'wallpaper_${item.path}'; // 使用路径作为唯一tag
                    final aspect = i == 0 ? (3 / 2) : (3 / 4);

                    final mq = MediaQuery.of(c);
                    const padding = 16.0, spacing = 12.0, columns = 2;
                    final colW =
                        (mq.size.width - padding * 2 - spacing) / columns;
                    final cacheWidth = (colW * mq.devicePixelRatio).round();

                    return WallpaperCard(
                      tag: tag,
                      image: MediaViewer(
                        path: item.path,
                        mediaType: item.mediaType,
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                      ),
                      isFavorite: item.isFavorite,
                      onTap: () {
                        // 震动反馈
                        HapticFeedback.mediumImpact();
                        _openPreview(c, item, tag, i);
                      },
                      onToggleFavorite: () => controller.toggleFavorite(item),
                      aspectRatio: aspect,
                      showFavoriteButton: false, // 隐藏列表页的收藏按钮
                      index: i, // 传入索引
                      isVideo: item.mediaType == MediaType.video, // 是否为视频
                      onLongPress: item.mediaType == MediaType.video
                          ? () {
                              // 长按视频卡片时触发震动并预览
                              HapticFeedback.mediumImpact();
                              controller.previewVideo(i);
                            }
                          : null,
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                CupertinoIcons.sparkles,
                size: 64,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Text(
            'recommend_featured'.tr,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          const SizedBox(height: 8),
          Text(
            'no_data'.tr,
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, dynamic item, String tag, int index) {
    // 准备图片列表（所有壁纸的路径）
    final imageList = controller.wallpapers.map((w) => w.path).toList();

    // 🔥 使用 GetX 路由，自动管理控制器生命周期
    Get.toNamed(
      Routes.MEDIA_PREVIEW,
      arguments: {'mediaList': imageList, 'initialIndex': index},
    );
  }
}
