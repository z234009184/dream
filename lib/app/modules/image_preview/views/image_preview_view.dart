import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heroine/heroine.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../services/favorites_service.dart';
import '../../../services/media_service.dart';

/// 图片预览页面
class ImagePreviewView extends StatefulWidget {
  const ImagePreviewView({
    super.key,
    required this.imagePath,
    required this.heroTag,
    this.showFavorite = true,
    this.showSave = true,
    this.imageList, // 图片列表，支持左右滑动
    this.initialIndex, // 初始索引
  });

  final String imagePath;
  final String heroTag;
  final bool showFavorite;
  final bool showSave;
  final List<String>? imageList; // 可选的图片列表
  final int? initialIndex; // 可选的初始索引

  @override
  State<ImagePreviewView> createState() => _ImagePreviewViewState();
}

class _ImagePreviewViewState extends State<ImagePreviewView> {
  PageController? _pageController;
  double _currentScale = 1.0;
  double _dragDistance = 0.0;
  late int _currentIndex;
  late List<String> _images;
  late bool _canSwipe; // 是否支持左右滑动

  @override
  void initState() {
    super.initState();

    // 初始化图片列表和索引
    _canSwipe = widget.imageList != null && widget.imageList!.isNotEmpty;
    if (_canSwipe) {
      _images = widget.imageList!;
      _currentIndex = widget.initialIndex ?? 0;
      _pageController = PageController(initialPage: _currentIndex);
    } else {
      _images = [widget.imagePath];
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      // 重置缩放状态（翻页时）
      _currentScale = 1.0;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // 只在原始缩放时累积下拉距离
    if (_currentScale <= 1.0) {
      _dragDistance += details.delta.dy;
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // 如果向下拖动超过阈值，关闭页面
    if (_dragDistance > 100 && _currentScale <= 1.0) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
    // 重置拖动距离
    _dragDistance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentImagePath = _images[_currentIndex];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // 图片展示区域（支持 Gallery 或单张）
            if (_canSwipe)
              Heroine(
                tag: 'image_$_currentIndex',
                motion: CupertinoMotion.bouncy(extraBounce: 0.05),
                child: PhotoViewGallery.builder(
                  scrollPhysics: _currentScale > 1.0
                      ? const NeverScrollableScrollPhysics() // 放大时禁止翻页
                      : const BouncingScrollPhysics(), // 原始大小时允许翻页
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: AssetImage(_images[index]),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      onScaleEnd: (context, details, controllerValue) {
                        // 监听缩放状态，更新是否可以翻页
                        final scale = controllerValue.scale ?? 1.0;
                        if (scale < 1.0) {
                          HapticFeedback.lightImpact();
                        }
                        if (mounted && index == _currentIndex) {
                          setState(() {
                            _currentScale = scale;
                          });
                        }
                      },
                    );
                  },
                  itemCount: _images.length,
                  loadingBuilder: (context, event) => const Center(
                    child: CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    ),
                  ),
                  backgroundDecoration: const BoxDecoration(
                    color: CupertinoColors.black,
                  ),
                  pageController: _pageController,
                  onPageChanged: _onPageChanged,
                  scrollDirection: Axis.horizontal,
                ),
              )
            else
              _buildPhotoView(currentImagePath, 0),

            // 顶部返回按钮
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _GlassButton(
                      icon: CupertinoIcons.back,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 底部操作栏
            if (widget.showFavorite || widget.showSave)
              Positioned(
                // left: 24,
                // right: 24,
                bottom: 10,
                child: SafeArea(
                  child: _BottomActionBar(
                    imagePath: currentImagePath,
                    showFavorite: widget.showFavorite,
                    showSave: widget.showSave,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建单个 PhotoView（仅用于非滑动模式）
  Widget _buildPhotoView(String imagePath, int index) {
    return Heroine(
      tag: widget.heroTag,
      motion: CupertinoMotion.bouncy(extraBounce: 0.05),
      child: PhotoView(
        imageProvider: AssetImage(imagePath),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: const BoxDecoration(color: CupertinoColors.black),
        enableRotation: false,
        tightMode: false,
        onScaleEnd: (context, details, controllerValue) {
          // 监听缩放结束，触觉反馈
          final scale = controllerValue.scale ?? 1.0;
          if (scale < 1.0) {
            HapticFeedback.lightImpact();
          }
        },
        loadingBuilder: (context, event) => const Center(
          child: CupertinoActivityIndicator(color: CupertinoColors.white),
        ),
      ),
    );
  }
}

/// 液态玻璃底部操作栏
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.imagePath,
    required this.showFavorite,
    required this.showSave,
  });

  final String imagePath;
  final bool showFavorite;
  final bool showSave;

  @override
  Widget build(BuildContext context) {
    final favService = Get.find<FavoritesService>();

    return LiquidGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: const Radius.circular(24)),
      settings: const LiquidGlassSettings(
        blur: 2,
        glassColor: Color(0x1AFFFFFF),
        lightIntensity: 1,
      ),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 收藏按钮
            if (showFavorite)
              Obx(() {
                final isFav = favService.isFavoritePath(imagePath);
                return _GlassIconButton(
                  icon: isFav
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: isFav
                      ? CupertinoColors.systemRed
                      : CupertinoColors.white,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    favService.toggleWallpaper(imagePath);
                  },
                );
              }),

            if (showFavorite && showSave) const SizedBox(width: 40),

            // 保存按钮
            if (showSave)
              _GlassIconButton(
                icon: CupertinoIcons.arrow_down_circle,
                color: CupertinoColors.white,
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  final ok = await Get.find<MediaService>()
                      .saveAssetImageToGallery(imagePath);
                  if (ok) {
                    Get.rawSnackbar(
                      message: 'wallpaper_save_success'.tr,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.rawSnackbar(
                      message: 'wallpaper_save_failed'.tr,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// 液态玻璃图标按钮
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onTap,
      child: Icon(icon, size: 28, color: color),
    );
  }
}

/// 卡片化的返回按钮
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: FakeGlass(
        shape: LiquidRoundedSuperellipse(
          borderRadius: const Radius.circular(16),
        ),
        settings: const LiquidGlassSettings(blur: 5, lightIntensity: 1),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 24, color: CupertinoColors.white),
        ),
      ),
    );
  }
}
