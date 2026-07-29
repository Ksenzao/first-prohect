import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isCompleted = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "person.crop.circle.badge.plus",
            title: "Добавьте контакты",
            description: "Укажите информацию о себе, чтобы завершить регистрацию и легко связываться с владельцами других питомцев."
        ),
        OnboardingPage(
            iconName: "pawprint.fill",
            title: "Создайте профиль питомца",
            description: "Загрузите фото, укажите повод для знакомства и характеристики вашего хвостика, чтобы очаровать всех вокруг!"
        ),
        OnboardingPage(
            iconName: "heart.circle.fill",
            title: "Начинайте свайпать",
            description: "Листайте анкеты пушистых симпатяг поблизости и находите лучших друзей или пару за пару свайпов."
        )
    ]
    
    var body: some View {
        if isCompleted {
            Text("Главный экран свайпов")
                .font(.title)
        } else {
            ZStack {
                // Новый теплый естественный градиент
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color("AppBackground1"), location: 0.1),
                        Gradient.Stop(color: Color("AppBackground2"), location: 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Кнопка "Пропустить"
                    HStack {
                        Spacer()
                        Button("Пропустить") {
                            withAnimation { isCompleted = true }
                        }
                        .foregroundColor(Color("AppAccent"))
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                    
                    // Карусель карточек
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            let page = pages[index]
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(Color("AppBackground1").opacity(0.5))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: page.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                        .foregroundColor(Color("AppAccent"))
                                }
                                .padding(.top, 20)
                                
                                Text(page.title)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                
                                Text(page.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 16)
                                
                                Spacer()
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(32)
                            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
                            .padding(.horizontal, 24)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 460)
                    
                    // Точки-индикаторы
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring()) {
                                    currentPage = index
                                }
                            }) {
                                Capsule()
                                    .fill(currentPage == index ? Color("AppAccent") : Color("AppAccent").opacity(0.3))
                                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Главная кнопка
                    Button(action: {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                isCompleted = true
                            }
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Погнали!" : "Далее")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AppAccent"))
                            .cornerRadius(28)
                            .shadow(color: Color("AppAccent").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
