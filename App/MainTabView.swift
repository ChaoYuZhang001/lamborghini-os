import SwiftUI

/// 主导航 Tab 枚举。
/// 使用枚举统一管理 Tab 标题、图标与标识，便于后续扩展与维护。
private enum MainTab: Int, Hashable {
    case home
    case market
    case mySkills
    case profile

    /// Tab 标题（展示在底部标签栏）。
    var title: String {
        switch self {
        case .home: return "首页"
        case .market: return "技能市场"
        case .mySkills: return "我的技能"
        case .profile: return "个人中心"
        }
    }

    /// Tab 对应 SF Symbols 图标。
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .market: return "square.grid.2x2.fill"
        case .mySkills: return "wand.and.stars"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

/// Lamborghini OS 主 Tab 容器视图。
///
/// 功能目标：
/// 1. 承载首页（发现）、技能市场、我的技能、个人中心四个一级页面。
/// 2. 使用现代 SwiftUI `TabView` 语法构建底部导航。
/// 3. 统一黑橙科技风强调色（选中态使用 HomeTheme.accentOrange）。
struct MainTabView: View {
    /// 当前选中的 Tab。
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(MainTab.home.title, systemImage: MainTab.home.systemImage)
            }
            .tag(MainTab.home)

            NavigationStack {
                MarketView()
            }
            .tabItem {
                Label(MainTab.market.title, systemImage: MainTab.market.systemImage)
            }
            .tag(MainTab.market)

            NavigationStack {
                MySkillsView()
            }
            .tabItem {
                Label(MainTab.mySkills.title, systemImage: MainTab.mySkills.systemImage)
            }
            .tag(MainTab.mySkills)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(MainTab.profile.title, systemImage: MainTab.profile.systemImage)
            }
            .tag(MainTab.profile)
        }
        .tint(HomeTheme.accentOrange)
    }
}

#Preview {
    MainTabView()
}
