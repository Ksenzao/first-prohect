import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    
    // Поля регистрации питомца
    @Published var petNameText: String = ""
    @Published var breedText: String = ""
    @Published var ageYearsText: String = "1"
    @Published var ownerCityText: String = "Минск"
    @Published var ownerNameText: String = ""
    @Published var bioText: String = ""
    @Published var isVaccinated: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSignUpMode: Bool = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Авторизация (Вход)
    func login() {
        let cleanEmail = emailText.trimmingCharacters(in: .whitespaces)
        let cleanPassword = passwordText.trimmingCharacters(in: .whitespaces)
        
        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            errorMessage = "Заполните Email и пароль"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: cleanEmail, password: cleanPassword) { [weak self] authResult, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // 🚀 Успешный вход -> Уведомляем PetsDateApp
                NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
            }
        }
    }
    
    // MARK: - Регистрация нового пользователя и создание анкеты
    func register() {
        let cleanEmail = emailText.trimmingCharacters(in: .whitespaces)
        let cleanPassword = passwordText.trimmingCharacters(in: .whitespaces)
        let cleanPetName = petNameText.trimmingCharacters(in: .whitespaces)
        
        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            errorMessage = "Укажите Email и пароль"
            return
        }
        
        guard !cleanPetName.isEmpty else {
            errorMessage = "Укажите кличку питомца"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: cleanEmail, password: cleanPassword) { [weak self] authResult, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let user = authResult?.user else {
                    self.isLoading = false
                    return
                }
                
                // Создаём профиль питомца в Firestore
                var newProfile = PetProfile()
                newProfile.id = user.uid
                newProfile.ownerUid = user.uid
                newProfile.ownerEmail = cleanEmail
                newProfile.ownerName = self.ownerNameText.trimmingCharacters(in: .whitespaces)
                newProfile.ownerCity = self.ownerCityText.trimmingCharacters(in: .whitespaces).isEmpty ? "Минск" : self.ownerCityText
                newProfile.petName = cleanPetName
                newProfile.breed = self.breedText.trimmingCharacters(in: .whitespaces)
                newProfile.ageYears = self.ageYearsText.trimmingCharacters(in: .whitespaces).isEmpty ? "1" : self.ageYearsText
                newProfile.bioText = self.bioText.trimmingCharacters(in: .whitespaces)
                newProfile.isVaccinated = self.isVaccinated
                
                FirestoreService.shared.savePetProfile(newProfile) { saveResult in
                    Task { @MainActor in
                        self.isLoading = false
                        
                        switch saveResult {
                        case .success:
                            // 🚀 Успешная регистрация и сохранение анкеты -> Уведомляем PetsDateApp
                            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
                        case .failure(let saveError):
                            self.errorMessage = "Ошибка сохранения анкеты: \(saveError.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}
