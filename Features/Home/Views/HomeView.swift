import SwiftUI

/// 首页（发现页，轻量最终版）。
///
/// 重构原则：
/// 1. 本文件只负责页面布局与状态绑定。
/// 2. 通用 UI 全部复用 Shared/Components：
///    - TechBackgroundView
///    - GlassPanel
///    - InstallActionButton
///    - SkillCardView
///    - EmptyStateView
/// 3. 业务逻辑统一交由 HomeViewModel 管理。
struct HomeView: View {
    /// 首页状态对象。
    @StateObject private var viewModel = HomeViewModel()

    /// 自然语言搜索文本。
    @State private var searchText: String = ""

    /// 去除首尾空白后的关键词。
    private var trimmedKeyword: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 是否处于搜索状态。
    private var isSearching: Bool {
        !trimmedKeyword.isEmpty
    }

    /// 根据关键词过滤热门技能。
    private var filteredHotSkills: [SkillItem] {
        guard isSearching else { return viewModel.hotSkills }

        return viewModel.hotSkills.filter { skill in
            skill.searchableTextTokens.contains { token in
                token.localizedCaseInsensitiveContains(trimmedKeyword)
            }
        }
    }

    var body: some View {
        ZStack {
            TechBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    searchSection
                    recommendationSection
                    hotSkillsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("发现")
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

private extension HomeView {
    /// 顶部品牌 Header。
    var heroSection: some View {
        GlassPanel(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(HomeTheme.accentOrange)

                    Text("AI 生活管家")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)
                }

                Text("AI 生活管家 · 像超跑一样迅猛执行")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("开口即触发，点按即执行")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.accentOrange)
            }
        }
    }

    /// 自然语言搜索区。
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("自然语言搜索", subtitle: "一句话描述需求，AI 自动匹配技能")

            GlassPanel(
                cornerRadius: 14,
                contentPadding: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
            ) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(HomeTheme.accentOrange)

                    TextField("例如：帮我把截图拼成长图", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                        .foregroundStyle(HomeTheme.textPrimary)

                    if isSearching {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(HomeTheme.textMuted)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("清空搜索内容")
                    }
                }
            }

            if isSearching {
                Text("AI 已为你匹配以下技能")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HomeTheme.accentOrange)
            }
        }
    }

    /// AI 推荐区。
    ///
    /// 约束说明：推荐区技能卡与热门区技能卡统一复用 SkillCardView，
    /// 保证组件一致性并避免 HomeView 内重复实现卡片逻辑。
    var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("AI 智能推荐", subtitle: "根据高频场景与执行效率优先级")

            if viewModel.recommendedSkills.isEmpty {
                EmptyStateView(
                    title: "暂无推荐技能",
                    subtitle: "请稍后再试，AI 正在学习你的使用偏好",
                    systemImage: "sparkles"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recommendedSkills) { skill in
                            SkillCardView(
                                skill: skill,
                                isInstalling: viewModel.isInstalling(skill.id),
                                isInstalled: viewModel.isInstalled(skill.id),
                                showsRankBadge: false,
                                showsEstimatedDuration: false,
                                cornerRadius: 18
                            ) {
                                Task {
                                    await viewModel.installRecommendedSkill(skill)
                                }
                            }
                            .frame(width: 280)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    /// 热门技能榜单区。
    var hotSkillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("热门技能榜单", subtitle: "共 \(filteredHotSkills.count) 项")

            if viewModel.isLoading && filteredHotSkills.isEmpty {
                ProgressView("正在加载热门技能…")
                    .tint(HomeTheme.accentOrange)
                    .foregroundStyle(HomeTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else if filteredHotSkills.isEmpty {
                EmptyStateView(
                    title: "暂无匹配技能",
                    subtitle: "请尝试关键词：工作模式、助眠、截图拼接",
                    systemImage: "magnifyingglass"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredHotSkills) { skill in
                        SkillCardView(
                            skill: skill,
                            isInstalling: viewModel.isInstalling(skill.id),
                            isInstalled: viewModel.isInstalled(skill.id),
                            showsRankBadge: true,
                            showsEstimatedDuration: true
                        ) {
                            Task {
                                await viewModel.install(skill: skill)
                            }
                        }
                    }
                }
            }
        }
    }

    /// 统一分区标题样式。
    func sectionTitle(_ title: String, subtitle: String) -> some View {
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

#Preview {
    NavigationStack {
        HomeView()
    }
}
