import Foundation

/// 统一假数据提供器。
///
/// 使用原则：
/// 1. 所有 Feature 页面统一从此处读取 Mock 数据，避免分散定义。
/// 2. 通过静态方法返回值拷贝，防止页面间相互污染状态。
/// 3. 后续切换到真实 Service 时，只需替换调用源而不改 UI 结构。
enum MockDataProvider {
    // MARK: - Profile Mock

    /// 个人中心基础信息快照。
    struct ProfileSnapshot {
        let accountEmail: String
        let lastSyncDescription: String
        let licenseName: String
        let projectNature: String
        let disclaimerSummary: String
        let developerEmail: String
        let repositoryURL: String
    }

    /// 获取技能市场假数据。
    static func marketSkills() -> [SkillItem] {
        [
            SkillItem(
                id: "skill-work-focus-mode",
                title: "工作模式",
                description: "自动开启专注模式、静音手机并打开企业微信与邮箱。",
                category: .work,
                triggerPhrase: "开始工作",
                estimatedDuration: "约 2 秒",
                installationCount: 12840,
                rank: 1,
                requiredPermissions: ["通知", "Siri 与搜索"],
                updatedAt: Date(),
                isInstalled: true,
                isFeatured: true
            ),
            SkillItem(
                id: "skill-sleep-mode",
                title: "助眠模式",
                description: "一键开启勿扰、设置次日闹钟并播放助眠白噪音。",
                category: .life,
                triggerPhrase: "我要睡觉了",
                estimatedDuration: "约 3 秒",
                installationCount: 10320,
                rank: 2,
                requiredPermissions: ["健康", "闹钟", "Siri 与搜索"],
                updatedAt: Date(),
                isInstalled: false,
                isFeatured: true
            ),
            SkillItem(
                id: "skill-screenshot-stitch",
                title: "截图拼接",
                description: "将最近截图自动拼接成长图并保存，适合内容整理分享。",
                category: .creativity,
                triggerPhrase: "拼接截图",
                estimatedDuration: "约 4 秒",
                installationCount: 8940,
                rank: 3,
                requiredPermissions: ["照片"],
                updatedAt: Date(),
                isInstalled: false,
                isFeatured: true
            ),
            SkillItem(
                id: "skill-home-navigation",
                title: "回家导航",
                description: "自动打开地图并规划回家路线，智能规避拥堵路段。",
                category: .travel,
                triggerPhrase: "导航回家",
                estimatedDuration: "约 2 秒",
                installationCount: 7760,
                rank: 4,
                requiredPermissions: ["定位", "Siri 与搜索"],
                updatedAt: Date(),
                isInstalled: false,
                isFeatured: false
            ),
            SkillItem(
                id: "skill-hydration-reminder",
                title: "补水提醒",
                description: "按时间段自动提醒喝水，支持午后强化提醒。",
                category: .health,
                triggerPhrase: "开启补水提醒",
                estimatedDuration: "约 1 秒",
                installationCount: 6410,
                rank: 5,
                requiredPermissions: ["通知"],
                updatedAt: Date(),
                isInstalled: false,
                isFeatured: false
            )
        ]
    }

    /// 获取已安装技能假数据。
    static func installedSkills() -> [SkillItem] {
        marketSkills()
            .filter(\.isInstalled)
            .sorted(by: { $0.rank < $1.rank })
    }

    /// 获取首页推荐技能假数据。
    static func homeRecommendedSkills() -> [SkillItem] {
        marketSkills()
            .filter(\.isFeatured)
            .sorted(by: { $0.rank < $1.rank })
            .prefix(3)
            .map { $0 }
    }

    /// 获取首页热门技能假数据。
    static func homeHotSkills() -> [SkillItem] {
        marketSkills()
            .sorted(by: { $0.rank < $1.rank })
            .prefix(4)
            .map { $0 }
    }

    /// 获取个人中心基础信息假数据。
    static func profileSnapshot() -> ProfileSnapshot {
        ProfileSnapshot(
            accountEmail: "founder@lamborghini-os.dev",
            lastSyncDescription: "2 分钟前",
            licenseName: "MIT License",
            projectNature: "社区驱动的非官方开源项目",
            disclaimerSummary: "Lamborghini OS 与 Automobili Lamborghini S.p.A. 无任何关联、背书或合作关系。\n“Lamborghini”仅为内部开发代号；如收到权利方通知，项目将启动品牌更名流程。\n所有提及商标均归其各自所有者。",
            developerEmail: "2900814034@qq.com",
            repositoryURL: "github.com/ChaoYuZhang001/lamborghini-os"
        )
    }
}
