import SwiftUI

/// 通用技能卡片组件。
///
/// 适用场景：
/// 1. 技能市场：展示技能摘要并提供一键安装。
/// 2. 我的技能：展示已安装技能信息，并复用统一状态按钮。
///
/// 设计要点：
/// - 视觉统一：复用 HomeTheme + GlassPanel（黑橙超跑科技风）。
/// - 交互统一：复用 InstallActionButton 三态按钮。
/// - 结构清晰：支持标题、描述、分类、触发词、预计耗时等基础信息。
struct SkillCardView: View {
    /// 技能数据模型。
    let skill: SkillItem

    /// 当前是否正在安装。
    let isInstalling: Bool

    /// 当前是否已安装。
    let isInstalled: Bool

    /// 点击安装按钮回调。
    /// 说明：当按钮处于安装中/已安装态时，InstallActionButton 会自动禁用。
    let onInstallTap: () -> Void

    /// 是否展示热度排行标签。
    /// 市场页可开启；我的技能页可按需关闭。
    let showsRankBadge: Bool

    /// 是否展示“预计耗时”。
    let showsEstimatedDuration: Bool

    /// 卡片圆角大小。
    let cornerRadius: CGFloat

    /// 便捷初始化。
    init(
        skill: SkillItem,
        isInstalling: Bool,
        isInstalled: Bool,
        showsRankBadge: Bool = true,
        showsEstimatedDuration: Bool = true,
        cornerRadius: CGFloat = 16,
        onInstallTap: @escaping () -> Void
    ) {
        self.skill = skill
        self.isInstalling = isInstalling
        self.isInstalled = isInstalled
        self.showsRankBadge = showsRankBadge
        self.showsEstimatedDuration = showsEstimatedDuration
        self.cornerRadius = cornerRadius
        self.onInstallTap = onInstallTap
    }

    var body: some View {
        GlassPanel(cornerRadius: cornerRadius) {
            VStack(alignment: .leading, spacing: 12) {
                headerRow
                titleDescriptionSection
                metadataSection
                actionSection
            }
        }
        .overlay(
            // 额外细描边，让卡片在深色背景下更有“精密机械”层次感。
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5)
        )
    }
}

// MARK: - Private Sections

private extension SkillCardView {
    /// 顶部信息行：热度标签 + 分类标签。
    var headerRow: some View {
        HStack {
            if showsRankBadge {
                Text(skill.rankText)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(HomeTheme.badgeGradient, in: Capsule())
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: skill.category.systemImage)
                Text(skill.category.displayName)
            }
            .font(.caption)
            .foregroundStyle(HomeTheme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.06), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
    }

    /// 标题与描述区。
    var titleDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(skill.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(HomeTheme.textPrimary)
                .lineLimit(1)

            Text(skill.description)
                .font(.subheadline)
                .foregroundStyle(HomeTheme.textSecondary)
                .lineLimit(2)
        }
    }

    /// 元信息区：触发短语与预计耗时。
    var metadataSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "waveform.and.mic")
                    .foregroundStyle(HomeTheme.accentOrange)
                Text("触发词：\(skill.triggerPhrase)")
                    .foregroundStyle(HomeTheme.textSecondary)
            }
            .font(.caption)

            if showsEstimatedDuration {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(HomeTheme.accentRed)
                    Text("预计耗时：\(skill.estimatedDurationText)")
                        .foregroundStyle(HomeTheme.textSecondary)
                }
                .font(.caption)
            }
        }
    }

    /// 按钮操作区。
    var actionSection: some View {
        HStack {
            Text("安装量 \(formattedInstallationCount)")
                .font(.caption)
                .foregroundStyle(HomeTheme.textMuted)

            Spacer()

            InstallActionButton(
                isInstalling: isInstalling,
                isInstalled: isInstalled,
                compact: false,
                action: onInstallTap
            )
        }
    }

    /// 安装量格式化展示。
    var formattedInstallationCount: String {
        if skill.installationCount >= 10_000 {
            let value = Double(skill.installationCount) / 10_000.0
            return String(format: "%.1f万", value)
        }
        return "\(skill.installationCount)"
    }
}

#Preview {
    ZStack {
        TechBackgroundView()

        VStack(spacing: 14) {
            SkillCardView(
                skill: .marketMocks[0],
                isInstalling: false,
                isInstalled: false,
                showsRankBadge: true
            ) {}

            SkillCardView(
                skill: .marketMocks[1],
                isInstalling: true,
                isInstalled: false,
                showsRankBadge: false
            ) {}

            SkillCardView(
                skill: .marketMocks[2],
                isInstalling: false,
                isInstalled: true,
                showsRankBadge: true
            ) {}
        }
        .padding(16)
    }
}
