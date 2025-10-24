import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class MediaService extends GetxService {
  static MediaService get to => Get.find();

  final Logger _logger = Logger();

  Future<MediaService> init() async {
    _logger.i('MediaService 初始化');
    return this;
  }

  Future<bool> _ensurePhotosPermission() async {
    // iOS 优先使用 photosAddOnly，其次 photos；Android 使用 storage/mediaLibrary 视实际而定
    var status = await Permission.photosAddOnly.status;
    if (!status.isGranted) {
      status = await Permission.photosAddOnly.request();
    }
    if (!status.isGranted) {
      // 尝试退化到 photos
      var alt = await Permission.photos.status;
      if (!alt.isGranted) {
        alt = await Permission.photos.request();
      }
      if (!alt.isGranted) {
        _logger.w('相册权限未授予');
        return false;
      }
    }
    return true;
  }

  Future<bool> saveAssetImageToGallery(
    String assetPath, {
    String album = 'Glasso',
  }) async {
    try {
      final granted = await _ensurePhotosPermission();
      if (!granted) return false;

      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();

      await Gal.putImageBytes(bytes, album: album);
      HapticFeedback.selectionClick();
      _logger.i('保存到相册成功: $assetPath');
      return true;
    } catch (e) {
      _logger.e('保存到相册失败: $e');
      return false;
    }
  }
}
