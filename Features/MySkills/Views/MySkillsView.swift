import SwiftUI

/// 我的技能页面。
///
/// 页面职责：
/// 1. 展示用户已安装技能列表。
/// 2. 提供“一键执行”入口。
/// 3. 提供 Siri 短语设置入口（MVP 阶段使用服务占位交互）。
/// 4. 当没有已安装技能时展示统一空状态。
struct MySkillsView: View {
    /// 我的技能页状态对象。
    @StateObject private var viewModel = MySkillsViewModel()

    var body: some View {
        ZStack {
            TechBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    skillListSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("我的技能")
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

private extension MySkillsView {
    /// 顶部说明区。
    var heroSection: some View {
        GlassPanel(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(HomeTheme.accentOrange)

                    Text("我的技能库")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)
                }

                Text("已安装技能，随时执行")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("点击“执行”立即触发技能；点击“Siri 短语”可继续配置语音唤醒。")
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
            }
        }
    }

    /// 已安装技能列表区。
    var skillListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("已安装技能")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Spacer()

                Text("共 \(viewModel.installedSkillCount) 项")
                    .font(.caption)
                    .foregroundStyle(HomeTheme.textSecondary)
            }

            if viewModel.isEmpty {
                EmptyStateView(
                    title: "暂无已安装技能",
                    subtitle: "前往技能市场安装你的第一个技能",
                    systemImage: "tray.fill"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.installedSkills) { skill in
                        VStack(spacing: 8) {
                            // 复用通用技能卡片，保持与市场页一致的视觉语言。
                            SkillCardView(
                                skill: skill,
                                isInstalling: false,
                                isInstalled: true,
                                showsRankBadge: false,
                                showsEstimatedDuration: true
                            ) {
                                // 我的技能页不触发安装动作，按钮会展示“已安装”禁用态。
                            }

                            // 卡片下方动作区：执行 + Siri 短语设置入口。
                            actionBar(for: skill)
                        }
                    }
                }
            }
        }
    }

    /// 技能动作栏。
    /// - 包含：执行按钮、Siri 短语设置入口。
    func actionBar(for skill: SkillItem) -> some View {
        GlassPanel(
            cornerRadius: 12,
            contentPadding: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        ) {
            HStack(spacing: 10) {
                executeButton(for: skill)
                siriSetupButton(for: skill)
            }
        }
    }

    /// 一键执行按钮。
    func executeButton(for skill: SkillItem) -> some View {
        Button {
            Task {
                await viewModel.execute(skill: skill)
            }
        } label: {
            HStack(spacing: 6) {
                if viewModel.isExecuting(skill.id) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                    Text("执行中")
                } else {
                    Image(systemName: "bolt.fill")
                    Text("执行")
                }
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(HomeTheme.accentOrange)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: HomeTheme.accentOrangeShadow, radius: 7, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isExecuting(skill.id))
    }

    /// Siri 短语设置入口。
    func siriSetupButton(for skill: SkillItem) -> some View {
        Button {
            Task {
                await viewModel.openSiriShortcutEntry(for: skill)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "mic.fill")
                Text("Siri 短语")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(HomeTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(HomeTheme.accentRed.opacity(0.48), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MySkillsView()
    }
}
