import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

/// 视频播放器组件 - 性能优先版本
/// 只负责显示，不管理控制器生命周期
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _startPlayback();
    }
  }

  void _startPlayback() {
    final controller = widget.controller;
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.hasError) {
      controller.setLooping(true);
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) {
      return Container(color: CupertinoColors.black);
    }

    return Container(
      color: CupertinoColors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
