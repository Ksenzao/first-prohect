import SwiftUI

struct MainSwipeView: View {
    var userProfile: PetProfile
    var onLogout: () -> Void = {}
    
    @StateObject private var swipeVM = SwipeViewModel()
    @State private var showProfile = false
    
    // Жесты для верхней карточки
    @State private var cardOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            if showProfile {
                UserProfileView(
                    profile: userProfile,
                    onBack: {
                        withAnimation { showProfile = false }
                    },
                    onEditProfile: {},
                    onOpenPreferences: {},
                    onLogout: onLogout
                )
                .transition(.move(edge: .trailing))
            } else {
                mainSwipeContent
                    .transition(.move(edge: .leading))
            }
            
            // Всплывающее окно Мэтча (It's a Match!)
            if swipeVM.showMatchPopup, let match = swipeVM.matchedProfile {
                matchOverlayView(matchedPet: match)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            swipeVM.fetchCandidates(currentPetType: userProfile.petType)
        }
    }
    
    // MARK: - Главный контент свайпов
    private var mainSwipeContent: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Шапка
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("AppAccent"))
                        Text("PetsDate")
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color("AppAccent"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { showProfile = true }
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("AppAccent"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
                
                // Дек карточек
                ZStack {
                    if swipeVM.isLoading {
                        VStack(spacing: 12) {
                            ProgressView().tint(Color("AppAccent"))
                            Text("Ищем варианты...").font(.subheadline).foregroundColor(.gray)
                        }
                    } else if swipeVM.candidateProfiles.isEmpty {
                        emptyCardsView
                    } else {
                        // Показываем до 2 карточек (заднюю и переднюю)
                        ForEach(Array(swipeVM.candidateProfiles.prefix(2).enumerated().reversed()), id: \.offset) { index, candidate in
                            if index == 0 {
                                topCardView(candidate: candidate)
                            } else {
                                backgroundCardView(candidate: candidate)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 520)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Кнопки управления (Дизлайк / Лайк)
                if !swipeVM.candidateProfiles.isEmpty {
                    HStack(spacing: 40) {
                        Button(action: {
                            if let topCandidate = swipeVM.candidateProfiles.first {
                                withAnimation(.spring()) {
                                    swipeVM.swipeLeft(profile: topCandidate)
                                }
                            }
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.title.weight(.bold))
                                        .foregroundColor(.red)
                                )
                        }
                        
                        Button(action: {
                            if let topCandidate = swipeVM.candidateProfiles.first {
                                withAnimation(.spring()) {
                                    swipeVM.swipeRight(profile: topCandidate)
                                }
                            }
                        }) {
                            Circle()
                                .fill(Color("AppAccent"))
                                .frame(width: 72, height: 72)
                                .shadow(color: Color("AppAccent").opacity(0.3), radius: 10, x: 0, y: 5)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    // MARK: - Верхняя активная карточка
    private func topCardView(candidate: PetProfile) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let image = candidate.mainPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 520)
                    .clipped()
            } else {
                Rectangle()
                    .fill(LinearGradient(colors: [Color("AppBackground1"), Color("AppBackground2")], startPoint: .top, endPoint: .bottom))
                    .overlay(Image(systemName: "pawprint.fill").font(.system(size: 80)).foregroundColor(.white.opacity(0.3)))
            }
            
            // Градиентное затемнение снизу
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            // Информация о питомце
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(candidate.petName), \(candidate.ageYears)г")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    if candidate.isVaccinated {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.cyan)
                            .font(.title3)
                    }
                }
                
                Text("\(candidate.petType) • \(candidate.breed.isEmpty ? "Метис" : candidate.breed)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                if !candidate.bioText.isEmpty {
                    Text(candidate.bioText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }
            .padding(24)
        }
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
        .offset(x: cardOffset.width, y: cardOffset.height)
        .rotationEffect(.degrees(Double(cardOffset.width / 15)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    cardOffset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width > 120 {
                        swipeVM.swipeRight(profile: candidate)
                    } else if gesture.translation.width < -120 {
                        swipeVM.swipeLeft(profile: candidate)
                    }
                    cardOffset = .zero
                }
        )
    }
    
    // MARK: - Задняя карточка (превью следующего)
    private func backgroundCardView(candidate: PetProfile) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let image = candidate.mainPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 520)
                    .clipped()
            } else {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
        }
        .cornerRadius(32)
        .scaleEffect(0.95)
        .offset(y: 10)
    }
    
    // MARK: - Пустое состояние
    private var emptyCardsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(Color("AppAccent"))
            
            Text("Пока это все питомцы поблизости!")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: {
                swipeVM.fetchCandidates(currentPetType: userProfile.petType)
            }) {
                Text("Обновить список")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Color("AppAccent"))
            }
        }
        .padding(32)
    }
    
    // MARK: - Модалка Взаимного Мэтча
    private func matchOverlayView(matchedPet: PetProfile) -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("У вас Взаимный Мэтч! 🐾")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: -20) {
                    if let myPhoto = userProfile.mainPhoto {
                        Image(uiImage: myPhoto)
                            .resizable().scaledToFill().frame(width: 110, height: 110).clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    }
                    
                    if let matchPhoto = matchedPet.mainPhoto {
                        Image(uiImage: matchPhoto)
                            .resizable().scaledToFill().frame(width: 110, height: 110).clipShape(Circle())
                            .overlay(Circle().stroke(Color("AppAccent"), lineWidth: 3))
                    }
                }
                
                Text("\(userProfile.petName) и \(matchedPet.petName) понравились друг другу!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    withAnimation { swipeVM.showMatchPopup = false }
                }) {
                    Text("Написать сообщение")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color("AppAccent"))
                        .cornerRadius(26)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    withAnimation { swipeVM.showMatchPopup = false }
                }) {
                    Text("Продолжить свайпать")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

#Preview {
    MainSwipeView(userProfile: PetProfile(petName: "Арчи"))
}
