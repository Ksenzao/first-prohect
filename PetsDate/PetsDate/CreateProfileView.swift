import SwiftUI
import PhotosUI

struct CreateProfileView: View {
    @State var profile: PetProfile
    var onFinish: (PetProfile) -> Void
    
    // Состояния UI
    @State private var currentStep = 1
    @State private var isSaving = false
    @State private var saveErrorMessage: String? = nil
    
    // Локальные буферы для ввода
    @State private var petName: String = ""
    @State private var breedQuery: String = ""
    @State private var bioText: String = ""
    @State private var ageYears: String = "1"
    @State private var ageMonths: String = "0"
    @State private var weightKg: String = ""
    
    // Фотографии
    @State private var mainPhoto: UIImage? = nil
    
    // Константы
    let totalSteps = 9
    let traitsList = ["Игривый", "Спокойный", "Активный", "Любит детей", "Умный", "Охотник", "Соня", "Дружелюбный"]
    let belarusCities = ["Минск", "Гомель", "Могилев", "Витебск", "Гродно", "Брест"]
    
    // Цветовая палитра
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let appBackground = Color(red: 1.0, green: 0.98, blue: 0.96)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    init(initialProfile: PetProfile, onFinish: @escaping (PetProfile) -> Void) {
        self._profile = State(initialValue: initialProfile)
        self.onFinish = onFinish
        
        self._petName = State(initialValue: initialProfile.petName)
        self._breedQuery = State(initialValue: initialProfile.breed)
        self._bioText = State(initialValue: initialProfile.bioText)
        self._ageYears = State(initialValue: initialProfile.ageYears)
        self._ageMonths = State(initialValue: initialProfile.ageMonths)
        self._weightKg = State(initialValue: initialProfile.weightKg)
        self._mainPhoto = State(initialValue: initialProfile.mainPhoto)
    }
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 20) {
                        currentStepContent
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                bottomActionButton
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            currentStep -= 1
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Назад")
                                .font(.system(size: 16, design: .rounded))
                        }
                        .foregroundColor(appAccent)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").opacity(0)
                        Text("Назад").opacity(0)
                    }
                }
                
                Spacer()
                
                Text("Создание профиля")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(txtColor)
                
                Spacer()
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 18))
                    .foregroundColor(appAccent.opacity(0.3))
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 4) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Capsule()
                        .frame(height: 6)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(step <= currentStep ? appAccent : Color.gray.opacity(0.2))
                        .animation(.spring(), value: currentStep)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.9))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 3)
    }
    
    // MARK: - Action Button
    private var bottomActionButton: some View {
        VStack {
            if currentStep < totalSteps {
                primaryButton(title: "Продолжить 🐾") {
                    withAnimation(.easeInOut) {
                        currentStep += 1
                    }
                }
                .disabled(!isCurrentStepValid)
                .opacity(isCurrentStepValid ? 1.0 : 0.6)
            } else {
                finalSaveButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 10)
        .background(Color.white.opacity(0.9))
    }
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 2: return !breedQuery.trimmingCharacters(in: .whitespaces).isEmpty
        case 4: return !petName.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
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
                    saveErrorMessage = "Пожалуйста, укажите кличку питомца на шаге 4!"
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
    
    // MARK: - Steps Router
    @ViewBuilder
    private var currentStepContent: some View {
        VStack(spacing: 25) {
            switch currentStep {
            case 1: stepPetType
            case 2: stepBreed
            case 3: stepGender
            case 4: stepNameAndPhoto
            case 5: stepAge
            case 6: stepPhysical
            case 7: stepTraits
            case 8: stepBio
            case 9: stepCity
            default: Text("Ошибка шага")
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Steps Views
    private var stepPetType: some View {
        VStack(spacing: 20) {
            stepTitle("Кто твой пушистый друг?")
            HStack(spacing: 20) {
                petTypeButton(title: "Собака", icon: "dog.fill")
                petTypeButton(title: "Кошка", icon: "cat.fill")
            }
        }
    }
    
    private var stepBreed: some View {
        VStack(spacing: 15) {
            stepTitle("Какой он породы?")
            HStack {
                Image(systemName: "pawprint.fill").foregroundColor(appAccent)
                TextField("Напр: Золотистый ретривер", text: $breedQuery)
                    .font(.system(size: 16, design: .rounded))
            }
            .padding().background(appBackground).cornerRadius(15)
        }
    }
    
    private var stepGender: some View {
        VStack(spacing: 20) {
            stepTitle("Пол питомца")
            HStack(spacing: 20) {
                genderButton(title: "Мальчик", icon: "m.circle.fill", color: .blue)
                genderButton(title: "Девочка", icon: "f.circle.fill", color: .red)
            }
        }
    }
    
    private var stepNameAndPhoto: some View {
        VStack(spacing: 20) {
            stepTitle("Как зовут питомца?")
            HStack {
                Image(systemName: "pencil").foregroundColor(appAccent)
                TextField("Кличка", text: $petName)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .autocapitalization(.words)
            }
            .padding().background(appBackground).cornerRadius(15)
            
            Divider().padding(.vertical, 10)
            
            stepTitle("Главное фото (опционально)")
            PhotoPickerView(selectedImage: $mainPhoto)
        }
    }
    
    private var stepAge: some View {
        VStack(spacing: 15) {
            stepTitle("Сколько ему лет?")
            HStack(spacing: 15) {
                agePicker(title: "Лет", value: $ageYears, range: 0...25)
                agePicker(title: "Месяцев", value: $ageMonths, range: 0...11)
            }
        }
    }
    
    private var stepPhysical: some View {
        VStack(spacing: 15) {
            stepTitle("Вес питомца (кг)")
            HStack {
                Image(systemName: "scalemass.fill").foregroundColor(appAccent)
                TextField("Напр: 12.5", text: $weightKg)
                    .font(.system(size: 16, design: .rounded))
                    .keyboardType(.decimalPad)
            }
            .padding().background(appBackground).cornerRadius(15)
        }
    }
    
    private var stepTraits: some View {
        VStack(spacing: 15) {
            stepTitle("Выберите 3 черты характера")
            
            TagsFlowLayout(spacing: 10) {
                ForEach(traitsList, id: \.self) { trait in
                    Button(action: {
                        if profile.traits.contains(trait) {
                            profile.traits.remove(trait)
                        } else if profile.traits.count < 3 {
                            profile.traits.insert(trait)
                        }
                    }) {
                        Text(trait)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(profile.traits.contains(trait) ? .white : txtColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(profile.traits.contains(trait) ? appAccent : appAccent.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private var stepBio: some View {
        VStack(spacing: 15) {
            stepTitle("Расскажите о нем ✍️")
            TextEditor(text: $bioText)
                .font(.system(size: 15, design: .rounded))
                .frame(height: 150)
                .padding(10)
                .background(appBackground)
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(appAccent.opacity(0.2), lineWidth: 1))
        }
    }
    
    private var stepCity: some View {
        VStack(spacing: 15) {
            stepTitle("Ваш город")
            Picker("Выберите город", selection: $profile.ownerCity) {
                ForEach(belarusCities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
    }
    
    // MARK: - UI Helpers
    private func stepTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(txtColor)
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)
    }
    
    private func petTypeButton(title: String, icon: String) -> some View {
        Button(action: { profile.petType = title }) {
            VStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 40))
                Text(title).font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(profile.petType == title ? .white : appAccent)
            .frame(maxWidth: .infinity).frame(height: 110)
            .background(profile.petType == title ? appAccent : appAccent.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    private func genderButton(title: String, icon: String, color: Color) -> some View {
        Button(action: { profile.gender = title }) {
            HStack {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(profile.gender == title ? .white : color)
            .frame(maxWidth: .infinity).frame(height: 55)
            .background(profile.gender == title ? color : color.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    private func agePicker(title: String, value: Binding<String>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 5) {
            Text(title).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(.gray)
            Picker(title, selection: value) {
                ForEach(range, id: \.self) { num in Text("\(num)").tag("\(num)") }
            }
            .pickerStyle(.wheel).frame(width: 80, height: 100).clipped()
        }
        .padding().background(appBackground).cornerRadius(15)
    }
    
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(LinearGradient(colors: [appAccent, appAccent.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                .cornerRadius(27)
        }
    }
}

// MARK: - PhotoPickerView (Импорт фото)
struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem? = nil
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    
    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(appAccent, lineWidth: 2))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled").font(.system(size: 30))
                    Text("Загрузить").font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(appAccent)
                .frame(width: 140, height: 140)
                .background(appAccent.opacity(0.1))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(appAccent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6])))
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { selectedImage = image }
                }
            }
        }
    }
}

// MARK: - TagsFlowLayout (Теги характера)
struct TagsFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}
