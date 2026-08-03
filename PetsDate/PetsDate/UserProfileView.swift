import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @StateObject private var profileVM = ProfileViewModel()
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            if profileVM.isLoading {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(appAccent)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Аватарка питомца
                        ZStack(alignment: .bottomTrailing) {
                            if let photo = profileVM.profile.mainPhoto {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(appAccent, lineWidth: 3))
                            } else {
                                Circle()
                                    .fill(appAccent.opacity(0.15))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(appAccent)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Имя и порода
                        VStack(spacing: 4) {
                            Text(profileVM.profile.petName.isEmpty ? "Ваш питомец" : profileVM.profile.petName)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(txtColor)
                            
                            Text(profileVM.profile.breed.isEmpty ? "Порода не указана" : profileVM.profile.breed)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        // Информационные карточки
                        VStack(spacing: 12) {
                            profileInfoRow(icon: "mappin.circle.fill", title: "Город", value: profileVM.profile.ownerCity)
                            profileInfoRow(icon: "person.fill", title: "Хозяин", value: profileVM.profile.ownerName)
                            profileInfoRow(icon: "phone.fill", title: "Телефон", value: profileVM.profile.ownerPhone)
                            profileInfoRow(icon: "envelope.fill", title: "Email", value: profileVM.profile.ownerEmail)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Кнопка Выхода с полным сбросом состояния
                        Button(action: {
                            profileVM.profile = PetProfile() // Очищаем кэш профиля
                            try? Auth.auth().signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Выйти из аккаунта")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(25)
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            profileVM.fetchCurrentUserProfile()
        }
    }
    
    private func profileInfoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(appAccent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.gray)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(txtColor)
        }
    }
}
