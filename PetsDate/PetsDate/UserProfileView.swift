import SwiftUI

enum ProfileSubScreen {
    case main
    case infoDetails
    case preferences
    case notifications
    case security
    case changePassword
}

struct UserProfileView: View {
    // Данные питомца и владельца
    var profile: PetProfile
    
    var onBack: () -> Void = {}
    var onEditProfile: () -> Void = {}
    var onOpenPreferences: () -> Void = {}
    var onLogout: () -> Void = {}
    
    @State private var activeSubScreen: ProfileSubScreen = .main
    
    // MARK: - Состояния Уведомлений
    @State private var pushAll = true
    @State private var pushNewMatch = true
    @State private var pushNewUser = true
    @State private var pushSubscription = false
    @State private var pushPlatform = false
    
    // MARK: - Состояния Безопасности
    @State private var isFaceIDEnabled = true
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    
    // MARK: - Состояния Предпочтений (Preferences)
    @State private var prefPetType: String = "Собака"
    @State private var prefSelectedBreeds: Set<String> = ["Золотистый ретривер"]
    @State private var prefBreedSearchQuery: String = ""
    @State private var prefMinAge: Int = 2
    @State private var prefMaxAge: Int = 5
    @State private var prefGender: String = "Мальчик"
    
    // Списки типов и пород (идентичные онбордингу)
    let petTypes = ["Кошка", "Собака", "Другое"]
    
    let popularDogBreeds = ["Любая", "Метис / Беспородный", "Золотистый ретривер", "Лабрадор ретривер", "Французский бульдог", "Бигль"]
    let otherDogBreeds = ["Акита-ину", "Аляскинский маламут", "Бульдог", "Вельш-корги пемброк", "Джек-рассел-терьер", "Доберман", "Йоркширский терьер", "Кане-корсо", "Мопс", "Немецкая овчарка", "Померанский шпиц", "Пудель", "Такса", "Чихуахуа", "Шпиц"]
    
    let popularCatBreeds = ["Любая", "Метис / Беспородная", "Мейн-кун", "Британская короткошерстная", "Шотландская вислоухая", "Сфинкс"]
    let otherCatBreeds = ["Абиссинская", "Бенгальская", "Девон-рекс", "Канадский сфинкс", "Корниш-рекс", "Невская маскарадная", "Персидская", "Рэгдолл", "Русская голубая", "Сиамская", "Сибирская"]
    
    let otherPetsBreeds = ["Любая", "Кролик", "Хомяк", "Морская свинка", "Шиншилла", "Хорёк", "Попугай", "Черепаха", "Другой вид"]
    
