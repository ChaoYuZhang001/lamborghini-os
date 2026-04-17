import Foundation
import Intents

/// Siri 短语服务协议。
///
/// 目的：
/// - 抽象 Siri 授权与短语入口文案逻辑，便于后续替换真实实现。
protocol SiriShortcutServiceProtocol {
    /// 获取当前 Siri 授权状态。
    func currentAuthorizationStatus() -> INSiriAuthorizationStatus

    /// 如有需要，发起 Siri 授权请求并返回最终状态。
    func requestAuthorizationIfNeeded() async -> INSiriAuthorizationStatus

    /// 生成“技能 Siri 短语入口”提示文案。
    func buildShortcutEntryMessage(for skill: SkillItem) async -> String
}

/// Siri 短语服务（MVP 占位实现）。
///
/// 说明：
/// 1. 当前仅处理授权状态判断与提示文案生成。
/// 2. 后续可在此处接入 App Intents / SiriKit 的真实短语添加流程。
final class SiriShortcutService: SiriShortcutServiceProtocol {
    /// 全局单例。
    static let shared = SiriShortcutService()

    /// 私有初始化，确保单例使用方式。
    private init() {}

    /// 当前 Siri 授权状态。
    func currentAuthorizationStatus() -> INSiriAuthorizationStatus {
        INPreferences.siriAuthorizationStatus()
    }

    /// 如有必要，触发 Siri 授权弹窗。
    func requestAuthorizationIfNeeded() async -> INSiriAuthorizationStatus {
        let status = currentAuthorizationStatus()

        guard status == .notDetermined else {
            return status
        }

        return await withCheckedContinuation { continuation in
            INPreferences.requestSiriAuthorization { newStatus in
                continuation.resume(returning: newStatus)
            }
        }
    }

    /// 生成 Siri 入口提示文案。
    func buildShortcutEntryMessage(for skill: SkillItem) async -> String {
        let status = await requestAuthorizationIfNeeded()

        switch status {
        case .authorized:
            return "“\(skill.title)”的 Siri 短语入口已就绪（MVP 占位）。下一步可接入真实 Add to Siri 流程。"
        case .notDetermined:
            return "尚未完成 Siri 权限授权。请稍后重试“\(skill.title)”语音短语配置。"
        case .denied, .restricted:
            return "Siri 权限未开启。请先在系统设置中开启 Siri 后，再配置“\(skill.title)”语音短语。"
        @unknown default:
            return "当前 Siri 权限状态未知，暂时无法完成“\(skill.title)”语音短语配置。"
        }
    }
}
