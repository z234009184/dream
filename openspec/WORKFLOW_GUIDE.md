# 📘 OpenSpec 工作流程指南

这是一份针对 **Glasso 项目**的 OpenSpec 使用指南，帮助你理解如何使用规范驱动开发。

---

## 🎯 什么是 OpenSpec？

OpenSpec 是一个**规范驱动开发**（Spec-Driven Development）工具，它帮助你：
- 📝 在编码前明确需求和设计
- 🔍 追踪功能变更历史
- ✅ 确保实现符合规范
- 📚 维护项目文档

---

## 🔄 三阶段工作流

### 阶段 1️⃣: 创建变更提案（Creating Changes）

**何时创建提案？**
- ✅ 添加新功能（如：添加视频播放功能）
- ✅ 重大变更（如：重构收藏系统）
- ✅ 架构调整（如：从 StatefulWidget 迁移到 StatelessWidget）
- ✅ 性能优化（如：优化视频播放器为单例）
- ❌ Bug 修复（直接修复）
- ❌ 代码格式化（直接修复）
- ❌ 依赖更新（直接更新）

**创建步骤：**

```bash
# 1. 查看现有规范和变更
openspec list --specs          # 查看已有功能
openspec list                  # 查看进行中的变更

# 2. 创建变更目录（使用 kebab-case，动词开头）
mkdir -p openspec/changes/add-video-playback/{specs/media-preview}

# 3. 编写 proposal.md
cat > openspec/changes/add-video-playback/proposal.md << 'EOF'
## Why
用户需要在应用内预览视频壁纸，当前仅支持图片和 GIF。

## What Changes
- 添加视频播放功能到媒体预览页
- 实现全局单例视频播放器
- 添加视频缩略图生成服务

## Impact
- Affected specs: media-preview
- Affected code: 
  - lib/app/modules/media_preview/
  - lib/app/services/video_controller_service.dart
EOF

# 4. 编写 tasks.md
cat > openspec/changes/add-video-playback/tasks.md << 'EOF'
## 1. 实现视频播放器服务
- [ ] 1.1 创建 VideoControllerService
- [ ] 1.2 实现单例模式
- [ ] 1.3 实现自动资源释放

## 2. 更新媒体预览页
- [ ] 2.1 添加视频检测逻辑
- [ ] 2.2 集成 video_player 组件
- [ ] 2.3 添加播放控制 UI

## 3. 测试
- [ ] 3.1 测试视频播放流畅度
- [ ] 3.2 测试资源释放
- [ ] 3.3 测试性能指标
EOF

# 5. 编写规范变更（delta spec）
cat > openspec/changes/add-video-playback/specs/media-preview/spec.md << 'EOF'
## ADDED Requirements

### Requirement: Video Playback Support
The system SHALL support video playback in the media preview page.

#### Scenario: Play video wallpaper
- **WHEN** user opens a video file
- **THEN** the video plays automatically with controls

#### Scenario: Pause and resume
- **WHEN** user taps the video
- **THEN** the video pauses or resumes

### Requirement: Resource Management
The system SHALL automatically release video resources when leaving the page.

#### Scenario: Automatic cleanup
- **WHEN** user navigates away from preview
- **THEN** video controller is disposed immediately
EOF

# 6. 验证提案
openspec validate add-video-playback --strict
```

---

### 阶段 2️⃣: 实现变更（Implementing Changes）

**实现步骤：**

1. **阅读提案文档**
   ```bash
   # 查看提案详情
   openspec show add-video-playback
   ```

2. **按照 tasks.md 逐步实现**
   - 从第一个任务开始
   - 完成一个任务后再开始下一个
   - 确保每个任务都通过测试

3. **更新任务状态**
   ```markdown
   ## 1. 实现视频播放器服务
   - [x] 1.1 创建 VideoControllerService
   - [x] 1.2 实现单例模式
   - [ ] 1.3 实现自动资源释放  # 进行中
   ```

4. **验证实现**
   ```bash
   # 运行测试
   flutter test
   
   # 检查性能
   flutter run --profile
   ```

---

### 阶段 3️⃣: 归档变更（Archiving Changes）

**何时归档？**
- ✅ 功能已完全实现
- ✅ 所有测试通过
- ✅ 已部署到生产环境

**归档步骤：**

```bash
# 1. 确认所有任务完成
openspec show add-video-playback

# 2. 归档变更（会自动更新 specs/）
openspec archive add-video-playback --yes

# 3. 验证归档结果
openspec validate --strict

# 4. 查看归档历史
ls openspec/changes/archive/
```

---

## 📁 目录结构说明

