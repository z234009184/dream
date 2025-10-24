import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glasso/app/core/theme/app_theme.dart';
import 'package:heroine/heroine.dart';

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
  });

  final String tag;
  final Image image;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final Color? borderColor;
  final double aspectRatio;
  final bool showFavoriteButton;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Heroine(
        tag: tag,
        motion: CupertinoMotion.bouncy(extraBounce: 0.05),
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
