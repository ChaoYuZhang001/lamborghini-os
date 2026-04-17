import SwiftUI

/// Lamborghini OS 全局视觉主题（黑橙超跑科技风）。
///
/// 设计原则：
/// 1. 主背景采用深黑/炭黑，突出“高级、克制、力量感”。
/// 2. 强调色采用超跑橙 + 深红，强调速度与执行力。
/// 3. 面板统一使用半透明暗底，便于叠加 glassmorphism（玻璃拟态）效果。
/// 4. 文本颜色统一抽象，保证在深色背景上的可读性与一致性。
enum HomeTheme {

    // MARK: - 背景色

    /// 页面顶部背景色（深黑）。
    static let backgroundTop = Color(red: 0.05, green: 0.05, blue: 0.07)

    /// 页面底部背景色（炭黑）。
    static let backgroundBottom = Color(red: 0.11, green: 0.11, blue: 0.13)

    // MARK: - 品牌强调色

    /// 超跑橙（品牌主强调色）。
    /// 说明：用于主按钮、关键图标、激活态控件。
    static let accentOrange = Color(red: 1.0, green: 0.38, blue: 0.0)

    /// 力量深红（辅助强调色）。
    /// 说明：用于能量感渐变与风险/警示语境的高亮。
    static let accentRed = Color(red: 0.95, green: 0.15, blue: 0.18)

    // MARK: - 面板与输入控件

    /// 通用玻璃面板底色（半透明暗层）。
    static let panelBackground = Color.white.opacity(0.06)

    /// 通用面板描边（用于提升层次）。
    static let panelBorder = Color.white.opacity(0.12)

    /// 输入框底色（略亮于普通面板，便于聚焦）。
    static let inputBackground = Color.white.opacity(0.08)

    /// 已安装按钮底色（弱化状态，避免与主操作冲突）。
    static let installedButtonBackground = Color.white.opacity(0.16)

    // MARK: - 文本语义色

    /// 主文本（高对比白色）。
    static let textPrimary = Color.white

    /// 次级文本（说明文案、辅助信息）。
    static let textSecondary = Color.white.opacity(0.72)

    /// 弱化文本（占位提示、非关键信息）。
    static let textMuted = Color.white.opacity(0.50)

    // MARK: - 渐变与阴影辅助

    /// 页面全局背景渐变。
    static let backgroundGradient = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 榜单标签渐变（TOP 徽标常用）。
    static let badgeGradient = LinearGradient(
        colors: [accentOrange, accentRed],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// 橙色发光阴影（用于主按钮/关键卡片）。
    static let accentOrangeShadow = accentOrange.opacity(0.32)

    /// 红色发光阴影（用于辅助能量卡片）。
    static let accentRedShadow = accentRed.opacity(0.28)
}
