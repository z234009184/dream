import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:video_player/video_player.dart';
import '../data/models/wallpaper.dart';
import '../services/video_controller_service.dart';
import '../services/video_thumbnail_cache_service.dart';
import 'video_player_widget.dart';

/// 统一的媒体查看器组件
/// 根据媒体类型自动选择合适的展示方式
class MediaViewer extends StatefulWidget {
  const MediaViewer({
    super.key,
    required this.path,
    required this.mediaType,
    this.fit = BoxFit.cover,
    this.enableGesture = false,
    this.minScale = 0.8,
    this.maxScale = 3.0,
    this.cacheWidth,
    this.onScaleEnd,
  });

  final String path;
  final MediaType mediaType;
  final BoxFit fit;
  final bool enableGesture; // 是否启用手势（缩放、平移）
  final double minScale;
  final double maxScale;
  final int? cacheWidth;
  final GestureScaleEndCallback? onScaleEnd;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  Uint8List? _videoThumbnail; // 视频缩略图

  @override
  void initState() {
    super.initState();

    if (widget.mediaType == MediaType.video) {
      // 先尝试获取已缓存的缩略图
      _videoThumbnail = VideoThumbnailCacheService.to.getCached(widget.path);

      if (widget.enableGesture) {
        // 预览模式：加载视频控制器
        _initVideoController();
      } else {
        // 列表模式：加载视频缩略图
        _loadThumbnail();
      }
    }
  }

  @override
  void didUpdateWidget(MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.path != oldWidget.path && widget.mediaType == MediaType.video) {
      if (widget.enableGesture) {
        // 预览模式：重新加载控制器
        _initVideoController();
      } else {
        // 列表模式：重新加载缩略图
        _loadThumbnail();
      }
    }
  }

  /// 加载视频缩略图（列表模式）
  Future<void> _loadThumbnail() async {
    try {
      final thumbnail = await VideoThumbnailCacheService.to.getThumbnail(
        widget.path,
        maxWidth: widget.cacheWidth ?? 400,
      );

      if (mounted && thumbnail != null) {
        setState(() {
          _videoThumbnail = thumbnail;
        });
      }
    } catch (e) {
      // 加载失败，忽略
    }
  }

  /// 初始化视频控制器（预览模式）
  Future<void> _initVideoController() async {
    final controller = await VideoControllerService.to.switchTo(widget.path);
    if (mounted) {
      setState(() {
        _videoController = controller;
      });
    }
  }

  @override
  void dispose() {
    // 🔥 清理视频控制器引用
    _videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mediaType) {
      case MediaType.gif:
      case MediaType.image:
        return _buildImage();
      case MediaType.video:
        return _buildVideo();
    }
  }

  /// 构建图片/GIF 查看器
  Widget _buildImage() {
    if (widget.enableGesture) {
      // 预览模式：支持手势缩放
      return ExtendedImage.asset(
        widget.path,
        mode: ExtendedImageMode.gesture,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        initGestureConfigHandler: (state) {
          return GestureConfig(
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            animationMinScale: widget.minScale * 0.8,
            animationMaxScale: widget.maxScale * 1.2,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false,
            initialAlignment: InitialAlignment.center,
          );
        },
        onDoubleTap: (state) {
          // 双击缩放
          final pointerDownPosition = state.pointerDownPosition;
          final begin = state.gestureDetails!.totalScale!;
          double end;

          if (begin == 1.0) {
            end = 2.0;
          } else if (begin > 1.99 && begin < 2.01) {
            end = 3.0;
          } else {
            end = 1.0;
          }

          state.handleDoubleTap(
            scale: end,
            doubleTapPosition: pointerDownPosition,
          );
        },
        loadStateChanged: (state) {
          // 移除 loading 状态，让过渡更丝滑
          if (state.extendedImageLoadState == LoadState.failed) {
            return const Center(
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: CupertinoColors.systemGrey,
                size: 48,
              ),
            );
          }
          return null;
        },
      );
    } else {
      // 列表模式：简单展示，不显示 loading
      return ExtendedImage.asset(
        widget.path,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        // 移除 loadStateChanged，让图片直接显示
      );
    }
  }

  /// 构建视频播放器
  Widget _buildVideo() {
    // 列表模式：显示视频首帧缩略图
    if (!widget.enableGesture) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // 缩略图或占位背景
          if (_videoThumbnail != null)
            Image.memory(
              _videoThumbnail!,
              fit: widget.fit,
              gaplessPlayback: true,
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CupertinoColors.systemGrey6.resolveFrom(context),
                    CupertinoColors.systemGrey5.resolveFrom(context),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // 预览模式：显示缩略图 + 视频播放器
    return Stack(
      fit: StackFit.expand,
      children: [
        // 底层：缩略图占位
        if (_videoThumbnail != null)
          Image.memory(
            _videoThumbnail!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),

        // 顶层：视频播放器
        VideoPlayerWidget(controller: _videoController),
      ],
    );
  }
}
