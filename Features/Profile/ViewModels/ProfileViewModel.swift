import SwiftUI
import Combine

/// 个人中心页 ViewModel（阶段 2：安装状态 Core Data 迁移版）。
///
/// 设计目标：
/// 1. 承接账号与同步、隐私设置、帮助反馈、开源声明的全部状态。
/// 2. 与 ProfileView 交互保持一致（Toggle、按钮点击、提示弹窗）。
/// 3. 保留 `MockDataProvider` 的静态文案数据，但安装数量改为本地真实数据。
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published State

    /// 当前账号邮箱。
    @Published var currentAccountEmail: String = ""

    /// 是否开启自动同步（与 Toggle 双向绑定）。
    @Published var isAutoSyncEnabled: Bool = true

    /// 最近同步时间描述。
    @Published var lastSyncDescription: String = ""

    /// 是否正在执行同步动作。
    @Published var isSyncing: Bool = false

    /// 隐私与权限动作项。
    @Published var privacyActions: [ProfileActionItem] = []

    /// 帮助与反馈动作项。
    @Published var helpActions: [ProfileActionItem] = []

    /// 开源相关动作项。
    @Published var openSourceActions: [ProfileActionItem] = []

    /// 开源许可证文案。
    @Published var licenseName: String = ""

    /// 项目性质文案。
    @Published var projectNature: String = ""

    /// 免责声明摘要。
    @Published var disclaimerSummary: String = ""

    /// 已安装技能数量（本地 Core Data 真值）。
    @Published var installedSkillCount: Int = 0

    /// 弹窗提示文案。
    @Published var alertMessage: String = ""

    /// 是否展示弹窗提示。
    @Published var showAlert: Bool = false

    /// 页面加载状态。
    @Published var isLoading: Bool = false

    // MARK: - Private State

    /// 防止重复初始化加载。
    private var hasLoaded: Bool = false

    /// 安装状态仓储（统一 Core Data 访问入口）。
    private let skillRepository: SkillRepositoryProtocol

    /// 通知订阅集合。
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(skillRepository: SkillRepositoryProtocol = SkillRepository.shared) {
        self.skillRepository = skillRepository
        observeInstallationChanges()
    }

    // MARK: - Derived State

    /// 同步状态文案（用于“同步状态”展示行）。
    var syncStatusText: String {
        isAutoSyncEnabled ? "已开启自动同步" : "手动同步"
    }

    // MARK: - Public Actions

    /// 首次进入页面时加载初始化数据。
    func loadInitialDataIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        isLoading = true
        defer { isLoading = false }

        do {
            // 模拟异步读取耗时。
            try await Task.sleep(nanoseconds: 180_000_000)

            let snapshot = MockDataProvider.profileSnapshot()
            currentAccountEmail = snapshot.accountEmail
            isAutoSyncEnabled = true
            lastSyncDescription = snapshot.lastSyncDescription
            installedSkillCount = try skillRepository.installedSkillCount()

            licenseName = snapshot.licenseName
            projectNature = snapshot.projectNature
            disclaimerSummary = snapshot.disclaimerSummary

            privacyActions = Self.mockPrivacyActions
            helpActions = Self.mockHelpActions(developerEmail: snapshot.developerEmail)
            openSourceActions = Self.mockOpenSourceActions(repositoryURL: snapshot.repositoryURL)
        } catch is CancellationError {
            // 页面切换取消任务时静默处理。
        } catch {
            presentAlert("个人中心数据加载失败：\(error.localizedDescription)")
        }
    }

    /// 处理自动同步开关变化（与 Toggle 一致）。
    func setAutoSyncEnabled(_ enabled: Bool) {
        isAutoSyncEnabled = enabled

        if enabled {
            // MVP 阶段：开启自动同步后视为刚完成配置刷新。
            lastSyncDescription = "刚刚"
        }
    }

    /// 手动执行一次同步（预留“立即同步”按钮可直接复用）。
    func runManualSync() async {
        guard !isSyncing else { return }

        isSyncing = true
        defer { isSyncing = false }

        do {
            // 模拟同步耗时。
            try await Task.sleep(nanoseconds: 420_000_000)
            lastSyncDescription = "刚刚"
            presentAlert("数据同步完成。")
        } catch is CancellationError {
            presentAlert("同步已取消，请稍后重试。")
        } catch {
            presentAlert("同步失败：\(error.localizedDescription)")
        }
    }

    /// 处理分区动作项点击。
    func handleActionTap(_ action: ProfileActionType) {
        switch action {
        case .privacyPolicy:
            presentAlert("隐私策略页面入口已预留（MVP 占位）。")
        case .siriPermission:
            presentAlert("Siri 权限管理入口已预留（MVP 占位）。")
        case .photoPermission:
            presentAlert("照片权限管理入口已预留（MVP 占位）。")
        case .notificationPermission:
            presentAlert("通知权限管理入口已预留（MVP 占位）。")
        case .faq:
            presentAlert("FAQ 页面入口已预留（MVP 占位）。")
        case .feedback:
            presentAlert("反馈入口已预留（MVP 占位）。")
        case .contactDeveloper:
            presentAlert("邮件联系入口已预留（MVP 占位）：\(MockDataProvider.profileSnapshot().developerEmail)")
        case .githubRepository:
            presentAlert("GitHub 跳转入口已预留（MVP 占位）：\(MockDataProvider.profileSnapshot().repositoryURL)")
        }
    }

    // MARK: - Private Helpers

    /// 统一弹窗出口。
    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    /// 监听安装状态变更通知，实时刷新安装数量。
    private func observeInstallationChanges() {
        NotificationCenter.default
            .publisher(for: .skillInstallationDidChange)
            .sink { [weak self] _ in
                guard let self else { return }

                Task { @MainActor in
                    self.refreshInstalledSkillCountIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    /// 页面已加载后刷新安装数量，避免未加载时触发无意义更新。
    private func refreshInstalledSkillCountIfNeeded() {
        guard hasLoaded else { return }

        do {
            installedSkillCount = try skillRepository.installedSkillCount()
        } catch {
            presentAlert("安装数量刷新失败：\(error.localizedDescription)")
        }
    }
}

// MARK: - Action Models

/// 个人中心动作类型。
enum ProfileActionType: String, CaseIterable, Hashable {
    case privacyPolicy
    case siriPermission
    case photoPermission
    case notificationPermission
    case faq
    case feedback
    case contactDeveloper
    case githubRepository
}

/// 个人中心动作项模型。
struct ProfileActionItem: Identifiable, Hashable {
    /// 主键（使用动作类型 rawValue 保证稳定）。
    let id: String

    /// SF Symbols 图标。
    let icon: String

    /// 主标题。
    let title: String

    /// 副标题。
    let subtitle: String

    /// 点击动作类型。
    let actionType: ProfileActionType

    /// 便捷初始化。
    init(icon: String, title: String, subtitle: String, actionType: ProfileActionType) {
        self.id = actionType.rawValue
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionType = actionType
    }
}

// MARK: - Mock Data Mapping

private extension ProfileViewModel {
    /// 隐私与权限分区假数据。
    static let mockPrivacyActions: [ProfileActionItem] = [
        ProfileActionItem(
            icon: "lock.shield.fill",
            title: "隐私策略",
            subtitle: "查看数据收集与使用说明",
            actionType: .privacyPolicy
        ),
        ProfileActionItem(
            icon: "mic.fill",
            title: "Siri 与搜索权限",
            subtitle: "语音触发与技能执行相关",
            actionType: .siriPermission
        ),
        ProfileActionItem(
            icon: "photo.fill",
            title: "照片与媒体权限",
            subtitle: "用于截图拼接等技能",
            actionType: .photoPermission
        ),
        ProfileActionItem(
            icon: "bell.badge.fill",
            title: "通知权限",
            subtitle: "用于提醒类技能与执行反馈",
            actionType: .notificationPermission
        )
    ]

    /// 帮助与反馈分区假数据。
    static func mockHelpActions(developerEmail: String) -> [ProfileActionItem] {
        [
            ProfileActionItem(
                icon: "questionmark.circle.fill",
                title: "常见问题",
                subtitle: "查看 iOS 使用说明与能力边界",
                actionType: .faq
            ),
            ProfileActionItem(
                icon: "bubble.left.and.bubble.right.fill",
                title: "提交反馈",
                subtitle: "提交 Bug 或功能建议",
                actionType: .feedback
            ),
            ProfileActionItem(
                icon: "envelope.fill",
                title: "联系开发者",
                subtitle: developerEmail,
                actionType: .contactDeveloper
            )
        ]
    }

    /// 开源分区动作项假数据。
    static func mockOpenSourceActions(repositoryURL: String) -> [ProfileActionItem] {
        [
            ProfileActionItem(
                icon: "link",
                title: "GitHub 仓库",
                subtitle: repositoryURL,
                actionType: .githubRepository
            )
        ]
    }
}
