import Foundation
import UIKit
import Combine
import FirebaseFirestore
import FirebaseAuth

final class ProfileViewModel: ObservableObject {
    @Published var profile: PetProfile
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init(profile: PetProfile = PetProfile()) {
        self.profile = profile
    }
    
    // MARK: - Загрузка профиля текущего пользователя из Firestore
    @MainActor
    func fetchProfileFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("pets").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let data = document?.data(), document?.exists == true else { return }
            
            // Заполняем текстовые данные профиля
            self.profile.petName = data["petName"] as? String ?? ""
            self.profile.petType = data["petType"] as? String ?? "Собака"
            self.profile.breed = data["breed"] as? String ?? ""
            self.profile.gender = data["gender"] as? String ?? "Мальчик"
            self.profile.ageYears = data["ageYears"] as? String ?? "1"
            self.profile.ageMonths = data["ageMonths"] as? String ?? "0"
            self.profile.heightCm = data["heightCm"] as? String ?? ""
            self.profile.weightKg = data["weightKg"] as? String ?? ""
            self.profile.bioText = data["bioText"] as? String ?? ""
            self.profile.isVaccinated = data["isVaccinated"] as? Bool ?? false
            
            if let traitsArray = data["traits"] as? [String] {
                self.profile.traits = Set(traitsArray)
            }
            
            // Данные владельца
            self.profile.ownerName = data["ownerName"] as? String ?? ""
            self.profile.ownerEmail = data["ownerEmail"] as? String ?? ""
            self.profile.ownerPhone = data["ownerPhone"] as? String ?? ""
            self.profile.ownerCity = data["ownerCity"] as? String ?? "Минск"
            
            // Декодирование фото из Base64
            if let base64String = data["mainPhotoURL"] as? String, !base64String.isEmpty,
               let imageData = Data(base64Encoded: base64String),
               let downloadedImage = UIImage(data: imageData) {
                self.profile.mainPhoto = downloadedImage
            }
        }
    }
    
    @MainActor
    func updateOwnerInfo(name: String, email: String, phone: String, city: String) {
        profile.ownerName = name
        profile.ownerEmail = email
        profile.ownerPhone = phone
        profile.ownerCity = city
    }
}
