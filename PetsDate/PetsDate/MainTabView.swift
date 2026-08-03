import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка 1: Свайпы анкет 🐾
            MainSwipeView()
                .tabItem {
                    Label("Поиск", systemImage: "pawprint.fill")
                }
                .tag(0)
            
            // Вкладка 2: Мой профиль 👤
            UserProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(1)
        }
        .tint(appAccent)
    }
}

#Preview {
    MainTabView()
}
