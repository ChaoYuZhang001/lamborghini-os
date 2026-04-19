# AGENTS.md

## 目标
本文件是 Codex 在本仓库执行任务时必须遵守的工程规则。所有改动都以《Lamborghini OS 产品说明书》为上位约束，禁止另起炉灶重写项目。

## 当前项目现状
- 四个主页面（Home / Market / MySkills / Profile）与对应 ViewModel 已完成基础结构。
- UI 视觉语言已稳定：黑橙超跑科技风（HomeTheme + Shared/Components）。
- 当前业务层仍有较多 Mock 数据。
- Core Data 基础能力已接入（PersistenceController + App 注入），但业务读写闭环未完全打通。
- Siri 目前真实能力仅包括授权状态查询与权限申请。
- Siri 短语添加 / Donation / App Intents 仍处于增量开发阶段。

## 架构硬约束
- 技术栈：SwiftUI + MVVM。
- 自动化能力必须基于系统能力：App Intents + SiriKit + Shortcuts。
- 禁止模拟点击、越狱、私有 API、动态脚本注入。
- 数据持久化统一使用 Core Data。
- 代码需具备：详细中文注释、必要错误处理、权限检查。
- 必须符合 App Store 审核指南。

## 目录硬约束
必须保留并沿用以下主目录，不做大规模重排：
- App
- Data
- Features
- Services
- Shared
- Theme

## 数据源约定（强制执行）
- 技能目录数据：当前仍可由 `MockDataProvider.swift` 提供
- 技能安装状态：应逐步迁移到 `Core Data`
- 我的技能列表：应以本地安装记录为准
- 个人中心统计：应基于本地真实数据生成
- Siri 权限状态：以系统真实返回结果为准
- Siri 短语添加 / Donation / App Intents：当前未完全落地，属于增量开发范围

## 开发策略
- 不要大改 UI 风格。
- 不要重写项目。
- 优先最小改动（small, safe, incremental）。
- 优先完成 Mock -> Core Data 迁移，先状态闭环，再增强能力。
- Siri 相关开发按阶段推进，不跨阶段一次性重构。

## 组件复用规则
- HomeView / MarketView / MySkillsView / ProfileView 仅做页面组合。
- 通用 UI 一律复用 Shared/Components：
  - InstallActionButton
  - GlassPanel
  - TechBackgroundView
  - SkillCardView
  - EmptyStateView
- 禁止在业务页面重复定义上述通用组件。

## 每次任务交付要求
每次任务结束必须输出：
1. 改动文件清单
2. 风险点与回滚点
3. Xcode 验证步骤与结果（通过/未通过）

## Xcode 最低验证清单
- Clean Build 通过。
- App 可启动并进入主 Tab。
- 四个 Tab 切换正常。
- 安装/执行/搜索流程无崩溃。
- 若任务涉及持久化：重启后状态可保留。
- 若任务涉及 Siri：权限与入口行为符合预期。
