import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../services/theme_service.dart';
import '../../../services/storage_service.dart';

/// 个人中心控制器
class ProfileController extends GetxController {
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _logger.i('ProfileController 初始化');
  }

  /// 切换主题
  Future<void> switchTheme(ThemeMode mode) async {
    await ThemeService.to.switchTheme(mode);
    update();
  }

  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    try {
      // 保存语言设置
      await StorageService.to.save(StorageService.keyLocale, languageCode);

      // 更新应用语言
      if (languageCode == 'zh') {
        Get.updateLocale(const Locale('zh', 'CN'));
      } else {
        Get.updateLocale(const Locale('en', 'US'));
      }

      _logger.i('语言已切换为: $languageCode');
    } catch (e) {
      _logger.e('切换语言失败: $e');
    }
  }

  @override
  void onClose() {
    _logger.i('ProfileController 销毁');
    super.onClose();
  }
}
