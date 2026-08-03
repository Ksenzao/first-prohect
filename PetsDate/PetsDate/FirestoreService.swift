import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Валидация Email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Сохранение / Обновление Профиля
    func savePetProfile(_ profile: PetProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Необходима авторизация"])))
            return
        }
        
        let data: [String: Any] = [
            "id": currentUid,
            "ownerUid": currentUid,
            "petName": profile.petName,
            "petType": profile.petType,
            "gender": profile.gender,
            "breed": profile.breed,
            "ageYears": profile.ageYears,
            "ageMonths": profile.ageMonths,
            "weightKg": profile.weightKg,
            "bioText": profile.bioText,
            "isVaccinated": profile.isVaccinated,
            "ownerCity": profile.ownerCity.isEmpty ? "Минск" : profile.ownerCity,
            "ownerName": profile.ownerName.isEmpty ? "Хозяин" : profile.ownerName,
            "ownerEmail": profile.ownerEmail.isEmpty ? (Auth.auth().currentUser?.email ?? "") : profile.ownerEmail,
            "ownerPhone": profile.ownerPhone,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(currentUid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Загрузка профиля одного питомца
    func fetchPetProfile(userId: String, completion: @escaping (Result<PetProfile, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(), snapshot?.exists == true else {
                completion(.failure(NSError(domain: "NotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Профиль не найден"])))
                return
            }
            
            var profile = PetProfile()
            profile.id = snapshot?.documentID ?? userId
            profile.ownerUid = data["ownerUid"] as? String ?? userId
            profile.petName = data["petName"] as? String ?? ""
            profile.petType = data["petType"] as? String ?? "Собака"
            profile.gender = data["gender"] as? String ?? ""
            profile.breed = data["breed"] as? String ?? ""
            profile.ageYears = data["ageYears"] as? String ?? "1"
            profile.ageMonths = data["ageMonths"] as? String ?? "0"
            profile.weightKg = data["weightKg"] as? String ?? ""
            profile.bioText = data["bioText"] as? String ?? ""
            profile.isVaccinated = data["isVaccinated"] as? Bool ?? false
            profile.ownerCity = data["ownerCity"] as? String ?? "Минск"
            profile.ownerName = data["ownerName"] as? String ?? ""
            profile.ownerEmail = data["ownerEmail"] as? String ?? ""
            profile.ownerPhone = data["ownerPhone"] as? String ?? ""
            
            completion(.success(profile))
        }
    }
    
    // MARK: - Обработка Лайка и Взаимного Мэтча (Tinder-Flow)
    func processLike(from fromUserId: String, to toUserId: String, completion: @escaping (Bool) -> Void) {
        let likeDocId = "\(fromUserId)_\(toUserId)"
        let likeData: [String: Any] = [
            "from": fromUserId,
            "to": toUserId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // 1. Фиксируем лайк
        db.collection("likes").document(likeDocId).setData(likeData) { [weak self] error in
            guard error == nil else {
                completion(false)
                return
            }
            
            // 2. Проверяем ответный лайк от того пользователя
            let reverseLikeId = "\(toUserId)_\(fromUserId)"
            self?.db.collection("likes").document(reverseLikeId).getDocument { snapshot, _ in
                let isMatch = snapshot?.exists ?? false
                
                if isMatch {
                    // 3. Создаем документ взаимодействия в коллекции matches
                    let matchId = fromUserId < toUserId ? "\(fromUserId)_\(toUserId)" : "\(toUserId)_\(fromUserId)"
                    self?.db.collection("matches").document(matchId).setData([
                        "participants": [fromUserId, toUserId],
                        "createdAt": FieldValue.serverTimestamp()
                    ], merge: true)
                }
                
                completion(isMatch)
            }
        }
    }
}
