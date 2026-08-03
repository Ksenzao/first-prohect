import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct PetsDateApp: App {
    @State private var isAuthenticated: Bool = false
    @State private var hasCompletedProfile: Bool = false
    @State private var isCheckingAuth: Bool = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isCheckingAuth {
                    ZStack {
                        PetsBackground()
                        ProgressView("Проверка профиля...")
                            .tint(Color(red: 0.95, green: 0.5, blue: 0.2))
                    }
                } else if isAuthenticated && hasCompletedProfile {
                    MainTabView(onLogout: {
                        logoutUser()
                    })
                } else {
                    AuthView()
                }
            }
            .onAppear {
                checkUserProfile()
            }
            // Отслеживаем успешный вход в Firebase Auth
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserLoggedIn"))) { _ in
                checkUserProfile()
            }
        }
    }
    
    // MARK: - Проверка наличия анкеты в Firestore
    private func checkUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.isAuthenticated = false
            self.hasCompletedProfile = false
            self.isCheckingAuth = false
            return
        }
        
        self.isAuthenticated = true
        
        FirestoreService.shared.fetchPetProfile(userId: currentUserId) { result in
            Task { @MainActor in
                self.isCheckingAuth = false
                
                switch result {
                case .success(let profile):
                    if profile.petName.isEmpty {
                        self.hasCompletedProfile = false
                    } else {
                        self.hasCompletedProfile = true
                    }
                case .failure:
                    // Если анкеты нет в базе — автоматически сбрасываем невалидный вход
                    logoutUser()
                }
            }
        }
    }
    
    private func logoutUser() {
        try? Auth.auth().signOut()
        self.isAuthenticated = false
        self.hasCompletedProfile = false
        self.isCheckingAuth = false
    }
}
