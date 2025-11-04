import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/mood.dart';
import '../../../data/models/favorite_mood.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../../services/video_controller_service.dart';
import '../../../services/favorites_service.dart';

/// 心情详情页控制器
class MoodDetailController extends GetxController {
  final Logger _logger = Logger();
  final WallpaperRepository _wallpaperRepo = WallpaperRepository();
  final FavoritesService _favoritesService = FavoritesService.to;

  // 当前心情
  late final Mood mood;

  // 候选壁纸列表
  final candidateWallpapers = <String>[].obs;

  // 当前壁纸索引
  final currentWallpaperIndex = 0.obs;

  // 是否显示操作菜单
  final showMenu = false.obs;

  // 视差滚动偏移
  final parallaxOffset = 0.0.obs;

  // 是否已收藏
  final isFavorite = false.obs;

  // 当前显示的壁纸路径
  String get currentWallpaper => candidateWallpapers.isEmpty
      ? ''
      : candidateWallpapers[currentWallpaperIndex.value];

  // 判断是否为视频
  bool get isVideo {
    if (currentWallpaper.isEmpty) return false;
    final ext = currentWallpaper.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov');
  }

  @override
  void onInit() {
    super.onInit();
    _logger.d('MoodDetailController 初始化');

    // 从路由参数获取心情数据
    mood = Get.arguments as Mood;

    // 检查收藏状态
    isFavorite.value = _favoritesService.isFavoriteMood(mood.id);

    // 加载匹配的壁纸
    _loadMatchedWallpapers();
  }

  @override
  void onClose() {
    _logger.d('MoodDetailController 关闭');
    // 释放视频控制器
    VideoControllerService.to.release();
    super.onClose();
  }

  /// 加载匹配的壁纸
  Future<void> _loadMatchedWallpapers() async {
    final allWallpapers = await _wallpaperRepo.loadWallpapers();
    _logger.d('所有壁纸数量: ${allWallpapers.length}');

    // 根据心情分类匹配壁纸主题
    final matchedPaths = _matchWallpapersByCategory(
      mood.category,
      allWallpapers,
    );

    if (matchedPaths.isEmpty) {
      _logger.w('未找到匹配的壁纸，使用渐变背景');
      candidateWallpapers.value = [];
    } else {
      candidateWallpapers.value = matchedPaths;
      _logger.d('匹配到 ${matchedPaths.length} 张壁纸');
    }
  }

  /// 根据心情分类匹配壁纸主题
  List<String> _matchWallpapersByCategory(
    String category,
    List<dynamic> allWallpapers,
  ) {
    // 心情分类到壁纸主题的映射
    final categoryThemeMap = {
      '心情语录': ['gradient', 'aesthetic'], // 心情 → 渐变/美学
      '励志语录': ['gradient', 'minimal'], // 励志 → 渐变/简约
      '经典台词': ['aesthetic', 'abstract'], // 台词 → 美学/抽象
      '名人名言': ['minimal', 'abstract'], // 名言 → 简约/抽象
      '爱情语录': ['gradient', 'aesthetic'], // 爱情 → 渐变/美学
      '人生感悟': ['minimal', 'aesthetic'], // 人生 → 简约/美学
      '精美译文': ['aesthetic', 'minimal'], // 译文 → 美学/简约
    };

    final themes = categoryThemeMap[category];

    if (themes != null) {
      // 筛选匹配主题的壁纸
      final matched = allWallpapers
          .where((wallpaper) {
            final path = wallpaper.path as String;
            return themes.any((theme) => path.contains('/wallpapers/$theme/'));
          })
          .map((w) => w.path as String)
          .toList();

      // 打乱顺序
      matched.shuffle();

      if (matched.isNotEmpty) {
        _logger.d('分类 "$category" 匹配到主题 $themes，壁纸数量: ${matched.length}');
        return matched;
      }
    }

    // 如果没有匹配或主题不存在，随机返回所有壁纸
    _logger.d('分类 "$category" 未匹配到主题，使用随机壁纸');
    final randomList = allWallpapers.map((w) => w.path as String).toList();
    randomList.shuffle();
    return randomList;
  }

