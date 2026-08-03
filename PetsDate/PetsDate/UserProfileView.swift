import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct UserProfileView: View {
    var onLogout: () -> Void
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditing: Bool = false
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                PetsBackground()
                
                if viewModel.isLoading {
                    ProgressView().tint(appAccent)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Хедер профиля
                            headerView
                            
                            // Главная карточка питомца
                            petCardView
                            
                            // Информация о хозяине и контакты
                            ownerDetailsSection
                            
                            // Кнопка Редактировать
                            Button(action: { isEditing = true }) {
                                HStack {
                                    Image(systemName: "pencil.line")
                                    Text("Редактировать анкету")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(appAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(appAccent.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // Кнопка Выхода
                            Button(action: onLogout) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Выйти из аккаунта")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(25)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 90)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchCurrentUserProfile()
            }
            .sheet(isPresented: $isEditing) {
                EditProfileSheetView(profile: viewModel.profile) { updatedProfile in
                    viewModel.profile = updatedProfile
                    viewModel.fetchCurrentUserProfile()
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Мой профиль 🐾")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(txtColor)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Pet Card View
    private var petCardView: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(appAccent.opacity(0.15))
                    .frame(width: 130, height: 130)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 60))
                            .foregroundColor(appAccent)
                    )
                    .overlay(Circle().stroke(appAccent, lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 10)
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(viewModel.profile.petName.isEmpty ? "Ваш питомец" : viewModel.profile.petName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(txtColor)
                    
                    if viewModel.profile.isVaccinated {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 18))
                    }
                }
                
                Text("\(viewModel.profile.breed.isEmpty ? "Порода не указана" : viewModel.profile.breed) • \(viewModel.profile.ageYears) \(ageTitle(years: viewModel.profile.ageYears))")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            if !viewModel.profile.bioText.isEmpty {
                Text(viewModel.profile.bioText)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(txtColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    private func ageTitle(years: String) -> String {
        guard let num = Int(years) else { return "лет" }
        if num == 1 { return "год" }
        if num >= 2 && num <= 4 { return "года" }
        return "лет"
    }
    
    // MARK: - Owner Details
    private var ownerDetailsSection: some View {
        VStack(spacing: 14) {
            infoRow(icon: "mappin.circle.fill", title: "Город", value: viewModel.profile.ownerCity.isEmpty ? "Минск" : viewModel.profile.ownerCity)
            Divider()
            infoRow(icon: "person.fill", title: "Хозяин", value: viewModel.profile.ownerName.isEmpty ? "Не указано" : viewModel.profile.ownerName)
            Divider()
            infoRow(icon: "envelope.fill", title: "Email", value: viewModel.profile.ownerEmail.isEmpty ? (Auth.auth().currentUser?.email ?? "Не указан") : viewModel.profile.ownerEmail)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(appAccent)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(txtColor)
        }
    }
}

// MARK: - Modal Edit Profile Sheet View
struct EditProfileSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State var profile: PetProfile
    var onSave: (PetProfile) -> Void
    
    @State private var isSaving: Bool = false
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Данные питомца").font(.system(.subheadline, design: .rounded))) {
                    TextField("Кличка", text: $profile.petName)
                    TextField("Порода", text: $profile.breed)
                    TextField("Возраст (лет)", text: $profile.ageYears)
                        .keyboardType(.numberPad)
                    Toggle("Есть прививки / паспорт", isOn: $profile.isVaccinated)
                    
                    VStack(alignment: .leading) {
                        Text("О питомце")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextEditor(text: $profile.bioText)
                            .frame(height: 70)
                    }
                }
                
                Section(header: Text("Данные владельца").font(.system(.subheadline, design: .rounded))) {
                    TextField("Имя хозяина", text: $profile.ownerName)
                    TextField("Город", text: $profile.ownerCity)
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveChanges) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Сохранить").bold()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func saveChanges() {
        isSaving = true
        FirestoreService.shared.savePetProfile(profile) { result in
            Task { @MainActor in
                isSaving = false
                if case .success = result {
                    onSave(profile)
                    dismiss()
                }
            }
        }
    }
}
