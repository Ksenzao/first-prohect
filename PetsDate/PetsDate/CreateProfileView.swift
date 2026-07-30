import SwiftUI
import PhotosUI

struct CreateProfileView: View {
    // Callback для возврата на логин или завершения
    var onBackToLogin: () -> Void = {}
    var onFinish: () -> Void = {}
    
    // MARK: - Переменные состояния
    @State private var currentStep: Int = 1
    let totalSteps = 11
    
    // Шаг 1: Тип питомца
    @State private var selectedPetType: String = "Собака"
    let petTypes = ["Кошка", "Собака", "Другое"]
    
    // Шаг 2: Порода
    @State private var breedQuery: String = ""
    let popularDogBreeds = ["Метис / Беспородный", "Золотистый ретривер", "Лабрадор ретривер", "Французский бульдог", "Бигль"]
    let otherDogBreeds = ["Акита-ину", "Аляскинский маламут", "Бульдог", "Вельш-корги пемброк", "Джек-рассел-терьер", "Доберман", "Йоркширский терьер", "Кане-корсо", "Мопс", "Немецкая овчарка", "Померанский шпиц", "Пудель", "Такса", "Чихуахуа", "Шпиц"]
    
    let popularCatBreeds = ["Метис / Беспородная", "Мейн-кун", "Британская короткошерстная", "Шотландская вислоухая", "Сфинкс"]
    let otherCatBreeds = ["Абиссинская", "Бенгальская", "Девон-рекс", "Канадский сфинкс", "Корниш-рекс", "Невская маскарадная", "Персидская", "Рэгдолл", "Русская голубая", "Сиамская", "Сибирская"]
    
    let otherPetsBreeds = ["Кролик", "Хомяк", "Морская свинка", "Шиншилла", "Хорёк", "Попугай", "Черепаха", "Другой вид"]
    
    // Шаг 3: Имя питомца
    @State private var petName: String = ""
    
    // Шаг 4: Фотографии
    @State private var mainPhoto: UIImage? = nil
    @State private var additionalPhotos: [UIImage?] = [nil, nil, nil, nil]
    
    @State private var showSourceDialog = false
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var activePhotoIndex: Int = 0
    @State private var selectedPhotosPickerItem: PhotosPickerItem? = nil
    
    // Шаг 5: Пол
    @State private var selectedGender: String = "Мальчик"
    let genderOptions = ["Мальчик", "Девочка"]
    
    // Шаг 6: Возраст
    @State private var ageYears: String = "1"
    @State private var ageMonths: String = "0"
    
    // Шаг 7: Рост и вес
    @State private var heightCm: String = "40"
    @State private var weightKg: String = "10"
    
    // Шаг 8: Характер / Черты
    @State private var selectedTraits: Set<String> = ["Игривый", "Дружелюбный"]
    let allTraits = [
        "Игривый", "Активный", "Милый", "Маленький", "Красивый",
        "Пушистый", "Дружелюбный", "Шумный", "Тихий", "Ласковый",
        "Умный", "Быстрый", "Одиночка", "Спокойный", "Любопытный"
    ]
    
    // Шаг 9: Описание
    @State private var bioText: String = ""
    
    // Шаг 10 & 11: Вакцинация
    @State private var isVaccinated: Bool? = nil
    @State private var vaccineCertificatePhoto: UIImage? = nil
    @State private var vaccineDate: Date = Date()
    @State private var showVaccineSourceDialog = false
    @State private var showVaccineImagePicker = false
    @State private var showVaccineCameraPicker = false
    @State private var selectedVaccinePickerItem: PhotosPickerItem? = nil
    
    // MARK: - Переменные для Экрана Предпочтений (Preferences)
    @State private var showPreferencesEdit = false
    @State private var prefPetType: String = "Собака"
    @State private var prefSelectedBreeds: Set<String> = ["Золотистый ретривер"]
    @State private var prefBreedSearchQuery: String = ""
    @State private var prefMinAge: Int = 1
    @State private var prefMaxAge: Int = 5
    @State private var prefGender: String = "Все"
    
    // MARK: - Динамический выбор пород
    var currentPopularBreeds: [String] {
        switch selectedPetType {
        case "Кошка": return popularCatBreeds
        case "Собака": return popularDogBreeds
        default: return otherPetsBreeds
        }
    }
    
