import 'package:get/get.dart';
import '../controllers/recommend_controller.dart';

/// 推荐页依赖绑定
class RecommendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendController>(() => RecommendController());
  }
}
