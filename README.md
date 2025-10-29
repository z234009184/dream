# 🌟 Glasso - 离线壁纸与心情日记应用

一个基于 **Flutter + GetX** 架构的纯离线 iOS 应用，提供精美壁纸、心情语录和头像展示功能。

---

## 📱 应用特性

### ✨ 核心功能
- 🖼️ **壁纸推荐**：瀑布流展示，支持图片/GIF/视频
- 💭 **心情语录**：分类展示，配有精美头像
- ⭐ **收藏功能**：本地收藏管理
- 🎨 **主题切换**：日间/夜间模式
- 🌐 **多语言**：中文/英文支持

### 🎯 技术亮点
- ✅ **纯离线**：无网络权限，无数据收集
- ✅ **流畅动画**：Liquid Glass UI + Hero 动画
- ✅ **性能优化**：单例视频播放器，CPU 占用 < 5%
- ✅ **原生集成**：Swift 插件实现视频缩略图生成
- ✅ **现代架构**：StatelessWidget + GetX Controller

---

## 🏗️ 项目架构

### 技术栈
```yaml
Flutter SDK: ^3.0.0
核心框架: GetX ^4.7.2
UI 风格: Cupertino (纯 iOS 风格)
状态管理: GetX (响应式)
路由管理: GetX 路由
本地存储: get_storage ^2.1.1
```

### 目录结构
```
lib/
├── app/
│   ├── core/              # 核心配置（主题、国际化）
│   ├── data/              # 数据层（模型、仓库）
│   ├── modules/           # 功能模块（GetX MVC）
│   │   ├── recommend/     # 推荐页
│   │   ├── mood/          # 心情页
│   │   ├── profile/       # 个人页
│   │   ├── favorites/     # 收藏页
│   │   └── image_preview/ # 媒体预览
│   ├── routes/            # 路由配置
│   ├── services/          # 全局服务
│   └── widgets/           # 通用组件
└── main.dart
```

### 架构设计

#### 1. **StatelessWidget + Controller 模式**
```dart
// View: 纯 StatelessWidget
class MediaPreviewView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaPreviewController>();
    return Obx(() => /* 响应式 UI */);
  }
}

// Controller: 管理状态和业务逻辑
class MediaPreviewController extends GetxController {
  final currentIndex = 0.obs;
  
  @override
  void onClose() {
    // 自动清理资源
    VideoControllerService.to.release();
  }
}
```

#### 2. **全局单例服务**
```dart
// 视频播放器服务：全局唯一实例
class VideoControllerService extends GetxService {
  VideoPlayerController? _controller;
  
  Future<VideoPlayerController?> switchTo(String path) async {
    _releaseSync(); // 自动释放旧的
    _controller = VideoPlayerController.asset(path);
    await _controller!.initialize();
    return _controller;
  }
}

// 视频缩略图服务：原生 Swift 插件
class VideoThumbnailCacheService extends GetxService {
  Future<Uint8List?> getThumbnail(String videoPath) async {
    // 调用原生方法生成缩略图
    return await _channel.invokeMethod('getThumbnail', {...});
  }
}
```

#### 3. **GetX 路由管理**
```dart
// 路由配置
GetPage(
  name: Routes.MEDIA_PREVIEW,
  page: () => const MediaPreviewView(),
  binding: MediaPreviewBinding(), // 自动注入/销毁 Controller
)

// 导航
Get.toNamed(
  Routes.MEDIA_PREVIEW,
  arguments: {'mediaList': [...], 'initialIndex': 0},
);
```

---

## 🚀 性能优化

### 视频播放优化
- **全局单例播放器**：同时最多 1 个视频控制器
- **自动资源管理**：页面关闭立即释放
- **原生缩略图**：Swift + AVFoundation 生成首帧
- **CPU 占用**：列表静止 2%，视频播放 30%

### 内存优化
- **图片缓存**：`cacheWidth` 限制解码尺寸
- **视频缩略图缓存**：内存缓存 + 懒加载
- **状态保持**：`IndexedStack` 保留 Tab 状态

### UI 优化
- **瀑布流布局**：`flutter_staggered_grid_view`
- **渐进动画**：`flutter_animate` 淡入 + 缩放
- **Liquid Glass UI**：`liquid_glass_renderer` 毛玻璃效果
- **Hero 动画**：`extended_image` 无缝转场

