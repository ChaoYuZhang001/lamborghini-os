import SwiftUI
import Intents

/// 首页 ViewModel（最终优化版）。
///
/// 设计目标：
/// 1. 承接 Home 页全部状态与业务逻辑，View 层只负责布局。
/// 2. 全量统一使用 `SkillItem` 模型，保证与市场页/我的技能页一致。
/// 3. 使用 `MockDataProvider` 作为统一假数据入口。
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published State

    /// AI 推荐技能列表。
    @Published var recommendedSkills: [SkillItem] = []

    /// 热门技能榜单。
    @Published var hotSkills: [SkillItem] = []

    /// 正在安装中的技能 ID 集合。
    @Published var installingSkillIDs: Set<String> = []

    /// 已安装技能 ID 集合。
    @Published var installedSkillIDs: Set<String> = []

    /// 页面是否处于初始加载中。
    @Published var isLoading: Bool = false

    /// 弹窗提示文案。
    @Published var alertMessage: String = ""

    /// 是否展示弹窗提示。
    @Published var showAlert: Bool = false

    // MARK: - Private State

    /// 防止重复初始化加载。
    private var hasLoaded: Bool = false

    /// 缓存全量技能源，确保推荐区/热门区安装状态同步一致。
    private var cachedSkills: [SkillItem] = []

    // MARK: - Public Actions

    /// 首次进入首页时加载数据（只执行一次）。
    func loadInitialDataIfNeeded() async {
        guard !hasLoaded else { return }
        await reloadData(force: false)
    }

    /// 重新加载首页数据。
    ///
    /// - Parameter force: 是否强制忽略 `hasLoaded` 标记。
    func reloadData(force: Bool = true) async {
        if !force, hasLoaded { return }
        hasLoaded = true

        isLoading = true
        defer { isLoading = false }

        do {
            // 模拟接口耗时，保留真实异步节奏。
            try await Task.sleep(nanoseconds: 220_000_000)

            cachedSkills = MockDataProvider.marketSkills()
            applySnapshot(from: cachedSkills)
        } catch is CancellationError {
            // 页面切换触发取消时静默处理。
        } catch {
            presentAlert(message: "首页数据加载失败：\(error.localizedDescription)")
        }
    }

    /// 安装 AI 推荐区技能。
    func installRecommendedSkill(_ skill: SkillItem) async {
        await install(skill: skill)
    }

    /// 安装指定技能。
    ///
    /// 安装逻辑：
    /// 1. 已安装：直接提示。
    /// 2. 安装中：忽略重复点击。
    /// 3. 安装成功后同步更新推荐区与热门区状态。
    func install(skill: SkillItem) async {
        if isInstalled(skill.id) {
            presentAlert(message: "“\(skill.title)”已在我的技能中。")
            return
        }

        guard !isInstalling(skill.id) else { return }

        installingSkillIDs.insert(skill.id)
        defer { installingSkillIDs.remove(skill.id) }

        do {
            // 模拟安装耗时。
            try await Task.sleep(nanoseconds: 420_000_000)

            markInstalled(skillID: skill.id, isInstalled: true)

            let permissionTip = siriPermissionTip()
            let base = "“\(skill.title)”安装成功，已加入我的技能。"
            let message = permissionTip.map { "\(base)\n\n\($0)" } ?? base
            presentAlert(message: message)
        } catch is CancellationError {
            presentAlert(message: "安装已取消，请稍后重试。")
        } catch {
            presentAlert(message: "安装失败：\(error.localizedDescription)")
        }
    }

    // MARK: - Public Query

    /// 查询技能是否正在安装中。
    func isInstalling(_ skillID: String) -> Bool {
        installingSkillIDs.contains(skillID)
    }

    /// 查询技能是否已安装。
    func isInstalled(_ skillID: String) -> Bool {
        installedSkillIDs.contains(skillID)
    }

    // MARK: - Private Helpers

    /// 基于全量快照更新首页展示数据。
    private func applySnapshot(from source: [SkillItem]) {
        let sorted = source.sorted(by: { $0.rank < $1.rank })
        hotSkills = Array(sorted.prefix(4))
        recommendedSkills = Array(sorted.filter(\.isFeatured).prefix(3))
        installedSkillIDs = Set(sorted.filter(\.isInstalled).map(\.id))
    }

    /// 更新技能安装状态并同步到展示层。
    private func markInstalled(skillID: String, isInstalled: Bool) {
        if let index = cachedSkills.firstIndex(where: { $0.id == skillID }) {
            cachedSkills[index].isInstalled = isInstalled
        }

        applySnapshot(from: cachedSkills)
    }

    /// 根据 Siri 权限状态补充提示。
    private func siriPermissionTip() -> String? {
        switch INPreferences.siriAuthorizationStatus() {
        case .authorized:
            return nil
        case .notDetermined:
            return "你可以在“我的技能”中继续配置 Siri 语音短语。"
        case .denied, .restricted:
            return "检测到 Siri 权限未开启。当前仍可手动执行技能；如需语音触发，请前往系统设置开启 Siri 权限。"
        @unknown default:
            return "当前 Siri 权限状态未知，语音触发能力可能受限。"
        }
    }

    /// 统一弹窗出口。
    private func presentAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
