import SwiftUI

/// 通用玻璃拟态面板容器。
///
/// 设计目的：
/// 1. 为首页、市场页、我的技能页等模块提供统一的“玻璃面板”视觉。
/// 2. 保持黑橙超跑科技风格：半透明暗层 + 轻描边 + 材质感。
/// 3. 降低重复代码，后续只需包裹内容即可获得一致样式。
struct GlassPanel<Content: View>: View {
    /// 圆角大小。
    private let cornerRadius: CGFloat

    /// 内容内边距。
    private let contentPadding: EdgeInsets

    /// 面板内容。
    @ViewBuilder private let content: () -> Content

    /// 初始化方法。
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角大小，默认 16。
    ///   - contentPadding: 内容内边距，默认提供舒适阅读间距。
    ///   - content: 子视图内容。
    init(
        cornerRadius: CGFloat = 16,
        contentPadding: EdgeInsets = EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.contentPadding = contentPadding
        self.content = content
    }

    var body: some View {
        content()
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                // 背景由两层构成：
                // 1) HomeTheme.panelBackground：统一品牌深色半透明基底
                // 2) ultraThinMaterial：提供系统级玻璃质感
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(HomeTheme.panelBackground)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
            )
            .overlay(
                // 轻描边提升分层感，避免在深色背景中边界模糊。
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(HomeTheme.panelBorder, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        HomeTheme.backgroundGradient
            .ignoresSafeArea()

        VStack(spacing: 14) {
            GlassPanel(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI 生活管家")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)

                    Text("这是统一玻璃拟态面板示例，适用于市场卡片与设置面板。")
                        .font(.footnote)
                        .foregroundStyle(HomeTheme.textSecondary)
                }
            }

            GlassPanel(cornerRadius: 12, contentPadding: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(HomeTheme.accentOrange)

                    Text("超跑黑橙科技风样式已生效")
                        .font(.subheadline)
                        .foregroundStyle(HomeTheme.textPrimary)
                }
            }
        }
        .padding(20)
    }
}
