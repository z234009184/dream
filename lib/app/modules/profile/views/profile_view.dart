import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/theme_service.dart';
import '../controllers/profile_controller.dart';
import 'package:flutter/services.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 监听主题切换自动刷新
      ThemeService.to.themeMode;
      final brandColor = AppTheme.primary();
      final isDark = ThemeService.to.isDarkMode;
      final overlayStyle = isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.secondarySystemBackground
              .resolveFrom(context),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                // 顶部Logo与App名
                Center(
                  child: Column(
                    children: [
                      FakeGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 32),
                        settings: LiquidGlassSettings(
                          glassColor: brandColor.withAlpha(22),
                          blur: 18,
                          lightIntensity: 1.1,
                        ),
                        child: Container(
                          width: 86,
                          height: 86,
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.sparkles,
                            color: brandColor,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Glasso',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navLargeTitleTextStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: brandColor,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // 设置功能组
                _GlassSection(
                  title: 'profile_settings'.tr,
                  children: [
                    _GlassListTile(
                      leading: CupertinoIcons.brightness,
                      text: 'profile_theme_mode'.tr,
                      onTap: () => _showThemeSelector(context),
                    ),
                    _GlassListTile(
                      leading: CupertinoIcons.globe,
                      text: 'profile_language_label'.tr,
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ],
                ),
                _GlassSection(
                  title: 'profile_common'.tr,
                  children: [
                    _GlassListTile(
                      leading: CupertinoIcons.question_square,
                      text: 'profile_faq'.tr,
                      onTap: () => controller.openFAQ(),
                    ),
                    _GlassListTile(
                      leading: CupertinoIcons.delete,
                      text: 'profile_clear_cache'.tr,
                      onTap: () => controller.clearCache(context),
                    ),
                  ],
                ),
                _GlassSection(
                  title: 'profile_about_label'.tr,
                  children: [
                    _GlassListTile(
                      leading: CupertinoIcons.info_circle,
                      text: 'profile_about_label'.tr,
                      onTap: () => controller.openAbout(),
                    ),
                    _GlassListTile(
                      leading: CupertinoIcons.mail,
                      text: 'profile_feedback'.tr,
                      onTap: () => controller.openFeedback(),
                    ),
                    _GlassListTile(
                      leading: CupertinoIcons.doc_text,
                      text: 'profile_user_agreement'.tr,
                      onTap: () => controller.openLicense('user'),
                    ),
                    _GlassListTile(
                      leading: CupertinoIcons.shield_lefthalf_fill,
                      text: 'profile_privacy_policy'.tr,
                      onTap: () => controller.openLicense('privacy'),
                    ),
                  ],
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 显示主题选择器
  void _showThemeSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('profile_theme_mode'.tr),
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
        title: Text('profile_language_label'.tr),
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

// 玻璃风格分区
class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ),
          FakeGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 22),
            settings: LiquidGlassSettings(
              glassColor: CupertinoColors.secondarySystemBackground
                  .resolveFrom(context)
                  .withAlpha(150),
              blur: 13,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// 玻璃风格列表项
class _GlassListTile extends StatelessWidget {
  const _GlassListTile({
    required this.leading,
    required this.text,
    required this.onTap,
  });
  final IconData leading;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(leading, color: CupertinoColors.activeBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.systemGrey2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
