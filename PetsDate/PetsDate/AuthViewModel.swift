import Foundation
import FirebaseAuth
import Combine

enum AuthScreen {
    case login
    case selectCity
    case signUp
    case verifyOTP
    case createProfile
    case mainSwipe
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen = .login
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Заполните все поля"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Заполните все поля"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
