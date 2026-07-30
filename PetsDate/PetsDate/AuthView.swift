import SwiftUI
import FirebaseAuth

// MARK: - Модель состояния экранов авторизации
enum AuthScreen {
    case login
    case selectCity
    case signUp
    case verifyOTP
    case createProfile
}

struct AuthView: View {
    @State private var currentScreen: AuthScreen = .login
    
    // Поля формы
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    @State private var name = ""
    @State private var email = ""
    @State private var selectedCity = "Минск"
    @State private var isAgreed = false
    
    // Поля OTP / Верификации
    @State private var timeRemaining = 60
    @State private var timerActive = false
    @State private var authErrorMessage = ""
    
    let belarusCities = ["Минск", "Брест", "Гродно", "Гомель", "Могилёв", "Витебск"]
    
    // MARK: - Валидация пароля
    private var isMinLength: Bool { password.count >= 8 }
    private var hasUppercase: Bool { password.range(of: "[A-ZА-Я]", options: .regularExpression) != nil }
    private var hasLowercase: Bool { password.range(of: "[a-zа-я]", options: .regularExpression) != nil }
    private var hasNumberOrSymbol: Bool { password.range(of: "[0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]", options: .regularExpression) != nil }
    private var isPasswordValid: Bool { isMinLength && hasUppercase && hasLowercase && hasNumberOrSymbol }
    private var isPasswordsMatch: Bool { !password.isEmpty && password == confirmPassword }
    
