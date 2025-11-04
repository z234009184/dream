# Project Context

## Purpose
**Glasso** 是一个纯离线 iOS 应用，提供精美壁纸展示、心情语录和头像浏览功能。目标是为用户提供流畅、美观、隐私安全的本地内容体验，符合 Apple App Store 审核标准。

## Tech Stack
- **Flutter SDK**: ^3.0.0
- **Dart**: ^3.9.2
- **状态管理**: GetX ^4.7.2 (响应式 + 路由)
- **UI 风格**: Cupertino (纯 iOS 原生风格)
- **本地存储**: get_storage ^2.1.1
- **UI 特效**: liquid_glass_renderer 0.2.0-dev.2
- **图片处理**: extended_image ^10.0.1
- **视频播放**: video_player ^2.9.2
- **动画**: flutter_animate ^4.5.2, animate_do ^4.2.0
- **权限管理**: permission_handler ^12.0.1
- **相册保存**: gal ^2.3.2

## Project Conventions

### Code Style
- **文件命名**: 使用 snake_case（如 `mood_controller.dart`）
- **类命名**: 使用 PascalCase（如 `MoodController`）
- **变量命名**: 使用 camelCase（如 `currentIndex`）
- **响应式变量**: 使用 `.obs` 后缀（如 `final loading = false.obs;`）
- **私有成员**: 使用 `_` 前缀（如 `_logger`）
- **常量**: 使用 `kPrefixName` 或 `const` 声明
- **格式化**: 使用 `flutter format` 保持一致性
- **Lint**: 遵循 `flutter_lints ^5.0.0` 规则

### Architecture Patterns
- **架构模式**: StatelessWidget + GetX Controller + Service
- **状态管理**: GetX 响应式（Rx 变量 + Obx）
- **路由管理**: GetX 命名路由 + Bindings
- **依赖注入**: GetX `Get.lazyPut()` / `Get.put()`
- **生命周期**: Controller 的 `onInit()` / `onClose()` 管理资源

**模块结构**:
```
lib/app/modules/[module_name]/
├── controllers/[module_name]_controller.dart
├── views/[module_name]_view.dart
└── bindings/[module_name]_binding.dart
```

**全局服务**:
```dart
class XxxService extends GetxService {
  static XxxService get to => Get.find();
  
  Future<XxxService> init() async {
    // 初始化逻辑
    return this;
  }
}
```

**Controller 规范**:
```dart
class XxxController extends GetxController {
  // 1. 依赖注入
  final XxxService _service = XxxService.to;
  
  // 2. 响应式变量
  final loading = false.obs;
  final data = <Type>[].obs;
  
  // 3. 生命周期
  @override
  void onInit() {
    super.onInit();
    // 初始化
  }
  
  @override
  void onClose() {
    // 清理资源（必须）
    super.onClose();
  }
  
  // 4. 公共方法
  Future<void> loadData() async { }
  
  // 5. 私有方法
  void _helperMethod() { }
}
```

### Testing Strategy
- **单元测试**: 使用 `flutter_test` 测试 Controller 和 Service 逻辑
- **性能测试**: 监控 CPU 占用、内存占用、帧率（目标 60 FPS）
- **手动测试**: 重点测试 UI 交互、动画流畅度、资源释放

**性能指标**:
- 列表静止: CPU < 5%, 内存 < 50MB
- 列表滚动: CPU < 15%, 内存 < 100MB
- 视频播放: CPU < 35%, 内存 < 150MB

### Git Workflow
- **分支策略**: 
  - `main`: 稳定版本
  - `develop`: 开发分支
  - `feature/*`: 功能分支
- **提交规范**: 
  - `feat: 新功能`
  - `fix: Bug 修复`
  - `refactor: 重构`
  - `docs: 文档更新`
  - `style: 代码格式`
  - `perf: 性能优化`

## Domain Context

### 应用功能域
1. **推荐页（Recommend）**: 壁纸和头像的瀑布流展示，支持图片/GIF/视频
2. **心情页（Mood）**: 分类展示心情语录，配有头像和背景壁纸
3. **收藏页（Favorites）**: 本地收藏管理，分壁纸和心情两个 Tab
4. **个人页（Profile）**: 主题切换、语言切换、FAQ、清除缓存、法律文档
5. **媒体预览（MediaPreview）**: 全屏预览图片/GIF/视频，支持手势缩放和保存

### 关键业务逻辑
- **壁纸匹配**: 根据心情分类自动匹配对应主题的壁纸
- **视频播放**: 全局单例播放器，同时最多 1 个视频控制器
- **缩略图生成**: 使用原生 Swift 插件（AVFoundation）生成视频首帧
- **收藏数据**: 保存完整的心情+壁纸+头像+颜色+时间组合
- **Hero 动画**: 使用 `heroine` 包实现页面间的无缝转场

## Important Constraints

### 技术约束
- **纯离线应用**: 禁止使用网络权限，不收集用户数据
- **iOS 专用**: 仅支持 iOS 平台，遵循 Human Interface Guidelines
- **Cupertino 风格**: 禁止使用 Material Design 组件
- **StatelessWidget**: 除非有明确理由，否则禁止使用 StatefulWidget
- **资源管理**: Controller 必须在 `onClose()` 中清理资源

### 业务约束
- **隐私合规**: 符合 Apple 隐私政策，明确说明权限用途
- **性能要求**: 保持 60 FPS，CPU 占用合理，无内存泄漏
- **用户体验**: 动画流畅，交互响应及时，支持深色模式

### App Store 审核要求
- 提供完整的用户协议和隐私政策
- 详细说明照片库权限用途（`Info.plist`）
- 无第三方 SDK，无数据收集
- 包含儿童隐私保护条款

## External Dependencies

### 原生插件
- **视频缩略图服务**: Swift + AVFoundation（`ios/Runner/VideoThumbnailPlugin.swift`）
  - 方法: `getThumbnail(videoPath, time, quality)`
  - 返回: JPEG 字节数组

### 本地资源
- **壁纸**: `assets/images/wallpapers/[category]/`
  - 分类: abstract, aesthetic, gradient, minimal
- **头像**: `assets/images/avatars/[category]/`
  - 分类: anime, cute, minimal, vintage
- **视频**: `assets/videos/[category]/`
  - 分类: liquid, colorful
  - 缩略图: `assets/videos/[category]/thumbnails/`

### 数据存储
- **GetStorage**: 
  - 收藏数据: `keyFavoriteWallpapers`, `keyFavoriteMoods`
  - 主题设置: `keyThemeMode`
  - 语言设置: `keyLanguage`
  - 主题颜色: `keyThemeColor`

### 性能优化策略
- **图片缓存**: 使用 `cacheWidth` 限制解码尺寸
- **视频缓存**: 内存缓存缩略图，懒加载
- **状态保持**: `IndexedStack` 保留 Tab 状态
- **单例服务**: 视频播放器全局唯一实例
