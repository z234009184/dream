import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// 头像资源仓库
class AvatarRepository {
  static final AvatarRepository _instance = AvatarRepository._internal();
  factory AvatarRepository() => _instance;
  AvatarRepository._internal();

  List<String> _avatarPaths = [];
  bool _isLoaded = false;

  /// 加载所有头像资源
  Future<void> loadAvatars() async {
    if (_isLoaded) return;

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      _avatarPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/images/avatars/'))
          .where(
            (String key) =>
                key.endsWith('.jpg') ||
                key.endsWith('.png') ||
                key.endsWith('.jpeg'),
          )
          .toList();

      _isLoaded = true;
      print('✅ 已加载 ${_avatarPaths.length} 张头像');
    } catch (e) {
      print('⚠️  加载头像失败: $e');
    }
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
    return _avatarPaths[index % _avatarPaths.length];
  }

  /// 根据主题获取头像
  List<String> getAvatarsByTheme(String theme) {
    return _avatarPaths.where((path) => path.contains('/$theme/')).toList();
  }

  /// 获取所有头像
  List<String> getAllAvatars() => List.from(_avatarPaths);
}
