import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

/// 主题模式枚举
enum ThemeMode { light, dark, system }

/// 主题服务
/// 管理应用的主题模式切换（白天/黑夜模式）
class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final Logger _logger = Logger();

  // 当前主题模式（响应式）
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  Future<ThemeService> init() async {
    try {
      // 从本地存储读取主题设置
      final savedMode = StorageService.to.read<String>(
        StorageService.keyThemeMode,
      );
      if (savedMode != null) {
        _themeMode.value = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
      _logger.i('ThemeService 初始化成功，当前主题: ${_themeMode.value.name}');
      return this;
    } catch (e) {
      _logger.e('ThemeService 初始化失败: $e');
      return this;
    }
  }

  /// 切换主题模式
  Future<void> switchTheme(ThemeMode mode) async {
    try {
      _themeMode.value = mode;
      await StorageService.to.save(StorageService.keyThemeMode, mode.name);
      _logger.i('主题已切换为: ${mode.name}');
    } catch (e) {
      _logger.e('切换主题失败: $e');
    }
  }

  /// 是否为深色模式
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.dark) return true;
    if (_themeMode.value == ThemeMode.light) return false;
    // 系统模式：根据系统设置判断
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  /// 切换到下一个主题模式
  Future<void> toggleTheme() async {
    final modes = ThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode.value);
    final nextIndex = (currentIndex + 1) % modes.length;
    await switchTheme(modes[nextIndex]);
  }
}


