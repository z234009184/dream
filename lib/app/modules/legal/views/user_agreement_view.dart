import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 用户协议页面
class UserAgreementView extends StatelessWidget {
  const UserAgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('user_agreement_title'.tr),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 欢迎标题
            _buildSectionTitle('user_agreement_intro'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(context, 'user_agreement_intro_content'.tr),
            const SizedBox(height: 24),

            // 第1节：服务说明
            _buildSectionTitle('user_agreement_section_1'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'user_agreement_section_1_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第2节：使用规则
            _buildSectionTitle('user_agreement_section_2'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'user_agreement_section_2_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第3节：知识产权
            _buildSectionTitle('user_agreement_section_3'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'user_agreement_section_3_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第4节：免责声明
            _buildSectionTitle('user_agreement_section_4'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'user_agreement_section_4_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第5节：协议变更
            _buildSectionTitle('user_agreement_section_5'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'user_agreement_section_5_content'.tr,
            ),
            const SizedBox(height: 24),

            // 联系我们
            _buildSectionTitle('user_agreement_contact'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(context, 'user_agreement_contact_content'.tr),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }

  /// 构建章节内容
  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }
}
