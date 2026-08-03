import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Логотип
                    VStack(spacing: 8) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 56))
                            .foregroundColor(appAccent)
                            .shadow(color: appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("PetsDate")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(txtColor)
                        
                        Text("Найди компанию своему питомцу 🐾")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Переключатель режим Вход / Регистрация
                    Picker("", selection: $viewModel.isSignUpMode) {
                        Text("Вход").tag(false)
                        Text("Регистрация").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    
                    // MARK: - Форма
                    VStack(spacing: 16) {
                        // Основные данные
                        customTextField(placeholder: "Email", text: $viewModel.emailText, icon: "envelope.fill")
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        customSecureField(placeholder: "Пароль", text: $viewModel.passwordText, icon: "lock.fill")
                        
                        // Дополнительные поля при регистрации
                        if viewModel.isSignUpMode {
                            VStack(spacing: 14) {
                                Divider().padding(.vertical, 4)
                                
                                Text("Данные питомца и хозяина")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(txtColor)
                                
                                customTextField(placeholder: "Кличка питомца*", text: $viewModel.petNameText, icon: "pawprint.fill")
                                customTextField(placeholder: "Порода", text: $viewModel.breedText, icon: "tag.fill")
                                customTextField(placeholder: "Возраст (лет)", text: $viewModel.ageYearsText, icon: "calendar")
                                    .keyboardType(.numberPad)
                                customTextField(placeholder: "Имя хозяина", text: $viewModel.ownerNameText, icon: "person.fill")
                                customTextField(placeholder: "Город (например, Минск)", text: $viewModel.ownerCityText, icon: "mappin.circle.fill")
                                
                                customTextField(placeholder: "О питомце (характер, привычки)", text: $viewModel.bioText, icon: "text.alignleft")
                                
                                Toggle(isOn: $viewModel.isVaccinated) {
                                    HStack {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                        Text("Есть прививки / ветпаспорт")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(txtColor)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Ошибка
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // MARK: - Кнопка действия
                    Button(action: {
                        if viewModel.isSignUpMode {
                            viewModel.register()
                        } else {
                            viewModel.login()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(viewModel.isSignUpMode ? "Создать профиль" : "Войти")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(appAccent)
                        .cornerRadius(27)
                        .shadow(color: appAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Кастомное текстовое поле
    private func customTextField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(appAccent)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(red: 0.97, green: 0.95, blue: 0.93))
        .cornerRadius(16)
    }
    
    private func customSecureField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(appAccent)
                .frame(width: 20)
            SecureField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(red: 0.97, green: 0.95, blue: 0.93))
        .cornerRadius(16)
    }
}
