import SwiftUI

struct MainSwipeView: View {
    // Принимаем реальный профиль пользователя
    var userProfile: PetProfile
    var onLogout: () -> Void = {}
    
    @State private var showProfile = false
    
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
        }
    }
    
    private var mainSwipeContent: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
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
                
                // Карточка поиска
                VStack(spacing: 16) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("AppAccent").opacity(0.3))
                    
                    Text("Привет, \(userProfile.petName.isEmpty ? "друг" : userProfile.petName)! 🐾")
                        .font(.title2.weight(.bold))
                    
                    Text("Ищем идеальные мэтчи под твои параметры...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: 480)
                .background(Color.white)
                .cornerRadius(32)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Кнопки свайпов
                HStack(spacing: 32) {
                    Button(action: {}) {
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
                    
                    Button(action: {}) {
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

#Preview {
    MainSwipeView(userProfile: PetProfile(petName: "Арчи"))
}
