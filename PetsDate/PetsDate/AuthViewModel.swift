import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen = .login
    
    // Поля формы авторизации
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isConfirmPasswordVisible: Bool = false
    
    // Поля формы регистрации
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var selectedCity: String = "Минск"
    @Published var isAgreed: Bool = false
    
    // Статус и ошибки
    @Published var authErrorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isEmailVerified: Bool = false
    
    // Валидация пароля
    var isMinLength: Bool { password.count >= 8 }
    var hasUppercase: Bool { password.range(of: "[A-ZА-Я]", options: .regularExpression) != nil }
    var hasLowercase: Bool { password.range(of: "[a-zа-я]", options: .regularExpression) != nil }
    var hasNumberOrSymbol: Bool { password.range(of: "[0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]", options: .regularExpression) != nil }
    var isPasswordValid: Bool { isMinLength && hasUppercase && hasLowercase && hasNumberOrSymbol }
    var isPasswordsMatch: Bool { !password.isEmpty && password == confirmPassword }
    
    var canSignUp: Bool {
        !name.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && isPasswordValid && isPasswordsMatch
    }
    
    // MARK: - Регистрация пользователя
    func registerUserInfo(profileVM: ProfileViewModel) {
        authErrorMessage = ""
        isLoading = true
        
        profileVM.updateOwnerInfo(
            name: name,
            email: email,
            phone: "+375 " + phoneNumber,
            city: selectedCity
        )
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.authErrorMessage = error.localizedDescription
                return
            }
            
            Auth.auth().currentUser?.sendEmailVerification { error in
                if let error = error {
                    self.authErrorMessage = error.localizedDescription
                } else {
                    withAnimation { self.currentScreen = .verifyOTP }
                }
            }
        }
    }
    
    // MARK: - Проверка клика по ссылке в Email (Спринт 2)
    func checkEmailVerification(onSuccess: @escaping () -> Void) {
        authErrorMessage = ""
        isLoading = true
        
        guard let user = Auth.auth().currentUser else {
            isLoading = false
            authErrorMessage = "Пользователь не найден. Попробуйте зарегистрироваться снова."
            return
        }
        
        // Обновляем состояние пользователя из Firebase
        user.reload { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.authErrorMessage = "Ошибка проверки: \(error.localizedDescription)"
                return
            }
            
            if user.isEmailVerified {
                self.isEmailVerified = true
                onSuccess()
            } else {
                self.authErrorMessage = "Email еще не подтвержден. Пожалуйста, перейдите по ссылке в письме."
            }
        }
    }
}
