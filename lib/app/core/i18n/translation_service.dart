import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'translation_zh_cn.dart';
import 'translation_en_us.dart';

/// 多语言翻译服务
class TranslationService extends Translations {
  // 支持的语言列表
  static final locales = [
    const Locale('zh', 'CN'), // 简体中文
    const Locale('en', 'US'), // 英文
  ];

  // 默认语言
  static const fallbackLocale = Locale('zh', 'CN');

  @override
  Map<String, Map<String, String>> get keys => {'zh_CN': zhCN, 'en_US': enUS};

  /// 根据系统语言获取初始语言
  static Locale getLocaleFromLanguage(String langCode) {
    final locale = locales.firstWhere(
      (locale) => locale.languageCode == langCode,
      orElse: () => fallbackLocale,
    );
    return locale;
  }
}


