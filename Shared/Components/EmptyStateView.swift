import SwiftUI

/// 通用空状态组件。
///
/// 适用场景：
/// 1. 搜索无结果（例如：未匹配到技能）。
/// 2. 列表暂无数据（例如：我的技能为空）。
/// 3. 某功能未初始化或尚未配置。
///
/// 设计目标：
/// - 统一风格：使用 HomeTheme 黑橙超跑科技视觉。
/// - 易于复用：支持标题、副标题、系统图标配置。
/// - 易于落地：默认内置玻璃拟态效果，页面直接调用即可。
struct EmptyStateView: View {
    /// 主标题。
    let title: String

    /// 副标题说明。
    let subtitle: String

    /// SF Symbols 图标名。
    let systemImage: String

    /// 图标强调色。
    /// 默认使用品牌主强调色（超跑橙）。
    let iconColor: Color

    /// 面板圆角。
    let cornerRadius: CGFloat

    /// 便捷初始化。
    ///
    /// - Parameters:
    ///   - title: 主标题文本。
    ///   - subtitle: 副标题文本。
    ///   - systemImage: 图标名称，默认 `magnifyingglass`。
    ///   - iconColor: 图标颜色，默认 HomeTheme.accentOrange。
    ///   - cornerRadius: 面板圆角，默认 14。
    init(
        title: String,
        subtitle: String,
        systemImage: String = "magnifyingglass",
        iconColor: Color = HomeTheme.accentOrange,
        cornerRadius: CGFloat = 14
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.iconColor = iconColor
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GlassPanel(
            cornerRadius: cornerRadius,
            contentPadding: EdgeInsets(top: 18, leading: 14, bottom: 18, trailing: 14)
        ) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        TechBackgroundView()

        VStack(spacing: 14) {
            EmptyStateView(
                title: "暂无匹配技能",
                subtitle: "请尝试关键词：工作模式、助眠、截图拼接",
                systemImage: "magnifyingglass"
            )

            EmptyStateView(
                title: "你还没有安装技能",
                subtitle: "前往技能市场获取第一个技能，打造你的 AI 生活管家",
                systemImage: "tray.fill",
                iconColor: HomeTheme.accentRed
            )
        }
        .padding(16)
    }
}
