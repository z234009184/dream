import 'package:get/get.dart';
import '../modules/recommend/bindings/recommend_binding.dart';
import '../modules/recommend/views/recommend_view.dart';
import '../modules/mood/bindings/mood_binding.dart';
import '../modules/mood/views/mood_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/favorites/bindings/favorites_binding.dart';
import '../modules/favorites/views/favorites_view.dart';
import '../modules/image_preview/bindings/media_preview_binding.dart';
import '../modules/image_preview/views/media_preview_view.dart';
import '../widgets/main_tab_view.dart';
import 'app_routes.dart';

/// 应用页面配置
class AppPages {
  AppPages._();

  static const initial = Routes.MAIN;

  static final routes = [
    // 主标签页
    GetPage(
      name: Routes.MAIN,
      page: () => const MainTabView(),
      bindings: [
        RecommendBinding(),
        MoodBinding(),
        ProfileBinding(),
        FavoritesBinding(),
      ],
    ),

    // 推荐页
    GetPage(
      name: Routes.RECOMMEND,
      page: () => const RecommendView(),
      binding: RecommendBinding(),
    ),

    // 心情
    GetPage(
      name: Routes.MOOD,
      page: () => const MoodView(),
      binding: MoodBinding(),
    ),

    // 我的
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    // 收藏
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),

    // 媒体预览
    GetPage(
      name: Routes.MEDIA_PREVIEW,
      page: () => const MediaPreviewView(),
      binding: MediaPreviewBinding(),
      transition: Transition.noTransition,
    ),
  ];
}
