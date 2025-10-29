import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/wallpaper.dart';

class WallpaperRepository {
  static const String imageDirParent = 'assets/images/wallpapers/';
  static const String videoDirParent = 'assets/videos/';

  Future<List<Wallpaper>> loadWallpapers() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestJson);

    final List<Wallpaper> items = [];

    manifestMap.forEach((assetPath, meta) {
      // 检查是否为图片壁纸
      if (assetPath.startsWith(imageDirParent) &&
          (assetPath.endsWith('.jpg') ||
              assetPath.endsWith('.jpeg') ||
              assetPath.endsWith('.png') ||
              assetPath.endsWith('.webp') ||
              assetPath.endsWith('.gif'))) {
        final segments = assetPath.replaceFirst(imageDirParent, '').split('/');
        if (segments.length >= 2) {
          final topic = segments[0];
          final name = segments.last;
          items.add(Wallpaper(path: assetPath, topic: topic, name: name));
        }
      }

      // 检查是否为视频壁纸（排除缩略图）
      if (assetPath.startsWith(videoDirParent) &&
          !assetPath.contains('/thumbnails/') &&
          (assetPath.endsWith('.mp4') || assetPath.endsWith('.mov'))) {
        final segments = assetPath.replaceFirst(videoDirParent, '').split('/');
        if (segments.length >= 2) {
          final topic = segments[0];
          final name = segments.last;
          items.add(Wallpaper(path: assetPath, topic: topic, name: name));
        }
      }
    });

    // 简单排序：按主题、文件名
    items.sort((a, b) {
      final t = a.topic.compareTo(b.topic);
      if (t != 0) return t;
      return a.name.compareTo(b.name);
    });

    return items;
  }
}
