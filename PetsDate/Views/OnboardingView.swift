import SwiftUI

// MARK: - Onboarding Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isCompleted = false
    
    // Данные для 3 экранов онбординга
    let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "person.crop.circle.badge.plus",
            title: "Добавьте контакты",
            description: "Укажите информацию о себе, чтобы завершить регистрацию и легко связываться с владельцами других питомцев."
        ),
        OnboardingPage(
            iconName: "pawprint.circle.fill",
            title: "Создайте профиль питомца",
            description: "Загрузите фото хвостика, укажите порода, характер и интересные детали. Пусть ваш питомец очарует всех!"
        ),
        OnboardingPage(
            iconName: "sparkles.rectangle.stack.fill",
            title: "Начните свайпать",
            description: "Ищите идеальных компаньонов для игр, прогулок и общения поблизости всего в пару простых свайпов."
        )
    ]
    
    var body: some View {
        if isCompleted {
            // Переход к следующему экрану (например, авторизация или главный экран)
            Text("Экран авторизации / Регистрация")
                .font(.title)
                .bold()
        } else {
            ZStack {
                // 1. Единый фирменный градиентный фон PetsDate
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.45, blue: 0.35), // Теплый коралловый
                        Color(red: 0.95, green: 0.25, blue: 0.45)  // Насыщенный розовый
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Декоративные полупрозрачные фигуры на фоне
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 300, height: 300)
                        .offset(x: -80, y: -50)
                    
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 250, height: 250)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
                }
                
                // 2. Основной контент
                VStack(spacing: 24) {
                    // Кнопка "Пропустить" сверху справа
                    HStack {
                        Spacer()
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                withAnimation {
                                    isCompleted = true
                                }
                            }) {
                                Text("Пропустить")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.white.opacity(0.2)))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Свайпер карточек (TabView)
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingCardView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)
                    
                    // 3. Индикатор страниц (Dots)
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.35))
                                .frame(width: currentPage == index ? 28 : 9, height: 9)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // 4. Главная кнопка "Далее" / "Начать"
                    Button(action: {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                isCompleted = true
                            }
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Давайте начнем!" : "Далее")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.95, green: 0.25, blue: 0.45))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(28)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// MARK: - Onboarding Card View
struct OnboardingCardView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Иконка карточки с аккуратным свечением
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.45, blue: 0.35).opacity(0.15),
                                Color(red: 0.95, green: 0.25, blue: 0.45).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color(red: 0.95, green: 0.25, blue: 0.45))
            }
            .padding(.top, 20)
            
            // Текст карточки
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView()
}