```
openspec/
├── project.md                    # 项目约定（已填充）
├── AGENTS.md                     # AI 助手指南
├── WORKFLOW_GUIDE.md            # 本文档
│
├── specs/                        # 当前真相 - 已构建的功能
│   ├── media-preview/
│   │   └── spec.md              # 媒体预览功能规范
│   ├── favorites/
│   │   └── spec.md              # 收藏功能规范
│   └── ...
│
└── changes/                      # 提案 - 计划中的变更
    ├── add-video-playback/      # 进行中的变更
    │   ├── proposal.md          # 为什么做这个变更
    │   ├── tasks.md             # 实现清单
    │   ├── design.md            # 技术决策（可选）
    │   └── specs/               # 规范变更（delta）
    │       └── media-preview/
    │           └── spec.md      # ADDED/MODIFIED/REMOVED
    │
    └── archive/                 # 已完成的变更
        └── 2025-10-31-refactor-favorites/
            ├── proposal.md
            ├── tasks.md
            └── specs/
```

---

## 🛠️ 常用命令

### 查看信息
```bash
# 查看所有规范
openspec list --specs

# 查看进行中的变更
openspec list

# 查看特定变更详情
openspec show add-video-playback

# 查看特定规范详情
openspec show media-preview --type spec
```

### 验证
```bash
# 验证特定变更
openspec validate add-video-playback --strict

# 验证所有变更和规范
openspec validate --strict
```

### 搜索
```bash
# 搜索规范中的需求
rg -n "Requirement:" openspec/specs

# 搜索场景
rg -n "Scenario:" openspec/specs

# 搜索变更
rg -n "^#|Requirement:" openspec/changes
```

---

## 📝 规范编写规则

### ✅ 正确的场景格式
```markdown
#### Scenario: User login success
- **WHEN** valid credentials provided
- **THEN** return JWT token
```

### ❌ 错误的场景格式
```markdown
- **Scenario: User login**      # ❌ 不要用列表
**Scenario**: User login         # ❌ 不要用粗体
### Scenario: User login         # ❌ 不要用三个 #
```

### 需求措辞
- 使用 **SHALL** 或 **MUST** 表示强制要求
- 避免使用 "should" 或 "may"（除非是非强制性）

### Delta 操作类型
- `## ADDED Requirements` - 新增功能
- `## MODIFIED Requirements` - 修改现有功能
- `## REMOVED Requirements` - 删除功能
- `## RENAMED Requirements` - 重命名功能

---

## 💡 实际示例

### 示例 1: 添加下拉刷新功能

**1. 创建提案**
```bash
mkdir -p openspec/changes/add-pull-refresh/{specs/mood-list}
```

**2. proposal.md**
```markdown
## Why
用户希望能够刷新心情列表，看到随机重排的内容。

## What Changes
- 添加下拉刷新功能到心情列表页
- 实现内容随机重排逻辑

## Impact
- Affected specs: mood-list
- Affected code: lib/app/modules/mood/
```

**3. specs/mood-list/spec.md**
```markdown
## ADDED Requirements

### Requirement: Pull to Refresh
The system SHALL support pull-to-refresh to randomize mood list.

#### Scenario: Refresh mood list
- **WHEN** user pulls down the list
- **THEN** content is randomly reordered after 500ms delay
```

**4. 验证并实现**
```bash
openspec validate add-pull-refresh --strict
# 开始实现...
# 完成后归档
openspec archive add-pull-refresh --yes
```

---

## 🚨 常见错误

### 错误 1: "Change must have at least one delta"
**原因**: `changes/[name]/specs/` 目录为空或没有 `.md` 文件

**解决**:
```bash
# 确保创建了 spec delta 文件
ls openspec/changes/add-feature/specs/
```

### 错误 2: "Requirement must have at least one scenario"
**原因**: 场景格式不正确

**解决**:
```markdown
# ✅ 正确
#### Scenario: Success case
- **WHEN** ...
- **THEN** ...

# ❌ 错误
- **Scenario: Success case**
```

### 错误 3: "Scenario parsing failed"
**原因**: 场景标题格式不符合 `#### Scenario: Name`

**调试**:
```bash
openspec show [change] --json --deltas-only
```

---

## 🎓 最佳实践

### 1. 简单优先
- 默认实现 < 100 行代码
- 单文件实现，直到证明需要拆分
- 避免过度设计

### 2. 清晰引用
- 使用 `file.dart:42` 格式引用代码位置
- 使用 `specs/auth/spec.md` 引用规范

### 3. 能力命名
- 使用动词-名词: `media-preview`, `mood-list`
- 单一职责
- 10 分钟可理解规则

### 4. 变更 ID 命名
- 使用 kebab-case: `add-video-playback`
- 动词开头: `add-`, `update-`, `remove-`, `refactor-`
- 确保唯一性

---

## 📚 下一步

1. **阅读 `project.md`** - 了解项目约定
2. **查看现有规范** - `openspec list --specs`
3. **创建你的第一个提案** - 按照本指南操作
4. **寻求帮助** - 使用 `openspec show [item]` 查看详情

---

**最后更新**: 2025-11-02  
**适用项目**: Glasso (Flutter + GetX)


