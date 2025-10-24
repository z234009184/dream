import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// 个人中心依赖绑定
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}


