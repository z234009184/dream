import 'package:flutter/cupertino.dart';

/// 心情数据模型
class Mood {
  final String id;
  final String text;
  final String category;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String author;
  final String? avatarPath; // 头像路径（可选）

  Mood({
    required this.id,
    required this.text,
    required this.category,
    required this.color,
    required this.bgColor,
    required this.icon,
    this.author = '',
    this.avatarPath,
  });
}

/// 心情分类
enum MoodCategory {
  all('全部', CupertinoColors.systemGrey, CupertinoIcons.square_grid_2x2_fill),
  feeling(
    '心情语录',
    CupertinoColors.systemPink,
    CupertinoIcons.chat_bubble_text_fill,
  ),
  motivation('励志语录', CupertinoColors.systemOrange, CupertinoIcons.flame_fill),
  movieLines('经典台词', CupertinoColors.systemPurple, CupertinoIcons.film_fill),
  famous('名人名言', CupertinoColors.systemIndigo, CupertinoIcons.book_fill),
  love('爱情语录', CupertinoColors.systemRed, CupertinoIcons.heart_fill),
  life('人生感悟', CupertinoColors.systemTeal, CupertinoIcons.lightbulb_fill),
  translation(
    '精美译文',
    CupertinoColors.systemBlue,
    CupertinoIcons.textformat_alt,
  );

  final String label;
  final Color color;
  final IconData icon;

  const MoodCategory(this.label, this.color, this.icon);
}
