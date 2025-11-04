import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:flutter/cupertino.dart';

class MediaService extends GetxService {
  static MediaService get to => Get.find();

  final Logger _logger = Logger();

  Future<MediaService> init() async {
    _logger.i('MediaService 初始化');
    return this;
  }

  Future<bool> _ensurePhotosPermission() async {
    try {
      // iOS 14+ 优先使用 photosAddOnly（只写权限）
      var status = await Permission.photosAddOnly.status;
      _logger.d('photosAddOnly 权限状态: $status');

      if (!status.isGranted) {
        status = await Permission.photosAddOnly.request();
        _logger.d('photosAddOnly 请求后状态: $status');
      }

      // iOS 14+ 可能返回 limited，limited 也可用于保存
      if (status.isGranted || status.isLimited == true) {
        return true;
      }

      // 如果 photosAddOnly 失败，尝试完整的 photos 权限
      var photosStatus = await Permission.photos.status;
      _logger.d('photos 权限状态: $photosStatus');

      if (!photosStatus.isGranted) {
        photosStatus = await Permission.photos.request();
        _logger.d('photos 请求后状态: $photosStatus');
      }

      if (photosStatus.isGranted || photosStatus.isLimited == true) {
        return true;
      }

      // 如果被永久拒绝，提示用户去设置
      if (status.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
        _logger.w('相册权限被永久拒绝');
        await _promptOpenSettings();
      } else {
        _logger.w('相册权限未授予');
        // 再给一次明确提示，引导用户授予
        await _promptOpenSettings(showSettingsButton: false);
      }

      return false;
    } catch (e) {
      _logger.e('检查相册权限失败: $e');
      return false;
    }
  }

  Future<void> _promptOpenSettings({bool showSettingsButton = true}) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text('permission_denied'.tr),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('permission_photos'.tr),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('cancel'.tr),
            onPressed: () => Get.back(),
          ),
          if (showSettingsButton)
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                await openAppSettings();
                Get.back();
              },
              child: Text('permission_open_settings'.tr),
            ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<bool> saveAssetImageToGallery(
    String assetPath, {
    String album = 'Glasso',
  }) async {
    try {
      _logger.d('开始保存图片: $assetPath');

      final granted = await _ensurePhotosPermission();
      if (!granted) {
        _logger.w('权限未授予，取消保存');
        return false;
      }

      _logger.d('权限已授予，开始加载资源');
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      _logger.d('资源加载成功，大小: ${bytes.length} bytes');

      _logger.d('开始保存到相册...');
      await Gal.putImageBytes(bytes, album: album);

      HapticFeedback.mediumImpact();
      _logger.i('✅ 保存到相册成功: $assetPath');

      // 显示成功提示
      Get.snackbar(
        'wallpaper_save_success'.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      _logger.e('❌ 保存到相册失败: $e');

      // 显示失败提示
      Get.snackbar(
        'wallpaper_save_failed'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }
}
