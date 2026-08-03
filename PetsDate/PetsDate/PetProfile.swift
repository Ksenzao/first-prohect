import Foundation
import UIKit

struct PetProfile: Identifiable, Codable {
    // MARK: - Identifiable & Уникальный ID
    var id: String = UUID().uuidString
    
    // MARK: - Данные питомца
    var petType: String = "Собака"
    var breed: String = ""
    var gender: String = "Мальчик"
    var petName: String = ""
    var ageYears: String = "1"
    var ageMonths: String = "0"
    var weightKg: String = ""
    var heightCm: String = "" // 👈 Добавлено поле
    var traits: Set<String> = []
    var bioText: String = ""
    var isVaccinated: Bool = false
    
    // MARK: - Данные хозяина и локация
    var ownerCity: String = "Минск"
    var ownerName: String = ""
    var ownerPhone: String = ""
    var ownerEmail: String = ""
    
    // MARK: - Фотография (Не кодируется напрямую в Codable)
    var mainPhoto: UIImage? = nil
    
    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id
        case petType
        case breed
        case gender
        case petName
        case ageYears
        case ageMonths
        case weightKg
        case heightCm
        case traits
        case bioText
        case isVaccinated
        case ownerCity
        case ownerName
        case ownerPhone
        case ownerEmail
    }
    
    // Кастомная инициализация для Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.petType = try container.decodeIfPresent(String.self, forKey: .petType) ?? "Собака"
        self.breed = try container.decodeIfPresent(String.self, forKey: .breed) ?? ""
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "Мальчик"
        self.petName = try container.decodeIfPresent(String.self, forKey: .petName) ?? ""
        self.ageYears = try container.decodeIfPresent(String.self, forKey: .ageYears) ?? "1"
        self.ageMonths = try container.decodeIfPresent(String.self, forKey: .ageMonths) ?? "0"
        self.weightKg = try container.decodeIfPresent(String.self, forKey: .weightKg) ?? ""
        self.heightCm = try container.decodeIfPresent(String.self, forKey: .heightCm) ?? ""
        self.traits = try container.decodeIfPresent(Set<String>.self, forKey: .traits) ?? []
        self.bioText = try container.decodeIfPresent(String.self, forKey: .bioText) ?? ""
        self.isVaccinated = try container.decodeIfPresent(Bool.self, forKey: .isVaccinated) ?? false
        self.ownerCity = try container.decodeIfPresent(String.self, forKey: .ownerCity) ?? "Минск"
        self.ownerName = try container.decodeIfPresent(String.self, forKey: .ownerName) ?? ""
        self.ownerPhone = try container.decodeIfPresent(String.self, forKey: .ownerPhone) ?? ""
        self.ownerEmail = try container.decodeIfPresent(String.self, forKey: .ownerEmail) ?? ""
        self.mainPhoto = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(petType, forKey: .petType)
        try container.encode(breed, forKey: .breed)
        try container.encode(gender, forKey: .gender)
        try container.encode(petName, forKey: .petName)
        try container.encode(ageYears, forKey: .ageYears)
        try container.encode(ageMonths, forKey: .ageMonths)
        try container.encode(weightKg, forKey: .weightKg)
        try container.encode(heightCm, forKey: .heightCm)
        try container.encode(traits, forKey: .traits)
        try container.encode(bioText, forKey: .bioText)
        try container.encode(isVaccinated, forKey: .isVaccinated)
        try container.encode(ownerCity, forKey: .ownerCity)
        try container.encode(ownerName, forKey: .ownerName)
        try container.encode(ownerPhone, forKey: .ownerPhone)
        try container.encode(ownerEmail, forKey: .ownerEmail)
    }
    
    // Стандартный инициализатор
    init() {}
}
