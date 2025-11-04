import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:heroine/heroine.dart';
import '../../../services/video_thumbnail_cache_service.dart';
import '../controllers/mood_detail_controller.dart';

/// 心情详情页面
class MoodDetailView extends GetView<MoodDetailController> {
  const MoodDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, // 白色状态栏
        child: Stack(
          children: [
            // 背景壁纸（视差滚动）
            _buildParallaxBackground(context),

            // 顶部到底部渐变色蒙层
            _buildGradientMask(context),

            // 内容区域
            _buildContent(context),

            // 顶部导航栏（毛玻璃）
            _buildNavigationBar(context),

            // 底部提示
            _buildBottomHint(context),
          ],
        ),
      ),
    );
  }

  /// 构建顶部到底部渐变色蒙层
  Widget _buildGradientMask(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.black.withAlpha(200),
            CupertinoColors.black.withAlpha(0),
          ],
        ),
      ),
    );
  }

  /// 构建视差背景
  Widget _buildParallaxBackground(BuildContext context) {
    return Obx(() {
      final wallpaper = controller.currentWallpaper;

      if (wallpaper.isEmpty) {
        // 渐变背景
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                controller.mood.color.withOpacity(0.6),
                controller.mood.bgColor.withOpacity(0.8),
                CupertinoColors.black,
              ],
            ),
          ),
        );
      }

      return Positioned.fill(
        child: Obx(() {
          return Transform.translate(
            offset: Offset(0, -controller.parallaxOffset.value),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildWallpaperImage(wallpaper),
            ),
          );
        }),
      );
    });
  }

  /// 构建壁纸图片/视频
  Widget _buildWallpaperImage(String path) {
    final isVideo = controller.isVideo;

    if (isVideo) {
      // 视频：显示缩略图
      return FutureBuilder<Uint8List?>(
        key: ValueKey(path), // 唯一 key，确保 AnimatedSwitcher 识别
        future: VideoThumbnailCacheService.to.getThumbnail(path),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }
          return Container(color: CupertinoColors.black);
        },
      );
    }

    // 图片
    return ExtendedImage.asset(
      key: ValueKey(path), // 唯一 key，确保 AnimatedSwitcher 识别
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      enableLoadState: false,
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          controller.updateParallaxOffset(notification.metrics.pixels);
        }
        return false;
      },
      child: GestureDetector(
        // 左右滑动切换壁纸
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // 向右滑动 - 上一张
            controller.previousWallpaper();
          } else if (details.primaryVelocity! < 0) {
            // 向左滑动 - 下一张
            controller.nextWallpaper();
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // 顶部间距（为导航栏留空间）
                SizedBox(height: MediaQuery.of(context).padding.top + 50),

                const SizedBox(height: 40),

                // 头像（Hero 动画）
                _buildAvatar(),

                const SizedBox(height: 40),

                // 心情文字（动画）
                _buildMoodText(context),

                const SizedBox(height: 60),

                // 作者信息
                if (controller.mood.author.isNotEmpty) _buildAuthor(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头像（Hero 动画）
  Widget _buildAvatar() {
    final avatarPath = controller.mood.avatarPath;

    if (avatarPath == null || avatarPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Heroine(
      tag: 'mood_avatar_${controller.mood.id}',
      motion: const CupertinoMotion.bouncy(),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: controller.mood.color.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: controller.mood.color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: ExtendedImage.asset(
            avatarPath,
            fit: BoxFit.cover,
            enableLoadState: false,
          ),
        ),
      ),
    );
  }

  /// 构建心情文字（打字机动画）
  Widget _buildMoodText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 24,
          height: 1.6,
          color: CupertinoColors.white,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color: CupertinoColors.black,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              controller.mood.text,
              speed: const Duration(milliseconds: 50),
              cursor: '',
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
        ),
      ),
    );
  }

  /// 构建作者信息
  Widget _buildAuthor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '—— ${controller.mood.author}',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
            shadows: const [
              Shadow(
                color: CupertinoColors.black,
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建导航栏（毛玻璃）
  Widget _buildNavigationBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            // 返回按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                Get.back();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 操作菜单按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: null,
              child: const SizedBox(width: 40, height: 40),
            ),

            const Spacer(),

            // 标题
            Text(
              controller.mood.category,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // 收藏按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.toggleFavorite,
              child: Obx(() {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey(controller.isFavorite.value),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isFavorite.value
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: controller.isFavorite.value
                          ? CupertinoColors.systemRed
                          : CupertinoColors.white,
                      size: 22,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(width: 8),

            // 操作菜单按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                _showActionMenu(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部提示
  Widget _buildBottomHint(BuildContext context) {
    return Obx(() {
      // 只有在有壁纸时才显示提示
      if (controller.candidateWallpapers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CupertinoColors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.arrow_left,
                  color: CupertinoColors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '滑动切换壁纸 (${controller.currentWallpaperIndex.value + 1}/${controller.candidateWallpapers.length})',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.arrow_right,
                  color: CupertinoColors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 显示操作菜单
  void _showActionMenu(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('选择操作', style: TextStyle(fontSize: 14)),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              controller.saveAvatar();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 20),
                SizedBox(width: 8),
                Text('保存头像'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              controller.saveWallpaper();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_on_rectangle, size: 20),
                SizedBox(width: 8),
                Text('保存壁纸'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              controller.copyMoodText();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                SizedBox(width: 8),
                Text('复制心情'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Get.back();
          },
          isDefaultAction: true,
          child: const Text('取消'),
        ),
      ),
    );
  }
}
