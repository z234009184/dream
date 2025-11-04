import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 隐私政策页面
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('privacy_policy_title'.tr),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 隐私承诺
            _buildSectionTitle('privacy_policy_intro'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(context, 'privacy_policy_intro_content'.tr),
            const SizedBox(height: 24),

            // 第1节：信息收集
            _buildSectionTitle('privacy_policy_section_1'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_1_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第2节：本地存储
            _buildSectionTitle('privacy_policy_section_2'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_2_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第3节：权限使用
            _buildSectionTitle('privacy_policy_section_3'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_3_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第4节：第三方服务
            _buildSectionTitle('privacy_policy_section_4'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_4_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第5节：数据安全
            _buildSectionTitle('privacy_policy_section_5'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_5_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第6节：儿童隐私
            _buildSectionTitle('privacy_policy_section_6'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_6_content'.tr,
            ),
            const SizedBox(height: 24),

            // 第7节：政策变更
            _buildSectionTitle('privacy_policy_section_7'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(
              context,
              'privacy_policy_section_7_content'.tr,
            ),
            const SizedBox(height: 24),

            // 联系我们
            _buildSectionTitle('privacy_policy_contact'.tr, context),
            const SizedBox(height: 8),
            _buildSectionContent(context, 'privacy_policy_contact_content'.tr),
            const SizedBox(height: 24),

            // 最后更新日期
            Center(
              child: Text(
                'privacy_policy_last_update'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
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
