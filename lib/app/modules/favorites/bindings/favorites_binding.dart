import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';

/// 收藏页依赖绑定
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(() => FavoritesController());
  }
}
