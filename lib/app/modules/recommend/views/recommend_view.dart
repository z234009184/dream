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
import 'package:extended_image/extended_image.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/theme/app_theme.dart';

/// 推荐页视图
class RecommendView extends GetView<RecommendController> {
  const RecommendView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: Obx(() {
        final isDark = ThemeService.to.isDarkMode;
        ThemeService.to.themeMode;
        return Listener(
          onPointerDown: (_) => controller.onUserInteraction(),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            controller: controller.scrollController,
            cacheExtent: 600.0,
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text('tab_recommend'.tr),
                heroTag: 'recommend_nav_bar',
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              // 顶部分段选择器
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  child: _CategoryFilter(controller: controller),
                ),
              ),
              // Tab 切换显示
              Obx(() {
                if (controller.currentTab.value == 0) {
                  // 壁纸 Tab：复用原有列表
                  return CupertinoSliverRefreshControl(
                    onRefresh: controller.refreshWallpapers,
                  );
                } else {
                  // 头像 Tab：刷新控件（重排）
                  return CupertinoSliverRefreshControl(
                    onRefresh: controller.refreshAvatars,
                  );
                }
              }),
              Obx(() {
                if (controller.currentTab.value == 0) {
                  // 壁纸列表原逻辑
                  if (controller.loading.value) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  } else if (controller.wallpapers.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmpty(context),
                    );
                  } else {
                    controller.refreshKey.value;
                    return SliverWallpaperMasonry(
                      itemCount: controller.wallpapers.length,
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 64 + 10,
                      ),
                      tileBuilder: (c, i) {
                        final item = controller.wallpapers[i];
                        final tag = 'wallpaper_${item.path}';
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
                            HapticFeedback.mediumImpact();
                            _openPreview(c, item, tag, i);
                          },
                          onToggleFavorite: () =>
                              controller.toggleFavorite(item),
                          aspectRatio: aspect,
                          showFavoriteButton: false,
                          index: i,
                          isVideo: item.mediaType == MediaType.video,
                          onLongPress: item.mediaType == MediaType.video
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  controller.previewVideo(i);
                                }
                              : null,
                        );
                      },
                    );
                  }
                } else {
                  // 头像Tab
                  if (controller.loadingAvatars.value) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }

                  if (controller.avatars.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmpty(context, isAvatar: true),
                    );
                  }

                  controller.refreshAvatarKey.value; //监听重排
                  final gridPadding = EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 64 + 10,
                  );
                  return SliverPadding(
                    padding: gridPadding,
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1,
                          ),
                      delegate: SliverChildBuilderDelegate((c, i) {
                        final avatar = controller.avatars[i];
                        return _AvatarCard(
                          path: avatar.path,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _openAvatarPreview(context, i);
                          },
                        );
                      }, childCount: controller.avatars.length),
                    ),
                  );
                }
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmpty(BuildContext context, {bool isAvatar = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                isAvatar ? CupertinoIcons.person_2 : CupertinoIcons.sparkles,
                size: 64,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Text(
            isAvatar ? '暂无头像' : 'recommend_featured'.tr,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          const SizedBox(height: 8),
          Text(
            isAvatar ? '请在 assets/avatars 目录中添加图片' : 'no_data'.tr,
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, dynamic item, String tag, int index) {
    final imageList = controller.wallpapers.map((w) => w.path).toList();
    Get.toNamed(
      Routes.MEDIA_PREVIEW,
      arguments: {'mediaList': imageList, 'initialIndex': index},
    );
  }

  void _openAvatarPreview(BuildContext context, int index) {
    final avatarList = controller.avatars.map((a) => a.path).toList();
    Get.toNamed(
      Routes.MEDIA_PREVIEW,
      arguments: {'mediaList': avatarList, 'initialIndex': index},
    );
  }
}

/// 分类筛选组件 (移植自 Mood 模块)
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.controller});
  final RecommendController controller;

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 0, 'label': '壁纸'},
      {'key': 1, 'label': '头像'},
    ];
    return Container(
      color: CupertinoColors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Obx(() {
          return Row(
            children: categories.map((cat) {
              final key = cat['key']! as int;
              final label = cat['label']! as String;
              final isSelected = controller.currentTab.value == key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.switchTab(key);
                  },
                  child: FakeGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 20),
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
    );
  }
}

/// 固定头部代理 (移植自 Mood 模块)
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CategoryHeaderDelegate({required this.child});
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
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return false;
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.path, required this.onTap});
  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1,
      duration: 220.ms,
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey6, width: 2),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.09),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExtendedImage.asset(
              path,
              fit: BoxFit.cover,
              enableLoadState: false,
              loadStateChanged: (state) {
                if (state.extendedImageLoadState == LoadState.failed ||
                    state.extendedImageLoadState == LoadState.loading) {
                  return Container(color: CupertinoColors.black);
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
