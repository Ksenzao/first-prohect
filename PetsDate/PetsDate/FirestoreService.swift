import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// Сжимает и конвертирует UIImage в строку Base64
    private func convertImageToBase64(_ image: UIImage, quality: CGFloat = 0.3) -> String? {
        let targetWidth: CGFloat = 400 // Оптимальный размер для быстродействия
        let scale = targetWidth / image.size.width
        let targetHeight = image.size.height * scale
        
        let newSize = CGSize(width: targetWidth, height: targetHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = resizedImage ?? Optional(image),
              let imageData = finalImage.jpegData(compressionQuality: quality) else {
            return nil
        }
        
        return imageData.base64EncodedString()
    }
    
    /// Сохраняет профиль в Cloud Firestore
    func savePetProfile(_ profile: PetProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            // Если UID по какой-то причине нет — генерируем временный идентификатор устройства
            let fallbackUID = UUID().uuidString
            saveWithUID(fallbackUID, profile: profile, completion: completion)
            return
        }
        
        saveWithUID(userId, profile: profile, completion: completion)
    }
    
    private func saveWithUID(_ userId: String, profile: PetProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1. Кодируем главную фотографию
            var mainPhotoBase64 = ""
            if let mainImage = profile.mainPhoto {
                mainPhotoBase64 = self.convertImageToBase64(mainImage) ?? ""
            }
            
            // 2. Кодируем дополнительные фото
            var additionalPhotosBase64: [String] = []
            for photo in profile.additionalPhotos {
                if let photo = photo, let base64Str = self.convertImageToBase64(photo) {
                    additionalPhotosBase64.append(base64Str)
                }
            }
            
            // 3. Кодируем сертификат
            var vaccineCertBase64 = ""
            if profile.isVaccinated, let certImage = profile.vaccineCertificatePhoto {
                vaccineCertBase64 = self.convertImageToBase64(certImage) ?? ""
            }
            
            // 4. Данные для отправки
            let data: [String: Any] = [
                "uid": userId,
                "petType": profile.petType,
                "breed": profile.breed,
                "petName": profile.petName,
                "mainPhotoURL": mainPhotoBase64,
                "additionalPhotoURLs": additionalPhotosBase64,
                "gender": profile.gender,
                "ageYears": profile.ageYears,
                "ageMonths": profile.ageMonths,
                "heightCm": profile.heightCm,
                "weightKg": profile.weightKg,
                "traits": Array(profile.traits),
                "bioText": profile.bioText,
                "isVaccinated": profile.isVaccinated,
                "vaccineCertURL": vaccineCertBase64,
                "vaccineDate": Timestamp(date: profile.vaccineDate),
                "ownerName": profile.ownerName,
                "ownerEmail": profile.ownerEmail,
                "ownerPhone": profile.ownerPhone,
                "ownerCity": profile.ownerCity,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            // 5. Запись в Firestore
            DispatchQueue.main.async {
                self.db.collection("pets").document(userId).setData(data, merge: true) { error in
                    if let error = error {
                        print("❌ Ошибка Firestore: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("✅ Профиль успешно сохранен в Firestore!")
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
