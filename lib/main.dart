import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:heroine/heroine.dart';
import 'app/core/i18n/translation_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage_service.dart';
import 'app/services/theme_service.dart';
import 'app/services/media_service.dart';
import 'app/services/favorites_service.dart';
import 'app/services/video_controller_service.dart';
import 'app/services/video_thumbnail_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  logger.i('🚀 Glasso 应用启动中...');

  // 设置系统 UI 样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化核心服务
  try {
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => ThemeService().init());
    await Get.putAsync(() => MediaService().init());
    await Get.putAsync(() => FavoritesService().init());
    Get.put(VideoControllerService()); // 视频控制器服务
    Get.put(VideoThumbnailCacheService()); // 视频缩略图缓存服务
    logger.i('✅ 核心服务初始化完成');
  } catch (e) {
    logger.e('❌ 核心服务初始化失败: $e');
  }

  runApp(const GlassoApp());
}

/// Glasso 应用主类
class GlassoApp extends StatelessWidget {
  const GlassoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'Glasso',
      debugShowCheckedModeBanner: false,

      // 国际化配置
      translations: TranslationService(),
      locale: _getInitialLocale(),
      fallbackLocale: TranslationService.fallbackLocale,
      supportedLocales: TranslationService.locales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 注册 heroine 导航观察者
      navigatorObservers: [HeroineController()],

      // 主题配置
      theme: AppTheme.lightTheme,

      // 路由配置
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // 默认过渡动画
      defaultTransition: Transition.cupertino,

      // 构建器：监听主题变化
      builder: (context, child) {
        return Obx(() {
          // 根据主题服务动态切换主题
          final isDark = ThemeService.to.isDarkMode;

          return CupertinoTheme(
            data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            child: child!,
          );
        });
      },
    );
  }

  /// 获取初始语言
  Locale _getInitialLocale() {
    try {
      final savedLocale = StorageService.to.read<String>(
        StorageService.keyLocale,
      );
      if (savedLocale != null) {
        if (savedLocale == 'zh') {
          return const Locale('zh', 'CN');
        } else if (savedLocale == 'en') {
          return const Locale('en', 'US');
        }
      }
    } catch (e) {
      Logger().e('获取保存的语言设置失败: $e');
    }

    // 默认使用系统语言
    return Get.deviceLocale ?? TranslationService.fallbackLocale;
  }
}
