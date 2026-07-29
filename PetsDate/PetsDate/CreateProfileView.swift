import SwiftUI

struct CreateProfileView: View {
    // MARK: - Переменные состояния
    @State private var currentStep: Int = 1
    
    // Шаг 1: Тип питомца
    @State private var selectedPetType: String = "Dog"
    let petTypes = ["Cat", "Dog", "Other"]
    
    // Шаг 2: Порода
    @State private var breedQuery: String = ""
    let popularBreeds = ["Mixed breed", "Golden retriever", "Labrador retriever", "French bulldog", "Beagle"]
    let otherBreeds = ["Bulldog", "Poodle", "Pug", "German Shepherd", "Yorkshire Terrier"]
    
    // Фильтрация пород
    var filteredBreeds: [String] {
        let allBreeds = popularBreeds + otherBreeds
        if breedQuery.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.localizedCaseInsensitiveContains(breedQuery) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Прогресс бар и заголовок
            headerView
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            // Контент текущего шага
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if currentStep == 1 {
                        step1PetTypeView
                    } else if currentStep == 2 {
                        step2BreedView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            
            Spacer()
            
            // Нижняя кнопка "Next"
            nextButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Header & Progress Bar
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("Create profile")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            // Прогресс бар из 7 сегментов
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Color("AppAccent") : Color.gray.opacity(0.2))
                        .frame(height: 4)
                }
            }
            
            // Кнопка Назад
            if currentStep > 1 {
                HStack {
                    Button(action: {
                        withAnimation { currentStep -= 1 }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Шаг 1: Who are you?
    private var step1PetTypeView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Who are you?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 16) {
                ForEach(petTypes, id: \.self) { type in
                    Button(action: {
                        selectedPetType = type
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(selectedPetType == type ? Color("AppAccent") : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                
                                if selectedPetType == type {
                                    Circle()
                                        .fill(Color("AppAccent"))
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                            Text(type)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    // MARK: - Шаг 2: What is your breed?
    private var step2BreedView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What is your breed?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            // Поле поиска
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search breed", text: $breedQuery)
                    .font(.system(size: 16))
            }
            .padding(.bottom, 8)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .bottom
            )
            
            // Список пород
            VStack(alignment: .leading, spacing: 14) {
                ForEach(filteredBreeds, id: \.self) { breed in
                    Button(action: {
                        breedQuery = breed
                    }) {
                        HStack {
                            Text(breed)
                                .font(.system(size: 16, weight: popularBreeds.contains(breed) ? .bold : .regular))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Кнопка Далее
    private var nextButton: some View {
        Button(action: {
            if currentStep < 7 {
                withAnimation { currentStep += 1 }
            }
        }) {
            Text("Next")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black) // На макете кнопка черная
                .cornerRadius(26)
        }
    }
}

#Preview {
    CreateProfileView()
}
