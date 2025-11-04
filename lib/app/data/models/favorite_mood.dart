import 'package:flutter/cupertino.dart';
import 'mood.dart';

/// 收藏的心情数据模型
///
/// 保存用户收藏的心情完整信息，包括心情文本、分类、头像、壁纸和收藏时间
class FavoriteMood {
  /// 心情 ID
  final String moodId;

  /// 心情文本内容
  final String text;

  /// 心情分类
  final String category;

  /// 头像路径（可选）
  final String? avatarPath;

  /// 收藏时显示的壁纸路径
  final String wallpaperPath;

  /// 收藏时间
  final DateTime savedAt;

  /// 主题色（用于卡片展示）
  final Color color;

  /// 背景色（用于卡片展示）
  final Color bgColor;

  const FavoriteMood({
    required this.moodId,
    required this.text,
    required this.category,
    this.avatarPath,
    required this.wallpaperPath,
    required this.savedAt,
    required this.color,
    required this.bgColor,
  });

  /// 从 JSON 反序列化
  factory FavoriteMood.fromJson(Map<String, dynamic> json) {
    return FavoriteMood(
      moodId: json['moodId'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      avatarPath: json['avatarPath'] as String?,
      wallpaperPath: json['wallpaperPath'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      color: Color(json['color'] as int),
      bgColor: Color(json['bgColor'] as int),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'moodId': moodId,
      'text': text,
      'category': category,
      'avatarPath': avatarPath,
      'wallpaperPath': wallpaperPath,
      'savedAt': savedAt.toIso8601String(),
      'color': color.value,
      'bgColor': bgColor.value,
    };
  }

  /// 从 Mood 对象创建收藏数据
  factory FavoriteMood.fromMood({
    required String moodId,
    required String text,
    required String category,
    String? avatarPath,
    required String wallpaperPath,
    required Color color,
    required Color bgColor,
  }) {
    return FavoriteMood(
      moodId: moodId,
      text: text,
      category: category,
      avatarPath: avatarPath,
      wallpaperPath: wallpaperPath,
      savedAt: DateTime.now(),
      color: color,
      bgColor: bgColor,
    );
  }

  /// 转换为 Mood 对象（用于跳转到详情页）
  Mood toMood() {
    // 根据分类获取对应的图标
    IconData icon;
    switch (category) {
      case '心情语录':
        icon = CupertinoIcons.chat_bubble_text_fill;
        break;
      case '励志语录':
        icon = CupertinoIcons.flame_fill;
        break;
      case '经典台词':
        icon = CupertinoIcons.film_fill;
        break;
      case '名人名言':
        icon = CupertinoIcons.book_fill;
        break;
      case '爱情语录':
        icon = CupertinoIcons.heart_fill;
        break;
      case '人生感悟':
        icon = CupertinoIcons.lightbulb_fill;
        break;
      case '精美译文':
        icon = CupertinoIcons.textformat_alt;
        break;
      default:
        icon = CupertinoIcons.chat_bubble_text_fill;
    }

    return Mood(
      id: moodId,
      text: text,
      category: category,
      color: color,
      bgColor: bgColor,
      icon: icon,
      avatarPath: avatarPath,
      author: '', // 收藏数据不保存作者信息
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteMood && other.moodId == moodId;
  }

  @override
  int get hashCode => moodId.hashCode;
}
