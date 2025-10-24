import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/recommend_controller.dart';
import '../../../widgets/wallpaper_masonry.dart';
import '../../image_preview/views/image_preview_view.dart';
import '../../../services/theme_service.dart';

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
                    final tag = 'image_$i'; // 使用统一的索引tag，方便PageView匹配
                    final aspect = i == 0 ? (3 / 2) : (3 / 4);

                    final mq = MediaQuery.of(c);
                    const padding = 16.0, spacing = 12.0, columns = 2;
                    final colW =
                        (mq.size.width - padding * 2 - spacing) / columns;
                    final cacheWidth = (colW * mq.devicePixelRatio).round();

                    return WallpaperCard(
                      tag: tag,
                      image: Image.asset(
                        item.path,
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                        filterQuality: FilterQuality.low,
                        frameBuilder: (ctx, child, frame, wasSync) {
                          if (frame != null) return child;
                          return Container(
                            color: CupertinoColors.secondarySystemBackground
                                .resolveFrom(ctx),
                          );
                        },
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

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // 透明背景
        barrierColor: CupertinoColors.black, // 黑色遮罩
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImagePreviewView(
            imagePath: item.path,
            heroTag: tag,
            showFavorite: true,
            showSave: true,
            imageList: imageList, // 传入图片列表
            initialIndex: index, // 传入当前索引
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 背景渐变动画
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
