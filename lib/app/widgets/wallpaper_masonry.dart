import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glasso/app/core/theme/app_theme.dart';

typedef WallpaperTileBuilder = Widget Function(BuildContext context, int index);

class SliverWallpaperMasonry extends StatelessWidget {
  const SliverWallpaperMasonry({
    super.key,
    required this.itemCount,
    required this.tileBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final WallpaperTileBuilder tileBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childCount: itemCount,
        itemBuilder: (context, index) {
          return tileBuilder(context, index)
              .animate()
              .fadeIn(duration: 220.ms)
              .moveY(begin: 10, end: 0, duration: 220.ms)
              .scale(begin: const Offset(0.98, 0.98), duration: 220.ms);
        },
      ),
    );
  }
}

class WallpaperCard extends StatelessWidget {
  const WallpaperCard({
    super.key,
    required this.tag,
    required this.image,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.borderColor,
    this.aspectRatio = 3 / 4, // 默认 3:4，避免无限高度
    this.showFavoriteButton = true, // 是否显示收藏按钮
    this.index, // 用于 PageView 的索引
    this.isVideo = false, // 是否为视频
    this.onLongPress, // 长按回调
  });

  final String tag;
  final Widget image; // 改为 Widget，支持 MediaViewer
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final Color? borderColor;
  final double aspectRatio;
  final bool showFavoriteButton;
  final int? index;
  final bool isVideo; // 是否为视频
  final VoidCallback? onLongPress; // 长按回调

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: tag,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? AppTheme.primary(),
              width: 4,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(child: image),
                  // 实况标识（视频）
                  if (isVideo) Positioned(top: 8, left: 8, child: _LiveBadge()),
                  if (showFavoriteButton)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _Fav(isFav: isFavorite, onTap: onToggleFavorite),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 实况标识（Live Badge）- 类似 iOS Live Photos
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/others/live_photo_line.png',
      width: 24,
      height: 24,
      fit: BoxFit.cover,
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

class _Fav extends StatelessWidget {
  const _Fav({required this.isFav, required this.onTap});
  final bool isFav;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoColors.systemBackground
        .resolveFrom(context)
        .withOpacity(0.7);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isFav ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
          size: 18,
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}
