import 'package:get/get.dart';
import '../controllers/mood_detail_controller.dart';

/// 心情详情页面绑定
class MoodDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoodDetailController>(() => MoodDetailController());
  }
}
