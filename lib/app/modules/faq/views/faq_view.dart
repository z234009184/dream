import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/theme/app_theme.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': '如何保存壁纸？', 'a': '在推荐页点击壁纸卡片右下角菜单，选择“保存到相册”即可。'},
      {'q': '如何更换主题色？', 'a': '在“我的-主题模式”中可切换浅色、深色或跟随系统。'},
      {'q': '是否需要网络权限？', 'a': 'Glasso 是纯离线应用，无需任何网络权限。'},
      {'q': '如何反馈建议？', 'a': '在“我的-反馈与联系我们”点击进入反馈渠道。'},
    ];

    final brandColor = AppTheme.primary();
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('常见问题'),
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(
          0.9,
        ),
        previousPageTitle: '我的',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          children: [
            for (var i = 0; i < faqs.length; i++)
              _FAQGlass(
                question: faqs[i]['q']!,
                answer: faqs[i]['a']!,
                brandColor: brandColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _FAQGlass extends StatelessWidget {
  const _FAQGlass({
    required this.question,
    required this.answer,
    required this.brandColor,
  });
  final String question;
  final String answer;
  final Color brandColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FakeGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: 16),
        settings: LiquidGlassSettings(
          glassColor: brandColor.withAlpha(22),
          blur: 17,
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: Text(question),
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(answer, style: const TextStyle(fontSize: 15)),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('我知道了'),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.question_circle,
                  size: 26,
                  color: brandColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.right_chevron,
                  size: 18,
                  color: CupertinoColors.systemGrey3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
