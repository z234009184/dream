import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:heroine/heroine.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../controllers/mood_controller.dart';
import '../../../data/models/mood.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/theme_service.dart';
import '../../../routes/app_routes.dart';

/// 心情页视图
class MoodView extends GetView<MoodController> {
  const MoodView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent, // 透明背景，显示渐变
      child: Obx(() {
        // 监听主题变化以自动重建
        final isDark = ThemeService.to.isDarkMode;
        ThemeService.to.themeMode; // 触发响应式更新

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 1000, // 预加载区域，减少重建
          slivers: [
            // 大标题导航栏
            CupertinoSliverNavigationBar(
              heroTag: 'mood_nav_bar', // 唯一的 Hero tag
              brightness: isDark ? Brightness.dark : Brightness.light,
              largeTitle: Text('tab_mood'.tr),
            ),

            // 下拉刷新
            CupertinoSliverRefreshControl(onRefresh: controller.refreshMoods),

            // 分类筛选栏
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryHeaderDelegate(
                child: _CategoryFilter(controller: controller),
              ),
            ),

            // 心情列表
            if (controller.loading.value)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (controller.filteredMoods.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmpty(context),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 64 + 10,
                ),
                sliver: Obx(() {
                  // 监听 refreshKey 以触发列表重建
                  controller.refreshKey.value;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final mood = controller.filteredMoods[index];
                      return _MoodCard(
                        key: ValueKey(
                          '${mood.id}_${controller.refreshKey.value}',
                        ),
                        mood: mood,
                        index: index,
                      );
                    }, childCount: controller.filteredMoods.length),
                  );
                }),
              ),
          ],
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
                CupertinoIcons.heart,
                size: 64,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Text(
            'mood_empty'.tr,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          const SizedBox(height: 8),
          Text(
            'mood_empty_hint'.tr,
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
        ],
      ),
    );
  }
}

/// 分类筛选组件
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.controller});

  final MoodController controller;

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 'all', 'label': 'mood_all'.tr},
      {'key': '心情语录', 'label': 'mood_feeling'.tr},
      {'key': '励志语录', 'label': 'mood_励志'.tr},
      {'key': '经典台词', 'label': 'mood_台词'.tr},
      {'key': '名人名言', 'label': 'mood_名人'.tr},
      {'key': '爱情语录', 'label': 'mood_爱情'.tr},
      {'key': '人生感悟', 'label': 'mood_人生'.tr},
      {'key': '精美译文', 'label': 'mood_译文'.tr},
    ];

    return Container(
      color: CupertinoColors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Obx(() {
          return Row(
            children: categories.map((cat) {
              final key = cat['key']!;
              final label = cat['label']!;
              final isSelected = controller.selectedCategory.value == key;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectCategory(key);
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

/// 心情卡片
class _MoodCard extends StatefulWidget {
  const _MoodCard({super.key, required this.mood, required this.index});

  final Mood mood;
  final int index;

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // 只在首次显示时动画
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _hasAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: _hasAnimated ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _hasAnimated ? Offset.zero : const Offset(0, 0.05),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // 打开心情详情
              Get.toNamed(Routes.MOOD_DETAIL, arguments: widget.mood);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.mood.bgColor,
                    widget.mood.bgColor.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.mood.color.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.mood.color.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像 + 图标和分类
                  Row(
                    children: [
                      // 头像
                      if (widget.mood.avatarPath != null)
                        Heroine(
                          tag: 'mood_avatar_${widget.mood.id}',
                          motion: const CupertinoMotion.bouncy(),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: widget.mood.color.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.mood.color.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: Image.asset(
                                widget.mood.avatarPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: widget.mood.color.withOpacity(0.1),
                                    child: Icon(
                                      CupertinoIcons.person_fill,
                                      color: widget.mood.color,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                      if (widget.mood.avatarPath != null)
                        const SizedBox(width: 12),

                      // 图标
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.mood.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.mood.icon,
                          color: widget.mood.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 分类标签
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.mood.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.mood.category,
                            style: TextStyle(
                              color: widget.mood.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 收藏图标
                      Icon(
                        CupertinoIcons.heart,
                        color: widget.mood.color.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 心情文字
                  Text(
                    widget.mood.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                      height: 1.5,
                    ),
                  ),

                  if (widget.mood.author.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '— ${widget.mood.author}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 固定头部代理
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
  double get maxExtent => 70; // 增加高度以适应不同语言

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return false;
  }
}