    // Динамический фильтр пород в зависимости от выбранного Вида
    var prefFilteredBreeds: [String] {
        let allBreeds: [String]
        switch prefPetType {
        case "Кошка":
            allBreeds = popularCatBreeds + otherCatBreeds
        case "Собака":
            allBreeds = popularDogBreeds + otherDogBreeds
        default:
            allBreeds = otherPetsBreeds
        }
        
        if prefBreedSearchQuery.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.localizedCaseInsensitiveContains(prefBreedSearchQuery) }
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            switch activeSubScreen {
            case .main:
                mainProfileView
                    .transition(.move(edge: .leading))
            case .infoDetails:
                profileInfoDetailsView
                    .transition(.move(edge: .trailing))
            case .preferences:
                preferencesView
                    .transition(.move(edge: .trailing))
            case .notifications:
                notificationsView
                    .transition(.move(edge: .trailing))
            case .security:
                securityView
                    .transition(.move(edge: .trailing))
            case .changePassword:
                changePasswordView
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    // MARK: - 1. Главный экран профиля
    private var mainProfileView: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        if let image = profile.mainPhoto {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 320)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        } else {
                            ZStack {
                                LinearGradient(
                                    colors: [Color("AppBackground1"), Color("AppBackground2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(Color("AppAccent").opacity(0.3))
                            }
                            .frame(height: 320)
                        }
                    }
                    
                    VStack(spacing: 20) {
                        if profile.isVaccinated {
                            HStack(spacing: 8) {
                                Image(systemName: "cross.case.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.cyan)
                                    .clipShape(Circle())
                                
                                Text("Вакцинирован")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.cyan.opacity(0.12))
                            .cornerRadius(20)
                            .offset(y: -20)
                            .padding(.bottom, -20)
                        }
                        
                        VStack(spacing: 8) {
                            menuItem(icon: "person.crop.square", title: "Информация о профиле") {
                                withAnimation { activeSubScreen = .infoDetails }
                            }
                            menuItem(icon: "slider.horizontal.3", title: "Мои предпочтения") {
                                withAnimation { activeSubScreen = .preferences }
                            }
                            menuItem(icon: "sparkles.rectangle.stack", title: "Подписка", action: {})
                            menuItem(icon: "bell", title: "Уведомления") {
                                withAnimation { activeSubScreen = .notifications }
                            }
                            menuItem(icon: "key", title: "Безопасность") {
                                withAnimation { activeSubScreen = .security }
                            }
                        }
                        .padding(.top, profile.isVaccinated ? 8 : 20)
                        
                        Button(action: onLogout) {
                            HStack {
                                Text("Выйти из аккаунта")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Подробнее о \(profile.petName.isEmpty ? "питомце" : profile.petName)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black.opacity(0.85))
                                .underline()
                            
                            HStack(spacing: 6) {
                                Link("Политика конфиденциальности", destination: URL(string: "https://petsdate.app/privacy")!)
                                    .foregroundColor(Color("AppAccent"))
                                Text("и").foregroundColor(.gray)
                                Link("Условия использования", destination: URL(string: "https://petsdate.app/terms")!)
                                    .foregroundColor(Color("AppAccent"))
                            }
                            .font(.system(size: 12, weight: .medium))
                            
                            Text("Версия 1.0.1")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding(.top, 12)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(32)
                    .offset(y: -24)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            HStack {
                Button(action: onBack) {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        )
                }
                
                Spacer()
                
                Button(action: onEditProfile) {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
        }
    }
    
    // MARK: - 2. Информация о профиле (Profile information)
    private var profileInfoDetailsView: some View {
        VStack(spacing: 0) {
            subScreenHeader(title: "Информация о профиле", backAction: { activeSubScreen = .main })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("О питомце")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            detailRow(title: "Кличка", value: profile.petName.isEmpty ? "Не указана" : profile.petName)
                            Divider().padding(.leading, 16)
                            detailRow(title: "Вид и порода", value: "\(profile.petType), \(profile.breed.isEmpty ? "Метис" : profile.breed)")
                            Divider().padding(.leading, 16)
                            detailRow(title: "Пол", value: profile.gender)
                            Divider().padding(.leading, 16)
                            detailRow(title: "Возраст", value: "\(profile.ageYears) года \(profile.ageMonths) мес")
                            Divider().padding(.leading, 16)
                            detailRow(title: "Рост и Вес", value: "\(profile.heightCm.isEmpty ? "40" : profile.heightCm) см / \(profile.weightKg.isEmpty ? "10" : profile.weightKg) кг")
                            Divider().padding(.leading, 16)
                            detailRow(title: "Характер", value: profile.traits.isEmpty ? "Игривый" : profile.traits.joined(separator: ", "))
                            Divider().padding(.leading, 16)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Описание")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                                }
                                Text(profile.bioText.isEmpty ? "Описание пока не добавлено." : profile.bioText)
                                    .font(.system(size: 14)).foregroundColor(.gray).lineLimit(3)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            
                            Divider().padding(.leading, 16)
                            
                            HStack {
                                Text("Вакцинация").font(.system(size: 15, weight: .medium)).foregroundColor(.black)
                                Spacer()
                                if profile.isVaccinated {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                                        Text("Да").font(.system(size: 15, weight: .medium)).foregroundColor(.gray)
                                    }
                                } else {
                                    Text("Нет").font(.system(size: 15, weight: .medium)).foregroundColor(.gray)
                                }
                                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                        }
                        .background(Color.white).cornerRadius(16).padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("О владельце")
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(.gray).padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            detailRow(title: "Имя владельца", value: profile.ownerName.isEmpty ? "Не указано" : profile.ownerName)
                            Divider().padding(.leading, 16)
                            detailRow(title: "Email", value: profile.ownerEmail.isEmpty ? "Не указан" : profile.ownerEmail)
                            Divider().padding(.leading, 16)
                            detailRow(title: "Номер телефона", value: profile.ownerPhone.isEmpty ? "Не указан" : profile.ownerPhone)
                            Divider().padding(.leading, 16)
                            detailRow(title: "Город", value: profile.ownerCity.isEmpty ? "Минск" : profile.ownerCity)
                        }
                        .background(Color.white).cornerRadius(16).padding(.horizontal, 16)
                    }
                    
                    Button(action: {}) {
                        Text("Удалить аккаунт")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.red)
                            .padding(.horizontal, 20).padding(.vertical, 8)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground)).ignoresSafeArea(edges: .top)
    }
    
