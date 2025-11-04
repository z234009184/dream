import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/avatar.dart';

/// 头像资源仓库
class AvatarRepository {
  final Logger _logger = Logger();

  static final AvatarRepository _instance = AvatarRepository._internal();
  factory AvatarRepository() => _instance;
  AvatarRepository._internal();

  List<String> _avatarPaths = [];

  /// 递归读取 assets/images/avatars 目录所有图片文件
  Future<List<Avatar>> loadAvatars() async {
    _logger.i('正在加载 AssetManifest.json...');
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    _logger.d('开始扫描资源，寻找路径为 "assets/images/avatars/" 的头像...');

    final List<String> avatarPaths = manifestMap.keys
        .where((path) => path.startsWith('assets/images/avatars/'))
        .where(
          (path) =>
              path.endsWith('.png') ||
              path.endsWith('.jpg') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.webp'),
        )
        .toList();

    if (avatarPaths.isEmpty) {
      _logger.w(
        '警告：在 AssetManifest.json 中未找到任何以 "assets/images/avatars/" 开头的资源。',
      );
      _logger.d('--- AssetManifest.json 中包含的全部资源路径 (部分示例) ---');
      manifestMap.keys.take(20).forEach((key) => _logger.d(key));
      _logger.d('----------------------------------------------------');
      _avatarPaths = [];
      return [];
    }

    // 写入缓存供其他模块（如 MoodRepository）按索引或随机获取
    _avatarPaths = avatarPaths;

    final List<Avatar> avatars = avatarPaths
        .map((p) => Avatar(path: p))
        .toList();
    _logger.i('扫描完成！找到了 ${avatars.length} 个头像。');
    return avatars;
  }

  /// 获取随机头像路径
  String? getRandomAvatar() {
    if (_avatarPaths.isEmpty) return null;
    final random = Random();
    return _avatarPaths[random.nextInt(_avatarPaths.length)];
  }

  /// 根据索引获取头像（用于固定分配）
  String? getAvatarByIndex(int index) {
    if (_avatarPaths.isEmpty) return null;
    final i = index % _avatarPaths.length;
    return _avatarPaths[i];
  }
}
