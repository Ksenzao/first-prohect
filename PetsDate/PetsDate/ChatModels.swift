import Foundation
import UIKit
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

// Модель одиночного сообщения
struct ChatMessage: Identifiable, Codable {
    var id: String = UUID().uuidString
    let senderId: String
    let text: String
    let timestamp: Date
    
    var isFromCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
}

// Менеджер для работы с чатом
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessageText: String = ""
    
    let targetProfile: PetProfile
    private let db = Firestore.firestore()
    
    init(targetProfile: PetProfile) {
        self.targetProfile = targetProfile
        loadInitialMessages()
    }
    
    // Начальные тестовые сообщения для быстрого тестирования UI
    private func loadInitialMessages() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "me"
        
        self.messages = [
            ChatMessage(
                senderId: "other",
                text: "Привет! Ваш \(targetProfile.petName) просто прелесть 🐾",
                timestamp: Date().addingTimeInterval(-300)
            ),
            ChatMessage(
                senderId: currentUserId,
                text: "Привет! Спасибо большое! Давайте погуляем вместе?",
                timestamp: Date().addingTimeInterval(-120)
            )
        ]
    }
    
    // Отправка сообщения
    func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let currentUserId = Auth.auth().currentUser?.uid ?? "me"
        let msg = ChatMessage(senderId: currentUserId, text: trimmed, timestamp: Date())
        
        withAnimation {
            messages.append(msg)
        }
        
        newMessageText = ""
    }
}
