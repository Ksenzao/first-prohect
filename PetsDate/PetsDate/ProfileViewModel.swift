import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: PetProfile = PetProfile()
    @Published var isLoading: Bool = false
    @Published var isProfileNotFound: Bool = false
    
    func fetchCurrentUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.isProfileNotFound = true
            return
        }
        
        isLoading = true
        
        FirestoreService.shared.fetchPetProfile(userId: currentUserId) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let fetchedProfile):
                    self.profile = fetchedProfile
                    self.isProfileNotFound = false
                case .failure:
                    // Если документ в Firestore удален или не найден
                    self.isProfileNotFound = true
                }
            }
        }
    }
}
