import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 视频缩略图缓存服务
/// 使用原生 iOS 代码生成视频首帧，并全局缓存
class VideoThumbnailCacheService extends GetxService {
  static VideoThumbnailCacheService get to => Get.find();

  final Logger _logger = Logger();
  static const _channel = MethodChannel('com.glasso/video_thumbnail');

  // 缩略图缓存 {videoPath: thumbnailData}
  final Map<String, Uint8List> _cache = {};

  // 正在加载的任务 {videoPath: Future}
  final Map<String, Future<Uint8List?>> _loadingTasks = {};

  /// 获取视频缩略图（带缓存）
  Future<Uint8List?> getThumbnail(
    String videoPath, {
    int maxWidth = 400,
  }) async {
    // 如果已缓存，直接返回
    if (_cache.containsKey(videoPath)) {
      _logger.d('缩略图缓存命中: $videoPath');
      return _cache[videoPath];
    }

    // 如果正在加载，等待加载完成
    if (_loadingTasks.containsKey(videoPath)) {
      _logger.d('等待缩略图加载: $videoPath');
      return await _loadingTasks[videoPath];
    }

    // 开始新的加载任务
    final task = _generateThumbnail(videoPath, maxWidth: maxWidth);
    _loadingTasks[videoPath] = task;

    try {
      final thumbnail = await task;
      if (thumbnail != null) {
        _cache[videoPath] = thumbnail;
        _logger.d('缩略图生成成功: $videoPath (${thumbnail.length} bytes)');
      }
      return thumbnail;
    } finally {
      _loadingTasks.remove(videoPath);
    }
  }

  /// 使用原生代码生成视频缩略图
  Future<Uint8List?> _generateThumbnail(
    String videoPath, {
    int maxWidth = 400,
  }) async {
    try {
      _logger.d('开始生成视频缩略图: $videoPath');

      final result = await _channel.invokeMethod('getThumbnail', {
        'videoPath': videoPath,
        'maxWidth': maxWidth,
      });

      if (result is Uint8List) {
        return result;
      } else {
        _logger.w('视频缩略图返回类型错误: ${result.runtimeType}');
        return null;
      }
    } on PlatformException catch (e) {
      _logger.e('生成视频缩略图失败: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _logger.e('生成视频缩略图异常: $e');
      return null;
    }
  }

  /// 预加载视频缩略图（后台异步）
  void preload(String videoPath, {int maxWidth = 400}) {
    if (!_cache.containsKey(videoPath) &&
        !_loadingTasks.containsKey(videoPath)) {
      getThumbnail(videoPath, maxWidth: maxWidth).catchError((e) {
        _logger.w('预加载视频缩略图失败: $videoPath');
        return null;
      });
    }
  }

  /// 获取缓存中的缩略图（同步）
  Uint8List? getCached(String videoPath) {
    return _cache[videoPath];
  }

  /// 检查是否已缓存
  bool isCached(String videoPath) {
    return _cache.containsKey(videoPath);
  }

  /// 清除指定缩略图缓存
  void remove(String videoPath) {
    _cache.remove(videoPath);
    _logger.d('已清除缩略图缓存: $videoPath');
  }

  /// 清除所有缓存
  void clearAll() {
    final count = _cache.length;
    _cache.clear();
    _logger.d('已清除所有缩略图缓存: $count 个');
  }

  /// 获取缓存大小
  int getCacheSize() {
    return _cache.length;
  }

  /// 获取缓存内存占用（估算）
  int getCacheMemoryUsage() {
    int total = 0;
    for (final data in _cache.values) {
      total += data.length;
    }
    return total;
  }

  @override
  void onClose() {
    _cache.clear();
    _loadingTasks.clear();
    super.onClose();
  }
}