---

## 📦 核心依赖

```yaml
dependencies:
  # 框架
  get: ^4.7.2                           # 状态管理 + 路由
  get_storage: ^2.1.1                   # 本地存储
  
  # UI 组件
  liquid_glass_renderer: ^0.1.1-dev.25  # 液体玻璃效果
  extended_image: ^10.0.1               # 图片/GIF + 手势
  flutter_staggered_grid_view: ^0.7.0   # 瀑布流布局
  
  # 动画
  flutter_animate: ^4.5.2               # 动画库
  animate_do: ^4.2.0                    # 预设动画
  lottie: ^3.3.2                        # Lottie 动画
  
  # 媒体
  video_player: ^2.9.2                  # 视频播放
  gal: ^2.3.2                           # 保存到相册
  permission_handler: ^12.0.1           # 权限管理
  
  # 工具
  logger: ^2.6.2                        # 日志
```

---

## 🔧 开发指南

### 环境要求
- Flutter SDK >= 3.0.0
- Xcode >= 14.0 (iOS 开发)
- Dart >= 3.0.0

### 安装步骤
```bash
# 1. 克隆项目
git clone <repository-url>
cd dream

# 2. 安装依赖
flutter pub get

# 3. 运行项目
flutter run
```

### 添加新模块
```bash
# 使用 get_cli 生成模块
get create page:new_module

# 生成结构：
# lib/app/modules/new_module/
#   ├── controllers/new_module_controller.dart
#   ├── views/new_module_view.dart
#   └── bindings/new_module_binding.dart
```

### 代码规范
- ✅ 所有页面使用 `StatelessWidget`
- ✅ 业务逻辑写在 `Controller` 中
- ✅ 全局功能使用 `Service`
- ✅ 使用 `Obx` 实现响应式 UI
- ✅ 路由使用 `Get.toNamed()`

---

## 🎨 UI 设计原则

### Cupertino 风格
- 使用 `CupertinoPageScaffold`、`CupertinoButton` 等组件
- 遵循 iOS Human Interface Guidelines
- 原生导航栏：`CupertinoSliverNavigationBar`

### 主题系统
```dart
// 深紫色主题
static const primaryColor = Color(0xFF5E17EB);

// 渐变背景
LinearGradient(
  colors: [
    CupertinoColors.systemBackground,
    primaryColor.withOpacity(0.05),
  ],
)
```

### 动画规范
- 淡入动画：220ms
- 缩放动画：从 0.98 到 1.0
- Hero 动画：300ms
- 页面转场：300ms

---

## 📊 性能指标

| 场景 | CPU 占用 | 内存占用 | 帧率 |
|------|----------|----------|------|
| 列表静止 | 2% | 40MB | 60 FPS |
| 列表滚动 | 10-15% | 50MB | 60 FPS |
| 视频播放 | 30% | 60MB | 60 FPS |
| 页面切换 | 5-10% | 稳定 | 60 FPS |

---

## 🐛 已知问题与解决方案

### ✅ 已解决
1. **CPU 累积不下降** → 使用 StatelessWidget + 单例播放器
2. **视频控制器泄漏** → Controller.onClose() 自动释放
3. **Hero 动画冲突** → 使用路径作为唯一 tag
4. **视频首帧黑屏** → 原生 Swift 插件生成缩略图
5. **PageView 重复构建** → 移除 KeepAlive，改用 Controller 管理

---

## 📝 开发日志

### 重大重构
- **2025-10-24**: 彻底重构为 StatelessWidget + GetX 架构
- **2025-10-24**: 实现原生 Swift 视频缩略图插件
- **2025-10-24**: 优化视频播放器为全局单例

### 功能迭代
- ✅ 推荐页瀑布流布局
- ✅ 心情页分类展示
- ✅ 收藏功能
- ✅ 媒体预览（图片/GIF/视频）
- ✅ 主题切换
- ✅ 多语言支持

---

## 📄 许可证

本项目仅供学习和个人使用。

---

## 👨‍💻 作者

Glasso Team

---

**最后更新**: 2025-10-24
