import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../data/models/favorite_mood.dart';
import 'storage_service.dart';

/// 收藏服务
///
/// 管理壁纸和心情的收藏状态，使用本地存储持久化数据
class FavoritesService extends GetxService {
  static FavoritesService get to => Get.find();

  final Logger _logger = Logger();

  // 壁纸收藏（路径列表）
  final RxSet<String> favoriteWallpaperPaths = <String>{}.obs;

  // 心情收藏（完整数据）
  final RxList<FavoriteMood> favoriteMoods = <FavoriteMood>[].obs;

  /// 初始化服务
  Future<FavoritesService> init() async {
    try {
      // 加载壁纸收藏
      final wallpaperList =
          StorageService.to.read<List>(StorageService.keyFavoriteWallpapers) ??
          [];
      favoriteWallpaperPaths.addAll(wallpaperList.map((e) => e.toString()));

      // 加载心情收藏
      final moodList =
          StorageService.to.read<List>(StorageService.keyFavoriteMoods) ?? [];
      favoriteMoods.addAll(
        moodList.map((e) => FavoriteMood.fromJson(e as Map<String, dynamic>)),
      );

      _logger.i('FavoritesService 初始化完成');
      _logger.i('- 壁纸收藏: ${favoriteWallpaperPaths.length}');
      _logger.i('- 心情收藏: ${favoriteMoods.length}');
    } catch (e) {
      _logger.e('FavoritesService 初始化失败: $e');
    }
    return this;
  }

  // ========== 壁纸收藏 ==========

  /// 判断壁纸是否已收藏
  bool isFavoritePath(String path) => favoriteWallpaperPaths.contains(path);

  /// 切换壁纸收藏状态
  Future<void> toggleWallpaper(String path) async {
    if (favoriteWallpaperPaths.contains(path)) {
      favoriteWallpaperPaths.remove(path);
      _logger.d('取消收藏壁纸: $path');
    } else {
      favoriteWallpaperPaths.add(path);
      _logger.d('收藏壁纸: $path');
    }
    await _persistWallpapers();
  }

  /// 持久化壁纸收藏
  Future<void> _persistWallpapers() async {
    await StorageService.to.save(
      StorageService.keyFavoriteWallpapers,
      favoriteWallpaperPaths.toList(),
    );
  }

  // ========== 心情收藏 ==========

  /// 判断心情是否已收藏
  bool isFavoriteMood(String moodId) {
    return favoriteMoods.any((m) => m.moodId == moodId);
  }

  /// 切换心情收藏状态
  ///
  /// 返回值：true 表示已收藏，false 表示已取消收藏
  Future<bool> toggleMood(FavoriteMood mood) async {
    final index = favoriteMoods.indexWhere((m) => m.moodId == mood.moodId);

    if (index >= 0) {
      // 取消收藏
      favoriteMoods.removeAt(index);
      _logger.d('取消收藏心情: ${mood.moodId}');
      await _persistMoods();
      return false;
    } else {
      // 添加收藏（插入到列表头部，保持按时间倒序）
      favoriteMoods.insert(0, mood);
      _logger.d('收藏心情: ${mood.moodId}');
      await _persistMoods();
      return true;
    }
  }

  /// 删除心情收藏
  Future<void> removeMood(String moodId) async {
    favoriteMoods.removeWhere((m) => m.moodId == moodId);
    _logger.d('删除心情收藏: $moodId');
    await _persistMoods();
  }

  /// 持久化心情收藏
  Future<void> _persistMoods() async {
    await StorageService.to.save(
      StorageService.keyFavoriteMoods,
      favoriteMoods.map((m) => m.toJson()).toList(),
    );
  }

  @override
  void onClose() {
    _logger.d('FavoritesService 关闭');
    super.onClose();
  }
}
