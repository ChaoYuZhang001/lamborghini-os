import SwiftUI

/// 统一安装按钮组件。
///
/// 适用场景：
/// 1. 技能市场卡片的“安装/已安装”按钮。
/// 2. 首页推荐卡片的快捷安装按钮。
/// 3. 我的技能页里的状态化操作按钮。
///
/// 状态说明：
/// - 未安装：超跑橙实底 + 白字（主操作态）
/// - 安装中：橙色实底 + 加载动画 + 白字
/// - 已安装：弱化半透明底色 + 白字（禁用态）
struct InstallActionButton: View {
    /// 是否处于安装中。
    let isInstalling: Bool

    /// 是否已安装。
    let isInstalled: Bool

    /// 是否使用紧凑尺寸。
    /// - true：适用于横向卡片或空间受限区域。
    /// - false：适用于常规列表卡片。
    let compact: Bool

    /// 点击回调。
    /// 说明：当按钮处于“安装中”或“已安装”时会自动禁用，不会触发该回调。
    let action: () -> Void

    /// 便捷初始化。
    /// `compact` 默认 `false`，调用时可按需覆盖。
    init(
        isInstalling: Bool,
        isInstalled: Bool,
        compact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.isInstalling = isInstalling
        self.isInstalled = isInstalled
        self.compact = compact
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isInstalling {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }

                Text(buttonTitle)
                    .font(buttonFont)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minWidth: compact ? 70 : 84)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
        }
        .buttonStyle(.plain)
        .disabled(isInstalling || isInstalled)
        .accessibilityLabel(accessibilityText)
    }
}

// MARK: - Private Helpers

private extension InstallActionButton {
    /// 当前按钮文案。
    var buttonTitle: String {
        if isInstalling { return "安装中" }
        if isInstalled { return "已安装" }
        return "安装"
    }

    /// 无障碍朗读文案。
    var accessibilityText: String {
        if isInstalling { return "技能安装中" }
        if isInstalled { return "技能已安装" }
        return "安装技能"
    }

    /// 按钮字体，根据紧凑模式自动调整。
    var buttonFont: Font {
        compact ? .caption.weight(.semibold) : .footnote.weight(.semibold)
    }

    /// 水平内边距。
    var horizontalPadding: CGFloat {
        compact ? 12 : 14
    }

    /// 垂直内边距。
    var verticalPadding: CGFloat {
        compact ? 6 : 8
    }

    /// 圆角。
    var cornerRadius: CGFloat {
        compact ? 10 : 12
    }

    /// 背景色。
    /// 未安装和安装中都保持主操作橙色；已安装切换为弱化色。
    var backgroundColor: Color {
        isInstalled ? HomeTheme.installedButtonBackground : HomeTheme.accentOrange
    }

    /// 描边色。
    /// 已安装态描边更弱，避免视觉抢占。
    var borderColor: Color {
        isInstalled ? Color.white.opacity(0.16) : Color.white.opacity(0.22)
    }

    /// 阴影色。
    /// 仅主操作态保留橙色发光，已安装态去阴影。
    var shadowColor: Color {
        isInstalled ? .clear : HomeTheme.accentOrangeShadow
    }

    /// 阴影半径。
    var shadowRadius: CGFloat {
        compact ? 5 : 7
    }

    /// 阴影 Y 偏移。
    var shadowYOffset: CGFloat {
        compact ? 3 : 4
    }
}

#Preview {
    ZStack {
        HomeTheme.backgroundGradient.ignoresSafeArea()

        VStack(spacing: 12) {
            InstallActionButton(isInstalling: false, isInstalled: false, compact: false) {}
            InstallActionButton(isInstalling: true, isInstalled: false, compact: false) {}
            InstallActionButton(isInstalling: false, isInstalled: true, compact: false) {}
            InstallActionButton(isInstalling: false, isInstalled: false, compact: true) {}
        }
        .padding()
    }
}
