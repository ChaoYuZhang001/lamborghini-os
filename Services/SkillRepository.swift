import Foundation
import CoreData

// 安装状态变更通知
// Home/Market/MySkills/Profile 可监听并刷新本地状态。
extension Notification.Name {
    static let skillInstallationDidChange = Notification.Name("SkillRepository.skillInstallationDidChange")
}

/// 技能仓储协议
/// 目标：
/// 1. 集中管理 Core Data 安装状态读写
/// 2. 对外提供最小可用接口
protocol SkillRepositoryProtocol {
    /// 获取已安装技能 ID 集合
    func fetchInstalledSkillIDs() throws -> Set<String>

    /// 用本地安装记录覆盖目录中的 isInstalled
    func applyInstallationState(to catalog: [SkillItem]) throws -> [SkillItem]

    /// 安装技能（按 id upsert）
    func install(skill: SkillItem, installedAt: Date) throws

    /// 从目录中过滤出已安装技能
    func fetchInstalledSkills(from catalog: [SkillItem]) throws -> [SkillItem]

    /// 获取已安装数量
    func installedSkillCount() throws -> Int

    /// 记录最近执行时间
    func markExecuted(skillID: String, executedAt: Date) throws
}

/// Core Data 技能仓储实现
/// 说明：
/// 1. MockDataProvider 继续作为目录源
/// 2. 安装状态真值统一来自 Core Data
/// 3. 唯一键使用 skill id
@MainActor
final class SkillRepository: SkillRepositoryProtocol {
    static let shared = SkillRepository()

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchInstalledSkillIDs() throws -> Set<String> {
        let objects = try fetchInstalledObjects()
        let ids = objects.compactMap { $0.value(forKey: Field.id) as? String }
        return Set(ids)
    }

    func applyInstallationState(to catalog: [SkillItem]) throws -> [SkillItem] {
        let installedIDs = try fetchInstalledSkillIDs()

        return catalog.map { skill in
            var item = skill
            item.isInstalled = installedIDs.contains(skill.id)
            return item
        }
    }

    func install(skill: SkillItem, installedAt: Date = Date()) throws {
        let object: NSManagedObject

        if let existing = try fetchInstalledObject(by: skill.id) {
            object = existing
        } else {
            object = try makeInstalledObject()
            object.setValue(skill.id, forKey: Field.id)
            object.setValue(installedAt, forKey: Field.installedAt)
        }

        // 同步更新可展示字段，避免目录文案变化后本地数据滞后
        object.setValue(skill.title, forKey: Field.title)
        object.setValue(skill.category.rawValue, forKey: Field.category)

        // 防御性补齐 installedAt，避免历史脏数据
        if object.value(forKey: Field.installedAt) == nil {
            object.setValue(installedAt, forKey: Field.installedAt)
        }

        try saveContextIfNeeded()
        NotificationCenter.default.post(name: .skillInstallationDidChange, object: nil)
    }

    func fetchInstalledSkills(from catalog: [SkillItem]) throws -> [SkillItem] {
        let merged = try applyInstallationState(to: catalog)
        return merged
            .filter(\.isInstalled)
            .sorted(by: { $0.rank < $1.rank })
    }

    func installedSkillCount() throws -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.installedSkill)
        return try context.count(for: request)
    }

    func markExecuted(skillID: String, executedAt: Date = Date()) throws {
        guard let object = try fetchInstalledObject(by: skillID) else {
            return
        }

        object.setValue(executedAt, forKey: Field.lastExecutedAt)
        try saveContextIfNeeded()
    }
}

private extension SkillRepository {
    enum Entity {
        static let installedSkill = "InstalledSkill"
    }

    enum Field {
        static let id = "id"
        static let title = "title"
        static let category = "category"
        static let installedAt = "installedAt"
        static let lastExecutedAt = "lastExecutedAt"
    }

    func fetchInstalledObjects() throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.installedSkill)
        request.sortDescriptors = [NSSortDescriptor(key: Field.installedAt, ascending: true)]
        return try context.fetch(request)
    }

    func fetchInstalledObject(by skillID: String) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: Entity.installedSkill)
        request.predicate = NSPredicate(format: "%K == %@", Field.id, skillID)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func makeInstalledObject() throws -> NSManagedObject {
        guard let entity = NSEntityDescription.entity(forEntityName: Entity.installedSkill, in: context) else {
            throw SkillRepositoryError.modelEntityMissing(Entity.installedSkill)
        }
        return NSManagedObject(entity: entity, insertInto: context)
    }

    func saveContextIfNeeded() throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            throw SkillRepositoryError.saveFailed(error.localizedDescription)
        }
    }
}

/// 仓储错误定义
enum SkillRepositoryError: LocalizedError {
    case modelEntityMissing(String)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelEntityMissing(let entityName):
            return "Core Data 模型缺少实体: \(entityName)"
        case .saveFailed(let message):
            return "安装状态保存失败: \(message)"
        }
    }
}
