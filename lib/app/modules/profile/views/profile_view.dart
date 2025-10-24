import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../services/theme_service.dart';
import '../controllers/profile_controller.dart';

/// 个人中心视图
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent, // 透明背景，显示渐变
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 应用图标和名称
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      size: 40,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'app_name'.tr,
                    style: CupertinoTheme.of(
                      context,
                    ).textTheme.navLargeTitleTextStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 设置列表
            CupertinoListSection.insetGrouped(
              header: Text('settings'.tr),
              children: [
                // 主题设置
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.brightness),
                  title: Text('profile_theme'.tr),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () => _showThemeSelector(context),
                ),

                // 语言设置
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: Text('profile_language'.tr),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () => _showLanguageSelector(context),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              children: [
                // 关于
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.info_circle),
                  title: Text('profile_about'.tr),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () {
                    // TODO: 显示关于页面
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示主题选择器
  void _showThemeSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('profile_theme'.tr),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              controller.switchTheme(ThemeMode.light);
              Navigator.pop(context);
            },
            child: Text('theme_light'.tr),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.switchTheme(ThemeMode.dark);
              Navigator.pop(context);
            },
            child: Text('theme_dark'.tr),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.switchTheme(ThemeMode.system);
              Navigator.pop(context);
            },
            child: Text('theme_system'.tr),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
      ),
    );
  }

  /// 显示语言选择器
  void _showLanguageSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('profile_language'.tr),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              controller.switchLanguage('zh');
              Navigator.pop(context);
            },
            child: Text('language_zh'.tr),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.switchLanguage('en');
              Navigator.pop(context);
            },
            child: Text('language_en'.tr),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
      ),
    );
  }
}
