import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatDetailView: View {
    let targetProfile: PetProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [ChatMessage] = []
    @State private var messageText: String = ""
    @State private var listener: ListenerRegistration? = nil
    
    private let db = Firestore.firestore()
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? "guest_user"
    }
    
    var matchId: String {
        let partnerId = targetProfile.ownerUid.isEmpty ? targetProfile.id : targetProfile.ownerUid
        return currentUserId < partnerId ? "\(currentUserId)_\(partnerId)" : "\(partnerId)_\(currentUserId)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerView
            
            // MARK: - Message List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            messageBubble(for: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Spacer()
            
            // MARK: - Input Field
            inputBar
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.93).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            listenForMessages()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(appAccent)
                    .padding(8)
            }
            
            Circle()
                .fill(appAccent.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 20))
                        .foregroundColor(appAccent)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(targetProfile.petName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(txtColor)
                Text("\(targetProfile.breed.isEmpty ? "Питомец" : targetProfile.breed) • \(targetProfile.ownerCity)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Message Bubble
    private func messageBubble(for message: ChatMessage) -> some View {
        let isFromMe = message.senderId == currentUserId
        
        return HStack {
            if isFromMe { Spacer() }
            
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(isFromMe ? .white : txtColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isFromMe ? appAccent : Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
            }
            
            if !isFromMe { Spacer() }
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Написать сообщение...", text: $messageText)
                .font(.system(size: 15, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 46, height: 46)
                    .background(messageText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.4) : appAccent)
                    .clipShape(Circle())
            }
            .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.8))
    }
    
    // MARK: - Firestore Listen & Send Logic
    private func listenForMessages() {
        if targetProfile.id.hasPrefix("mock") {
            // Для мок-профилей показываем тестовое приветственное сообщение
            self.messages = [
                ChatMessage(senderId: targetProfile.id, text: "Привет! Давай погуляем вместе в парке! 🐾", timestamp: Date())
            ]
            return
        }
        
        listener?.remove()
        
        listener = db.collection("chats")
            .document(matchId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }
                
                var newMessages: [ChatMessage] = []
                for doc in docs {
                    let data = doc.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let stamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    let msg = ChatMessage(id: doc.documentID, senderId: senderId, text: text, timestamp: stamp)
                    newMessages.append(msg)
                }
                
                Task { @MainActor in
                    self.messages = newMessages
                }
            }
    }
    
    private func sendMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespaces)
        guard !textToSend.isEmpty else { return }
        
        messageText = ""
        
        if targetProfile.id.hasPrefix("mock") {
            let userMsg = ChatMessage(senderId: currentUserId, text: textToSend, timestamp: Date())
            messages.append(userMsg)
            return
        }
        
        let msgData: [String: Any] = [
            "senderId": currentUserId,
            "text": textToSend,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // 1. Сохраняем сообщение в подколлекции messages
        db.collection("chats").document(matchId).collection("messages").addDocument(data: msgData)
        
        // 2. Обновляем метаданные диалога (для списка чатов)
        let partnerId = targetProfile.ownerUid.isEmpty ? targetProfile.id : targetProfile.ownerUid
        db.collection("chats").document(matchId).setData([
            "lastMessage": textToSend,
            "participants": [currentUserId, partnerId],
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}
