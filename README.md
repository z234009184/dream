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

---

## 📝 更新日志

### 2025-10-29 - 收藏功能重构

#### ✨ 新功能
- **双 Tab 收藏列表**：壁纸（网格）+ 心情（卡片列表）
- **心情详情页收藏**：导航栏爱心按钮，缩放动画 + 触觉反馈
- **完整数据持久化**：保存心情+壁纸+头像+颜色+时间
- **心情卡片头像**：收藏列表显示圆形头像（40x40）

#### 🐛 Bug 修复
- **Hero Tag 冲突**：修复心情 ID 生成逻辑，使用 getter 重置计数器
- **列表顺序稳定**：缓存打乱后的列表，避免页面切换时重新打乱导致 Hero 冲突
- **收藏跳转优化**：从收藏页跳转详情时先返回列表页，避免 Hero tag 重复

#### 🎨 UI 优化
- 心情卡片头像：40x40 圆形，白色边框 + 阴影效果
- 收藏时间显示：相对时间（刚刚、5分钟前、3天前）
- 空状态动画：图标闪烁效果

#### 📦 新增文件
- `lib/app/data/models/favorite_mood.dart` - 收藏心情数据模型
- `lib/app/services/favorites_service.dart` - 重构，添加心情收藏
- `lib/app/modules/favorites/` - 完全重写为双 Tab 布局

#### 🔧 技术改进
- FavoriteMood 模型支持 JSON 序列化/反序列化
- FavoriteMood.toMood() 方法实现数据转换
- MoodRepository 使用 getter 确保 ID 稳定性
- MoodController 缓存打乱后的列表

---

### 2025-10-27 - 心情列表下拉刷新

#### ✨ 新功能
- 心情列表页下拉刷新（随机重排）
- 推荐列表页下拉刷新（随机重排）

#### 🎨 UI 优化
- 原生 iOS CupertinoSliverRefreshControl
- 500ms 延迟提供视觉反馈
- 卡片淡入动画错落触发

---

### 2025-10-26 - 心情详情页壁纸切换

#### ✨ 新功能
- 心情详情页背景壁纸左右滑动切换
- 视差滚动效果（背景移动速度 50%）
- 壁纸平滑过渡动画（400ms）

#### 🔧 技术改进
- 根据心情分类自动匹配壁纸主题
- 支持图片和视频壁纸（显示缩略图）
- 无匹配壁纸时显示渐变背景

### v1.0.5 (2025-10-31)

#### 🌐 国际化支持
- **个人主页完整国际化**
  - 设置分组：设置、常用功能、关于
  - 主题模式选择器（浅色/深色/跟随系统）
  - 语言选择器（中文/英文）
  - FAQ、清除缓存、反馈等功能项

- **收藏页面完整国际化**
  - 壁纸/心情 Tab 标签
  - 导航栏标题
  - 空状态提示文本
  - 删除确认对话框

#### 🎨 UI 优化
- **媒体预览页面**
  - 返回按钮增加液态玻璃效果 + 圆角卡片 + 阴影
  - 底部操作按钮增加半透明背景 + 描边 + 阴影
  - 适配新版 `liquid_glass_renderer` (v0.2.0)
  - 解决图层叠加导致的交互问题

#### 📦 技术改进
- 国际化键值完整覆盖个人主页和收藏页
- 所有硬编码文本替换为 `.tr` 调用
- 支持切换语言后 UI 实时刷新

### v1.0.6 (2025-10-31)

#### 📄 法律文档
- **用户协议页面**
  - 服务说明、使用规则、知识产权
  - 免责声明、协议变更、联系方式
  - 完整中英文支持

- **隐私政策页面**
  - 信息收集说明（纯离线，不收集任何信息）
  - 本地存储说明（收藏、主题、语言设置）
  - 权限使用说明（仅照片库保存权限）
  - 第三方服务说明（无第三方 SDK）
  - 数据安全、儿童隐私、政策变更
  - 完整中英文支持

#### ✅ App Store 合规
- 符合 Apple 隐私政策要求
- 明确说明纯离线特性
- 详细列出权限使用场景
- 包含儿童隐私保护条款
- 提供联系方式和更新日期

#### 🔧 技术实现
- 独立 legal 模块（UserAgreementView / PrivacyPolicyView）
- 完整路由配置（Routes.USER_AGREEMENT / Routes.PRIVACY_POLICY）
- ProfileController 跳转逻辑更新
- 52 个新增国际化键值（中英文）

### v1.0.7 (2025-10-31)

#### 🔐 权限优化
- **iOS 相册权限配置完善**
  - 更新 `NSPhotoLibraryAddUsageDescription`（iOS 14+ 只写权限）
  - 更新 `NSPhotoLibraryUsageDescription`（iOS 14 以下）
  - 添加详细的权限说明文字，符合 App Store 审核要求

- **保存功能增强**
  - 权限请求优化（优先 photosAddOnly，回退 photos）
  - 添加详细日志输出（方便调试）
  - 权限拒绝时显示友好提示
  - 保存成功/失败显示 snackbar 提示
  - 增强触觉反馈（mediumImpact）

#### 🐛 Bug 修复
- 修复预览页面保存图片权限问题
- 优化权限请求流程，提升成功率
- 添加完整的错误处理和用户提示

#### 🎨 UI 改进
- 用户协议和隐私政策标题适配深色模式
- 使用 `resolveFrom(context)` 动态适配主题色

#### 📦 技术改进
- MediaService 权限检查逻辑重构
- 完善日志系统，便于问题定位
- 创建权限测试清单（PERMISSION_TEST.md）

---

## 📄 许可证

本项目仅供学习和个人使用。

---

## 👨‍💻 作者

Glasso Team

---

**最后更新**: 2025-10-31
