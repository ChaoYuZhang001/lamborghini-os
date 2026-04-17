import SwiftUI

/// 可复用的科技背景视图（深黑渐变 + 橙红光斑）。
///
/// 设计目标：
/// 1. 为 Home / Market / MySkills / Profile 提供统一底色氛围。
/// 2. 保持“黑橙超跑科技风”：克制、锐利、有速度感。
/// 3. 通过轻微模糊与偏移营造能量流动感，但不过度装饰。
struct TechBackgroundView: View {
    /// 是否显示右上角橙色能量光斑。
    let showsTopGlow: Bool

    /// 是否显示左下角红色能量光斑。
    let showsBottomGlow: Bool

    /// 顶部橙色光斑透明度（0~1）。
    let topGlowOpacity: Double

    /// 底部红色光斑透明度（0~1）。
    let bottomGlowOpacity: Double

    /// 初始化方法。
    ///
    /// - Parameters:
    ///   - showsTopGlow: 是否显示顶部光斑，默认 true。
    ///   - showsBottomGlow: 是否显示底部光斑，默认 true。
    ///   - topGlowOpacity: 顶部光斑透明度，默认 0.16。
    ///   - bottomGlowOpacity: 底部光斑透明度，默认 0.14。
    init(
        showsTopGlow: Bool = true,
        showsBottomGlow: Bool = true,
        topGlowOpacity: Double = 0.16,
        bottomGlowOpacity: Double = 0.14
    ) {
        self.showsTopGlow = showsTopGlow
        self.showsBottomGlow = showsBottomGlow
        self.topGlowOpacity = topGlowOpacity
        self.bottomGlowOpacity = bottomGlowOpacity
    }

    var body: some View {
        HomeTheme.backgroundGradient
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                if showsTopGlow {
                    Circle()
                        .fill(HomeTheme.accentOrange.opacity(topGlowOpacity))
                        .frame(width: 260, height: 260)
                        // 较大模糊半径让光斑更柔和，避免“硬边”显得廉价。
                        .blur(radius: 90)
                        // 偏移制造“从画面外射入”的速度感。
                        .offset(x: 90, y: -80)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if showsBottomGlow {
                    Circle()
                        .fill(HomeTheme.accentRed.opacity(bottomGlowOpacity))
                        .frame(width: 280, height: 280)
                        .blur(radius: 95)
                        .offset(x: -90, y: 120)
                }
            }
    }
}

#Preview {
    ZStack {
        TechBackgroundView()

        GlassPanel(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Lamborghini OS")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("深黑渐变 + 橙红光斑背景，强调速度与力量感。")
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
            }
        }
        .padding(24)
    }
}
