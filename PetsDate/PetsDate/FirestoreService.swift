import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Сохранение профиля в Firestore
    func savePetProfile(_ profile: PetProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }
        
        var profileData: [String: Any] = [
            "uid": currentUserId,
            "petType": profile.petType,
            "breed": profile.breed,
            "gender": profile.gender,
            "petName": profile.petName,
            "ageYears": profile.ageYears,
            "ageMonths": profile.ageMonths,
            "weightKg": profile.weightKg,
            "traits": Array(profile.traits),
            "bioText": profile.bioText,
            "isVaccinated": profile.isVaccinated,
            "ownerCity": profile.ownerCity,
            "ownerName": profile.ownerName,
            "ownerPhone": profile.ownerPhone,
            "ownerEmail": profile.ownerEmail,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Перевод картинки в Base64 для простой записи в Firestore
        if let image = profile.mainPhoto, let imageData = image.jpegData(compressionQuality: 0.6) {
            profileData["mainPhotoBase64"] = imageData.base64EncodedString()
        }
        
        db.collection("users").document(currentUserId).setData(profileData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Загрузка профиля пользователя
    func fetchPetProfile(userId: String, completion: @escaping (Result<PetProfile, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "NotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Профиль не найден"])))
                return
            }
            
            var profile = PetProfile()
            profile.petType = data["petType"] as? String ?? "Собака"
            profile.breed = data["breed"] as? String ?? ""
            profile.gender = data["gender"] as? String ?? "Мальчик"
            profile.petName = data["petName"] as? String ?? ""
            profile.ageYears = data["ageYears"] as? String ?? "1"
            profile.ageMonths = data["ageMonths"] as? String ?? "0"
            profile.weightKg = data["weightKg"] as? String ?? ""
            profile.bioText = data["bioText"] as? String ?? ""
            profile.isVaccinated = data["isVaccinated"] as? Bool ?? false
            profile.ownerCity = data["ownerCity"] as? String ?? "Минск"
            profile.ownerName = data["ownerName"] as? String ?? ""
            profile.ownerPhone = data["ownerPhone"] as? String ?? ""
            profile.ownerEmail = data["ownerEmail"] as? String ?? ""
            
            if let traitsArray = data["traits"] as? [String] {
                profile.traits = Set(traitsArray)
            }
            
            if let base64String = data["mainPhotoBase64"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let downloadedImage = UIImage(data: imageData) {
                profile.mainPhoto = downloadedImage
            }
            
            completion(.success(profile))
        }
    }
}
