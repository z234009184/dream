import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/wallpaper.dart';

class WallpaperRepository {
  static const String baseDir = 'assets/images/wallpapers/';

  Future<List<Wallpaper>> loadWallpapers() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestJson);

    final List<Wallpaper> items = [];

    manifestMap.forEach((assetPath, meta) {
      if (assetPath.startsWith(baseDir) &&
          (assetPath.endsWith('.jpg') ||
              assetPath.endsWith('.jpeg') ||
              assetPath.endsWith('.png') ||
              assetPath.endsWith('.webp'))) {
        final segments = assetPath.replaceFirst(baseDir, '').split('/');
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
