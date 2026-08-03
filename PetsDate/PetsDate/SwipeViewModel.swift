import Foundation
import UIKit
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SwipeViewModel: ObservableObject {
    @Published var candidateProfiles: [PetProfile] = []
    @Published var isLoading: Bool = false
    @Published var matchedProfile: PetProfile? = nil
    @Published var showMatchPopup: Bool = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Загрузка анкет из Firestore
    func fetchCandidates() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            loadMockCandidates()
            return
        }
        
        isLoading = true
        
        FirestoreService.shared.fetchPetProfile(userId: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            self.db.collection("users")
                .getDocuments { snapshot, error in
                    Task { @MainActor in
                        self.isLoading = false
                        
                        if let error = error {
                            print("⚠️ Ошибка загрузки кандидатов: \(error.localizedDescription)")
                            self.loadMockCandidates()
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            self.loadMockCandidates()
                            return
                        }
                        
                        var fetchedProfiles: [PetProfile] = []
                        
                        for doc in documents {
                            if doc.documentID == currentUserId { continue }
                            
                            let data = doc.data()
                            var profile = PetProfile()
                            
                            profile.petName = data["petName"] as? String ?? "Питомец"
                            profile.petType = data["petType"] as? String ?? "Собака"
                            profile.breed = data["breed"] as? String ?? ""
                            profile.gender = data["gender"] as? String ?? "Мальчик"
                            profile.ageYears = data["ageYears"] as? String ?? "1"
                            profile.bioText = data["bioText"] as? String ?? ""
                            profile.ownerCity = data["ownerCity"] as? String ?? "Минск"
                            profile.isVaccinated = data["isVaccinated"] as? Bool ?? false
                            profile.ownerName = data["ownerName"] as? String ?? ""
                            profile.ownerEmail = data["ownerEmail"] as? String ?? ""
                            
                            if let base64String = data["mainPhotoBase64"] as? String, !base64String.isEmpty,
                               let imageData = Data(base64Encoded: base64String),
                               let downloadedImage = UIImage(data: imageData) {
                                profile.mainPhoto = downloadedImage
                            }
                            
                            fetchedProfiles.append(profile)
                        }
                        
                        if fetchedProfiles.isEmpty {
                            self.loadMockCandidates()
                        } else {
                            self.candidateProfiles = fetchedProfiles
                        }
                    }
                }
        }
    }
    
    // MARK: - Моки для пустой базы
    private func loadMockCandidates() {
        var mock1 = PetProfile()
        mock1.petName = "Боливар"
        mock1.breed = "Лабрадор"
        mock1.ageYears = "2"
        mock1.ownerCity = "Минск"
        mock1.ownerEmail = "mock1@pets.date"
        
        var mock2 = PetProfile()
        mock2.petName = "Луна"
        mock2.breed = "Хаски"
        mock2.ageYears = "1"
        mock2.ownerCity = "Витебск"
        mock2.ownerEmail = "mock2@pets.date"
        
        self.candidateProfiles = [mock1, mock2]
    }
    
    // MARK: - Свайп вправо (Тестовый вызов Match Overlay)
    func swipeRight(profile: PetProfile) {
        self.matchedProfile = profile
        self.showMatchPopup = true
    }
    
    // MARK: - Свайп влево
    func swipeLeft(profile: PetProfile) {
        removeTopCard()
    }
    
    // MARK: - Удаление текущей карточки из стека
    func removeTopCard() {
        if !candidateProfiles.isEmpty {
            candidateProfiles.removeFirst()
        }
    }
}
