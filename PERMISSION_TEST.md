# 📸 相册权限测试清单

## 🔧 已完成的配置

### 1. iOS 权限配置 (`ios/Runner/Info.plist`)
- ✅ `NSPhotoLibraryAddUsageDescription` - iOS 14+ 保存照片权限（只写）
- ✅ `NSPhotoLibraryUsageDescription` - iOS 14 以下相册访问权限
- ✅ 添加了详细的权限说明文字

### 2. 代码优化 (`lib/app/services/media_service.dart`)
- ✅ 增强权限请求逻辑（优先 photosAddOnly，回退 photos）
- ✅ 添加详细日志输出（方便调试）
- ✅ 添加权限拒绝提示（Get.snackbar）
- ✅ 添加保存成功/失败提示
- ✅ 添加触觉反馈（mediumImpact）

### 3. 依赖库
- ✅ `permission_handler: ^12.0.1` - 权限管理
- ✅ `gal: ^2.3.2` - 保存到相册

---

## ✅ 测试步骤

### 步骤 1: 完全卸载应用
```bash
# 从设备上完全卸载应用（清除所有权限记录）
# 在 Xcode 中删除或手动从设备删除
```

### 步骤 2: 清理构建缓存
```bash
cd /Users/zhangguoliang/Desktop/dream
flutter clean
flutter pub get
```

### 步骤 3: 重新构建并安装
```bash
# 使用 Xcode 或 Flutter 重新构建
flutter run --release
# 或在 Xcode 中 Build & Run
```

### 步骤 4: 测试权限流程

#### 4.1 首次保存测试
1. 打开应用
2. 进入推荐页面或收藏页面
3. 点击一张壁纸进入预览
4. 点击底部的"保存"按钮（下载图标）
5. **预期**: 系统弹出权限请求对话框
6. **选择**: 点击"允许"
7. **预期**: 显示"保存成功"提示，触觉反馈
8. **验证**: 打开系统相册，检查"Glasso"相簿中是否有刚才保存的图片

#### 4.2 权限拒绝测试
1. 如果在步骤 4.1 中点击了"不允许"
2. **预期**: 显示"权限被拒绝"提示
3. 再次尝试保存图片
4. **预期**: 再次弹出权限请求（如果不是永久拒绝）

#### 4.3 永久拒绝测试
1. 到 iOS 设置 -> 隐私与安全性 -> 照片 -> Glasso
2. 选择"不允许"
3. 返回应用，尝试保存图片
4. **预期**: 显示"权限被拒绝"提示

---

## 🐛 问题排查

### 问题 1: 保存没有反应
**可能原因**:
- Info.plist 更改未生效
- 应用缓存未清理

**解决方案**:
1. 完全卸载应用
2. 执行 `flutter clean`
3. 重新构建安装

### 问题 2: 权限对话框不弹出
**可能原因**:
- 之前已经拒绝权限，需要手动到设置中开启
- Info.plist 权限描述未配置

**解决方案**:
1. 检查 `ios/Runner/Info.plist` 是否包含权限描述
2. 到 iOS 设置中手动开启照片权限
3. 重新安装应用

### 问题 3: 保存失败但有权限
**可能原因**:
- 资源路径错误
- Gal 库调用失败

**解决方案**:
1. 查看控制台日志（MediaService 会输出详细日志）
2. 检查资源路径是否正确
3. 确认 `gal` 库版本兼容性

---

## 📱 查看日志

在 Xcode 或终端中查看日志输出：

```bash
# 查看 MediaService 相关日志
flutter logs | grep MediaService

# 查看权限相关日志
flutter logs | grep "权限\|permission"

# 查看保存相关日志
flutter logs | grep "保存"
```

---

## 🎯 预期日志输出

### 成功保存时:
```
[MediaService] 开始保存图片: assets/images/wallpapers/...
[MediaService] photosAddOnly 权限状态: PermissionStatus.granted
[MediaService] 权限已授予，开始加载资源
[MediaService] 资源加载成功，大小: 123456 bytes
[MediaService] 开始保存到相册...
[MediaService] ✅ 保存到相册成功: assets/images/wallpapers/...
```

### 权限拒绝时:
```
[MediaService] 开始保存图片: assets/images/wallpapers/...
[MediaService] photosAddOnly 权限状态: PermissionStatus.denied
[MediaService] photosAddOnly 请求后状态: PermissionStatus.denied
[MediaService] photos 权限状态: PermissionStatus.denied
[MediaService] photos 请求后状态: PermissionStatus.denied
[MediaService] 相册权限未授予
[MediaService] 权限未授予，取消保存
```

---

## 📝 注意事项

1. **iOS 模拟器**: 模拟器可能行为与真机不同，建议在真机上测试
2. **权限缓存**: iOS 会缓存权限决定，需要完全卸载应用才能重置
3. **权限描述**: Info.plist 中的描述会显示在权限对话框中，必须清晰明确
4. **App Store 审核**: 权限描述必须与实际使用一致，否则会被拒审

---

## ✅ 验收标准

- [ ] 首次保存时能正常弹出权限请求对话框
- [ ] 权限描述文字清晰易懂（中文）
- [ ] 允许权限后能成功保存图片到相册
- [ ] 保存成功后有明确的提示（snackbar + 触觉反馈）
- [ ] 拒绝权限后有明确的提示
- [ ] 保存的图片在系统相册"Glasso"相簿中可见
- [ ] 多次保存都能成功
- [ ] 控制台日志清晰，方便调试

---

**最后更新**: 2025-10-31

