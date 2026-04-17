import SwiftUI

/// 技能市场页 ViewModel（最终优化版）。
///
/// 设计目标：
/// 1. 承接市场页全部交互状态：搜索、分类筛选、安装状态、提示弹窗。
/// 2. 全量统一使用 `SkillItem` 模型。
/// 3. 使用 `MockDataProvider` 作为统一假数据入口。
@MainActor
final class MarketViewModel: ObservableObject {
    // MARK: - Published State

    /// 市场全量技能列表。
    @Published var allSkills: [SkillItem] = []

    /// 当前选中的分类。
    @Published var selectedCategory: SkillCategory = .all

    /// 搜索文本（自然语言）。
    @Published var searchText: String = ""

    /// 当前安装中的技能 ID 集合。
    @Published var installingSkillIDs: Set<String> = []

    /// 页面加载状态。
    @Published var isLoading: Bool = false

    /// 弹窗提示文案。
    @Published var alertMessage: String = ""

    /// 是否展示弹窗提示。
    @Published var showAlert: Bool = false

    // MARK: - Private State

    /// 防止重复初始化加载。
    private var hasLoaded: Bool = false

    // MARK: - Static Config

    /// 分类展示顺序（固定顺序，避免枚举顺序变化影响 UI）。
    let categoryOrder: [SkillCategory] = [.all, .work, .life, .creativity, .travel, .health]

    // MARK: - Derived State

    /// 去除空白后的搜索关键词。
    var trimmedKeyword: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 当前是否处于搜索状态。
    var isSearching: Bool {
        !trimmedKeyword.isEmpty
    }

    /// 过滤后的技能列表（分类 + 搜索关键词）。
    var filteredSkills: [SkillItem] {
        allSkills
            .filter { skill in
                let categoryMatched = selectedCategory == .all || skill.category == selectedCategory
                let keywordMatched = !isSearching || skill.searchableTextTokens.contains {
                    $0.localizedCaseInsensitiveContains(trimmedKeyword)
                }
                return categoryMatched && keywordMatched
            }
            .sorted(by: { $0.rank < $1.rank })
    }

    // MARK: - Public Actions

    /// 首次进入页面加载数据（仅执行一次）。
    func loadInitialDataIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        isLoading = true
        defer { isLoading = false }

        do {
            // 模拟异步加载耗时。
            try await Task.sleep(nanoseconds: 200_000_000)
            allSkills = MockDataProvider.marketSkills()
        } catch is CancellationError {
            // 页面切换取消任务时静默处理。
        } catch {
            presentAlert("技能市场加载失败：\(error.localizedDescription)")
        }
    }

    /// 设置分类筛选。
    func selectCategory(_ category: SkillCategory) {
        selectedCategory = category
    }

    /// 清空搜索关键词。
    func clearSearch() {
        searchText = ""
    }

    /// 安装技能。
    func install(skill: SkillItem) async {
        guard let index = allSkills.firstIndex(where: { $0.id == skill.id }) else { return }

        if allSkills[index].isInstalled {
            presentAlert("“\(allSkills[index].title)”已安装。")
            return
        }

        guard !installingSkillIDs.contains(skill.id) else { return }

        installingSkillIDs.insert(skill.id)
        defer { installingSkillIDs.remove(skill.id) }

        do {
            // 模拟安装耗时。
            try await Task.sleep(nanoseconds: 420_000_000)
            allSkills[index].isInstalled = true
            presentAlert("“\(allSkills[index].title)”安装成功，已加入我的技能。")
        } catch is CancellationError {
            presentAlert("安装已取消，请稍后重试。")
        } catch {
            presentAlert("安装失败：\(error.localizedDescription)")
        }
    }

    // MARK: - Query Helpers

    /// 查询技能是否正在安装中。
    func isInstalling(_ skillID: String) -> Bool {
        installingSkillIDs.contains(skillID)
    }

    /// 查询技能是否已安装。
    func isInstalled(_ skillID: String) -> Bool {
        allSkills.first(where: { $0.id == skillID })?.isInstalled ?? false
    }

    // MARK: - Private Helpers

    /// 统一弹窗出口。
    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
