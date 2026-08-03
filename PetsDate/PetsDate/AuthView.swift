import SwiftUI

struct AuthView: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    // Локальные состояния для ввода текста
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var nameInput: String = ""
    @State private var phoneInput: String = ""
    @State private var otpInput: String = ""
    
    let belarusCities = ["Минск", "Гомель", "Могилев", "Витебск", "Гродно", "Брест"]
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack {
                if authVM.currentScreen == .mainSwipe {
                    MainSwipeView()
                } else {
                    scrollViewContent
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authVM.currentScreen)
    }
    
    private var scrollViewContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerLogoView
                
                switch authVM.currentScreen {
                case .login:
                    loginScreenView
                case .selectCity:
                    selectCityScreenView
                case .signUp:
                    signUpScreenView
                case .verifyOTP:
                    verifyOTPScreenView
                case .createProfile:
                    CreateProfileView(initialProfile: profileVM.profile, onFinish: { updatedProfile in
                        profileVM.profile = updatedProfile
                        authVM.currentScreen = .mainSwipe
                    })
                case .mainSwipe:
                    EmptyView()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Header Logo
    private var headerLogoView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
                .shadow(color: Color(red: 0.95, green: 0.5, blue: 0.2).opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("PetsDate")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            Text("Найди друга своему питомцу 🐾")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Login Screen
    private var loginScreenView: some View {
        VStack(spacing: 16) {
            Text("Вход в аккаунт")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            customTextField(placeholder: "Email", text: $emailInput, icon: "envelope.fill")
            customSecureField(placeholder: "Пароль", text: $passwordInput, icon: "lock.fill")
            
            if let error = authVM.errorMessage {
                Text(error)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            primaryButton(title: "Войти") {
                authVM.login(email: emailInput, password: passwordInput) { success in
                    if success {
                        authVM.currentScreen = .mainSwipe
                    }
                }
            }
            
            Button("Нет аккаунта? Зарегистрироваться") {
                authVM.errorMessage = nil
                authVM.currentScreen = .selectCity
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
        }
        .padding(24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Select City Screen
    private var selectCityScreenView: some View {
        VStack(spacing: 16) {
            Text("Выберите ваш город")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            ForEach(belarusCities, id: \.self) { city in
                Button(action: {
                    profileVM.profile.ownerCity = city
                    authVM.currentScreen = .signUp
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
                        Text(city)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding()
                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                    .cornerRadius(16)
                }
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Sign Up Screen
    private var signUpScreenView: some View {
        VStack(spacing: 16) {
            Text("Регистрация")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            customTextField(placeholder: "Ваше имя", text: $nameInput, icon: "person.fill")
            customTextField(placeholder: "Email", text: $emailInput, icon: "envelope.fill")
            customTextField(placeholder: "Телефон", text: $phoneInput, icon: "phone.fill")
            customSecureField(placeholder: "Пароль", text: $passwordInput, icon: "lock.fill")
            
            if let error = authVM.errorMessage {
                Text(error)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.red)
            }
            
            primaryButton(title: "Продолжить") {
                authVM.signUp(email: emailInput, password: passwordInput) { success in
                    if success {
                        profileVM.profile.ownerName = nameInput
                        profileVM.profile.ownerEmail = emailInput
                        profileVM.profile.ownerPhone = phoneInput
                        authVM.currentScreen = .createProfile
                    }
                }
            }
            
            Button("Уже есть аккаунт? Войти") {
                authVM.errorMessage = nil
                authVM.currentScreen = .login
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
        }
        .padding(24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Verify OTP Screen
    private var verifyOTPScreenView: some View {
        VStack(spacing: 16) {
            Text("Подтверждение кода")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            customTextField(placeholder: "Код из СМС", text: $otpInput, icon: "number")
            
            primaryButton(title: "Подтвердить") {
                authVM.currentScreen = .createProfile
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - UI Helpers
    private func customTextField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
                .frame(width: 24)
            TextField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
        }
        .padding()
        .background(Color(red: 0.97, green: 0.96, blue: 0.95))
        .cornerRadius(16)
    }
    
    private func customSecureField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
                .frame(width: 24)
            SecureField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
        }
        .padding()
        .background(Color(red: 0.97, green: 0.96, blue: 0.95))
        .cornerRadius(16)
    }
    
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if authVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.5, blue: 0.2), Color(red: 0.85, green: 0.35, blue: 0.15)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(26)
            .shadow(color: Color(red: 0.95, green: 0.5, blue: 0.2).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(authVM.isLoading)
    }
}
