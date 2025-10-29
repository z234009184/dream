import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';

/// 视频控制器管理服务 - 性能优先版本
/// 全局唯一实例，立即释放旧控制器
class VideoControllerService extends GetxService {
  static VideoControllerService get to => Get.find();

  final Logger _logger = Logger();

  VideoPlayerController? _controller;
  String? _currentPath;

  /// 切换视频（立即释放旧的）
  Future<VideoPlayerController?> switchTo(String assetPath) async {
    // 立即释放旧控制器
    _releaseSync();

    _logger.d('创建视频控制器: $assetPath');
    _controller = VideoPlayerController.asset(assetPath);
    _currentPath = assetPath;

    try {
      await _controller!.initialize();
      _logger.d('视频初始化成功: $assetPath');
      return _controller;
    } catch (e) {
      _logger.e('视频初始化失败: $e');
      _releaseSync();
      return null;
    }
  }

  /// 同步释放（立即执行）
  void _releaseSync() {
    if (_controller != null) {
      _logger.d('释放视频控制器: $_currentPath');
      try {
        // 先暂停再释放
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        }
        _controller!.dispose();
      } catch (e) {
        _logger.w('释放控制器时出错: $e');
      }
      _controller = null;
      _currentPath = null;
    }
  }

  /// 释放当前控制器
  void release() {
    _releaseSync();
  }

  @override
  void onClose() {
    _releaseSync();
    super.onClose();
  }
}