    // MARK: - 3. Мои предпочтения (My Preferences) с синхронизированными породами
    private var preferencesView: some View {
        VStack(spacing: 0) {
            subScreenHeader(title: "Мои предпочтения", backAction: { activeSubScreen = .main })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Вид питомца
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Вид").font(.system(size: 18, weight: .bold))
                        HStack(spacing: 20) {
                            ForEach(petTypes, id: \.self) { type in
                                Button(action: {
                                    prefPetType = type
                                    prefSelectedBreeds.removeAll() // Сбрасываем выбранные породы при смене вида
                                }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .stroke(prefPetType == type ? Color("AppAccent") : Color.gray.opacity(0.4), lineWidth: 2)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Circle()
                                                    .fill(prefPetType == type ? Color("AppAccent") : Color.clear)
                                                    .frame(width: 10, height: 10)
                                            )
                                        Text(type).font(.system(size: 15, weight: .medium)).foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Выбор и Поиск Породы
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Порода").font(.system(size: 18, weight: .bold))
                        
                        // Поле ввода поиска
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Выберите породу", text: $prefBreedSearchQuery).font(.system(size: 15))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Отображение выбранных плашек/тегов пород
                        if !prefSelectedBreeds.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(prefSelectedBreeds), id: \.self) { breed in
                                        HStack(spacing: 6) {
                                            Text(breed).font(.system(size: 14, weight: .medium))
                                            Button(action: { prefSelectedBreeds.remove(breed) }) {
                                                Image(systemName: "xmark").font(.system(size: 10, weight: .bold))
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.12))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        
                        // Выпадающий список пород для выбранного вида
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(prefFilteredBreeds, id: \.self) { breed in
                                    Button(action: {
                                        if breed == "Любая" {
                                            prefSelectedBreeds = ["Любая"]
                                        } else {
                                            prefSelectedBreeds.remove("Любая")
                                            if prefSelectedBreeds.contains(breed) {
                                                prefSelectedBreeds.remove(breed)
                                            } else {
                                                prefSelectedBreeds.insert(breed)
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(breed)
                                                .font(.system(size: 15))
                                                .foregroundColor(.black)
                                            Spacer()
                                            if prefSelectedBreeds.contains(breed) {
                                                Image(systemName: "checkmark.square.fill")
                                                    .foregroundColor(Color("AppAccent"))
                                            } else {
                                                Image(systemName: "square")
                                                    .foregroundColor(.gray.opacity(0.3))
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                            }
                            .padding(8)
                        }
                        .frame(maxHeight: 180)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Возраст
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Возраст").font(.system(size: 18, weight: .bold))
                        
                        HStack(spacing: 16) {
                            HStack {
                                Text("От:").foregroundColor(.gray)
                                TextField("2", value: $prefMinAge, formatter: NumberFormatter())
                                    .keyboardType(.numberPad).font(.system(size: 16, weight: .bold))
                            }
                            .padding(.horizontal, 14).frame(height: 46).background(Color.white).cornerRadius(12)
                            
                            HStack {
                                Text("До:").foregroundColor(.gray)
                                TextField("5", value: $prefMaxAge, formatter: NumberFormatter())
                                    .keyboardType(.numberPad).font(.system(size: 16, weight: .bold))
                            }
                            .padding(.horizontal, 14).frame(height: 46).background(Color.white).cornerRadius(12)
                        }
                    }
                    
                    // Пол
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Пол").font(.system(size: 18, weight: .bold))
                        
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(["Мальчик", "Девочка", "Все"], id: \.self) { gender in
                                Button(action: { prefGender = gender }) {
                                    HStack(spacing: 10) {
                                        Circle()
                                            .stroke(prefGender == gender ? Color("AppAccent") : Color.gray.opacity(0.4), lineWidth: 2)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Circle()
                                                    .fill(prefGender == gender ? Color("AppAccent") : Color.clear)
                                                    .frame(width: 10, height: 10)
                                            )
                                        Text(gender).font(.system(size: 15, weight: .medium)).foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: { withAnimation { activeSubScreen = .main } }) {
                        Text("Сохранить")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.black).cornerRadius(26)
                    }
                    .padding(.top, 16)
                }
                .padding(20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground)).ignoresSafeArea(edges: .top)
    }
    
    // MARK: - 4. Уведомления (Notifications)
    private var notificationsView: some View {
        VStack(spacing: 0) {
            subScreenHeader(title: "Уведомления", backAction: { activeSubScreen = .main })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Push-уведомления")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        Toggle(isOn: $pushAll) {
                            Text("Все push-уведомления").font(.system(size: 15, weight: .bold))
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                        
                        Divider().padding(.leading, 16)
                        
                        Toggle(isOn: $pushNewMatch) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Новый мэтч").font(.system(size: 15, weight: .bold))
                                Text("У вас новый мэтч!").font(.caption).foregroundColor(.gray)
                            }
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                        
                        Divider().padding(.leading, 16)
                        
                        Toggle(isOn: $pushNewUser) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Новый пользователь").font(.system(size: 15, weight: .bold))
                                Text("Не пропустите нового пользователя рядом!").font(.caption).foregroundColor(.gray)
                            }
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                        
                        Divider().padding(.leading, 16)
                        
                        Toggle(isOn: $pushSubscription) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Подписка").font(.system(size: 15, weight: .bold))
                                Text("Уведомления о вашей подписке.").font(.caption).foregroundColor(.gray)
                            }
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                        
                        Divider().padding(.leading, 16)
                        
                        Toggle(isOn: $pushPlatform) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Системные уведомления").font(.system(size: 15, weight: .bold))
                                Text("Служба поддержки и важные сообщения.").font(.caption).foregroundColor(.gray)
                            }
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground)).ignoresSafeArea(edges: .top)
    }
    
    // MARK: - 5. Безопасность (Security)
    private var securityView: some View {
        VStack(spacing: 0) {
            subScreenHeader(title: "Безопасность", backAction: { activeSubScreen = .main })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Пароль")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            withAnimation { activeSubScreen = .changePassword }
                        }) {
                            HStack {
                                Text("Сменить пароль")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color("AppAccent"))
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Face ID")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Toggle(isOn: $isFaceIDEnabled) {
                            Text("Вход по Face ID")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .tint(Color("AppAccent"))
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground)).ignoresSafeArea(edges: .top)
    }
    
    // MARK: - 6. Смена пароля (Change password)
    private var changePasswordView: some View {
        VStack(spacing: 0) {
            subScreenHeader(title: "Сменить пароль", backAction: { activeSubScreen = .security })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    SecureField("Текущий пароль", text: $currentPassword)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(16)
                    
                    SecureField("Новый пароль", text: $newPassword)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(16)
                    
                    SecureField("Повторите новый пароль", text: $confirmNewPassword)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(16)
                    
                    Button(action: {
                        withAnimation { activeSubScreen = .security }
                    }) {
                        Text("Сохранить изменения")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.black)
                            .cornerRadius(26)
                    }
                    .padding(.top, 10)
                    
                    Button(action: {
                        withAnimation { activeSubScreen = .security }
                    }) {
                        Text("Отмена")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(Color.black, lineWidth: 1.5)
                            )
                    }
                    
                    Button("Забыли пароль?") {}
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AppAccent"))
                        .padding(.top, 6)
                }
                .padding(20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground)).ignoresSafeArea(edges: .top)
    }
    
    private func subScreenHeader(title: String, backAction: @escaping () -> Void) -> some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .foregroundColor(Color("AppAccent"))
            }
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 16)
        .background(Color.white)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.black)
            Spacer()
            Text(value).font(.system(size: 15)).foregroundColor(.gray)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
    
    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
                Text(title).font(.system(size: 16, weight: .medium)).foregroundColor(.black.opacity(0.85))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.gray.opacity(0.5))
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    UserProfileView(profile: PetProfile(petType: "Собака", breed: "Мопс", petName: "Бетти", gender: "Девочка", isVaccinated: true))
}
