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
  final RxInt refreshKey = 0.obs; // 刷新标识，用于触发列表重建

  // 🔥 缓存已打乱的列表，避免每次访问都重新打乱
  List<Mood> _shuffledMoods = [];

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

      // 初始化时打乱一次
      _shuffledMoods = List<Mood>.from(items);
      _shuffledMoods.shuffle();

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
      // ✅ 返回已缓存的打乱列表，而不是每次都重新打乱
      return _shuffledMoods;
    }
    return moods.where((m) => m.category == selectedCategory.value).toList();
  }

  /// 选择分类
  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  /// 刷新心情列表（随机重排）
  Future<void> refreshMoods() async {
    try {
      _logger.d('刷新心情列表');

      // 重新打乱列表
      _shuffledMoods = List<Mood>.from(moods);
      _shuffledMoods.shuffle();

      // 增加刷新计数，触发列表重建
      refreshKey.value++;

      // 模拟加载延迟，提供更好的用户体验
      await Future.delayed(const Duration(milliseconds: 500));

      _logger.d('心情列表已刷新');
    } catch (e) {
      _logger.e('刷新心情失败: $e');
    }
  }
}
