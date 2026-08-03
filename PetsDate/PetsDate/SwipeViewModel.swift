import Foundation
import UIKit
import Combine
@preconcurrency import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SwipeViewModel: ObservableObject {
    @Published var candidateProfiles: [PetProfile] = []
    @Published var isLoading: Bool = false
    @Published var matchedProfile: PetProfile? = nil
    @Published var showMatchPopup: Bool = false
    
    init() {}
    
    // MARK: - Загрузка кандидатов через async/await (без захвата self)
    func fetchCandidates() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            loadMockCandidates()
            return
        }
        
        isLoading = true
        
        Task {
            let db = Firestore.firestore()
            
            // 1. Получаем список свайпнутых
            let swipedSnapshot = try? await db.collection("likes")
                .whereField("from", isEqualTo: currentUserId)
                .getDocuments()
            
            let swipedUserIds = Set(swipedSnapshot?.documents.compactMap { $0.data()["to"] as? String } ?? [])
            
            // 2. Получаем всех пользователей
            let usersSnapshot = try? await db.collection("users").getDocuments()
            
            guard let docs = usersSnapshot?.documents else {
                self.isLoading = false
                self.loadMockCandidates()
                return
            }
            
            // 3. Фильтруем профили
            var result: [PetProfile] = []
            for doc in docs {
                let docId = doc.documentID
                if docId == currentUserId || swipedUserIds.contains(docId) { continue }
                
                let data = doc.data()
                var profile = PetProfile()
                profile.id = docId
                profile.ownerUid = docId
                profile.petName = data["petName"] as? String ?? "Питомец"
                profile.breed = data["breed"] as? String ?? ""
                profile.ageYears = data["ageYears"] as? String ?? "1"
                profile.ownerCity = data["ownerCity"] as? String ?? "Минск"
                profile.ownerEmail = data["ownerEmail"] as? String ?? ""
                profile.bioText = data["bioText"] as? String ?? ""
                profile.isVaccinated = data["isVaccinated"] as? Bool ?? false
                
                result.append(profile)
            }
            
            self.isLoading = false
            if result.isEmpty {
                self.loadMockCandidates()
            } else {
                self.candidateProfiles = result
            }
        }
    }
    
    // MARK: - Свайп вправо (Лайк)
    func swipeRight(profile: PetProfile) {
        let currentUserId = Auth.auth().currentUser?.uid ?? "guest_user"
        let targetId = profile.ownerUid.isEmpty ? profile.id : profile.ownerUid
        
        removeTopCard()
        
        Task {
            let isMatch = await withCheckedContinuation { continuation in
                FirestoreService.shared.processLike(from: currentUserId, to: targetId) { match in
                    continuation.resume(returning: match)
                }
            }
            
            if isMatch || targetId.hasPrefix("mock") {
                self.matchedProfile = profile
                self.showMatchPopup = true
            }
        }
    }
    
    // MARK: - Свайп влево (Пропуск)
    func swipeLeft(profile: PetProfile) {
        let currentUserId = Auth.auth().currentUser?.uid ?? "guest_user"
        let targetId = profile.ownerUid.isEmpty ? profile.id : profile.ownerUid
        
        removeTopCard()
        
        if !currentUserId.isEmpty && !targetId.hasPrefix("mock") {
            let db = Firestore.firestore()
            db.collection("likes").document("\(currentUserId)_\(targetId)").setData([
                "from": currentUserId,
                "to": targetId,
                "status": "dislike",
                "timestamp": FieldValue.serverTimestamp()
            ])
        }
    }
    
    private func removeTopCard() {
        if !candidateProfiles.isEmpty {
            candidateProfiles.removeFirst()
        }
    }
    
    private func loadMockCandidates() {
        self.candidateProfiles = getMockProfiles()
    }
    
    private func getMockProfiles() -> [PetProfile] {
        var mock1 = PetProfile()
        mock1.id = "mock1"
        mock1.ownerUid = "mock1"
        mock1.petName = "Боливар"
        mock1.breed = "Лабрадор"
        mock1.ageYears = "2"
        mock1.ownerCity = "Минск"
        mock1.isVaccinated = true
        mock1.bioText = "Обожает бегать за палочкой и дружить с другими собаками!"
        
        var mock2 = PetProfile()
        mock2.id = "mock2"
        mock2.ownerUid = "mock2"
        mock2.petName = "Луна"
        mock2.breed = "Хаски"
        mock2.ageYears = "1"
        mock2.ownerCity = "Минск"
        mock2.isVaccinated = true
        mock2.bioText = "Энергичная красавица, ищет компанию для вечерних прогулок."
        
        return [mock1, mock2]
    }
}
