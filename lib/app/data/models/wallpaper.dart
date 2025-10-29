/// 媒体类型枚举
enum MediaType {
  image, // 静态图片 (JPG/PNG)
  gif, // 动图
  video, // 视频 (MP4/MOV)
}

class Wallpaper {
  final String path; // assets 路径
  final String topic; // 主题，如 nature/minimal
  final String name; // 文件名
  final int? width;
  final int? height;
  bool isFavorite;

  Wallpaper({
    required this.path,
    required this.topic,
    required this.name,
    this.width,
    this.height,
    this.isFavorite = false,
  });

  /// 根据文件扩展名判断媒体类型
  MediaType get mediaType {
    final ext = path.toLowerCase();
    if (ext.endsWith('.gif')) return MediaType.gif;
    if (ext.endsWith('.mp4') || ext.endsWith('.mov')) return MediaType.video;
    return MediaType.image;
  }

  /// 是否为动态内容（GIF 或视频）
  bool get isAnimated =>
      mediaType == MediaType.gif || mediaType == MediaType.video;
}
