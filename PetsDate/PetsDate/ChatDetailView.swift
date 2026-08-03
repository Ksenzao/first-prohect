import SwiftUI
import Combine

struct ChatDetailView: View {
    @StateObject private var chatVM: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    init(targetProfile: PetProfile) {
        _chatVM = StateObject(wrappedValue: ChatViewModel(targetProfile: targetProfile))
    }
    
    var body: some View {
        ZStack {
            PetsBackground()
            
            VStack(spacing: 0) {
                // Хедер чата
                chatHeaderView
                
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatVM.messages) { message in
                                messageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .onChange(of: chatVM.messages.count) { oldValue, newValue in
                        if let lastId = chatVM.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Поле ввода сообщения
                inputBarView
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Хедер чата
    private var chatHeaderView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(appAccent)
                    .padding(8)
            }
            
            // Аватарка собеседника
            if let photo = chatVM.targetProfile.mainPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(appAccent.opacity(0.2))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(appAccent)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chatVM.targetProfile.petName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(txtColor)
                
                Text("Хозяин: \(chatVM.targetProfile.ownerName.isEmpty ? "Пользователь" : chatVM.targetProfile.ownerName)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.9))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 3)
    }
    
    // MARK: - Баббл сообщения
    private func messageBubble(message: ChatMessage) -> some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .font(.system(size: 15, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromCurrentUser ? appAccent : Color.white)
                .foregroundColor(message.isFromCurrentUser ? .white : txtColor)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
    
    // MARK: - Панель ввода
    private var inputBarView: some View {
        HStack(spacing: 12) {
            HStack {
                TextField("Напишите сообщение...", text: $chatVM.newMessageText)
                    .font(.system(size: 15, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Button(action: {
                chatVM.sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(appAccent)
                    .clipShape(Circle())
                    .shadow(color: appAccent.opacity(0.4), radius: 6, x: 0, y: 3)
            }
            .disabled(chatVM.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(chatVM.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.9))
    }
}
