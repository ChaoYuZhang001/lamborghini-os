import SwiftUI

/// 技能市场页面。
///
/// 页面职责：
/// 1. 提供自然语言搜索入口。
/// 2. 提供技能分类筛选。
/// 3. 展示技能列表并支持一键安装。
/// 4. 在无结果时提供统一空状态反馈。
struct MarketView: View {
    /// 市场页状态对象。
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        ZStack {
            TechBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    searchSection
                    categorySection
                    resultSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("技能市场")
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

private extension MarketView {
    /// 页面头部说明区。
    var heroSection: some View {
        GlassPanel(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(HomeTheme.accentOrange)

                    Text("技能市场")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(HomeTheme.textPrimary)
                }

                Text("自然语言找技能，像超跑一样快速执行")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("发现并安装社区高频技能，打造你的 AI 生活管家。")
                    .font(.footnote)
                    .foregroundStyle(HomeTheme.textSecondary)
            }
        }
    }

    /// 搜索区（自然语言）。
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("自然语言搜索")
                .font(.headline.weight(.semibold))
                .foregroundStyle(HomeTheme.textPrimary)

            GlassPanel(cornerRadius: 14, contentPadding: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(HomeTheme.accentOrange)

                    TextField("例如：帮我快速进入工作模式", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                        .foregroundStyle(HomeTheme.textPrimary)

                    if viewModel.isSearching {
                        Button {
                            viewModel.clearSearch()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(HomeTheme.textMuted)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("清空搜索内容")
                    }
                }
            }

            if viewModel.isSearching {
                Text("AI 已为你匹配以下技能")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HomeTheme.accentOrange)
            }
        }
    }

    /// 分类筛选区。
    var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("分类浏览")
                .font(.headline.weight(.semibold))
                .foregroundStyle(HomeTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.categoryOrder) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.systemImage)
                                Text(category.displayName)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if viewModel.selectedCategory == category {
                                        HomeTheme.badgeGradient
                                    } else {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                },
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        viewModel.selectedCategory == category ? Color.white.opacity(0.20) : HomeTheme.panelBorder,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// 结果区：技能卡片列表 / 空状态。
    var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("可用技能")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Spacer()

                Text("共 \(viewModel.filteredSkills.count) 项")
                    .font(.caption)
                    .foregroundStyle(HomeTheme.textSecondary)
            }

            if viewModel.filteredSkills.isEmpty {
                EmptyStateView(
                    title: "暂无匹配技能",
                    subtitle: "请尝试更换关键词或切换分类筛选",
                    systemImage: "magnifyingglass"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredSkills) { skill in
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
}

#Preview {
    NavigationStack {
        MarketView()
    }
}