    var filteredBreeds: [String] {
        let allBreeds: [String]
        switch selectedPetType {
        case "Кошка": allBreeds = popularCatBreeds + otherCatBreeds
        case "Собака": allBreeds = popularDogBreeds + otherDogBreeds
        default: allBreeds = otherPetsBreeds
        }
        
        if breedQuery.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.localizedCaseInsensitiveContains(breedQuery) }
        }
    }
    
    var prefFilteredBreeds: [String] {
        let allBreeds: [String]
        switch prefPetType {
        case "Кошка": allBreeds = ["Любая"] + popularCatBreeds + otherCatBreeds
        case "Собака": allBreeds = ["Любая"] + popularDogBreeds + otherDogBreeds
        default: allBreeds = ["Любая"] + otherPetsBreeds
        }
        
        if prefBreedSearchQuery.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.localizedCaseInsensitiveContains(prefBreedSearchQuery) }
        }
    }
    
    // Валидация кнопки "Продолжить"
    var isNextButtonEnabled: Bool {
        switch currentStep {
        case 1: return true
        case 2: return !breedQuery.trimmingCharacters(in: .whitespaces).isEmpty
        case 3:
            let name = petName.trimmingCharacters(in: .whitespaces)
            return !name.isEmpty && name.count <= 15
        case 4: return mainPhoto != nil
        case 5: return true
        case 6: return !ageYears.isEmpty || !ageMonths.isEmpty
        case 7: return !heightCm.isEmpty && !weightKg.isEmpty
        case 8: return !selectedTraits.isEmpty && selectedTraits.count <= 5
        case 9: return !bioText.trimmingCharacters(in: .whitespaces).isEmpty && bioText.count <= 120
        case 10: return isVaccinated != nil
        case 11: return vaccineCertificatePhoto != nil
        default: return true
        }
    }
    
    var body: some View {
        ZStack {
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
                VStack(spacing: 20) {
                    Spacer(minLength: 20)
                    
                    VStack(spacing: 20) {
                        if !showPreferencesEdit {
                            headerView
                        }
                        
                        stepContent
                        
                        if !showPreferencesEdit && (currentStep < 10 || currentStep == 11) {
                            nextButton
                                .padding(.top, 10)
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(32)
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
            }
        }
        // Пикеры для фото питомца
        .confirmationDialog("Выберите источник", isPresented: $showSourceDialog, titleVisibility: .hidden) {
            Button("Сделать фото") { showCameraPicker = true }
            Button("Выбрать из медиатеки") { showImagePicker = true }
            Button("Отмена", role: .cancel) {}
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotosPickerItem, matching: .images)
        .onChange(of: selectedPhotosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run { savePhoto(uiImage, for: activePhotoIndex) }
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPickerView { capturedImage in savePhoto(capturedImage, for: activePhotoIndex) }
        }
        .confirmationDialog("Загрузка сертификата", isPresented: $showVaccineSourceDialog, titleVisibility: .hidden) {
            Button("Сделать фото") { showVaccineCameraPicker = true }
            Button("Выбрать из медиатеки") { showVaccineImagePicker = true }
            Button("Отмена", role: .cancel) {}
        }
        .photosPicker(isPresented: $showVaccineImagePicker, selection: $selectedVaccinePickerItem, matching: .images)
        .onChange(of: selectedVaccinePickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run { vaccineCertificatePhoto = uiImage }
                }
            }
        }
        .sheet(isPresented: $showVaccineCameraPicker) {
            CameraPickerView { capturedImage in vaccineCertificatePhoto = capturedImage }
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        if showPreferencesEdit {
            preferencesEditView
        } else {
            switch currentStep {
            case 1: step1PetTypeView
            case 2: step2BreedView
            case 3: step3PetNameView
            case 4: step4PhotosView
            case 5: step5GenderView
            case 6: step6AgeView
            case 7: step7HeightWeightView
            case 8: step8LikesTraitsView
            case 9: step9MoreAboutView
            case 10: step10VaccinationQuestionView
            case 11: step11VaccinationUploadView
            case 12: step12SuggestionView
            default: EmptyView()
            }
        }
    }
    
    private func savePhoto(_ image: UIImage, for index: Int) {
        if index == 0 { mainPhoto = image }
        else { additionalPhotos[index - 1] = image }
    }
    
    // MARK: - Header & Progress Bar
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if currentStep == 1 {
                        onBackToLogin()
                    } else if currentStep == 12 {
                        if isVaccinated == true { currentStep = 11 }
                        else { currentStep = 10 }
                    } else {
                        withAnimation { currentStep -= 1 }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                
                Spacer()
                
                Text(currentStep == 12 ? "Рекомендации PetsDate" : "Создание профиля")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .opacity(0)
            }
            
            if currentStep <= totalSteps {
                HStack(spacing: 4) {
                    ForEach(1...totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index <= min(currentStep, totalSteps) ? Color("AppAccent") : Color.gray.opacity(0.2))
                            .frame(height: 5)
                    }
                }
            }
        }
    }
    
    // MARK: - Шаги 1 - 9
    private var step1PetTypeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Кто ваш питомец?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            VStack(spacing: 14) {
                ForEach(petTypes, id: \.self) { type in
                    Button(action: {
                        selectedPetType = type
                        prefPetType = type
                        breedQuery = ""
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .stroke(selectedPetType == type ? Color("AppAccent") : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                if selectedPetType == type {
                                    Circle().fill(Color("AppAccent")).frame(width: 12, height: 12)
                                }
                            }
                            Text(type).font(.system(size: 16, weight: .medium)).foregroundColor(.black.opacity(0.8))
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    private var step2BreedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Какая у него порода?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Поиск породы", text: $breedQuery).font(.system(size: 16))
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredBreeds, id: \.self) { breed in
                        Button(action: { breedQuery = breed }) {
                            HStack {
                                Text(breed)
                                    .font(.system(size: 15, weight: currentPopularBreeds.contains(breed) ? .bold : .regular))
                                    .foregroundColor(.black.opacity(0.85))
                                Spacer()
                                if breedQuery == breed {
                                    Image(systemName: "checkmark").foregroundColor(Color("AppAccent"))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .frame(maxHeight: 220)
            .padding(12)
            .background(Color.gray.opacity(0.04))
            .cornerRadius(16)
        }
    }
    
    private var step3PetNameView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Как зовут питомца?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Введите кличку", text: $petName)
                    .font(.system(size: 16))
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(12)
                    .onChange(of: petName) { _, newValue in
                        if newValue.count > 15 { petName = String(newValue.prefix(15)) }
                    }
                
                HStack {
                    Text("Максимум 15 символов.").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("\(petName.count)/15").font(.caption).foregroundColor(petName.count == 15 ? .orange : .gray)
                }
            }
        }
    }
    
    private var step4PhotosView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Загрузите фото")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Максимум 5 ваших лучших фото.").font(.subheadline).foregroundColor(.gray)
            }
            
            Button(action: { activePhotoIndex = 0; showSourceDialog = true }) {
                ZStack {
                    if let image = mainPhoto {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(20)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .foregroundColor(Color.gray.opacity(0.4))
                            .frame(height: 220)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "photo").font(.system(size: 28)).foregroundColor(.black.opacity(0.7))
                            Text("Загрузить главное фото").font(.system(size: 15, weight: .bold)).foregroundColor(.black)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(1...4, id: \.self) { index in
                    let photo = additionalPhotos[index - 1]
                    ZStack {
                        if let image = photo {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(16)
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: { additionalPhotos[index - 1] = nil }) {
                                        Circle().fill(Color.black).frame(width: 24, height: 24)
                                            .overlay(Image(systemName: "xmark").foregroundColor(.white).font(.system(size: 10, weight: .bold)))
                                    }
                                    .padding(4)
                                }
                            }
                        } else {
                            Button(action: { activePhotoIndex = index; showSourceDialog = true }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                        .foregroundColor(Color.gray.opacity(0.4))
                                        .frame(height: 100)
                                    Image(systemName: "photo").font(.system(size: 20)).foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var step5GenderView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Какого пола питомец?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            VStack(spacing: 14) {
                ForEach(genderOptions, id: \.self) { gender in
                    Button(action: { selectedGender = gender }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .stroke(selectedGender == gender ? Color("AppAccent") : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                if selectedGender == gender {
                                    Circle().fill(Color("AppAccent")).frame(width: 12, height: 12)
                                }
                            }
                            Text(gender).font(.system(size: 16, weight: .medium)).foregroundColor(.black.opacity(0.8))
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    private var step6AgeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Сколько ему лет?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            HStack(spacing: 16) {
                HStack {
                    TextField("1", text: $ageYears).keyboardType(.numberPad).font(.system(size: 18, weight: .bold))
                    Text("лет / года").foregroundColor(.gray)
                }
                .padding(.horizontal, 14).frame(height: 50).background(Color.gray.opacity(0.08)).cornerRadius(14)
                
                HStack {
                    TextField("0", text: $ageMonths).keyboardType(.numberPad).font(.system(size: 18, weight: .bold))
                    Text("мес").foregroundColor(.gray)
                }
                .padding(.horizontal, 14).frame(height: 50).background(Color.gray.opacity(0.08)).cornerRadius(14)
            }
        }
    }
    
    private var step7HeightWeightView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Укажите рост и вес")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.85))
            
            HStack(spacing: 16) {
                HStack {
                    TextField("41", text: $heightCm).keyboardType(.numberPad).font(.system(size: 18, weight: .bold))
                    Text("см").foregroundColor(.gray)
                }
                .padding(.horizontal, 14).frame(height: 50).background(Color.gray.opacity(0.08)).cornerRadius(14)
                
                HStack {
                    TextField("10", text: $weightKg).keyboardType(.numberPad).font(.system(size: 18, weight: .bold))
                    Text("кг").foregroundColor(.gray)
                }
                .padding(.horizontal, 14).frame(height: 50).background(Color.gray.opacity(0.08)).cornerRadius(14)
            }
        }
    }
    
    private var step8LikesTraitsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Какой у него характер?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Выберите до 5 качеств.").font(.subheadline).foregroundColor(.gray)
            }
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 10) {
                    ForEach(allTraits, id: \.self) { trait in
                        let isSelected = selectedTraits.contains(trait)
                        Button(action: {
                            if isSelected { selectedTraits.remove(trait) }
                            else if selectedTraits.count < 5 { selectedTraits.insert(trait) }
                        }) {
                            Text(trait)
                                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                                .foregroundColor(isSelected ? .white : .black.opacity(0.8))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .frame(maxHeight: 220)
        }
    }
    
    private var step9MoreAboutView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Расскажите о нем")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Короткое описание для профиля.").font(.subheadline).foregroundColor(.gray)
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                TextEditor(text: $bioText)
                    .font(.system(size: 15))
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(14)
                    .onChange(of: bioText) { _, newValue in
                        if newValue.count > 120 { bioText = String(newValue.prefix(120)) }
                    }
                
                Text("\(bioText.count)/120").font(.caption).foregroundColor(bioText.count == 120 ? .orange : .gray)
            }
        }
    }
    
    // MARK: - Шаг 10: Вопрос о вакцинации
    private var step10VaccinationQuestionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Есть ли прививки?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Вакцинация помогает защитить питомца от опасных инфекционных заболеваний.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    isVaccinated = true
                    withAnimation { currentStep = 11 }
                }) {
                    Text("Да, есть вакцинация")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.black)
                        .cornerRadius(26)
                }
                
                Button(action: {
                    isVaccinated = false
                    withAnimation { currentStep = 12 }
                }) {
                    Text("Нет, вакцинации нет")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                        )
                }
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Шаг 11: Загрузка сертификата вакцинации
    private var step11VaccinationUploadView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Инфо о вакцинации")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Загрузите сертификат или ветпаспорт с отметками.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button(action: { showVaccineSourceDialog = true }) {
                ZStack {
                    if let image = vaccineCertificatePhoto {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(16)
                            .overlay(
                                Button(action: { vaccineCertificatePhoto = nil }) {
                                    Circle().fill(Color.black).frame(width: 30, height: 30)
                                        .overlay(Image(systemName: "xmark").foregroundColor(.white).font(.system(size: 12, weight: .bold)))
                                }
                                .padding(8),
                                alignment: .bottomTrailing
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .foregroundColor(Color("AppAccent").opacity(0.6))
                            .frame(height: 160)
                            .background(Color("AppAccent").opacity(0.04).cornerRadius(16))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up.doc")
                                .font(.system(size: 26))
                                .foregroundColor(Color("AppAccent"))
                            Text("Загрузить сертификат")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("AppAccent"))
                                .underline()
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                Text("Дата вакцинации:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                
                DatePicker("", selection: $vaccineDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Шаг 12: Рекомендации PetsDate (Suggestions)
    private var step12SuggestionView: some View {
        VStack(spacing: 20) {
            Text("На основе вашего профиля мы подберем идеальных кандидатов для знакомств.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                preferenceRow(title: "Вид:", value: prefPetType)
                preferenceRow(title: "Порода:", value: prefSelectedBreeds.isEmpty ? "Любая" : prefSelectedBreeds.joined(separator: ", "))
                preferenceRow(title: "Пол:", value: prefGender)
                preferenceRow(title: "Вакцинация:", value: isVaccinated == true ? "Да" : "Не важно")
                preferenceRow(title: "Возраст:", value: "\(prefMinAge) - \(prefMaxAge) лет")
            }
            .padding(16)
            .background(Color.gray.opacity(0.06))
            .cornerRadius(20)
            
            Button(action: {
                withAnimation { showPreferencesEdit = true }
            }) {
                Text("Изменить предпочтения")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppAccent"))
                    .underline()
            }
            
            Button(action: { onFinish() }) {
                Text("Начать знакомства 🐾")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AppAccent"))
                    .cornerRadius(26)
                    .shadow(color: Color("AppAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Экран Редактирования Предпочтений (Preferences Edit Screen)
    private var preferencesEditView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: { withAnimation { showPreferencesEdit = false } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                Text("Предпочтения")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Вид")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                
                HStack(spacing: 16) {
                    ForEach(petTypes, id: \.self) { type in
                        Button(action: {
                            prefPetType = type
                            prefSelectedBreeds.removeAll()
                        }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(prefPetType == type ? Color("AppAccent") : Color.gray.opacity(0.3))
                                    .frame(width: 14, height: 14)
                                Text(type)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Порода")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Выберите породу", text: $prefBreedSearchQuery)
                        .font(.system(size: 15))
                }
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                
                if !prefSelectedBreeds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(prefSelectedBreeds), id: \.self) { breed in
                                HStack(spacing: 6) {
                                    Text(breed)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                    Button(action: { prefSelectedBreeds.remove(breed) }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(prefFilteredBreeds, id: \.self) { breed in
                            Button(action: {
                                if prefSelectedBreeds.contains(breed) {
                                    prefSelectedBreeds.remove(breed)
                                } else {
                                    prefSelectedBreeds.insert(breed)
                                }
                            }) {
                                HStack {
                                    Text(breed)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                    Spacer()
                                    if prefSelectedBreeds.contains(breed) {
                                        Image(systemName: "checkmark.square.fill")
                                            .foregroundColor(Color("AppAccent"))
                                    } else {
                                        Image(systemName: "square")
                                            .foregroundColor(.gray.opacity(0.4))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .frame(maxHeight: 140)
                .padding(10)
                .background(Color.gray.opacity(0.04))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Возраст (лет)")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                
                HStack(spacing: 12) {
                    HStack {
                        Text("От:").foregroundColor(.gray)
                        TextField("1", value: $prefMinAge, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12).frame(height: 44).background(Color.gray.opacity(0.08)).cornerRadius(12)
                    
                    HStack {
                        Text("До:").foregroundColor(.gray)
                        TextField("5", value: $prefMaxAge, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12).frame(height: 44).background(Color.gray.opacity(0.08)).cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Пол")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                
                HStack(spacing: 16) {
                    ForEach(["Мальчик", "Девочка", "Все"], id: \.self) { gender in
                        Button(action: { prefGender = gender }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(prefGender == gender ? Color("AppAccent") : Color.gray.opacity(0.3))
                                    .frame(width: 14, height: 14)
                                Text(gender)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
            
            Button(action: {
                withAnimation { showPreferencesEdit = false }
            }) {
                Text("Сохранить и начать 🐾")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AppAccent"))
                    .cornerRadius(26)
                    .shadow(color: Color("AppAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)
        }
    }
    
    private func preferenceRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(.bold).foregroundColor(.black.opacity(0.85))
        }
        .font(.system(size: 15))
    }
    
    // MARK: - Кнопка Далее
    private var nextButton: some View {
        Button(action: {
            if currentStep == 11 {
                withAnimation { currentStep = 12 }
            } else if currentStep < totalSteps && isNextButtonEnabled {
                withAnimation { currentStep += 1 }
            }
        }) {
            Text("Продолжить")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isNextButtonEnabled ? Color("AppAccent") : Color.gray.opacity(0.4))
                .cornerRadius(26)
                .shadow(color: isNextButtonEnabled ? Color("AppAccent").opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!isNextButtonEnabled)
    }
}

// MARK: - Вспомогательный класс для съёмки на камеру
struct CameraPickerView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    CreateProfileView()
}
