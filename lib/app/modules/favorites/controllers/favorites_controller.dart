import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../../services/favorites_service.dart';

/// 收藏页控制器
class FavoritesController extends GetxController {
  final Logger _logger = Logger();
  final FavoritesService fav = FavoritesService.to;
  final WallpaperRepository _repo = WallpaperRepository();

  final RxBool loading = false.obs;
  final RxList<Wallpaper> favoriteWallpapers = <Wallpaper>[].obs;

  @override
  void onInit() {
    super.onInit();
    _logger.i('FavoritesController 初始化');
    loadFavorites();
    ever<Set<String>>(fav.favoriteWallpaperPaths, (_) => loadFavorites());
  }

  Future<void> loadFavorites() async {
    try {
      loading.value = true;
      final all = await _repo.loadWallpapers();
      final set = fav.favoriteWallpaperPaths;
      final selected = all.where((w) => set.contains(w.path)).toList();
      for (final w in selected) {
        w.isFavorite = true;
      }
      favoriteWallpapers.assignAll(selected);
      _logger.d('收藏壁纸数量: ${selected.length}');
    } catch (e) {
      _logger.e('加载收藏失败: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> removeFavorite(Wallpaper w) async {
    await fav.toggleWallpaper(w.path);
  }
}