    var body: some View {
        ZStack {
            // Фирменный градиентный фон (скрываем на экране создания профиля)
            if currentScreen != .createProfile {
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
            
            if currentScreen == .createProfile {
                CreateProfileView(onBackToLogin: {
                    withAnimation {
                        currentScreen = .login
                    }
                })
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
    
    // MARK: - Выбор экрана
    @ViewBuilder
    private var currentScreenView: some View {
        switch currentScreen {
        case .login:
            loginCard
        case .selectCity:
            selectCityCard
        case .signUp:
            signUpCard
        case .verifyOTP:
            otpCard
        case .createProfile:
            CreateProfileView(onBackToLogin: {
                withAnimation {
                    currentScreen = .login
                }
            })
        }
    }
    
    // MARK: - 1. Экран Входа (Login)
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
                
                Divider()
                    .frame(height: 20)
                
                TextField("29 123-45-67", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            // Пароль
            HStack {
                if isPasswordVisible {
                    TextField("Пароль", text: $password)
                } else {
                    SecureField("Пароль", text: $password)
                }
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
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
                // Переход к созданию профиля питомца
                withAnimation {
                    currentScreen = .createProfile
                }
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
                Text("Впервые в PetsDate?")
                    .foregroundColor(.gray)
                Button("Создать аккаунт") {
                    withAnimation { currentScreen = .selectCity }
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
    
    // MARK: - 2. Экран выбора города
    private var selectCityCard: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { withAnimation { currentScreen = .login } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                Text("Регистрация")
                    .font(.system(size: 20, weight: .bold))
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
            
            Text("Выберите ваш город")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Picker("Город", selection: $selectedCity) {
                ForEach(belarusCities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            
            Button(action: {
                withAnimation { currentScreen = .signUp }
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
                Text("Уже есть аккаунт?")
                    .foregroundColor(.gray)
                Button("Войти") {
                    withAnimation { currentScreen = .login }
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
    
    // MARK: - 3. Экран ввода данных и отправки Email через Firebase
    private var signUpCard: some View {
        VStack(spacing: 14) {
            HStack {
                Button(action: { withAnimation { currentScreen = .selectCity } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                Text("Создание аккаунта")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            
            TextField("Имя", text: $name)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            HStack {
                Text("+375")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                
                Divider()
                    .frame(height: 20)
                
                TextField("29 123-45-67", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Ввод пароля
            HStack {
                if isPasswordVisible {
                    TextField("Пароль", text: $password)
                } else {
                    SecureField("Пароль", text: $password)
                }
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Валидация пароля
            VStack(spacing: 6) {
                HStack {
                    validationItem(isMet: isMinLength, text: "Не менее 8 символов")
                    Spacer()
                    validationItem(isMet: hasUppercase, text: "Заглавная буква")
                }
                HStack {
                    validationItem(isMet: hasNumberOrSymbol, text: "Цифра или символ")
                    Spacer()
                    validationItem(isMet: hasLowercase, text: "Строчная буква")
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            
            // Повтор пароля
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Повторите пароль", text: $confirmPassword)
                } else {
                    SecureField("Повторите пароль", text: $confirmPassword)
                }
                
                if !confirmPassword.isEmpty {
                    Image(systemName: isPasswordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isPasswordsMatch ? .green : .red)
                }
                
                Button(action: { isConfirmPasswordVisible.toggle() }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Чекбокс согласия
            HStack(alignment: .top, spacing: 10) {
                Button(action: { isAgreed.toggle() }) {
                    Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                        .foregroundColor(isAgreed ? Color("AppAccent") : .gray)
                        .font(.system(size: 20))
                }
                
                Text("Я согласен с Условиями использования и Политикой конфиденциальности")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 2)
            
            if !authErrorMessage.isEmpty {
                Text(authErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // КНОПКА РЕГИСТРАЦИИ (Firebase)
            Button(action: {
                authErrorMessage = ""
                
                // 1. Создаем аккаунт в Firebase Auth
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        authErrorMessage = error.localizedDescription
                        print("Ошибка Firebase: \(error.localizedDescription)")
                        return
                    }
                    
                    // 2. Отправляем реальное письмо верификации на Email
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if let error = error {
                            authErrorMessage = error.localizedDescription
                            print("Ошибка отправки письма: \(error.localizedDescription)")
                        } else {
                            print("Письмо успешно отправлено на \(email)!")
                            startOTPTimer()
                            withAnimation { currentScreen = .verifyOTP }
                        }
                    }
                }
            }) {
                Text("Зарегистрироваться")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(canSignUp ? Color("AppAccent") : Color.gray.opacity(0.4))
                    .cornerRadius(26)
            }
            .disabled(!canSignUp)
            
            HStack {
                Text("Уже есть аккаунт?")
                    .foregroundColor(.gray)
                Button("Войти") {
                    withAnimation { currentScreen = .login }
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
    
    // Элемент списка правил
    private func validationItem(isMet: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark" : "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isMet ? .green : .gray.opacity(0.6))
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isMet ? .black.opacity(0.8) : .gray)
        }
    }
    
    // Разрешение на клик регистрации
    private var canSignUp: Bool {
        !name.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && isPasswordValid && isPasswordsMatch && isAgreed
    }
    
    // MARK: - 4. Экран ожидания подтверждения Email (otpCard)
    private var otpCard: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { withAnimation { currentScreen = .signUp } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
            }
            
            Text("Верификация Email")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            Text("Мы отправили ссылку для подтверждения на ваш email:\n\(email)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button("Изменить Email") {
                withAnimation { currentScreen = .signUp }
            }
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(Color("AppAccent"))
            
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundColor(Color("AppAccent"))
                .padding(.vertical, 10)
            
            if timeRemaining > 0 {
                Text(String(format: "Повторная отправка через 00:%02d сек", timeRemaining))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .task {
                        while timeRemaining > 0 && timerActive {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            timeRemaining -= 1
                        }
                    }
            } else {
                Button("Отправить письмо повторно") {
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if error == nil {
                            startOTPTimer()
                        }
                    }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("AppAccent"))
            }
            
            // КНОПКА ВОЗВРАТА К ЭКРАНУ ЛОГИНА
            Button(action: {
                withAnimation {
                    currentScreen = .login
                }
            }) {
                Text("Перейти к входу")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AppAccent"))
                    .cornerRadius(26)
            }
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
