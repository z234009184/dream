import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

class FavoritesService extends GetxService {
  static FavoritesService get to => Get.find();

  final Logger _logger = Logger();
  final RxSet<String> favoriteWallpaperPaths = <String>{}.obs;

  Future<FavoritesService> init() async {
    try {
      final list =
          StorageService.to.read<List>(StorageService.keyFavoriteWallpapers) ??
          [];
      favoriteWallpaperPaths.addAll(list.map((e) => e.toString()));
      _logger.i('FavoritesService 初始化，已加载收藏: ${favoriteWallpaperPaths.length}');
    } catch (e) {
      _logger.e('FavoritesService 初始化失败: $e');
    }
    return this;
  }

  bool isFavoritePath(String path) => favoriteWallpaperPaths.contains(path);

  Future<void> toggleWallpaper(String path) async {
    if (favoriteWallpaperPaths.contains(path)) {
      favoriteWallpaperPaths.remove(path);
    } else {
      favoriteWallpaperPaths.add(path);
    }
    await _persist();
  }

  Future<void> _persist() async {
    await StorageService.to.save(
      StorageService.keyFavoriteWallpapers,
      favoriteWallpaperPaths.toList(),
    );
  }
}