  /// 切换到下一张壁纸
  void nextWallpaper() {
    if (candidateWallpapers.isEmpty) return;

    // 释放当前视频控制器
    if (isVideo) {
      VideoControllerService.to.release();
    }

    currentWallpaperIndex.value =
        (currentWallpaperIndex.value + 1) % candidateWallpapers.length;

    _logger.d(
      '切换到壁纸: ${currentWallpaperIndex.value}/${candidateWallpapers.length}',
    );
    HapticFeedback.selectionClick();
  }

  /// 切换到上一张壁纸
  void previousWallpaper() {
    if (candidateWallpapers.isEmpty) return;

    // 释放当前视频控制器
    if (isVideo) {
      VideoControllerService.to.release();
    }

    currentWallpaperIndex.value =
        (currentWallpaperIndex.value - 1 + candidateWallpapers.length) %
        candidateWallpapers.length;

    _logger.d(
      '切换到壁纸: ${currentWallpaperIndex.value}/${candidateWallpapers.length}',
    );
    HapticFeedback.selectionClick();
  }

  /// 保存头像到相册
  Future<void> saveAvatar() async {
    try {
      _logger.d('保存头像: ${mood.avatarPath}');

      if (mood.avatarPath == null || mood.avatarPath!.isEmpty) {
        _showMessage('没有可保存的头像');
        return;
      }

      // 请求权限
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showMessage('需要相册权限');
        return;
      }

      // 加载图片数据
      final byteData = await rootBundle.load(mood.avatarPath!);
      final buffer = byteData.buffer.asUint8List();

      // 保存到相册
      await Gal.putImageBytes(buffer);

      _showMessage('头像已保存');
      HapticFeedback.mediumImpact();
    } catch (e) {
      _logger.e('保存头像失败: $e');
      _showMessage('保存失败');
    }
  }

  /// 保存壁纸到相册
  Future<void> saveWallpaper() async {
    try {
      if (currentWallpaper.isEmpty) {
        _showMessage('没有可保存的壁纸');
        return;
      }

      _logger.d('保存壁纸: $currentWallpaper');

      // 请求权限
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showMessage('需要相册权限');
        return;
      }

      // 加载壁纸数据
      final byteData = await rootBundle.load(currentWallpaper);
      final buffer = byteData.buffer.asUint8List();

      // 保存为图片（视频也使用 putImageBytes）
      await Gal.putImageBytes(buffer);

      _showMessage('壁纸已保存');
      HapticFeedback.mediumImpact();
    } catch (e) {
      _logger.e('保存壁纸失败: $e');
      _showMessage('保存失败');
    }
  }

  /// 复制心情文字
  Future<void> copyMoodText() async {
    try {
      await Clipboard.setData(ClipboardData(text: mood.text));
      _showMessage('已复制到剪贴板');
      HapticFeedback.mediumImpact();
      _logger.d('复制心情文字: ${mood.text}');
    } catch (e) {
      _logger.e('复制失败: $e');
      _showMessage('复制失败');
    }
  }

  /// 显示提示消息
  void _showMessage(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemGrey.withOpacity(0.9),
      colorText: CupertinoColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// 更新视差滚动偏移
  void updateParallaxOffset(double offset) {
    parallaxOffset.value = offset * 0.5; // 50% 速度
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    try {
      // 创建收藏数据
      final favoriteMood = FavoriteMood.fromMood(
        moodId: mood.id,
        text: mood.text,
        category: mood.category,
        avatarPath: mood.avatarPath,
        wallpaperPath: currentWallpaper.isNotEmpty
            ? currentWallpaper
            : '', // 如果没有壁纸则为空
        color: mood.color,
        bgColor: mood.bgColor,
      );

      // 切换收藏状态
      final isNowFavorite = await _favoritesService.toggleMood(favoriteMood);
      isFavorite.value = isNowFavorite;

      // 触觉反馈
      HapticFeedback.mediumImpact();

      _logger.d('收藏状态: $isNowFavorite');
    } catch (e) {
      _logger.e('切换收藏失败: $e');
      _showMessage('操作失败');
    }
  }
}
