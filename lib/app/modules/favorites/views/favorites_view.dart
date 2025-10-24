import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/favorites_controller.dart';

/// 收藏页视图
class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('tab_favorites'.tr),
        backgroundColor: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withOpacity(0.8),
        border: null,
      ),
      child: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (controller.favoriteWallpapers.isEmpty) {
            return _buildEmptyState(context);
          }
          return _WallGrid(ctrl: controller);
        }),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart,
            size: 64,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Text(
            'favorites_empty'.tr,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'favorites_empty_hint'.tr,
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _WallGrid extends StatelessWidget {
  const _WallGrid({required this.ctrl});
  final FavoritesController ctrl;

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 2;
    const spacing = 12.0;
    const padding = 16.0;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(padding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 9 / 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = ctrl.favoriteWallpapers[index];
              final tag = item.path;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _openPreview(context, item, tag),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: tag,
                        child: Image.asset(item.path, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _RemoveButton(
                          onTap: () => ctrl.removeFavorite(item),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms, delay: 40.ms),
              );
            }, childCount: ctrl.favoriteWallpapers.length),
          ),
        ),
      ],
    );
  }

  void _openPreview(BuildContext context, dynamic item, String tag) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.2),
      builder: (_) => _Preview(
        item: item,
        tag: tag,
        onRemove: () => ctrl.removeFavorite(item),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});
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
        child: const Icon(
          CupertinoIcons.delete,
          size: 18,
          color: CupertinoColors.systemRed,
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.item,
    required this.tag,
    required this.onRemove,
  });
  final dynamic item;
  final String tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: Container(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: tag,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(item.path, fit: BoxFit.cover),
                    ),
                  ),
                ).animate().fadeIn(duration: 250.ms),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _BlurButton(
                  icon: CupertinoIcons.xmark,
                  onTap: () => Get.back(),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _BlurButton(
                  icon: CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  onTap: () {
                    onRemove();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurButton extends StatelessWidget {
  const _BlurButton({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground
              .resolveFrom(context)
              .withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: color ?? CupertinoColors.label.resolveFrom(context),
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}
