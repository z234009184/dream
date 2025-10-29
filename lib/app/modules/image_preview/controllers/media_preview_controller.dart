import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import '../../../services/video_controller_service.dart';

/// 媒体预览控制器
/// 负责管理预览页面的状态和视频播放
class MediaPreviewController extends GetxController {
  final Logger _logger = Logger();

  // 当前显示的页面索引
  final currentIndex = 0.obs;

  // 媒体列表
  late final List<String> mediaList;

  // 当前是否为视频
  bool get isCurrentVideo => _isVideo(mediaList[currentIndex.value]);

  // 当前媒体路径
  String get currentPath => mediaList[currentIndex.value];

  // 视频控制器
  Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(null);

  @override
  void onInit() {
    super.onInit();

    // 从路由参数获取媒体列表和初始索引
    final args = Get.arguments as Map<String, dynamic>;
    mediaList = args['mediaList'] as List<String>;
    currentIndex.value = args['initialIndex'] as int;

    _logger.d('MediaPreviewController 初始化，媒体数量: ${mediaList.length}');

    // 监听页面切换
    ever(currentIndex, (_) {
      _onPageChanged();
    });

    // 初始化当前媒体
    _onPageChanged();
  }

  @override
  void onClose() {
    _logger.d('MediaPreviewController 关闭，释放视频控制器');
    // 🔥 关闭预览时，立即释放视频控制器
    VideoControllerService.to.release();
    videoController.value = null;
    super.onClose();
  }

  /// 页面切换回调
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// 处理页面切换
  Future<void> _onPageChanged() async {
    final path = currentPath;
    _logger.d('切换到媒体: $path');

    if (_isVideo(path)) {
      // 🔥 如果是视频，切换到这个视频
      await _loadVideo(path);
    } else {
      // 🔥 如果是图片，释放视频控制器
      VideoControllerService.to.release();
      videoController.value = null;
    }
  }

  /// 加载视频
  Future<void> _loadVideo(String path) async {
    try {
      _logger.d('开始加载视频: $path');
      final controller = await VideoControllerService.to.switchTo(path);
      videoController.value = controller;
      _logger.d('视频加载成功: $path');
    } catch (e) {
      _logger.e('视频加载失败: $e');
      videoController.value = null;
    }
  }

  /// 判断是否为视频
  bool _isVideo(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov');
  }
}
