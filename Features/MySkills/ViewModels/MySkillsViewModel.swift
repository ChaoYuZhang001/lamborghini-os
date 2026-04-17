import SwiftUI

/// 我的技能页 ViewModel（最终优化版）。
///
/// 设计目标：
/// 1. 承接已安装技能列表、执行状态、Siri 入口与提示弹窗状态。
/// 2. 全量统一使用 `SkillItem` 模型，并复用统一 Mock 数据入口。
/// 3. 通过 `SiriShortcutService` 统一管理 Siri 权限与入口提示逻辑。
@MainActor
final class MySkillsViewModel: ObservableObject {
    // MARK: - Published State

    /// 已安装技能列表。
    @Published var installedSkills: [SkillItem] = []

    /// 当前执行中的技能 ID 集合。
    @Published var executingSkillIDs: Set<String> = []

    /// 页面加载状态。
    @Published var isLoading: Bool = false

    /// 弹窗提示文案。
    @Published var alertMessage: String = ""

    /// 是否展示弹窗提示。
    @Published var showAlert: Bool = false

    // MARK: - Dependencies

    /// Siri 短语服务（可替换为测试桩）。
    private let siriShortcutService: SiriShortcutServiceProtocol

    // MARK: - Private State

    /// 防止重复初始化加载。
    private var hasLoaded: Bool = false

    // MARK: - Init

    init(siriShortcutService: SiriShortcutServiceProtocol = SiriShortcutService.shared) {
        self.siriShortcutService = siriShortcutService
    }

    // MARK: - Derived State

    /// 已安装技能数量。
    var installedSkillCount: Int {
        installedSkills.count
    }

    /// 是否为空状态。
    var isEmpty: Bool {
        installedSkills.isEmpty
    }

    // MARK: - Public Actions

    /// 首次进入页面时加载已安装技能。
    func loadInitialDataIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        isLoading = true
        defer { isLoading = false }

        do {
            // 模拟异步加载耗时。
            try await Task.sleep(nanoseconds: 180_000_000)
            installedSkills = MockDataProvider.installedSkills()
        } catch is CancellationError {
            // 页面切换取消任务时静默处理。
        } catch {
            presentAlert("我的技能加载失败：\(error.localizedDescription)")
        }
    }

    /// 执行技能。
    func execute(skill: SkillItem) async {
        guard installedSkills.contains(where: { $0.id == skill.id }) else {
            presentAlert("“\(skill.title)”未安装，请先前往技能市场安装。")
            return
        }

        guard !executingSkillIDs.contains(skill.id) else { return }

        executingSkillIDs.insert(skill.id)
        defer { executingSkillIDs.remove(skill.id) }

        do {
            // 模拟快捷指令执行耗时。
            try await Task.sleep(nanoseconds: 520_000_000)
            presentAlert("“\(skill.title)”已执行完成。")
        } catch is CancellationError {
            presentAlert("执行已取消，请稍后重试。")
        } catch {
            presentAlert("执行失败：\(error.localizedDescription)")
        }
    }

    /// 打开 Siri 短语入口（MVP 占位逻辑）。
    func openSiriShortcutEntry(for skill: SkillItem) async {
        let message = await siriShortcutService.buildShortcutEntryMessage(for: skill)
        presentAlert(message)
    }

    /// 外部注入已安装技能（便于后续接收市场页安装结果）。
    func upsertInstalledSkill(_ skill: SkillItem) {
        if let index = installedSkills.firstIndex(where: { $0.id == skill.id }) {
            installedSkills[index] = skill
            installedSkills[index].isInstalled = true
        } else {
            var installed = skill
            installed.isInstalled = true
            installedSkills.append(installed)
            installedSkills.sort(by: { $0.rank < $1.rank })
        }
    }

    // MARK: - Query Helpers

    /// 查询某技能是否处于执行中。
    func isExecuting(_ skillID: String) -> Bool {
        executingSkillIDs.contains(skillID)
    }

    // MARK: - Private Helpers

    /// 统一弹窗出口。
    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
