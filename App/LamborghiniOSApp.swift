import SwiftUI
import CoreData
import Intents

/// Lamborghini OS iOS 客户端主入口。
///
/// 说明：
/// 1. 负责注入 Core Data 上下文。
/// 2. 负责应用启动阶段的最小权限检查（Siri 权限状态）。
/// 3. 启动完成后进入主 Tab 容器页面（MainTabView）。
@main
struct LamborghiniOSApp: App {
    /// 监听应用前后台切换，用于在退到后台时触发数据落盘。
    @Environment(\.scenePhase) private var scenePhase

    /// 启动态 ViewModel，使用 `@StateObject` 保证生命周期与 App 一致。
    @StateObject private var appState = AppStateViewModel()

    /// Core Data 持久化控制器（单例）。
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Group {
                // 启动中：展示轻量加载页，避免白屏。
                if appState.isBootstrapping {
                    AppLoadingView()
                // 启动失败：展示错误信息与重试按钮。
                } else if let launchError = appState.launchError {
                    LaunchErrorView(
                        message: launchError.errorDescription ?? "应用启动失败，请稍后重试。",
                        retryAction: { appState.retryBootstrap() }
                    )
                // 启动成功：进入主 Tab。
                } else {
                    MainTabView()
                        .environmentObject(appState)
                }
            }
            // 保持系统默认配色策略，自动兼容浅色/深色模式。
            .preferredColorScheme(nil)
            .onAppear {
                appState.bootstrapIfNeeded()
            }
        }
        // 全局注入 Core Data 上下文，供各页面使用 `@FetchRequest` / `@Environment`。
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onChange(of: scenePhase) { _, newPhase in
            appState.handleScenePhaseChange(newPhase)

            // App 进入后台时主动保存，降低异常退出导致的数据丢失风险。
            if newPhase == .background {
                persistenceController.saveContext()
            }
        }
    }
}

// MARK: - App State

/// 全局 App 启动态管理。
///
/// 当前职责：
/// - 启动阶段最小能力检查（Siri 授权状态）
/// - 异常信息收敛与重试
@MainActor
final class AppStateViewModel: ObservableObject {
    /// 是否处于启动准备阶段。
    @Published var isBootstrapping: Bool = true

    /// 启动错误（若为 nil 表示启动正常）。
    @Published var launchError: AppLaunchError?

    /// Siri 权限是否已走过检查流程。
    @Published var hasCheckedSiriAuthorization: Bool = false

    /// 防止重复执行初始化。
    private var hasBootstrapped: Bool = false

    /// 首次启动触发。
    func bootstrapIfNeeded() {
        guard !hasBootstrapped else { return }
        hasBootstrapped = true

        Task {
            await bootstrap()
        }
    }

    /// 用户点击“重试”时触发。
    func retryBootstrap() {
        launchError = nil
        isBootstrapping = true

        Task {
            await bootstrap()
        }
    }

    /// 处理前后台切换。
    /// 这里先保留结构，后续可以补充日志上报、任务恢复等逻辑。
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            break
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }

    /// 启动流程主函数。
    private func bootstrap() async {
        do {
            // MVP 阶段先做 Siri 权限状态检查（不强制拦截，确保体验与合规平衡）。
            _ = await checkSiriAuthorizationStatus()

            hasCheckedSiriAuthorization = true
            isBootstrapping = false
        } catch {
            launchError = .unknown(description: error.localizedDescription)
            isBootstrapping = false
        }
    }

    /// 检查 Siri 授权状态。
    /// 返回值用于后续页面做提示（例如在“我的技能”引导用户开启 Siri）。
    private func checkSiriAuthorizationStatus() async -> INSiriAuthorizationStatus {
        let currentStatus = INPreferences.siriAuthorizationStatus()

        // 已经有结论时直接返回，避免重复请求系统弹窗。
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        // 首次触发系统授权弹窗。
        return await withCheckedContinuation { continuation in
            INPreferences.requestSiriAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}

// MARK: - Launch Error

/// 启动阶段错误类型定义。
enum AppLaunchError: LocalizedError {
    case unknown(description: String)

    var errorDescription: String? {
        switch self {
        case .unknown(let description):
            return "启动异常：\(description)"
        }
    }
}

// MARK: - Startup Views

/// 应用启动加载页。
private struct AppLoadingView: View {
    var body: some View {
        ZStack {
            HomeTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(HomeTheme.accentOrange)

                Text("Lamborghini OS 正在启动")
                    .font(.headline)
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("正在准备技能市场与本地数据环境…")
                    .font(.subheadline)
                    .foregroundStyle(HomeTheme.textSecondary)
            }
            .padding(24)
        }
    }
}

/// 启动失败兜底页。
private struct LaunchErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ZStack {
            HomeTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(HomeTheme.accentOrange)

                Text("启动失败")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(HomeTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Button("重试", action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .tint(HomeTheme.accentOrange)
            }
            .padding(24)
        }
    }
}
