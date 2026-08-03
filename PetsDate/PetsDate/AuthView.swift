import SwiftUI
import FirebaseAuth

enum AuthScreen {
    case login
    case selectCity
    case signUp
    case verifyOTP
    case createProfile
    case mainSwipe
}

struct AuthView: View {
    // Подключаем ViewModels через StateObject
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    // Таймер для OTP
    @State private var timeRemaining = 60
    @State private var timerActive = false
    
    let belarusCities = ["Минск", "Брест", "Гродно", "Гомель", "Могилёв", "Витебск"]
    
    var body: some View {
        ZStack {
            if authVM.currentScreen != .createProfile && authVM.currentScreen != .mainSwipe {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color("AppBackground1"), location: 0.1),
                        Gradient.Stop(color: Color("AppBackground2"), location: 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            if authVM.currentScreen == .createProfile {
                CreateProfileView(
                    initialProfile: profileVM.profile,
                    onBackToLogin: {
                        withAnimation { authVM.currentScreen = .login }
                    },
                    onFinish: { createdProfile in
                        profileVM.profile = createdProfile
                        withAnimation { authVM.currentScreen = .mainSwipe }
                    }
                )
            } else if authVM.currentScreen == .mainSwipe {
                MainSwipeView(
                    userProfile: profileVM.profile,
                    onLogout: {
                        withAnimation { authVM.currentScreen = .login }
                    }
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 40)
                        currentScreenView
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    @ViewBuilder
    private var currentScreenView: some View {
        switch authVM.currentScreen {
        case .login:
            loginCard
        case .selectCity:
            selectCityCard
        case .signUp:
            signUpCard
        case .verifyOTP:
            otpCard
        case .createProfile, .mainSwipe:
            EmptyView()
        }
    }
    
    // MARK: - 1. Вход
    private var loginCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("AppAccent"))
                
                Text("PetsDate")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AppAccent"))
            }
            .padding(.bottom, 10)
            
            Text("Вход")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
            
            HStack {
                Text("+375")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                
                Divider().frame(height: 20)
                
                TextField("29 123-45-67", text: $authVM.phoneNumber)
                    .keyboardType(.phonePad)
            }
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            HStack {
                if authVM.isPasswordVisible {
                    TextField("Пароль", text: $authVM.password)
                } else {
                    SecureField("Пароль", text: $authVM.password)
                }
                
                Button(action: { authVM.isPasswordVisible.toggle() }) {
                    Image(systemName: authVM.isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            Button("Забыли пароль?") { }
                .font(.footnote)
                .foregroundColor(Color("AppAccent"))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Button(action: {
                if profileVM.profile.ownerPhone.isEmpty {
                    profileVM.profile.ownerPhone = "+375 " + authVM.phoneNumber
                }
                // Подтягиваем свежий профиль из базы Firestore
                profileVM.fetchProfileFromFirestore()
                withAnimation { authVM.currentScreen = .mainSwipe }
            }) {
                Text("Войти")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AppAccent"))
                    .cornerRadius(26)
                    .shadow(color: Color("AppAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
            
            HStack {
                Text("Впервые в PetsDate?").foregroundColor(.gray)
                Button("Создать аккаунт") {
                    withAnimation { authVM.currentScreen = .selectCity }
                }
                .fontWeight(.bold)
                .foregroundColor(Color("AppAccent"))
            }
            .font(.subheadline)
            .padding(.top, 10)
        }
        .padding(24)
        .background(Color.white.opacity(0.95))
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - 2. Выбор города
    private var selectCityCard: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { withAnimation { authVM.currentScreen = .login } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                Text("Регистрация").font(.system(size: 20, weight: .bold))
                Spacer()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("AppBackground1").opacity(0.4))
                    .frame(height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color("AppAccent"))
                    Text("Республика Беларусь")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            
            Text("Выберите ваш город").font(.subheadline).foregroundColor(.gray)
            
            Picker("Город", selection: $authVM.selectedCity) {
                ForEach(belarusCities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            
            Button(action: {
                withAnimation { authVM.currentScreen = .signUp }
            }) {
                Text("Продолжить")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AppAccent"))
                    .cornerRadius(26)
            }
            
            HStack {
                Text("Уже есть аккаунт?").foregroundColor(.gray)
                Button("Войти") {
                    withAnimation { authVM.currentScreen = .login }
                }
                .fontWeight(.bold)
                .foregroundColor(Color("AppAccent"))
            }
            .font(.subheadline)
        }
        .padding(24)
        .background(Color.white.opacity(0.95))
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - 3. Форма регистрации
    private var signUpCard: some View {
        VStack(spacing: 14) {
            HStack {
                Button(action: { withAnimation { authVM.currentScreen = .selectCity } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                Text("Создание аккаунта").font(.system(size: 20, weight: .bold))
                Spacer()
            }
            
            TextField("Имя", text: $authVM.name)
                .padding(.horizontal, 16).frame(height: 48).background(Color.white).cornerRadius(14)
            
            TextField("Email", text: $authVM.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 16).frame(height: 48).background(Color.white).cornerRadius(14)
            
            HStack {
                Text("+375").fontWeight(.bold).foregroundColor(.gray).padding(.leading, 12)
                Divider().frame(height: 20)
                TextField("29 123-45-67", text: $authVM.phoneNumber).keyboardType(.phonePad)
            }
            .frame(height: 48).background(Color.white).cornerRadius(14)
            
            HStack {
                if authVM.isPasswordVisible {
                    TextField("Пароль", text: $authVM.password)
                } else {
                    SecureField("Пароль", text: $authVM.password)
                }
                Button(action: { authVM.isPasswordVisible.toggle() }) {
                    Image(systemName: authVM.isPasswordVisible ? "eye.fill" : "eye.slash.fill").foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16).frame(height: 48).background(Color.white).cornerRadius(14)
            
            VStack(spacing: 6) {
                HStack {
                    validationItem(isMet: authVM.isMinLength, text: "Не менее 8 символов")
                    Spacer()
                    validationItem(isMet: authVM.hasUppercase, text: "Заглавная буква")
                }
                HStack {
                    validationItem(isMet: authVM.hasNumberOrSymbol, text: "Цифра или символ")
                    Spacer()
                    validationItem(isMet: authVM.hasLowercase, text: "Строчная буква")
                }
            }
            .padding(.horizontal, 4)
            
            HStack {
                if authVM.isConfirmPasswordVisible {
                    TextField("Повторите пароль", text: $authVM.confirmPassword)
                } else {
                    SecureField("Повторите пароль", text: $authVM.confirmPassword)
                }
                if !authVM.confirmPassword.isEmpty {
                    Image(systemName: authVM.isPasswordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(authVM.isPasswordsMatch ? .green : .red)
                }
                Button(action: { authVM.isConfirmPasswordVisible.toggle() }) {
                    Image(systemName: authVM.isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill").foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16).frame(height: 48).background(Color.white).cornerRadius(14)
            
            HStack(alignment: .top, spacing: 10) {
                Button(action: { authVM.isAgreed.toggle() }) {
                    Image(systemName: authVM.isAgreed ? "checkmark.square.fill" : "square")
                        .foregroundColor(authVM.isAgreed ? Color("AppAccent") : .gray)
                        .font(.system(size: 20))
                }
                Text("Я согласен с Условиями использования и Политикой конфиденциальности")
                    .font(.caption).foregroundColor(.gray)
            }
            
            if !authVM.authErrorMessage.isEmpty {
                Text(authVM.authErrorMessage)
                    .font(.caption).foregroundColor(.red).multilineTextAlignment(.center)
            }
            
            Button(action: {
                authVM.registerUserInfo(profileVM: profileVM)
            }) {
                Text("Зарегистрироваться")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(authVM.canSignUp && authVM.isAgreed ? Color("AppAccent") : Color.gray.opacity(0.4))
                    .cornerRadius(26)
            }
            .disabled(!authVM.canSignUp || !authVM.isAgreed)
            
            HStack {
                Text("Уже есть аккаунт?").foregroundColor(.gray)
                Button("Войти") {
                    withAnimation { authVM.currentScreen = .login }
                }
                .fontWeight(.bold).foregroundColor(Color("AppAccent"))
            }
            .font(.subheadline)
        }
        .padding(24)
        .background(Color.white.opacity(0.95))
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func validationItem(isMet: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark" : "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isMet ? .green : .gray.opacity(0.6))
            Text(text).font(.system(size: 12)).foregroundColor(isMet ? .black.opacity(0.8) : .gray)
        }
    }
    
    // MARK: - 4. OTP / Верификация Email с реальной проверкой
    private var otpCard: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { withAnimation { authVM.currentScreen = .signUp } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
            }
            
            Text("Верификация Email")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            Text("Мы отправили ссылку для подтверждения на ваш email:\n\(authVM.email)")
                .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
            
            Button("Изменить Email") {
                withAnimation { authVM.currentScreen = .signUp }
            }
            .font(.footnote).fontWeight(.bold).foregroundColor(Color("AppAccent"))
            
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60)).foregroundColor(Color("AppAccent")).padding(.vertical, 10)
            
            if !authVM.authErrorMessage.isEmpty {
                Text(authVM.authErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            if timeRemaining > 0 {
                Text(String(format: "Повторная отправка через 00:%02d сек", timeRemaining))
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.gray)
                    .task {
                        while timeRemaining > 0 && timerActive {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            timeRemaining -= 1
                        }
                    }
            } else {
                Button("Отправить письмо повторно") {
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if error == nil { startOTPTimer() }
                    }
                }
                .font(.system(size: 14, weight: .bold)).foregroundColor(Color("AppAccent"))
            }
            
            Button(action: {
                // Проверяем подтверждение перед переходом
                authVM.checkEmailVerification {
                    withAnimation { authVM.currentScreen = .createProfile }
                }
            }) {
                HStack(spacing: 8) {
                    if authVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Перейти к созданию профиля")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color("AppAccent"))
                .cornerRadius(26)
            }
            .disabled(authVM.isLoading)
            .padding(.top, 10)
        }
        .padding(24)
        .background(Color.white.opacity(0.95))
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func startOTPTimer() {
        timeRemaining = 60
        timerActive = true
    }
}

#Preview {
    AuthView()
}
