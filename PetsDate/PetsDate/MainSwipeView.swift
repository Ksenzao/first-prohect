import SwiftUI

struct MainSwipeView: View {
    @StateObject private var viewModel = SwipeViewModel()
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack(spacing: 0) {
                // Header с логотипом PetsDate 🐾
                headerView
                
                Spacer()
                
                // Карточки питомцев
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(Color(red: 0.9, green: 0.45, blue: 0.2))
                        Text("Ищем пушистых друзей... 🐾")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                } else if viewModel.candidateProfiles.isEmpty {
                    emptyStateView
                } else {
                    cardsStackView
                }
                
                Spacer()
                
                // Кнопки управления (Дизлайк / Лапка)
                if !viewModel.candidateProfiles.isEmpty {
                    bottomActionButtons
                }
            }
        }
        .onAppear {
            viewModel.fetchCandidates(currentPetType: "Собака")
        }
        .overlay(
            matchPopupOverlay
        )
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
                
                Text("PetsDate")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.5, blue: 0.2), Color(red: 0.85, green: 0.35, blue: 0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
                    .padding(10)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Стек карточек
    private var cardsStackView: some View {
        ZStack {
            ForEach(Array(viewModel.candidateProfiles.enumerated().reversed()), id: \.element.petName) { index, profile in
                if index == 0 {
                    petCard(for: profile)
                        .offset(x: offset.width, y: offset.height * 0.4)
                        .rotationEffect(.degrees(Double(offset.width / 15)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                }
                                .onEnded { gesture in
                                    if gesture.translation.width > 120 {
                                        withAnimation(.spring()) {
                                            offset = CGSize(width: 500, height: 0)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            viewModel.swipeRight(profile: profile)
                                            offset = .zero
                                        }
                                    } else if gesture.translation.width < -120 {
                                        withAnimation(.spring()) {
                                            offset = CGSize(width: -500, height: 0)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            viewModel.swipeLeft(profile: profile)
                                            offset = .zero
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                } else if index == 1 {
                    petCard(for: profile)
                        .scaleEffect(0.95)
                        .offset(y: 15)
                        .opacity(0.7)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Карточка питомца
    private func petCard(for profile: PetProfile) -> some View {
        ZStack(alignment: .bottom) {
            // Фотография
            Group {
                if let image = profile.mainPhoto {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color(red: 0.95, green: 0.92, blue: 0.88)
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.85, green: 0.78, blue: 0.7))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            // Градиент затемнения
            LinearGradient(
                colors: [.clear, .black.opacity(0.2), .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            // Текстовая информация
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(profile.petName)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(profile.ageYears) года")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    if profile.isVaccinated {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 12))
                            Text("Привит")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.8))
                        .clipShape(Capsule())
                    }
                }
                
                // Порода и Город через explicit HStack
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "dog.fill")
                        Text(profile.breed.isEmpty ? "Порода не указана" : profile.breed)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                        Text(profile.ownerCity)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.85))
                
                if !profile.bioText.isEmpty {
                    Text(profile.bioText)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }
            .padding(24)
        }
        .frame(height: 500)
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Нижняя панель с кнопками
    private var bottomActionButtons: some View {
        HStack(spacing: 36) {
            // Кнопка Дизлайк ❌
            Button(action: {
                if let top = viewModel.candidateProfiles.first {
                    withAnimation {
                        viewModel.swipeLeft(profile: top)
                    }
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.3))
                    .frame(width: 64, height: 64)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            }
            
            // Кнопка Лапка 🐾
            Button(action: {
                if let top = viewModel.candidateProfiles.first {
                    withAnimation {
                        viewModel.swipeRight(profile: top)
                    }
                }
            }) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 76, height: 76)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.55, blue: 0.25), Color(red: 0.9, green: 0.4, blue: 0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.95, green: 0.5, blue: 0.2).opacity(0.4), radius: 14, x: 0, y: 7)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Экран отсутствия анкет
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.6, blue: 0.35).opacity(0.12))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "dog.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.2))
            }
            
            Text("Пока это все анкеты!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            Text("Зайдите позже, чтобы увидеть новых хвостиков поблизости 🐾")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Поп-ап Совпадения 🐾
    @ViewBuilder
    private var matchPopupOverlay: some View {
        if viewModel.showMatchPopup, let match = viewModel.matchedProfile {
            ZStack {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Это Взаимная Лапка! 🐾")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                    
                    Text("Вы и \(match.petName) понравились друг другу!")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        viewModel.showMatchPopup = false
                    }) {
                        Text("Написать сообщение 💬")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.95, green: 0.5, blue: 0.2))
                            .cornerRadius(25)
                    }
                }
                .padding(28)
                .background(Color.white)
                .cornerRadius(32)
                .padding(.horizontal, 36)
                .shadow(radius: 20)
            }
        }
    }
}
