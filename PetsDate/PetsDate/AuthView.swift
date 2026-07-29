import SwiftUI

// MARK: - Модель состояния экранов авторизации
enum AuthScreen {
    case login
    case selectCity
    case signUp
}

struct AuthView: View {
    @State private var currentScreen: AuthScreen = .login
    
    // Поля формы
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var email = ""
    @State private var selectedCity = "Минск"
    @State private var isAgreed = false
    
    let belarusCities = ["Минск", "Брест", "Гродно", "Гомель", "Могилёв", "Витебск"]
    
    var body: some View {
        ZStack {
            // Фирменный градиентный фон
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color("AppBackground1"), location: 0.1),
                    Gradient.Stop(color: Color("AppBackground2"), location: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer(minLength: 40)
                    
                    // Содержимое текущего экрана
                    currentScreenView
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Динамический выбор экрана
    @ViewBuilder
    private var currentScreenView: some View {
        switch currentScreen {
        case .login:
            loginCard
        case .selectCity:
            selectCityCard
        case .signUp:
            signUpCard
        }
    }
    
    // MARK: - 1. Экран Входа (Login)
    private var loginCard: some View {
        VStack(spacing: 20) {
            // Шапка бренда
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
            
            // Поле телефона (+375)
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
            
            // Поле пароля
            SecureField("Пароль", text: $password)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            Button("Забыли пароль?") { }
                .font(.footnote)
                .foregroundColor(Color("AppAccent"))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Кнопка Входа
            Button(action: {
                // Логика входа
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
            
            // Переход на Регистрацию
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
    
    // MARK: - 2. Экран выбора города (Беларусь)
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
            
            // Заглушка карты Беларуси
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
            
            // Выпадающий список городов
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
    
    // MARK: - 3. Экран ввода данных (Sign Up)
    private var signUpCard: some View {
        VStack(spacing: 16) {
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
            
            // Поле Имени
            TextField("Имя", text: $name)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Поле Email
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Телефон (+375)
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
            
            // Пароль
            SecureField("Пароль", text: $password)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Подтверждение пароля
            SecureField("Повторите пароль", text: $confirmPassword)
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
            .padding(.vertical, 4)
            
            // Кнопка Зарегистрироваться
            Button(action: {
                // Регистрация
            }) {
                Text("Зарегистрироваться")
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
}

#Preview {
    AuthView()
}
