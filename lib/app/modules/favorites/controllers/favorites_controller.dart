import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/models/favorite_mood.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../../services/favorites_service.dart';

/// 收藏页控制器
class FavoritesController extends GetxController {
  final Logger _logger = Logger();
  final FavoritesService fav = FavoritesService.to;
  final WallpaperRepository _repo = WallpaperRepository();

  // 当前选中的 Tab (0: 壁纸, 1: 心情)
  final RxInt currentTab = 0.obs;

  // 壁纸 Tab
  final RxBool wallpapersLoading = false.obs;
  final RxList<Wallpaper> favoriteWallpapers = <Wallpaper>[].obs;

  // 心情 Tab (直接从 Service 获取)
  List<FavoriteMood> get favoriteMoods => fav.favoriteMoods;

  @override
  void onInit() {
    super.onInit();
    _logger.i('FavoritesController 初始化');

    // 加载壁纸收藏
    loadWallpapers();

    // 监听壁纸收藏变化
    ever<Set<String>>(fav.favoriteWallpaperPaths, (_) => loadWallpapers());
  }

  /// 加载壁纸收藏
  Future<void> loadWallpapers() async {
    try {
      wallpapersLoading.value = true;
      final all = await _repo.loadWallpapers();
      final set = fav.favoriteWallpaperPaths;
      final selected = all.where((w) => set.contains(w.path)).toList();
      for (final w in selected) {
        w.isFavorite = true;
      }
      favoriteWallpapers.assignAll(selected);
      _logger.d('收藏壁纸数量: ${selected.length}');
    } catch (e) {
      _logger.e('加载收藏壁纸失败: $e');
    } finally {
      wallpapersLoading.value = false;
    }
  }

  /// 删除壁纸收藏
  Future<void> removeWallpaper(Wallpaper w) async {
    await fav.toggleWallpaper(w.path);
  }

  /// 删除心情收藏
  Future<void> removeMood(String moodId) async {
    await fav.removeMood(moodId);
  }

  /// 切换 Tab
  void switchTab(int index) {
    currentTab.value = index;
    _logger.d('切换到 Tab: $index');
  }

  @override
  void onClose() {
    _logger.d('FavoritesController 关闭');
    super.onClose();
  }
}
