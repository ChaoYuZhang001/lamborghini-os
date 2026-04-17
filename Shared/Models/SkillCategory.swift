import SwiftUI

/// 技能分类模型。
///
/// 设计说明：
/// 1. 使用 `CaseIterable` 便于市场页做分类筛选。
/// 2. 使用 `Codable` 便于后续与本地存储/网络接口对接。
/// 3. 统一提供展示文案、图标与主题色映射，确保黑橙超跑风格一致。
enum SkillCategory: String, CaseIterable, Identifiable, Codable {
    case all
    case work
    case life
    case travel
    case creativity
    case health

    /// 标准 `Identifiable` 主键。
    var id: String { rawValue }

    /// 分类中文名称（UI 展示用）。
    var displayName: String {
        switch self {
        case .all:
            return "全部"
        case .work:
            return "工作"
        case .life:
            return "生活"
        case .travel:
            return "出行"
        case .creativity:
            return "创作"
        case .health:
            return "健康"
        }
    }

    /// 分类图标（统一 SF Symbols）。
    var systemImage: String {
        switch self {
        case .all:
            return "square.grid.2x2.fill"
        case .work:
            return "briefcase.fill"
        case .life:
            return "house.fill"
        case .travel:
            return "car.fill"
        case .creativity:
            return "wand.and.stars"
        case .health:
            return "heart.fill"
        }
    }

    /// 分类主色。
    /// 说明：必须从 `HomeTheme` 取色，保证全局视觉风格统一。
    var accentColor: Color {
        switch self {
        case .all:
            return HomeTheme.accentOrange
        case .work:
            return HomeTheme.accentOrange
        case .life:
            return HomeTheme.accentRed
        case .travel:
            return HomeTheme.accentOrange
        case .creativity:
            return HomeTheme.accentRed
        case .health:
            return HomeTheme.accentRed
        }
    }

    /// 分类渐变色。
    /// 说明：用于分类胶囊、卡片徽标等高亮 UI。
    var accentGradient: LinearGradient {
        switch self {
        case .all:
            return LinearGradient(
                colors: [HomeTheme.accentOrange, HomeTheme.accentRed],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .work:
            return LinearGradient(
                colors: [HomeTheme.accentOrange, HomeTheme.accentOrange.opacity(0.78)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .life:
            return LinearGradient(
                colors: [HomeTheme.accentRed, HomeTheme.accentRed.opacity(0.75)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .travel:
            return LinearGradient(
                colors: [HomeTheme.accentOrange, HomeTheme.accentRed.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .creativity:
            return LinearGradient(
                colors: [HomeTheme.accentRed, HomeTheme.accentOrange.opacity(0.72)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .health:
            return LinearGradient(
                colors: [HomeTheme.accentRed, HomeTheme.accentOrange.opacity(0.62)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    /// 分类关键词（用于自然语言搜索时做基础匹配）。
    var searchKeywords: [String] {
        switch self {
        case .all:
            return ["全部", "所有"]
        case .work:
            return ["工作", "办公", "专注", "会议"]
        case .life:
            return ["生活", "睡眠", "居家", "提醒"]
        case .travel:
            return ["出行", "导航", "通勤", "打车"]
        case .creativity:
            return ["创作", "截图", "拼图", "内容"]
        case .health:
            return ["健康", "运动", "冥想", "喝水"]
        }
    }
}
