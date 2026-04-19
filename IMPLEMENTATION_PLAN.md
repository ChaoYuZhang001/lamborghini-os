# IMPLEMENTATION_PLAN.md

## 计划说明
本计划基于《Lamborghini OS 产品说明书》与当前仓库代码状态制定，目标是在不重写项目、不破坏现有 UI 风格的前提下完成 iOS MVP 的本地真实闭环。

## 数据源基线约定（所有阶段生效）
- 技能目录数据：当前仍可由 `MockDataProvider.swift` 提供
- 技能安装状态：应逐步迁移到 `Core Data`
- 我的技能列表：应以本地安装记录为准
- 个人中心统计：应基于本地真实数据生成
- Siri 权限状态：以系统真实返回结果为准
- Siri 短语添加 / Donation / App Intents：当前未完全落地，属于增量开发范围

---

## 阶段 1：项目可编译、可启动

### 目标
确保工程在 Xcode 中可稳定编译、启动，并可浏览四个主 Tab。

### 当前差距
- 结构已齐备，但需要持续校验 target membership、引用完整性与启动流程稳定性。

### 涉及文件
- `LamborghiniOS.xcodeproj/project.pbxproj`
- `App/LamborghiniOSApp.swift`
- `App/MainTabView.swift`
- `Features/*/Views/*.swift`

### 具体任务
1. 校验所有 Swift 文件均加入主 target。
2. 校验入口链路（@main -> WindowGroup -> MainTabView）正确。
3. 修复 import / 构建告警 / 可见性问题。
4. 建立基础冒烟检查流程（四 Tab 切换 + 基础交互）。

### 风险
- 工程引用不一致导致构建失败。
- 文件移动后 target membership 丢失。

### Xcode 验证方式
1. Product > Clean Build Folder
2. 运行模拟器启动 App
3. 逐个进入四个 Tab，确认无崩溃

---

## 阶段 2：技能安装状态迁移到 Core Data

### 目标
把安装状态从 Mock 迁移到 Core Data，并保证重启后状态可保留。

### 当前差距
- 安装状态仍主要来自 Mock。
- Core Data 已注入但业务层未形成统一读写入口。

### 涉及文件
- `Data/PersistenceController.swift`
- `Data/LamborghiniOS.xcdatamodeld/*`
- `Data/MockDataProvider.swift`
- `Shared/Models/SkillItem.swift`
- `Features/Market/ViewModels/MarketViewModel.swift`
- `Features/Home/ViewModels/HomeViewModel.swift`
- `Features/MySkills/ViewModels/MySkillsViewModel.swift`
- `Services/*`（建议新增 SkillRepository/InstallStore）

### 具体任务
1. 定义 SkillItem 与 Core Data 实体映射（按 skill id 唯一）。
2. 新增安装状态 Repository：install/uninstall/fetchInstalled/isInstalled。
3. 市场页安装动作写入 Core Data。
4. 首页/市场页展示状态以 Core Data 安装记录覆盖 Mock 默认值。
5. 保持技能目录来源仍为 Mock（本阶段不引入网络）。

### 风险
- Core Data 并发上下文使用不当。
- 重复写入导致安装记录冲突。
- 各页面安装状态不同步。

### Xcode 验证方式
1. 市场安装技能后，“我的技能”立即可见。
2. 退出重启 App，安装状态仍保留。
3. 首页/市场/我的技能显示一致。

---

## 阶段 3：首页/市场/我的技能/个人中心本地业务闭环

### 目标
完成四页本地闭环：可安装、可执行、可统计、可反馈。

### 当前差距
- 页面逻辑已具备，但跨页面状态同步与统计真实化仍需统一。

### 涉及文件
- `Features/Home/*`
- `Features/Market/*`
- `Features/MySkills/*`
- `Features/Profile/*`
- `Services/*`
- `Shared/Models/SkillItem.swift`

### 具体任务
1. 我的技能列表统一改为读取本地安装记录。
2. 个人中心统计（已安装数、最近同步）改为本地真实计算。
3. 统一错误提示、空状态与加载状态。
4. 保持现有黑橙科技风格与组件复用策略。

### 风险
- 多页面刷新时机不一致造成状态抖动。
- ViewModel 逻辑重复导致后续维护成本上升。

### Xcode 验证方式
1. 安装后四页状态一致。
2. 搜索/筛选/执行流程可用且无崩溃。
3. 个人中心统计与本地记录一致。

---

## 阶段 4：Siri / App Intents 最小可用接入

### 目标
在合规范围内实现最小可用 Siri 链路。

### 当前差距
- 当前仅权限查询/申请为真实系统调用。
- Add to Siri、Donation、App Intents 仍待落地。

### 涉及文件
- `Services/SiriShortcutService.swift`
- `Features/MySkills/Views/MySkillsView.swift`
- `Features/MySkills/ViewModels/MySkillsViewModel.swift`
- 可能新增：`Features/Intents/*` 或 `Services/Intents/*`
- `App/*` 与相关能力配置文件

### 具体任务
1. 完善 Siri 权限拒绝/受限时的降级处理。
2. 实现最小 Donation 流程（安装或执行后触发）。
3. 增量接入 Add to Siri 入口。
4. 实现最小 App Intent：按 skill id 执行本地已安装技能。

### 风险
- iOS 版本行为差异。
- 真机验证成本高。
- Siri 能力接入时序不当会影响审核风险。

### Xcode 验证方式
1. 首次授权流程正确。
2. 已授权时可进入短语添加入口。
3. App Intent 能触发本地技能执行。

---

## 阶段 5：未来可选 AI / 后端扩展

### 目标
在 MVP 稳定后逐步扩展 AI 与云能力，同时保持本地优先。

### 当前差距
- 当前无后端、无线上技能目录、无账号体系。

### 涉及文件
- `Services/*`（新增远程 API / AI 推荐服务）
- `Data/*`（缓存与同步策略）
- `Features/Home|Market|Profile/*`

### 具体任务
1. 引入可开关的远程能力（Feature Flag）。
2. 构建本地优先 + 云端增量同步策略。
3. AI 推荐先做增强，不替代本地核心流程。
4. 设计最小可回滚方案，避免影响现有 MVP。

### 风险
- 网络依赖带来可用性与成本波动。
- 隐私合规与数据治理复杂度上升。

### Xcode 验证方式
1. 离线场景核心能力仍可用。
2. 开启远程增强后不影响本地主流程。
3. 关闭 Feature Flag 可快速回退。

---

## 里程碑完成定义（DoD）
- 阶段 1：可编译可启动
- 阶段 2：安装状态本地持久化
- 阶段 3：四页本地闭环完成
- 阶段 4：Siri 最小可用链路打通
- 阶段 5：可选扩展方案可灰度验证
