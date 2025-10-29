import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../../services/favorites_service.dart';
import '../../../services/video_controller_service.dart';
import '../../../routes/app_routes.dart';

/// 推荐页控制器
class RecommendController extends GetxController {
  final Logger _logger = Logger();
  final WallpaperRepository _repo = WallpaperRepository();
  final FavoritesService fav = FavoritesService.to;

  final RxBool loading = false.obs;
  final RxList<Wallpaper> wallpapers = <Wallpaper>[].obs;

  // 滚动控制与自动滚动
  final ScrollController scrollController = ScrollController();
  Timer? _autoScrollTimer;
  Timer? _idleTimer;
  // bool _isAutoScrolling = false;

  // 自动滚动参数
  // static const Duration _idleDuration = Duration(seconds: 3); // 无操作1秒后开始自动滚动
  // static const Duration _scrollInterval = Duration(
  //   milliseconds: 50,
  // ); // 每50ms滚动一次
  // static const double _scrollStep = 0.8; // 每次滚动0.8像素（可调节速度）

  @override
  void onInit() {
    super.onInit();
    _logger.i('RecommendController 初始化');
    loadWallpapers();
    ever<Set<String>>(fav.favoriteWallpaperPaths, (_) => _syncFavorites());

    // 启动空闲检测
    // _startIdleTimer();
  }

  @override
  void onClose() {
    _stopAutoScroll();
    _idleTimer?.cancel();
    scrollController.dispose();

    // 释放视频控制器（全局只有一个）
    VideoControllerService.to.release();
    _logger.i('已释放视频控制器');

    super.onClose();
  }

  void _syncFavorites() {
    for (final w in wallpapers) {
      w.isFavorite = fav.isFavoritePath(w.path);
    }
    wallpapers.refresh();
  }

  /// 切换收藏
  Future<void> toggleFavorite(Wallpaper w) async {
    await fav.toggleWallpaper(w.path);
  }

  /// 加载壁纸
  Future<void> loadWallpapers() async {
    try {
      loading.value = true;
      final items = await _repo.loadWallpapers();
      for (final w in items) {
        w.isFavorite = fav.isFavoritePath(w.path);
      }
      wallpapers.assignAll(items);
      _logger.d('已加载壁纸: ${items.length}');

      // 首屏预解码少量图片，降低白屏
      final ctx = Get.context;
      if (ctx != null) {
        for (final w in wallpapers.take(8)) {
          precacheImage(AssetImage(w.path), ctx);
        }
      }
    } catch (e) {
      _logger.e('加载壁纸失败: $e');
    } finally {
      loading.value = false;
    }
  }

  // ============ 自动滚动控制 ============

  /// 用户交互时调用（手势或点击）
  void onUserInteraction() {
    _stopAutoScroll();
    // _startIdleTimer();
  }

  // /// 启动空闲计时器
  // void _startIdleTimer() {
  //   _idleTimer?.cancel();
  //   _idleTimer = Timer(_idleDuration, _startAutoScroll);
  // }

  // /// 开始自动滚动
  // void _startAutoScroll() {
  //   if (_isAutoScrolling || !scrollController.hasClients) return;

  //   _isAutoScrolling = true;
  //   _autoScrollTimer?.cancel();
  //   _autoScrollTimer = Timer.periodic(_scrollInterval, (timer) {
  //     if (!scrollController.hasClients) {
  //       _stopAutoScroll();
  //       return;
  //     }

  //     final position = scrollController.position;
  //     final currentPixels = position.pixels;
  //     final maxScroll = position.maxScrollExtent;

  //     // 滚动到底部，回到顶部继续
  //     if (currentPixels >= maxScroll) {
  //       scrollController.jumpTo(0);
  //       return;
  //     }

  //     // 平滑滚动
  //     final targetPixels = (currentPixels + _scrollStep).clamp(0.0, maxScroll);
  //     scrollController.jumpTo(targetPixels);
  //   });
  // }

  /// 停止自动滚动
  void _stopAutoScroll() {
    // _isAutoScrolling = false;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _idleTimer?.cancel();
  }

  /// 长按预览视频（直接打开完整预览页）
  void previewVideo(int index) {
    final wallpaper = wallpapers[index];
    if (wallpaper.mediaType != MediaType.video) return;

    // 触感反馈
    HapticFeedback.mediumImpact();

    // 准备图片列表（所有壁纸的路径）
    final imageList = wallpapers.map((w) => w.path).toList();

    // 🔥 使用 GetX 路由，自动管理控制器生命周期
    Get.toNamed(
      Routes.MEDIA_PREVIEW,
      arguments: {'mediaList': imageList, 'initialIndex': index},
    );
  }
}
