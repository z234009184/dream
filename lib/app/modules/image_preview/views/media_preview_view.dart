import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../services/favorites_service.dart';
import '../../../services/media_service.dart';
import '../../../services/video_thumbnail_cache_service.dart';
import '../../../widgets/video_player_widget.dart';
import '../controllers/media_preview_controller.dart';

/// 媒体预览页面 - 纯 StatelessWidget
/// 所有逻辑都在 MediaPreviewController 中
class MediaPreviewView extends StatelessWidget {
  const MediaPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaPreviewController>();

    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // 媒体展示区
            Obx(
              () => _MediaGallery(
                mediaList: controller.mediaList,
                currentIndex: controller.currentIndex.value,
                onPageChanged: controller.onPageChanged,
              ),
            ),
            // 顶部返回按钮用玻璃、卡片感突出
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: LiquidGlassLayer(
                      child: LiquidGlass(
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 54,
                        ),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(
                              color: CupertinoColors.white.withOpacity(0.25),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withOpacity(0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 44,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            child: const Icon(
                              CupertinoIcons.back,
                              color: CupertinoColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 底部操作栏，单独包裹LiquidGlassLayer
            Positioned(
              bottom: 10,
              child: SafeArea(
                child: LiquidGlassLayer(
                  child: _BottomActionBar(imagePath: controller.currentPath),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 媒体画廊组件 - StatelessWidget
class _MediaGallery extends StatelessWidget {
  const _MediaGallery({
    required this.mediaList,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> mediaList;
  final int currentIndex;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (mediaList.length == 1) {
      // 单个媒体，直接显示
      return _MediaItem(path: mediaList[0], isCurrentPage: true);
    }

    // 多个媒体，使用 PageView
    return ExtendedImageGesturePageView.builder(
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        return _MediaItem(
          path: mediaList[index],
          isCurrentPage: index == currentIndex,
        );
      },
      controller: ExtendedPageController(initialPage: currentIndex),
      onPageChanged: onPageChanged,
      scrollDirection: Axis.horizontal,
    );
  }
}

/// 单个媒体项 - StatelessWidget
class _MediaItem extends StatelessWidget {
  const _MediaItem({required this.path, required this.isCurrentPage});

  final String path;
  final bool isCurrentPage;

  bool get _isVideo {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov');
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'wallpaper_$path';

    if (_isVideo) {
      // 视频项
      return Hero(
        tag: heroTag,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 300) {
              HapticFeedback.mediumImpact();
              Get.back();
            }
          },
          child: _VideoItem(path: path, isCurrentPage: isCurrentPage),
        ),
      );
    }

    // 图片/GIF 项
    return ExtendedImage.asset(
      path,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      enableSlideOutPage: true,
      heroBuilderForSlidingPage: isCurrentPage
          ? (widget) {
              return Hero(
                tag: heroTag,
                child: widget,
                flightShuttleBuilder:
                    (
                      BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext,
                    ) {
                      final Hero hero =
                          (flightDirection == HeroFlightDirection.pop
                                  ? fromHeroContext.widget
                                  : toHeroContext.widget)
                              as Hero;
                      return hero.child;
                    },
              );
            }
          : null,
      initGestureConfigHandler: (state) {
        final controller = Get.find<MediaPreviewController>();
        return GestureConfig(
          minScale: 0.8,
          maxScale: 3.0,
          animationMinScale: 0.6,
          animationMaxScale: 3.5,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
          inPageView: controller.mediaList.length > 1,
          initialAlignment: InitialAlignment.center,
        );
      },
      onDoubleTap: (state) {
        final pointerDownPosition = state.pointerDownPosition;
        final begin = state.gestureDetails!.totalScale!;
        double end;

        if (begin == 1.0) {
          end = 2.0;
        } else if (begin > 1.99 && begin < 2.01) {
          end = 3.0;
        } else {
          end = 1.0;
        }

        state.handleDoubleTap(
          scale: end,
          doubleTapPosition: pointerDownPosition,
        );
      },
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.failed) {
          return const Center(
            child: Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemGrey,
              size: 48,
            ),
          );
        }
        return null;
      },
    );
  }
}

/// 视频项 - StatelessWidget
class _VideoItem extends StatelessWidget {
  const _VideoItem({required this.path, required this.isCurrentPage});

  final String path;
  final bool isCurrentPage;

  @override
  Widget build(BuildContext context) {
    if (!isCurrentPage) {
      // 非当前页面，显示黑色占位
      return Container(color: CupertinoColors.black);
    }

    // 当前页面，使用 GetX 获取控制器中的视频播放器
    final controller = Get.find<MediaPreviewController>();

    return Obx(() {
      final videoController = controller.videoController.value;
      final thumbnail = VideoThumbnailCacheService.to.getCached(path);

      return Stack(
        fit: StackFit.expand,
        children: [
          // 底层：缩略图占位
          if (thumbnail != null)
            Image.memory(thumbnail, fit: BoxFit.contain, gaplessPlayback: true),

          // 顶层：视频播放器
          if (videoController != null)
            Center(child: VideoPlayerWidget(controller: videoController)),
        ],
      );
    });
  }
}

/// 底部操作栏 - StatelessWidget
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final fav = FavoritesService.to;
    final media = MediaService.to;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      height: 64,
      width: MediaQuery.of(context).size.width * 0.6,
      child: LiquidGlass(
        shape: const LiquidRoundedSuperellipse(borderRadius: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 44,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  fav.toggleWallpaper(imagePath);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(
                      isDark ? 0.09 : 0.17,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: CupertinoColors.white.withOpacity(0.32),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    fav.isFavoritePath(imagePath)
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: fav.isFavoritePath(imagePath)
                        ? CupertinoColors.systemRed
                        : CupertinoColors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 44,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await media.saveAssetImageToGallery(imagePath);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(
                    isDark ? 0.09 : 0.17,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: CupertinoColors.white.withOpacity(0.32),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.arrow_down_to_line,
                  color: CupertinoColors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
