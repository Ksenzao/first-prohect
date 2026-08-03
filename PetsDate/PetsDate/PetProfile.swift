import Foundation
import UIKit

struct PetProfile: Identifiable, Codable {
    var id: String = UUID().uuidString
    var ownerUid: String = ""
    var ownerEmail: String = ""
    var ownerName: String = ""
    var ownerCity: String = "Минск"
    var ownerPhone: String = ""
    
    // Данные питомца
    var petName: String = ""
    var petType: String = "Собака" // Собака / Кошка
    var gender: String = "Мальчик" // Мальчик / Девочка
    var breed: String = ""
    var ageYears: String = "1"
    var ageMonths: String = "0"
    var weightKg: String = ""
    var bioText: String = ""
    var isVaccinated: Bool = false
    var photoURL: String = ""
    var traits: Set<String> = []
    
    // Локальное изображение для загрузки
    var mainPhoto: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, ownerUid, ownerEmail, ownerName, ownerCity, ownerPhone
        case petName, petType, gender, breed, ageYears, ageMonths, weightKg, bioText, isVaccinated, photoURL
    }
}
