import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

/// 本地存储服务
/// 使用 GetStorage 管理本地数据持久化
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late final GetStorage _box;
  final Logger _logger = Logger();

  // 存储键常量
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyFavoriteWallpapers = 'favorite_wallpapers';
  static const String keyFavoriteQuotes = 'favorite_quotes';

  Future<StorageService> init() async {
    try {
      await GetStorage.init();
      _box = GetStorage();
      _logger.i('StorageService 初始化成功');
      return this;
    } catch (e) {
      _logger.e('StorageService 初始化失败: $e');
      rethrow;
    }
  }

  /// 保存数据
  Future<void> save(String key, dynamic value) async {
    try {
      await _box.write(key, value);
      _logger.d('保存数据: $key = $value');
    } catch (e) {
      _logger.e('保存数据失败: $e');
    }
  }

  /// 读取数据
  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      _logger.e('读取数据失败: $e');
      return null;
    }
  }

  /// 删除数据
  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
      _logger.d('删除数据: $key');
    } catch (e) {
      _logger.e('删除数据失败: $e');
    }
  }

  /// 清空所有数据
  Future<void> clear() async {
    try {
      await _box.erase();
      _logger.w('清空所有本地数据');
    } catch (e) {
      _logger.e('清空数据失败: $e');
    }
  }

  /// 检查是否是首次启动
  bool get isFirstLaunch => read<bool>(keyFirstLaunch) ?? true;

  /// 设置已启动标记
  Future<void> setLaunched() async {
    await save(keyFirstLaunch, false);
  }
}


