import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// Сохраняет полную модель PetProfile в Firestore
    func savePetProfile(_ profile: PetProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"])))
            return
        }
        
        Task {
            do {
                var mainPhotoURL = ""
                var additionalPhotoURLs: [String] = []
                var vaccineCertURL = ""
                
                // 1. Загружаем главное фото
                if let mainImage = profile.mainPhoto {
                    mainPhotoURL = try await StorageService.shared.uploadImage(mainImage, path: "users/\(userId)/main.jpg")
                }
                
                // 2. Загружаем доп. фото
                for (index, photo) in profile.additionalPhotos.enumerated() {
                    if let photo = photo {
                        let url = try await StorageService.shared.uploadImage(photo, path: "users/\(userId)/additional_\(index).jpg")
                        additionalPhotoURLs.append(url)
                    }
                }
                
                // 3. Загружаем сертификат вакцинации (если есть)
                if profile.isVaccinated, let certImage = profile.vaccineCertificatePhoto {
                    vaccineCertURL = try await StorageService.shared.uploadImage(certImage, path: "users/\(userId)/vaccine_cert.jpg")
                }
                
                // 4. Формируем словарь данных для Firestore
                let data: [String: Any] = [
                    "uid": userId,
                    "petType": profile.petType,
                    "breed": profile.breed,
                    "petName": profile.petName,
                    "mainPhotoURL": mainPhotoURL,
                    "additionalPhotoURLs": additionalPhotoURLs,
                    "gender": profile.gender,
                    "ageYears": profile.ageYears,
                    "ageMonths": profile.ageMonths,
                    "heightCm": profile.heightCm,
                    "weightKg": profile.weightKg,
                    "traits": Array(profile.traits),
                    "bioText": profile.bioText,
                    "isVaccinated": profile.isVaccinated,
                    "vaccineCertURL": vaccineCertURL,
                    "vaccineDate": Timestamp(date: profile.vaccineDate),
                    
                    // Данные владельца
                    "ownerName": profile.ownerName,
                    "ownerEmail": profile.ownerEmail,
                    "ownerPhone": profile.ownerPhone,
                    "ownerCity": profile.ownerCity,
                    
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                
                // 5. Записываем в документ юзера
                try await db.collection("pets").document(userId).setData(data, merge: true)
                
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
