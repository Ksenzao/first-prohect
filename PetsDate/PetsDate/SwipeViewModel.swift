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
    func fetchCandidates(currentPetType: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("pets")
            .whereField("uid", isNotEqualTo: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.isLoading = false
                    
                    if let error = error {
                        print("Ошибка загрузки кандидатов: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    var fetchedProfiles: [PetProfile] = []
                    
                    for doc in documents {
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
                        
                        // Сохраняем ссылку на картинку в виде строки во временный параметр или сразу загружаем
                        let photoURLString = data["mainPhotoURL"] as? String
                        
                        fetchedProfiles.append(profile)
                        
                        // Если есть ссылка на главное фото — загружаем фоново
                        if let urlString = photoURLString, let url = URL(string: urlString) {
                            let targetName = profile.petName
                            Task {
                                if let (data, _) = try? await URLSession.shared.data(from: url),
                                   let downloadedImage = UIImage(data: data) {
                                    await MainActor.run {
                                        if let index = self.candidateProfiles.firstIndex(where: { $0.petName == targetName }) {
                                            self.candidateProfiles[index].mainPhoto = downloadedImage
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    self.candidateProfiles = fetchedProfiles
                }
            }
    }
    
    // MARK: - Обработка лайка
    func swipeRight(profile: PetProfile) {
        guard Auth.auth().currentUser?.uid != nil else { return }
        
        let isMatch = Bool.random()
        
        if isMatch {
            self.matchedProfile = profile
            self.showMatchPopup = true
        }
        
        removeTopCard()
    }
    
    // MARK: - Обработка дизлайка
    func swipeLeft(profile: PetProfile) {
        removeTopCard()
    }
    
    private func removeTopCard() {
        if !candidateProfiles.isEmpty {
            candidateProfiles.removeFirst()
        }
    }
}
