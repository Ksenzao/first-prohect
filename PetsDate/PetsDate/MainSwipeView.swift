import SwiftUI

struct MainSwipeView: View {
    @StateObject private var swipeVM = SwipeViewModel()
    
    // Состояния открытого чата
    @State private var activeChatProfile: PetProfile? = nil
    @State private var isChatPresented: Bool = false
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        GeometryReader { outerGeometry in
            ZStack {
                PetsBackground()
                
                VStack(spacing: 0) {
                    // Хедер
                    headerView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    Spacer(minLength: 10)
                    
                    // Контейнер карточек
                    if swipeVM.isLoading {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(appAccent)
                    } else if swipeVM.candidateProfiles.isEmpty {
                        emptyStateView
                    } else {
                        ZStack {
                            ForEach(swipeVM.candidateProfiles.reversed(), id: \.ownerEmail) { profile in
                                petCardView(profile: profile, maxHeight: outerGeometry.size.height * 0.62)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 10)
                    
                    // Кнопки действий (Лайк / Дизлайк)
                    if !swipeVM.candidateProfiles.isEmpty {
                        actionButtonsView
                            .padding(.bottom, 20)
                    }
                }
                
                // 💥 Поп-ап взаимности
                if swipeVM.showMatchPopup, let match = swipeVM.matchedProfile {
                    matchPopupOverlay(matchedPet: match)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(), value: swipeVM.showMatchPopup)
                }
            }
        }
        .onAppear {
            swipeVM.fetchCandidates()
        }
        // Безопасное открытие экрана чата
        .fullScreenCover(isPresented: $isChatPresented) {
            if let target = activeChatProfile {
                ChatDetailView(targetProfile: target)
            }
        }
    }
    
    // MARK: - Хедер
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundColor(appAccent)
                Text("PetsDate")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(txtColor)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(txtColor)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Карточка питомца
    private func petCardView(profile: PetProfile, maxHeight: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let image = profile.mainPhoto {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(appAccent.opacity(0.15))
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 80))
                                .foregroundColor(appAccent.opacity(0.4))
                        )
                }
                
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(profile.petName.isEmpty ? "Без имени" : profile.petName)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if let years = Int(profile.ageYears), years > 0 {
                            Text("\(years) \(formattedAgeString(years: years))")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(appAccent)
                        Text("\(profile.ownerCity.isEmpty ? "Минск" : profile.ownerCity) • \(profile.breed.isEmpty ? "Порода не указана" : profile.breed)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(20)
            }
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
        }
        .frame(height: maxHeight)
    }
    
    private func formattedAgeString(years: Int) -> String {
        let rem10 = years % 10
        let rem100 = years % 100
        
        if rem100 >= 11 && rem100 <= 14 { return "лет" }
        switch rem10 {
        case 1: return "год"
        case 2, 3, 4: return "года"
        default: return "лет"
        }
    }
    
    // MARK: - Кнопки Лайк/Дизлайк
    private var actionButtonsView: some View {
        HStack(spacing: 30) {
            Button(action: {
                if let topProfile = swipeVM.candidateProfiles.first {
                    swipeVM.swipeLeft(profile: topProfile)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            
            Button(action: {
                if let topProfile = swipeVM.candidateProfiles.first {
                    swipeVM.swipeRight(profile: topProfile)
                }
            }) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(appAccent)
                    .clipShape(Circle())
                    .shadow(color: appAccent.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    // MARK: - Пустое состояние
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(appAccent.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "dog.fill")
                    .font(.system(size: 44))
                    .foregroundColor(appAccent)
            }
            
            Text("Пока это все анкеты!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            
            Text("Зайдите позже, чтобы увидеть новых\nхвостиков поблизости 🐾")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Pop-up Match Overlay
    private func matchPopupOverlay(matchedPet: PetProfile) -> some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Это взаимность! 🐾")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Вы и \(matchedPet.petName) понравились друг другу")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                if let photo = matchedPet.mainPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(appAccent, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    Circle()
                        .fill(appAccent.opacity(0.2))
                        .frame(width: 130, height: 130)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 50))
                                .foregroundColor(appAccent)
                        )
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        let currentMatch = matchedPet
                        swipeVM.showMatchPopup = false
                        swipeVM.removeTopCard()
                        activeChatProfile = currentMatch
                        isChatPresented = true
                    }) {
                        Text("Написать хозяину 💬")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(appAccent)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        swipeVM.showMatchPopup = false
                        swipeVM.removeTopCard()
                    }) {
                        Text("Продолжить поиск")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            .padding(25)
            .background(Color(red: 0.18, green: 0.14, blue: 0.14))
            .cornerRadius(30)
            .padding(.horizontal, 30)
        }
    }
}
