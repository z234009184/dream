import 'package:get/get.dart';
import '../controllers/mood_controller.dart';

/// 心情页绑定
class MoodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoodController>(() => MoodController());
  }
}
