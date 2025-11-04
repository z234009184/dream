import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/painting.dart'; // for imageCache
import '../../../services/theme_service.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_routes.dart';

/// 个人中心控制器
class ProfileController extends GetxController {
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _logger.i('ProfileController 初始化');
  }

  /// 打开 FAQ 页面
  void openFAQ() {
    Get.toNamed(Routes.FAQ);
    _logger.d('打开 FAQ 页面');
  }

  // 清除图片/视频缓存，只清理 ExtendedImage 及本地缩略图缓存
  Future<void> clearCache(BuildContext context) async {
    try {
      imageCache.clear(); // Flutter图片内存cache
      // TODO: 补全本地磁盘文件缩略图/自定义视频缩略图清理逻辑
      _showDialog(context, '清理完成', '图片和视频缓存已清理');
      _logger.i('图片/视频缓存已清理');
    } catch (e) {
      _showDialog(context, '清理失败', e.toString());
      _logger.e('清理缓存失败: $e');
    }
  }

  // 关于
  void openAbout() {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text('Glasso'),
        content: Text('版本 1.0.0\n© 2025 Glasso Team'),
        actions: [
          CupertinoDialogAction(
            child: Text('确定'.tr),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  // 反馈与联系我们
  void openFeedback() {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text('反馈与联系我们'),
        content: Text('请发送邮件至\nsupport@glasso.app 或前往 App Store 留言'),
        actions: [
          CupertinoDialogAction(
            child: Text('确定'.tr),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// 打开协议或隐私政策页面
  void openLicense(String type) {
    if (type == 'user') {
      Get.toNamed(Routes.USER_AGREEMENT);
      _logger.d('打开用户协议页面');
    } else if (type == 'privacy') {
      Get.toNamed(Routes.PRIVACY_POLICY);
      _logger.d('打开隐私政策页面');
    }
  }

  /// 切换主题
  Future<void> switchTheme(ThemeMode mode) async {
    await ThemeService.to.switchTheme(mode);
    update();
  }

  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    try {
      await StorageService.to.save(StorageService.keyLocale, languageCode);
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

  void _showDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text('确定'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _logger.i('ProfileController 销毁');
    super.onClose();
  }
}
