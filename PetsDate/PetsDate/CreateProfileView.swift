import SwiftUI
import FirebaseAuth
import PhotosUI

struct CreateProfileView: View {
    var onFinish: (PetProfile) -> Void
    
    @State private var currentStep: Int = 1
    @State private var profile = PetProfile()
    
    // Поля формы
    @State private var petName: String = ""
    @State private var breedQuery: String = ""
    @State private var ageYears: String = "1"
    @State private var ageMonths: String = "0"
    @State private var weightKg: String = ""
    @State private var bioText: String = ""
    @State private var isVaccinated: Bool = false
    @State private var selectedTraits: Set<String> = []
    
    // Фото
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var mainPhoto: UIImage? = nil
    
    @State private var isSaving: Bool = false
    @State private var saveErrorMessage: String? = nil
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    let availableTraits = ["Дружелюбный", "Игривый", "Спокойный", "Любит детей", "Обученный", "Энергичный"]
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack(spacing: 0) {
                // Хедер
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Прогресс-бар
                progressBar
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case 1: step1PetType
                        case 2: step2Gender
                        case 3: step3Breed
                        case 4: step4Details
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                Spacer()
                
                // Кнопки навигации
                navigationButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            if currentStep > 1 {
                Button(action: { currentStep -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(appAccent)
                        .padding(8)
                }
            }
            Spacer()
            Text("Создание анкеты")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            Spacer()
            if currentStep > 1 {
                Color.clear.frame(width: 34, height: 34)
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(1...4, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? appAccent : Color.gray.opacity(0.2))
                    .frame(height: 6)
            }
        }
    }
    
    // MARK: - Step 1: Pet Type
    private var step1PetType: some View {
        VStack(spacing: 20) {
            Text("Кто ваш любимец? 🐾")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            
            HStack(spacing: 16) {
                typeCard(title: "Собака", icon: "dog.fill", selected: profile.petType == "Собака") {
                    profile.petType = "Собака"
                }
                typeCard(title: "Кошка", icon: "cat.fill", selected: profile.petType == "Кошка") {
                    profile.petType = "Кошка"
                }
            }
        }
        .padding(.top, 20)
    }
    
    private func typeCard(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(selected ? appAccent : .gray)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(selected ? txtColor : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(selected ? appAccent.opacity(0.12) : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selected ? appAccent : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - Step 2: Gender
    private var step2Gender: some View {
        VStack(spacing: 20) {
            Text("Пол питомца ⚡️")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            
            HStack(spacing: 16) {
                typeCard(title: "Мальчик", icon: "sparkles", selected: profile.gender == "Мальчик") {
                    profile.gender = "Мальчик"
                }
                typeCard(title: "Девочка", icon: "heart.fill", selected: profile.gender == "Девочка") {
                    profile.gender = "Девочка"
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Step 3: Breed
    private var step3Breed: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Порода")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            
            TextField("Например: Лабрадор", text: $breedQuery)
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Step 4: Full Details, Photo & Vaccine
    private var step4Details: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Детали и фото 📸")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            
            // 📸 Выбор фотографии
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack {
                        if let photo = mainPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(appAccent, lineWidth: 3))
                        } else {
                            Circle()
                                .fill(appAccent.opacity(0.12))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(appAccent)
                                        Text("Добавить фото")
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(appAccent)
                                    }
                                )
                        }
                    }
                }
                // 💥 Исправленная совместимость с iOS 17+ (два параметра: oldValue, newValue)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                self.mainPhoto = image
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Кличка
            VStack(alignment: .leading, spacing: 6) {
                Text("Кличка *")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                TextField("Имя питомца", text: $petName)
                    .font(.system(size: 16, design: .rounded))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
            }
            
            // Возраст и Вес
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Возраст (лет)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    TextField("Лет", text: $ageYears)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, design: .rounded))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Вес (кг)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    TextField("кг", text: $weightKg)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16, design: .rounded))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
            }
            
            // 💉 Сертификат Вакцинации
            Toggle(isOn: $isVaccinated) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(isVaccinated ? .green : .gray)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Есть прививки / сертификат")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(txtColor)
                        Text("Отметка о наличии паспорта вакцинации")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            // О себе
            VStack(alignment: .leading, spacing: 6) {
                Text("О себе")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                TextEditor(text: $bioText)
                    .font(.system(size: 16, design: .rounded))
                    .frame(height: 80)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(16)
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Bottom Navigation
    private var navigationButtons: some View {
        VStack {
            if currentStep < 4 {
                Button(action: { currentStep += 1 }) {
                    Text("Далее")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(appAccent)
                        .cornerRadius(27)
                        .shadow(color: appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            } else {
                finalSaveButton
            }
        }
    }
    
    // MARK: - Final Save Button
    private var finalSaveButton: some View {
        VStack(spacing: 8) {
            if let errorMessage = saveErrorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                guard !petName.trimmingCharacters(in: .whitespaces).isEmpty else {
                    saveErrorMessage = "Пожалуйста, укажите кличку питомца!"
                    return
                }
                
                isSaving = true
                saveErrorMessage = nil
                
                var finalProfile = profile
                finalProfile.petName = petName
                finalProfile.breed = breedQuery
                finalProfile.mainPhoto = mainPhoto
                finalProfile.ageYears = ageYears
                finalProfile.ageMonths = ageMonths
                finalProfile.weightKg = weightKg
                finalProfile.bioText = bioText
                finalProfile.isVaccinated = isVaccinated
                finalProfile.traits = selectedTraits
                
                // Связываем с Firebase Auth
                if let currentUser = Auth.auth().currentUser {
                    finalProfile.ownerUid = currentUser.uid
                    finalProfile.ownerEmail = currentUser.email ?? ""
                    if finalProfile.ownerName.isEmpty {
                        finalProfile.ownerName = currentUser.displayName ?? "Хозяин"
                    }
                }
                
                FirestoreService.shared.savePetProfile(finalProfile) { result in
                    isSaving = false
                    switch result {
                    case .success:
                        onFinish(finalProfile)
                    case .failure(let error):
                        print("⚠️ Ошибка сохранения: \(error.localizedDescription)")
                        onFinish(finalProfile)
                    }
                }
            }) {
                ZStack {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Начать знакомства 🐾")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(colors: [appAccent, appAccent.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(27)
                .shadow(color: appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isSaving || petName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(petName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
        }
    }
}
