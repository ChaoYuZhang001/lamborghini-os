import CoreData
import Foundation

/// Core Data 持久化控制器（全局单例）。
///
/// 设计目标：
/// 1. 为 iOS MVP 提供统一的数据持久化入口。
/// 2. 支持 `inMemory` 模式，便于 SwiftUI Preview 与单元测试。
/// 3. 封装安全保存逻辑，降低调用方心智负担。
struct PersistenceController {
    /// 全局共享实例（生产环境默认使用磁盘存储）。
    static let shared = PersistenceController()

    /// 预览专用实例（内存存储，不落盘）。
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    /// Core Data 容器。
    let container: NSPersistentContainer

    /// 初始化持久化控制器。
    ///
    /// - Parameter inMemory: 是否启用内存存储。
    init(inMemory: Bool = false) {
        // 说明：
        // 1. 优先尝试从主 Bundle 读取模型（常规 .xcdatamodeld 场景）。
        // 2. 若当前仓库尚未创建模型文件，使用空模型兜底，避免初始化崩溃。
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main]) ?? NSManagedObjectModel()
        container = NSPersistentContainer(name: "LamborghiniOS", managedObjectModel: managedObjectModel)

        if inMemory {
            // 使用 /dev/null 作为存储地址，实现“进程结束即清空”的内存语义。
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                #if DEBUG
                print("[CoreData] 持久化存储加载失败：\(error.localizedDescription)")
                #endif
            }
        }

        // 自动合并后台上下文变更，减少多上下文冲突概率。
        container.viewContext.automaticallyMergesChangesFromParent = true

        // 发生冲突时，优先采用当前对象属性值（MVP 阶段更符合交互预期）。
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// 安全保存主上下文。
    ///
    /// - 仅在存在变更时执行保存，避免无意义 I/O。
    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("[CoreData] 保存失败：\(error.localizedDescription)")
            #endif
        }
    }
}
