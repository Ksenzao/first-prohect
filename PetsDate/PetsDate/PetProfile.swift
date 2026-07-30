import UIKit

// Единая модель профиля: Данные питомца + Данные владельца
struct PetProfile {
    // --- Данные питомца ---
    var petType: String = "Собака"
    var breed: String = ""
    var petName: String = ""
    var mainPhoto: UIImage? = nil
    var additionalPhotos: [UIImage?] = []
    var gender: String = "Мальчик"
    var ageYears: String = "1"
    var ageMonths: String = "0"
    var heightCm: String = ""
    var weightKg: String = ""
    var traits: Set<String> = []
    var bioText: String = ""
    var isVaccinated: Bool = false
    var vaccineCertificatePhoto: UIImage? = nil
    var vaccineDate: Date = Date()
    
    // --- Данные владельца (из формы регистрации) ---
    var ownerName: String = ""
    var ownerEmail: String = ""
    var ownerPhone: String = ""
    var ownerCity: String = "Минск"
}
