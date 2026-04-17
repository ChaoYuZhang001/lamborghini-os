import SwiftUI

/// 个人中心页面。
///
/// 页面职责：
/// 1. 展示账号与同步信息。
/// 2. 提供隐私与权限管理入口。
/// 3. 提供帮助与反馈入口。
/// 4. 展示开源声明与关于项目信息（含免责声明要点）。
struct ProfileView: View {
    /// 个人中心状态对象。
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            TechBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    accountAndSyncSection
                    privacySection
                    helpSection
                    openSourceAndAboutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("个人中心")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(HomeTheme.backgroundTop.opacity(0.88), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.loadInitialDataIfNeeded()
        }
        .alert("提示", isPresented: $viewModel.showAlert) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// MARK: - Sections

private extension ProfileView {
    /// 页面头部品牌信息。
    var heroSection: some View {
        GlassPanel(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(HomeTheme.accentOrange)

                    Text("Lamborghini OS 账户")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)
                }

                Text("管理你的账号、隐私与开源信息")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("AI 生活管家的数据与权限在这里集中管理，保持透明、可控、可追溯。")
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
            }
        }
    }

    /// 账号与同步区域。
    var accountAndSyncSection: some View {
        GlassPanel(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                ProfileSectionHeader(
                    title: "账号与同步",
                    subtitle: "账户信息与多设备数据同步状态"
                )

                ProfileInfoRow(
                    icon: "person.fill",
                    title: "当前账号",
                    value: viewModel.currentAccountEmail
                )

                ProfileInfoRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "同步状态",
                    value: viewModel.syncStatusText
                )

                ProfileInfoRow(
                    icon: "clock.arrow.circlepath",
                    title: "最近同步",
                    value: viewModel.lastSyncDescription
                )

                ProfileInfoRow(
                    icon: "wand.and.stars",
                    title: "已安装技能",
                    value: "\(viewModel.installedSkillCount) 项"
                )

                Toggle(
                    isOn: Binding(
                        get: { viewModel.isAutoSyncEnabled },
                        set: { viewModel.setAutoSyncEnabled($0) }
                    )
                ) {
                    Label("自动同步", systemImage: "icloud.fill")
                        .foregroundStyle(HomeTheme.textPrimary)
                }
                .tint(HomeTheme.accentOrange)
            }
        }
    }

    /// 隐私与权限管理区域。
    var privacySection: some View {
        GlassPanel(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 10) {
                ProfileSectionHeader(
                    title: "隐私与权限管理",
                    subtitle: "最小权限原则，按需授权，可随时调整"
                )

                ForEach(viewModel.privacyActions) { item in
                    ProfileActionRow(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle
                    ) {
                        viewModel.handleActionTap(item.actionType)
                    }
                }
            }
        }
    }

    /// 帮助与反馈区域。
    var helpSection: some View {
        GlassPanel(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 10) {
                ProfileSectionHeader(
                    title: "帮助与反馈",
                    subtitle: "问题解答、需求反馈与社区支持"
                )

                ForEach(viewModel.helpActions) { item in
                    ProfileActionRow(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle
                    ) {
                        viewModel.handleActionTap(item.actionType)
                    }
                }
            }
        }
    }

    /// 开源声明与关于项目区域。
    ///
    /// 内容基于产品说明书中的免责声明与合规声明要点。
    var openSourceAndAboutSection: some View {
        GlassPanel(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 10) {
                ProfileSectionHeader(
                    title: "开源声明与关于项目",
                    subtitle: "透明、合规、社区驱动"
                )

                ProfileInfoRow(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "开源许可证",
                    value: viewModel.licenseName
                )

                ProfileInfoRow(
                    icon: "building.columns.fill",
                    title: "项目性质",
                    value: viewModel.projectNature
                )

                // 免责声明摘要（来自产品说明书第 14 章与第 11 章核心要点）。
                Text("免责声明摘要")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)
                    .padding(.top, 2)

                Text(viewModel.disclaimerSummary)
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
                    .lineSpacing(3)

                ForEach(viewModel.openSourceActions) { item in
                    ProfileActionRow(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle
                    ) {
                        viewModel.handleActionTap(item.actionType)
                    }
                }
            }
        }
    }
}

// MARK: - Reusable Rows

/// 个人中心分区标题组件。
private struct ProfileSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(HomeTheme.textPrimary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(HomeTheme.textSecondary)
        }
    }
}

/// 只读信息行组件。
private struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(HomeTheme.accentOrange)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(HomeTheme.textMuted)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(HomeTheme.textPrimary)
            }

            Spacer(minLength: 0)
        }
    }
}

/// 可点击动作行组件。
private struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(HomeTheme.accentOrange)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(HomeTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HomeTheme.textMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
