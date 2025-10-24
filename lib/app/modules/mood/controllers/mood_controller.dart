import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/models/mood.dart';
import '../../../data/repositories/mood_repository.dart';

/// 心情页控制器
class MoodController extends GetxController {
  final Logger _logger = Logger();
  final MoodRepository _repo = MoodRepository();

  final RxBool loading = false.obs;
  final RxList<Mood> moods = <Mood>[].obs;
  final RxString selectedCategory = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _logger.i('MoodController 初始化');
    loadMoods();
  }

  /// 加载心情列表
  Future<void> loadMoods() async {
    try {
      loading.value = true;
      final items = await _repo.loadMoods();
      moods.assignAll(items);
      _logger.d('已加载心情: ${items.length}');
    } catch (e) {
      _logger.e('加载心情失败: $e');
    } finally {
      loading.value = false;
    }
  }

  /// 根据分类筛选心情
  List<Mood> get filteredMoods {
    if (selectedCategory.value == 'all') {
      // 全部分类使用乱序
      final shuffled = List<Mood>.from(moods);
      shuffled.shuffle();
      return shuffled;
    }
    return moods.where((m) => m.category == selectedCategory.value).toList();
  }

  /// 选择分类
  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
