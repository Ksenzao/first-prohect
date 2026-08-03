import SwiftUI

struct MainSwipeView: View {
    @StateObject private var viewModel = SwipeViewModel()
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack(spacing: 0) {
                // Хедер
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                Spacer()
                
                // Стек карточек
                ZStack {
                    if viewModel.isLoading {
                        ProgressView().tint(appAccent)
                    } else if viewModel.candidateProfiles.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(viewModel.candidateProfiles.reversed()) { profile in
                            cardView(for: profile)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Кнопки действия (подняты над таб-баром)
                if !viewModel.candidateProfiles.isEmpty {
                    actionButtons
                        .padding(.bottom, 90)
                }
            }
        }
        .onAppear {
            viewModel.fetchCandidates()
        }
        .fullScreenCover(isPresented: $viewModel.showMatchPopup) {
            if let matched = viewModel.matchedProfile {
                MatchOverlayView(matchedProfile: matched) {
                    viewModel.showMatchPopup = false
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(appAccent)
                    .font(.system(size: 24))
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
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Card View
    private func cardView(for profile: PetProfile) -> some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.95, green: 0.85, blue: 0.75))
                
                VStack {
                    Spacer()
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 90))
                        .foregroundColor(appAccent.opacity(0.3))
                    Spacer()
                }
                
                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
                    .cornerRadius(28)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("\(profile.petName), \(profile.ageYears) \(ageTitle(years: profile.ageYears))")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if profile.isVaccinated {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(appAccent)
                        Text("\(profile.ownerCity) • \(profile.breed.isEmpty ? "Без породы" : profile.breed)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if !profile.bioText.isEmpty {
                        Text(profile.bioText)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                .padding(20)
            }
        }
        .frame(maxHeight: 480)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    private func ageTitle(years: String) -> String {
        guard let num = Int(years) else { return "лет" }
        if num == 1 { return "год" }
        if num >= 2 && num <= 4 { return "года" }
        return "лет"
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 40) {
            Button(action: {
                if let top = viewModel.candidateProfiles.first {
                    viewModel.swipeLeft(profile: top)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: 64, height: 64)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            
            Button(action: {
                if let top = viewModel.candidateProfiles.first {
                    viewModel.swipeRight(profile: top)
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(appAccent)
                    .clipShape(Circle())
                    .shadow(color: appAccent.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(appAccent)
            Text("Все анкеты просмотрены!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
            Text("Зайдите позже, чтобы найти новых друзей для прогулок.")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }
}

// MARK: - Modern Match Overlay View
struct MatchOverlayView: View {
    let matchedProfile: PetProfile
    var onClose: () -> Void
    
    @State private var showChatView: Bool = false
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("It's a Match! 🎉")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Вы и питомец \(matchedProfile.petName) понравились друг другу! Теперь можно договориться о прогулке.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Аватарка питомца
                Circle()
                    .fill(appAccent.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 60))
                            .foregroundColor(appAccent)
                    )
                    .overlay(Circle().stroke(appAccent, lineWidth: 3))
                
                Spacer()
                
                // Кнопка перехода в чат
                Button(action: {
                    showChatView = true
                }) {
                    Text("Написать сообщение 💬")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(appAccent)
                        .cornerRadius(27)
                }
                .padding(.horizontal, 30)
                
                // Кнопка продолжить поиск
                Button(action: onClose) {
                    Text("Продолжить поиск")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showChatView) {
            ChatDetailView(targetProfile: matchedProfile)
        }
    }
}
