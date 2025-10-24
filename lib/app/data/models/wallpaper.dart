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
}
