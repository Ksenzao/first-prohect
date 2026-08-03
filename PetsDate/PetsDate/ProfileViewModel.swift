import Foundation
import UIKit
import Combine
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: PetProfile = PetProfile()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Загрузка профиля текущего авторизованного пользователя
    func fetchCurrentUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        errorMessage = nil
        
        FirestoreService.shared.fetchPetProfile(userId: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                
                switch result {
                case .success(let fetchedProfile):
                    // fetchedProfile имеет тип PetProfile (не Optional),
                    // поэтому присваиваем его напрямую без `if let`
                    self.profile = fetchedProfile
                    
                case .failure(let error):
                    print("⚠️ Ошибка загрузки профиля: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
