import SwiftUI
import Combine

/// 我的技能页 ViewModel（阶段 2：安装状态 Core Data 迁移版）。
///
/// 设计目标：
/// 1. 承接已安装技能列表、执行状态、Siri 入口与提示弹窗状态。
/// 2. 全量统一使用 `SkillItem` 模型，技能目录来源仍为 `MockDataProvider`。
/// 3. 已安装列表真值来自 `SkillRepository`（Core Data）。
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

    /// 安装状态仓储（统一 Core Data 访问入口）。
    private let skillRepository: SkillRepositoryProtocol

    // MARK: - Private State

    /// 防止重复初始化加载。
    private var hasLoaded: Bool = false

    /// 通知订阅集合。
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(
        siriShortcutService: SiriShortcutServiceProtocol = SiriShortcutService.shared,
        skillRepository: SkillRepositoryProtocol = SkillRepository.shared
    ) {
        self.siriShortcutService = siriShortcutService
        self.skillRepository = skillRepository
        observeInstallationChanges()
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
            try refreshInstalledSkillsFromLocal()
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

            // 执行成功后回写最后执行时间（本地记录）。
            try skillRepository.markExecuted(skillID: skill.id, executedAt: Date())
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

    /// 监听安装状态变更通知，确保与首页/市场页状态一致。
    private func observeInstallationChanges() {
        NotificationCenter.default
            .publisher(for: .skillInstallationDidChange)
            .sink { [weak self] _ in
                guard let self else { return }

                Task { @MainActor in
                    self.refreshInstalledSkillsIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    /// 页面已加载后刷新已安装列表。
    private func refreshInstalledSkillsIfNeeded() {
        guard hasLoaded else { return }

        do {
            try refreshInstalledSkillsFromLocal()
        } catch {
            presentAlert("我的技能状态刷新失败：\(error.localizedDescription)")
        }
    }

    /// 基于本地安装记录刷新已安装技能列表。
    ///
    /// 说明：
    /// - 目录数据仍来自 Mock。
    /// - 最终是否已安装由 Core Data 决定。
    private func refreshInstalledSkillsFromLocal() throws {
        let catalog = MockDataProvider.marketSkills()
        installedSkills = try skillRepository.fetchInstalledSkills(from: catalog)
    }
}
