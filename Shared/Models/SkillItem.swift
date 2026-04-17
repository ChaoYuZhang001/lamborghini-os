import Foundation

/// 技能基础模型。
///
/// 设计说明：
/// 1. 覆盖 MVP 阶段市场页/我的技能页的核心展示字段。
/// 2. 使用 `Codable` 便于后续接入本地持久化与网络接口。
/// 3. `isInstalled` 为可变字段，用于 UI 的即时安装状态反馈。
struct SkillItem: Identifiable, Hashable, Codable {
    /// 技能唯一标识。
    let id: String

    /// 技能标题。
    var title: String

    /// 技能简要描述。
    var description: String

    /// 技能所属分类。
    var category: SkillCategory

    /// 推荐触发短语（Siri / 自然语言触发）。
    var triggerPhrase: String

    /// 预计执行时长文案。
    /// 示例："约 2 秒"
    var estimatedDuration: String

    /// 安装量（用于热度感知）。
    var installationCount: Int

    /// 热度排名（数字越小越靠前）。
    var rank: Int

    /// 可能涉及的权限说明。
    var requiredPermissions: [String]

    /// 最近更新时间。
    var updatedAt: Date

    /// 是否已安装。
    var isInstalled: Bool

    /// 是否为推荐技能。
    var isFeatured: Bool
}

// MARK: - 展示辅助

extension SkillItem {
    /// 兼容旧字段命名（用于已有组件过渡）。
    var popularityRank: Int { rank }

    /// 兼容旧字段命名（用于已有组件过渡）。
    var estimatedDurationText: String { estimatedDuration }

    /// 热榜文本展示。
    var rankText: String {
        "TOP \(rank)"
    }

    /// 安装按钮文案。
    var installButtonTitle: String {
        isInstalled ? "已安装" : "安装"
    }

    /// 搜索文本池（标题 + 描述 + 触发短语 + 分类关键词）。
    var searchableTextTokens: [String] {
        [title, description, triggerPhrase] + category.searchKeywords
    }
}

// MARK: - Mock 快捷入口（统一转发到 MockDataProvider）

extension SkillItem {
    /// 技能市场假数据。
    static var marketMocks: [SkillItem] {
        MockDataProvider.marketSkills()
    }

    /// 已安装技能假数据（供“我的技能”页面使用）。
    static var installedMocks: [SkillItem] {
        MockDataProvider.installedSkills()
    }
}
